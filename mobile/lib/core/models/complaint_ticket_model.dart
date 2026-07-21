/// Objek SLA — DIHITUNG SERVER, jangan dihitung ulang di Dart.
/// `sisaMenit` negatif = lewat tenggat; `terjeda` = jam SLA berhenti karena
/// menunggu pelapor.
class SlaInfo {
  const SlaInfo({
    this.targetResponsAt,
    this.targetSelesaiAt,
    this.sisaMenit,
    this.melanggar = false,
    this.responsTerlambat = false,
    this.terjeda = false,
  });

  final DateTime? targetResponsAt;
  final DateTime? targetSelesaiAt;
  final int? sisaMenit;
  final bool melanggar;
  final bool responsTerlambat;
  final bool terjeda;

  factory SlaInfo.fromJson(Map<String, dynamic> json) => SlaInfo(
    targetResponsAt: _tanggal(json['targetResponsAt']),
    targetSelesaiAt: _tanggal(json['targetSelesaiAt']),
    sisaMenit: (json['sisaMenit'] as num?)?.toInt(),
    melanggar: json['melanggar'] == true,
    responsTerlambat: json['responsTerlambat'] == true,
    terjeda: json['terjeda'] == true,
  );

  static DateTime? _tanggal(Object? raw) =>
      raw is String ? DateTime.tryParse(raw) : null;
}

/// Tiket pengaduan (model `Pengaduan` backend).
///
/// `nomorTiket` berformat TW-YYMM-XXXXXX dengan 6 karakter terakhir ACAK —
/// tampilkan apa adanya, jangan disusun sendiri.
///
/// `transisiTersedia` datang dari GET /pengaduan/:id — JANGAN menyalin
/// matriks transisi status ke Dart; server yang menegakkannya.
class ComplaintTicketModel {
  const ComplaintTicketModel({
    required this.id,
    required this.nomorTiket,
    required this.jenis,
    required this.judul,
    required this.deskripsi,
    required this.status,
    required this.prioritas,
    required this.pelapor,
    this.kontakPelapor,
    this.alamatKejadian,
    this.nomorLangganan,
    this.fotoUrl,
    this.createdAt,
    this.sla,
    this.transisiTersedia = const [],
    this.ditugaskanKe,
  });

  final String id;
  final String nomorTiket;

  /// KEBOCORAN | AIR_MATI | AIR_KERUH | METER_RUSAK | TAGIHAN_TIDAK_SESUAI |
  /// KUALITAS_LAYANAN | LAINNYA.
  final String jenis;
  final String judul;
  final String deskripsi;

  /// BARU | DITUGASKAN | DIPROSES | MENUNGGU_PELANGGAN | SELESAI | DITUTUP |
  /// DIBUKA_KEMBALI | DITOLAK.
  final String status;

  /// RENDAH | NORMAL | TINGGI | DARURAT.
  final String prioritas;

  final String pelapor;
  final String? kontakPelapor;
  final String? alamatKejadian;

  /// Teks bebas TIDAK terverifikasi (kebijakan anti-harvesting server).
  final String? nomorLangganan;

  final String? fotoUrl;
  final DateTime? createdAt;
  final SlaInfo? sla;
  final List<String> transisiTersedia;
  final String? ditugaskanKe;

  bool get lewatSla => sla?.melanggar ?? false;

  factory ComplaintTicketModel.fromJson(Map<String, dynamic> json) {
    final sla = json['sla'];
    final transisi = json['transisiTersedia'];
    final petugas = json['ditugaskanKe'];
    return ComplaintTicketModel(
      id: json['id'] as String? ?? '',
      nomorTiket: json['nomorTiket'] as String? ?? '',
      jenis: json['jenis'] as String? ?? 'LAINNYA',
      judul: json['judul'] as String? ?? '',
      deskripsi: json['deskripsi'] as String? ?? '',
      status: json['status'] as String? ?? 'BARU',
      prioritas: json['prioritas'] as String? ?? 'NORMAL',
      pelapor: json['pelapor'] as String? ?? '',
      kontakPelapor: json['kontakPelapor'] as String?,
      alamatKejadian: json['alamatKejadian'] as String?,
      nomorLangganan: json['nomorLangganan'] as String?,
      fotoUrl: json['fotoUrl'] as String?,
      createdAt: SlaInfo._tanggal(json['createdAt']),
      sla: sla is Map<String, dynamic> ? SlaInfo.fromJson(sla) : null,
      transisiTersedia: transisi is List
          ? transisi.whereType<String>().toList()
          : const [],
      ditugaskanKe: petugas is Map ? petugas['name'] as String? : null,
    );
  }

