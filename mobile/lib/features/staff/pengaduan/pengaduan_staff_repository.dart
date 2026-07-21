import 'package:dio/dio.dart';

import '../../../core/models/complaint_ticket_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';

/// Sumber data layar kelola pengaduan petugas (perlu login STAFF ke atas).
abstract interface class PengaduanStaffRepository {
  factory PengaduanStaffRepository.create() => ApiConfig.isDemo
      ? DemoPengaduanStaffRepository()
      : ApiPengaduanStaffRepository(ApiClient.instance);

  /// Tiket yang ditugaskan ke petugas ini (`milikSaya=true` — jangan
  /// menyalin id user sendiri ke filter `ditugaskanKeId`).
  Future<List<ComplaintTicketModel>> tiketSaya();

  /// Detail tiket — satu-satunya sumber `transisiTersedia`. Matriks transisi
  /// TIDAK boleh disalin ke Dart; server yang menegakkannya.
  Future<ComplaintTicketModel> detail(String id);

  /// Pindahkan status tiket. `DITUTUP`/`DIBUKA_KEMBALI` ditolak server —
  /// itu hak pelapor lewat jalur publik. `SELESAI` WAJIB menyertakan
  /// `catatanPenyelesaian` + `fotoPenyelesaianUrl` (unggah dulu lewat
  /// [unggahFotoBukti]) — server menolak tanpa keduanya.
  Future<void> ubahStatus(
    String id,
    String status, {
    String? catatan,
    String? catatanPenyelesaian,
    String? fotoPenyelesaianUrl,
  });

  /// Unggah foto bukti hasil pekerjaan (POST /pengaduan/foto, magic bytes
  /// divalidasi server) — kembalikan URL untuk dikirim di [ubahStatus].
  Future<String> unggahFotoBukti(String nomorTiket, String pathFoto);

  /// Catatan tindak lanjut tanpa mengubah status. `isPublik` default false —
  /// kirim true hanya bila catatan memang untuk dibaca warga.
  Future<void> tambahCatatan(String id, String catatan, {bool isPublik});

  /// Pesan CHAT ke pelapor (POST /pengaduan/:id/chat) — selalu publik,
  /// tampil sebagai percakapan di halaman pelacakan warga.
  Future<void> kirimChat(String id, String pesan);
}

class ApiPengaduanStaffRepository implements PengaduanStaffRepository {
  ApiPengaduanStaffRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<ComplaintTicketModel>> tiketSaya() async {
    final hasil = await _api.getList(
      '${ApiConfig.v1Path}/pengaduan',
      query: {'milikSaya': 'true', 'pageSize': 100},
      parseRow: ComplaintTicketModel.fromJson,
    );
    return hasil.rows;
  }

