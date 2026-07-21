import '../utils/formatters.dart';

/// Sumber sebuah bacaan meter di antrean petugas.
enum SumberBacaan {
  /// Laporan mandiri pelanggan (foto meter, `LaporanMandiri`).
  mandiri,

  /// Hasil catat petugas lapangan (`LaporanHarianPetugas`).
  harian,
}

/// Satu bacaan meter — menyatukan dua bentuk API:
///  - GET /api/v1/laporan-mandiri  → `standDilaporkan`, status MENUNGGU|
///    DIVERIFIKASI|DITOLAK|DIGUNAKAN, `fotoUrl`, periode integer thbl;
///  - GET /api/v1/laporan-harian   → `standAwal`/`standAkhir`, `pemakaian`,
///    `persentase` (deviasi % dari bulan lalu), `statusVerif`,
///    periode integer thbl.
///
/// Field relasi selalu nullable — data legacy punya baris orphan; tampilkan
/// snapshot `namaPelanggan`/`nomorLangganan` bila relasi null.
class MeterReadingModel {
  const MeterReadingModel({
    required this.id,
    required this.sumber,
    required this.nomorLangganan,
    required this.periode,
    required this.standAkhir,
    required this.status,
    this.namaPelanggan,
    this.alamatPelanggan,
    this.standAwal,
    this.pemakaian,
    this.persentase,
    this.kondisi,
    this.fotoUrl,
    this.namaPelapor,
    this.nomorPelapor,
    this.tanggalCatat,
  });

  final String id;
  final SumberBacaan sumber;
  final String nomorLangganan;

  /// Integer thbl (202607 = Juli 2026).
  final int periode;

  /// Angka meter yang dilaporkan/dicatat bulan ini.
  final int standAkhir;

  /// MENUNGGU | DIVERIFIKASI | DITOLAK | DIGUNAKAN.
  final String status;

  final String? namaPelanggan;
  final String? alamatPelanggan;
  final int? standAwal;
  final int? pemakaian;

  /// Deviasi % terhadap pemakaian bulan lalu — dihitung SERVER; nilai di luar
  /// ambang anomali harus ditandai merah di UI.
  final double? persentase;

  final String? kondisi;
  final String? fotoUrl;
  final String? namaPelapor;
  final String? nomorPelapor;
  final DateTime? tanggalCatat;

  int? get pemakaianTerhitung =>
      pemakaian ?? (standAwal == null ? null : standAkhir - standAwal!);

  /// Lonjakan/penurunan ekstrem menurut ambang server (default 50%).
  bool anomali(double ambang) =>
      persentase != null && persentase!.abs() > ambang;

  String get labelPeriodeBacaan => labelPeriode(periode);

  factory MeterReadingModel.fromLaporanMandiriJson(Map<String, dynamic> json) {
    final pelanggan = json['pelanggan'];
    return MeterReadingModel(
      id: json['id'] as String? ?? '',
      sumber: SumberBacaan.mandiri,
      nomorLangganan: json['nomorLangganan'] as String? ?? '',
      periode: _periodeThbl(json['periode']),
      standAkhir: _angka(json['standDilaporkan']),
      status: json['status'] as String? ?? 'MENUNGGU',
      namaPelanggan: pelanggan is Map ? pelanggan['nama'] as String? : null,
      alamatPelanggan: pelanggan is Map ? pelanggan['alamat'] as String? : null,
      standAwal: _angkaOpsional(json['standLalu']),
      persentase: _desimal(json['persentase']),
      fotoUrl: json['fotoUrl'] as String?,
      namaPelapor: json['namaPelapor'] as String?,
      nomorPelapor: json['nomorPelapor'] as String?,
      tanggalCatat: _tanggal(json['createdAt']),
    );
  }

  factory MeterReadingModel.fromLaporanHarianJson(Map<String, dynamic> json) {
    final pelanggan = json['pelanggan'];
    return MeterReadingModel(
      id: json['id'] as String? ?? '',
      sumber: SumberBacaan.harian,
      nomorLangganan: json['nomorLangganan'] as String? ?? '',
      periode: _periodeThbl(json['periode']),
      standAkhir: _angka(json['standAkhir']),
      status: json['statusVerif'] as String? ?? 'MENUNGGU',
      namaPelanggan:
          (pelanggan is Map ? pelanggan['nama'] as String? : null) ??
          json['namaPelanggan'] as String?,
      alamatPelanggan:
          (pelanggan is Map ? pelanggan['alamat'] as String? : null) ??
          json['alamatPelanggan'] as String?,
      standAwal: _angkaOpsional(json['standAwal']),
      pemakaian: _angkaOpsional(json['pemakaian']),
      persentase: _desimal(json['persentase']),
      kondisi: json['kondisi'] as String?,
      fotoUrl: json['fotoStandUrl'] as String?,
      tanggalCatat: _tanggal(json['tanggalCatat'] ?? json['createdAt']),
    );
  }

  MeterReadingModel copyWith({String? status}) => MeterReadingModel(
    id: id,
    sumber: sumber,
    nomorLangganan: nomorLangganan,
    periode: periode,
    standAkhir: standAkhir,
    status: status ?? this.status,
    namaPelanggan: namaPelanggan,
    alamatPelanggan: alamatPelanggan,
    standAwal: standAwal,
    pemakaian: pemakaian,
    persentase: persentase,
    kondisi: kondisi,
    fotoUrl: fotoUrl,
    namaPelapor: namaPelapor,
    nomorPelapor: nomorPelapor,
    tanggalCatat: tanggalCatat,
  );

  static int _periodeThbl(Object? raw) {
    if (raw is num) return raw.toInt();
    if (raw is String) return thblDariIso(raw);
    return 0;
  }

  static int _angka(Object? raw) => (raw as num?)?.toInt() ?? 0;

  static int? _angkaOpsional(Object? raw) => (raw as num?)?.toInt();

  static double? _desimal(Object? raw) => (raw as num?)?.toDouble();

  static DateTime? _tanggal(Object? raw) =>
      raw is String ? DateTime.tryParse(raw) : null;
}

/// Tanda terima POST /api/public/lapor-meter.
class LaporMeterReceipt {
  const LaporMeterReceipt({
    required this.periode,
    required this.standDilaporkan,
    required this.status,
    required this.pesan,
  });

  final int periode;
  final int standDilaporkan;
  final String status;
  final String pesan;

  factory LaporMeterReceipt.fromJson(
    Map<String, dynamic> json,
  ) => LaporMeterReceipt(
    periode: MeterReadingModel._periodeThbl(json['periode']),
    standDilaporkan: MeterReadingModel._angka(json['standDilaporkan']),
    status: json['status'] as String? ?? 'MENUNGGU',
    pesan:
        json['pesan'] as String? ??
        'Laporan meter Anda terkirim dan sedang menunggu verifikasi petugas.',
  );
}