  ComplaintTicketModel copyWith({
    String? status,
    List<String>? transisiTersedia,
  }) => ComplaintTicketModel(
    id: id,
    nomorTiket: nomorTiket,
    jenis: jenis,
    judul: judul,
    deskripsi: deskripsi,
    status: status ?? this.status,
    prioritas: prioritas,
    pelapor: pelapor,
    kontakPelapor: kontakPelapor,
    alamatKejadian: alamatKejadian,
    nomorLangganan: nomorLangganan,
    fotoUrl: fotoUrl,
    createdAt: createdAt,
    sla: sla,
    transisiTersedia: transisiTersedia ?? this.transisiTersedia,
    ditugaskanKe: ditugaskanKe,
  );
}

/// Data isian form pengaduan publik (POST /api/public/pengaduan).
/// KEBOCORAN wajib menyertakan koordinat — server menolak 422 tanpa itu.
class ComplaintDraft {
  const ComplaintDraft({
    required this.jenis,
    required this.judul,
    required this.deskripsi,
    required this.pelapor,
    required this.kontakPelapor,
    this.alamatKejadian,
    this.nomorLangganan,
    this.lat,
    this.lng,
  });

  final String jenis;
  final String judul;
  final String deskripsi;
  final String pelapor;
  final String kontakPelapor;
  final String? alamatKejadian;
  final String? nomorLangganan;
  final double? lat;
  final double? lng;

  Map<String, Object?> toJson() => {
    'jenis': jenis,
    'judul': judul,
    'deskripsi': deskripsi,
    'pelapor': pelapor,
    'kontakPelapor': kontakPelapor,
    if (alamatKejadian != null && alamatKejadian!.isNotEmpty)
      'alamatKejadian': alamatKejadian,
    if (nomorLangganan != null && nomorLangganan!.isNotEmpty)
      'nomorLangganan': nomorLangganan,
    if (lat != null && lng != null) 'koordinat': {'lat': lat, 'lng': lng},
  };

  /// Bentuk multipart (dipakai saat foto dilampirkan): server membaca
  /// koordinat sebagai DUA field skalar `lat`/`lng` di form-data, bukan
  /// objek bersarang — lihat `bacaBodyPengaduan()` di publik.router.ts.
  Map<String, Object?> toMultipartMap() => {
    'jenis': jenis,
    'judul': judul,
    'deskripsi': deskripsi,
    'pelapor': pelapor,
    'kontakPelapor': kontakPelapor,
    if (alamatKejadian != null && alamatKejadian!.isNotEmpty)
      'alamatKejadian': alamatKejadian,
    if (nomorLangganan != null && nomorLangganan!.isNotEmpty)
      'nomorLangganan': nomorLangganan,
    if (lat != null) 'lat': '$lat',
    if (lng != null) 'lng': '$lng',
  };
}

/// Satu entri linimasa PUBLIK tiket (riwayat dengan isPublik=true saja —
/// catatan internal tidak pernah keluar dari server).
class TicketTimelineEntry {
  const TicketTimelineEntry({
    required this.aksi,
    this.statusKe,
    this.catatan,
    this.olehNama,
    this.fotoUrl,
    this.createdAt,
  });

  final String aksi;
  final String? statusKe;
  final String? catatan;
  final String? olehNama;
  final String? fotoUrl;
  final DateTime? createdAt;

