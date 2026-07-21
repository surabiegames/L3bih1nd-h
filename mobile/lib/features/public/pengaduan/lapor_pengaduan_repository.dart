import 'dart:math';

import 'package:dio/dio.dart';

import '../../../core/models/complaint_ticket_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';

/// Sumber data layar Lapor Pengaduan & Lacak Tiket (publik).
abstract interface class LaporPengaduanRepository {
  factory LaporPengaduanRepository.create() => ApiConfig.isDemo
      ? DemoLaporPengaduanRepository()
      : ApiLaporPengaduanRepository(ApiClient.instance);

  /// Kirim pengaduan baru. Nomor langganan (bila diisi) TIDAK diverifikasi
  /// server — sengaja, agar endpoint ini tidak jadi alat cek nomor.
  /// KEBOCORAN wajib koordinat (server menolak 422 tanpa itu).
  ///
  /// `fotoPath`/`videoPath` opsional (path berkas lokal hasil kamera/galeri)
  /// — bila salah satu diisi, dikirim sebagai multipart (server menerima JSON
  /// ATAU multipart di endpoint yang sama); bila keduanya null, JSON biasa.
  /// Video dibatasi 60 detik di layar; server memvalidasi tipe & ukuran.
  Future<ComplaintReceipt> kirim(
    ComplaintDraft draft, {
    String? fotoPath,
    String? videoPath,
  });

  /// Lacak status tiket. Nomor tiket adalah kunci pembawa (6 karakter
  /// terakhirnya acak) — tanpa verifikasi identitas tambahan.
  Future<LacakTiketResult> lacak(String nomorTiket);

  /// Pelapor mengonfirmasi masalahnya beres + menilai penanganan.
  /// SELESAI -> DITUTUP. Hanya sah saat `LacakTiketResult.bisaDinilai`.
  Future<String> konfirmasi(
    String nomorTiket, {
    required int rating,
    String? komentar,
  });

  /// Pelapor menyatakan masalahnya BELUM beres. SELESAI -> DIBUKA_KEMBALI.
  /// Hanya sah saat `LacakTiketResult.bisaDibukaKembali`.
  Future<String> bukaKembali(String nomorTiket, {required String alasan});

  /// Kirim pesan CHAT ke petugas pada thread tiket. Hanya sah saat
  /// `LacakTiketResult.bisaChat` (tiket belum DITUTUP). Balasannya muncul
  /// sebagai entri riwayat aksi CHAT pada [lacak] berikutnya.
  Future<void> kirimChat(String nomorTiket, {required String pesan});
}

class ApiLaporPengaduanRepository implements LaporPengaduanRepository {
  ApiLaporPengaduanRepository(this._api);

  final ApiClient _api;

  @override
  Future<ComplaintReceipt> kirim(
    ComplaintDraft draft, {
    String? fotoPath,
    String? videoPath,
  }) async {
    if (fotoPath == null && videoPath == null) {
      return _api.post(
        '${ApiConfig.publicPath}/pengaduan',
        body: draft.toJson(),
        parse: (data) => ComplaintReceipt.fromJson(
          data as Map<String, dynamic>? ?? const {},
        ),
      );
    }

    final form = FormData.fromMap({
      ...draft.toMultipartMap(),
      if (fotoPath != null)
        'foto': await MultipartFile.fromFile(fotoPath, filename: 'bukti.jpg'),
      if (videoPath != null)
        'video': await MultipartFile.fromFile(videoPath, filename: 'bukti.mp4'),
    });
    return _api.postMultipart(
      '${ApiConfig.publicPath}/pengaduan',
      form: form,
      parse: (data) =>
          ComplaintReceipt.fromJson(data as Map<String, dynamic>? ?? const {}),
    );
  }

  @override
  Future<LacakTiketResult> lacak(String nomorTiket) {
    return _api.get(
      '${ApiConfig.publicPath}/pengaduan/${nomorTiket.trim().toUpperCase()}',
      parse: (data) =>
          LacakTiketResult.fromJson(data as Map<String, dynamic>? ?? const {}),
    );
  }