  @override
  Future<ComplaintTicketModel> detail(String id) {
    return _api.get(
      '${ApiConfig.v1Path}/pengaduan/$id',
      parse: (data) => ComplaintTicketModel.fromJson(
        data as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  @override
  Future<void> ubahStatus(
    String id,
    String status, {
    String? catatan,
    String? catatanPenyelesaian,
    String? fotoPenyelesaianUrl,
  }) {
    return _api.patch(
      '${ApiConfig.v1Path}/pengaduan/$id/status',
      body: {
        'status': status,
        if (catatan != null && catatan.isNotEmpty) 'catatan': catatan,
        if (catatanPenyelesaian != null && catatanPenyelesaian.isNotEmpty)
          'catatanPenyelesaian': catatanPenyelesaian,
        if (fotoPenyelesaianUrl != null && fotoPenyelesaianUrl.isNotEmpty)
          'fotoPenyelesaianUrl': fotoPenyelesaianUrl,
      },
      parse: (_) {},
    );
  }

  @override
  Future<String> unggahFotoBukti(String nomorTiket, String pathFoto) async {
    final form = FormData.fromMap({
      'nomorTiket': nomorTiket,
      'foto': await MultipartFile.fromFile(pathFoto),
    });
    return _api.postMultipart(
      '${ApiConfig.v1Path}/pengaduan/foto',
      form: form,
      parse: (data) => (data as Map<String, dynamic>?)?['url'] as String? ?? '',
    );
  }

  @override
  Future<void> tambahCatatan(
    String id,
    String catatan, {
    bool isPublik = false,
  }) {
    return _api.post(
      '${ApiConfig.v1Path}/pengaduan/$id/catatan',
      body: {'catatan': catatan, 'isPublik': isPublik},
      parse: (_) {},
    );
  }

  @override
  Future<void> kirimChat(String id, String pesan) {
    return _api.post(
      '${ApiConfig.v1Path}/pengaduan/$id/chat',
      body: {'pesan': pesan},
      parse: (_) {},
    );
  }
}

/// Mode demo. `transisiTersedia` di sini hanya PERKIRAAN untuk demo UI —
/// pada mode API nilai ini selalu datang dari server.
class DemoPengaduanStaffRepository implements PengaduanStaffRepository {
  static final List<ComplaintTicketModel> _tiket = _buatTiketAwal();

  static const Map<String, List<String>> _transisiDemo = {
    'DITUGASKAN': ['MENUJU_LOKASI', 'DIPROSES'],
    'MENUJU_LOKASI': ['DIPROSES', 'MENUNGGU_PELANGGAN'],
    'DIPROSES': ['SELESAI', 'MENUNGGU_PELANGGAN'],
    'MENUNGGU_PELANGGAN': ['DIPROSES'],
    'DIBUKA_KEMBALI': ['DIPROSES'],
  };

  static List<ComplaintTicketModel> _buatTiketAwal() {
    final sekarang = DateTime.now();
    ComplaintTicketModel tiket(
      String id,
      String nomor,
      String jenis,
      String judul,
      String status,
      String prioritas,
      int sisaMenit, {
      String? alamat,
      String? nomorLangganan,
    }) => ComplaintTicketModel(
      id: id,
      nomorTiket: nomor,
      jenis: jenis,
      judul: judul,
      deskripsi:
          'Deskripsi lengkap laporan warga untuk "$judul". '
          'Detail kronologi tersimpan di tiket.',
      status: status,
      prioritas: prioritas,
      pelapor: 'Warga Pelapor',
      kontakPelapor: '081234567890',
      alamatKejadian: alamat,
      nomorLangganan: nomorLangganan,
      createdAt: sekarang.subtract(Duration(hours: 6 + id.hashCode % 72)),
      sla: SlaInfo(
        targetSelesaiAt: sekarang.add(Duration(minutes: sisaMenit)),
        sisaMenit: sisaMenit,
        melanggar: sisaMenit < 0,
        terjeda: status == 'MENUNGGU_PELANGGAN',
      ),
      transisiTersedia: _transisiDemo[status] ?? const [],
      ditugaskanKe: 'Petugas Demo',
    );

    return [
      tiket(
        't-1',
        'TW-2607-K3W9QD',
        'KEBOCORAN',
        'Pipa bocor deras di Jl. Cihampelas',
        'DITUGASKAN',
        'DARURAT',
        -95,
        alamat: 'Jl. Cihampelas depan No. 112',
      ),
      tiket(
        't-2',
        'TW-2607-P7M2XA',
        'AIR_MATI',
        'Air mati total sejak subuh',
        'DIPROSES',
        'TINGGI',
        240,
        alamat: 'RW 05 Kel. Dago',
        nomorLangganan: '00000200509',
      ),
      tiket(
        't-3',
        'TW-2607-B4N8RC',
        'AIR_KERUH',
        'Air keruh kecoklatan dua hari',
        'DIPROSES',
        'NORMAL',
        1320,
        nomorLangganan: '00000301204',
      ),
      tiket(
        't-4',
        'TW-2606-J9T5VE',
        'METER_RUSAK',
        'Angka meter tidak berputar',
        'MENUNGGU_PELANGGAN',
        'NORMAL',
        2880,
        nomorLangganan: '00000400871',
      ),
      tiket(
        't-5',
        'TW-2606-Q2H6ZF',
        'TAGIHAN_TIDAK_SESUAI',
        'Tagihan melonjak 3x lipat',
        'DIBUKA_KEMBALI',
        'TINGGI',
        -30,
        nomorLangganan: '00000502316',
      ),
    ];
  }

  @override
  Future<List<ComplaintTicketModel>> tiketSaya() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return List.of(_tiket);
  }

  @override
  Future<ComplaintTicketModel> detail(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _tiket.firstWhere((t) => t.id == id);
  }

  @override
  Future<void> ubahStatus(
    String id,
    String status, {
    String? catatan,
    String? catatanPenyelesaian,
    String? fotoPenyelesaianUrl,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final i = _tiket.indexWhere((t) => t.id == id);
    if (i >= 0) {
      _tiket[i] = _tiket[i].copyWith(
        status: status,
        transisiTersedia: _transisiDemo[status] ?? const [],
      );
    }
  }

  @override
  Future<String> unggahFotoBukti(String nomorTiket, String pathFoto) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return 'https://demo.local/bukti/$nomorTiket.jpg';
  }

  @override
  Future<void> tambahCatatan(
    String id,
    String catatan, {
    bool isPublik = false,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> kirimChat(String id, String pesan) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
}