  factory TicketTimelineEntry.fromJson(Map<String, dynamic> json) =>
      TicketTimelineEntry(
        aksi: json['aksi'] as String? ?? '',
        statusKe: json['statusKe'] as String?,
        catatan: json['catatan'] as String?,
        olehNama: json['olehNama'] as String?,
        fotoUrl: json['fotoUrl'] as String?,
        createdAt: SlaInfo._tanggal(json['createdAt']),
      );
}

/// Hasil GET /api/public/pengaduan/:nomorTiket — status + linimasa publik.
/// `bisaDinilai`/`bisaDibukaKembali` dihitung server; jangan menyalin
/// aturannya ke client.
class LacakTiketResult {
  const LacakTiketResult({
    required this.nomorTiket,
    required this.jenis,
    required this.judul,
    required this.status,
    required this.prioritas,
    this.createdAt,
    this.selesaiAt,
    this.catatanPenyelesaian,
    this.ditugaskanKe,
    this.riwayat = const [],
    this.sla,
    this.bisaDinilai = false,
    this.bisaDibukaKembali = false,
    this.bisaChat = false,
    this.konfirmasiBatasAt,
    this.fotoPenyelesaianUrl,
  });

  final String nomorTiket;
  final String jenis;
  final String judul;
  final String status;
  final String prioritas;
  final DateTime? createdAt;
  final DateTime? selesaiAt;
  final String? catatanPenyelesaian;
  final String? ditugaskanKe;
  final List<TicketTimelineEntry> riwayat;
  final SlaInfo? sla;
  final bool bisaDinilai;
  final bool bisaDibukaKembali;

  /// Percakapan masih dibuka (tiket belum DITUTUP) — dihitung server.
  final bool bisaChat;

  /// Batas pelapor mengonfirmasi tiket SELESAI; lewat ini tiket ditutup
  /// otomatis oleh sistem.
  final DateTime? konfirmasiBatasAt;

  /// Foto bukti hasil pekerjaan dari petugas.
  final String? fotoPenyelesaianUrl;

  factory LacakTiketResult.fromJson(Map<String, dynamic> json) {
    final petugas = json['ditugaskanKe'];
    final riwayat = json['riwayat'];
    final sla = json['sla'];
    return LacakTiketResult(
      nomorTiket: json['nomorTiket'] as String? ?? '',
      jenis: json['jenis'] as String? ?? 'LAINNYA',
      judul: json['judul'] as String? ?? '',
      status: json['status'] as String? ?? 'BARU',
      prioritas: json['prioritas'] as String? ?? 'NORMAL',
      createdAt: SlaInfo._tanggal(json['createdAt']),
      selesaiAt: SlaInfo._tanggal(json['selesaiAt']),
      catatanPenyelesaian: json['catatanPenyelesaian'] as String?,
      ditugaskanKe: petugas is Map ? petugas['name'] as String? : null,
      riwayat: riwayat is List
          ? riwayat
                .whereType<Map<String, dynamic>>()
                .map(TicketTimelineEntry.fromJson)
                .toList()
          : const [],
      sla: sla is Map<String, dynamic> ? SlaInfo.fromJson(sla) : null,
      bisaDinilai: json['bisaDinilai'] == true,
      bisaDibukaKembali: json['bisaDibukaKembali'] == true,
      bisaChat: json['bisaChat'] == true,
      konfirmasiBatasAt: SlaInfo._tanggal(json['konfirmasiBatasAt']),
      fotoPenyelesaianUrl: json['fotoPenyelesaianUrl'] as String?,
    );
  }
}

/// Balasan POST /api/public/pengaduan.
class ComplaintReceipt {
  const ComplaintReceipt({
    required this.nomorTiket,
    this.targetSelesaiAt,
    required this.pesan,
  });

  final String nomorTiket;
  final DateTime? targetSelesaiAt;
  final String pesan;

  factory ComplaintReceipt.fromJson(Map<String, dynamic> json) =>
      ComplaintReceipt(
        nomorTiket: json['nomorTiket'] as String? ?? '',
        targetSelesaiAt: SlaInfo._tanggal(json['targetSelesaiAt']),
        pesan:
            json['pesan'] as String? ??
            'Pengaduan Anda diterima dan masuk antrean penanganan.',
      );
}