  @override
  Future<String> konfirmasi(
    String nomorTiket, {
    required int rating,
    String? komentar,
  }) {
    return _api.post(
      '${ApiConfig.publicPath}/pengaduan/${nomorTiket.trim().toUpperCase()}/konfirmasi',
      body: {
        'rating': rating,
        if (komentar != null && komentar.isNotEmpty) 'komentar': komentar,
      },
      parse: (data) =>
          (data as Map<String, dynamic>?)?['pesan'] as String? ??
          'Penilaian Anda tercatat dan tiket ditutup.',
    );
  }

  @override
  Future<String> bukaKembali(String nomorTiket, {required String alasan}) {
    return _api.post(
      '${ApiConfig.publicPath}/pengaduan/${nomorTiket.trim().toUpperCase()}/buka-kembali',
      body: {'alasan': alasan},
      parse: (data) =>
          (data as Map<String, dynamic>?)?['pesan'] as String? ??
          'Tiket Anda dibuka kembali.',
    );
  }

  @override
  Future<void> kirimChat(String nomorTiket, {required String pesan}) {
    return _api.post(
      '${ApiConfig.publicPath}/pengaduan/${nomorTiket.trim().toUpperCase()}/chat',
      body: {'pesan': pesan},
      parse: (_) {},
    );
  }
}

/// Mode demo. Status tiket disimpan di memori supaya aksi
/// konfirmasi/buka-kembali di layar Lacak Tiket punya sesuatu untuk diubah —
/// pada mode API, server-lah yang menyimpan status sesungguhnya.
class DemoLaporPengaduanRepository implements LaporPengaduanRepository {
  String _status = 'SELESAI';
  int? _ratingDemo;
  final List<TicketTimelineEntry> _chatDemo = [];

  @override
  Future<ComplaintReceipt> kirim(
    ComplaintDraft draft, {
    String? fotoPath,
    String? videoPath,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    // Meniru format nomor tiket server: TW-YYMM-XXXXXX (6 karakter acak).
    const abjad = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    final acak = Random();
    final akhiran = List.generate(
      6,
      (_) => abjad[acak.nextInt(abjad.length)],
    ).join();
    final sekarang = DateTime.now();
    final yymm =
        '${'${sekarang.year}'.substring(2)}'
        '${'${sekarang.month}'.padLeft(2, '0')}';
    return ComplaintReceipt(
      nomorTiket: 'TW-$yymm-$akhiran',
      targetSelesaiAt: sekarang.add(const Duration(days: 3)),
      pesan:
          'Pengaduan Anda diterima dan masuk antrean penanganan. '
          'Simpan nomor tiket untuk melacak status.',
    );
  }

  @override
  Future<LacakTiketResult> lacak(String nomorTiket) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final nomor = nomorTiket.trim().toUpperCase();
    if (!RegExp(r'^TW-\d{4}-[A-Z0-9]{6}$').hasMatch(nomor)) {
      throw const ApiException(
        404,
        'NOT_FOUND',
        'Tiket tidak ditemukan. Periksa kembali nomor tiket Anda '
            '(format TW-YYMM-XXXXXX).',
      );
    }
    final sekarang = DateTime.now();
    return LacakTiketResult(
      nomorTiket: nomor,
      jenis: 'KEBOCORAN',
      judul: 'Pipa bocor di depan rumah',
      status: _status,
      prioritas: 'TINGGI',
      createdAt: sekarang.subtract(const Duration(hours: 20)),
      catatanPenyelesaian: _status == 'SELESAI' || _status == 'DITUTUP'
          ? 'Pipa sudah disambung ulang dan area sekitar dirapikan.'
          : null,
      ditugaskanKe: 'Petugas Demo',
      sla: SlaInfo(
        targetSelesaiAt: sekarang.add(const Duration(hours: 28)),
        sisaMenit: 28 * 60,
      ),
      bisaDinilai: _status == 'SELESAI' && _ratingDemo == null,
      bisaDibukaKembali: _status == 'SELESAI',
      bisaChat: _status != 'DITUTUP',
      konfirmasiBatasAt: _status == 'SELESAI'
          ? sekarang.add(const Duration(hours: 71))
          : null,
      riwayat: [
        TicketTimelineEntry(
          aksi: 'DIBUAT',
          statusKe: 'BARU',
          catatan: 'Pengaduan diterima dan masuk antrean penanganan.',
          olehNama: 'Sistem',
          createdAt: sekarang.subtract(const Duration(hours: 20)),
        ),
        TicketTimelineEntry(
          aksi: 'DITUGASKAN',
          statusKe: 'DITUGASKAN',
          catatan: 'Tiket ditugaskan ke petugas lapangan.',
          olehNama: 'Koordinator Layanan',
          createdAt: sekarang.subtract(const Duration(hours: 16)),
        ),
        TicketTimelineEntry(
          aksi: 'DIPROSES',
          statusKe: 'DIPROSES',
          catatan: 'Petugas menuju lokasi dan mulai perbaikan.',
          olehNama: 'Petugas Demo',
          createdAt: sekarang.subtract(const Duration(hours: 3)),
        ),
        if (_status == 'SELESAI' || _status == 'DITUTUP')
          TicketTimelineEntry(
            aksi: 'STATUS_DIUBAH',
            statusKe: 'SELESAI',
            catatan: 'Perbaikan selesai, air kembali mengalir normal.',
            olehNama: 'Petugas Demo',
            createdAt: sekarang.subtract(const Duration(hours: 1)),
          ),
        if (_status == 'DITUTUP')
          TicketTimelineEntry(
            aksi: 'DIKONFIRMASI',
            statusKe: 'DITUTUP',
            catatan: 'Pelapor mengonfirmasi penanganan selesai. Tiket ditutup.',
            olehNama: 'Pelapor',
            createdAt: sekarang,
          ),
        if (_status == 'DIBUKA_KEMBALI')
          TicketTimelineEntry(
            aksi: 'DIBUKA_KEMBALI',
            statusKe: 'DIBUKA_KEMBALI',
            catatan: 'Pelapor menyatakan masalah belum selesai.',
            olehNama: 'Pelapor',
            createdAt: sekarang,
          ),
        // Chat demo di ekor — linimasa urut waktu, chat selalu terbaru.
        ..._chatDemo,
      ],
    );
  }

  @override
  Future<String> konfirmasi(
    String nomorTiket, {
    required int rating,
    String? komentar,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (_status != 'SELESAI') {
      throw const ApiException(
        400,
        'BAD_REQUEST',
        'Tiket ini belum dinyatakan selesai oleh petugas, jadi belum bisa '
            'dikonfirmasi.',
      );
    }
    _status = 'DITUTUP';
    _ratingDemo = rating;
    return 'Terima kasih. Penilaian Anda tercatat dan tiket ditutup.';
  }

  @override
  Future<String> bukaKembali(
    String nomorTiket, {
    required String alasan,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (_status != 'SELESAI') {
      throw const ApiException(
        400,
        'BAD_REQUEST',
        'Tiket ini masih dalam penanganan — belum ada yang perlu dibuka '
            'kembali.',
      );
    }
    _status = 'DIBUKA_KEMBALI';
    return 'Tiket Anda dibuka kembali dan akan ditinjau ulang petugas.';
  }

  @override
  Future<void> kirimChat(String nomorTiket, {required String pesan}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final sekarang = DateTime.now();
    _chatDemo
      ..add(
        TicketTimelineEntry(
          aksi: 'CHAT',
          catatan: pesan,
          olehNama: 'Pelapor',
          createdAt: sekarang,
        ),
      )
      ..add(
        TicketTimelineEntry(
          aksi: 'CHAT',
          catatan:
              'Baik, pesan Anda kami terima. Petugas akan menindaklanjuti.',
          olehNama: 'Petugas Demo',
          createdAt: sekarang.add(const Duration(seconds: 1)),
        ),
      );
  }
}
