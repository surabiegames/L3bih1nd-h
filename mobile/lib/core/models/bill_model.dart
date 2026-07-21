import '../utils/formatters.dart';

/// Satu baris tagihan air (model `Tagihan` backend).
///
/// Dipakai oleh dua sumber dengan bentuk sedikit berbeda:
///  - POST /api/public/cek-tagihan → `periode` sudah integer thbl,
///    tanpa `id`/`nominalTunggak` (sengaja tidak dibuka ke publik);
///  - GET /api/v1/tagihan → `periode` ISO DateTime, `nominalTunggak`
///    STRING berisi BigInt (bisa ratusan juta — jangan parse int).
class BillModel {
  const BillModel({
    this.id,
    required this.periode,
    required this.status,
    required this.totalTagihan,
    this.pemakaianM3,
    this.jmlHargaAir,
    this.beaBeban,
    this.beaAdmin,
    this.airKotor,
    this.lainLain,
    this.denda,
    this.tanggalJatuhTempo,
    this.tanggalBayar,
    this.standLalu,
    this.standAkhir,
    this.nominalTunggak,
  });

  final String? id;

  /// Selalu integer thbl di model (202605 = Mei 2026), apa pun bentuk
  /// aslinya di response.
  final int periode;

  /// BELUM_BAYAR | SUDAH_BAYAR | JATUH_TEMPO | DIHAPUSKAN.
  final String status;

  /// Uang dalam rupiah bulat (int biasa) — hanya `nominalTunggak` yang BigInt.
  final int totalTagihan;
  final int? pemakaianM3;
  final int? jmlHargaAir;
  final int? beaBeban;
  final int? beaAdmin;
  final int? airKotor;
  final int? lainLain;
  final int? denda;

  final DateTime? tanggalJatuhTempo;
  final DateTime? tanggalBayar;
  final int? standLalu;
  final int? standAkhir;
  final BigInt? nominalTunggak;

  bool get sudahLunas => status == 'SUDAH_BAYAR';
  bool get menunggak => status == 'BELUM_BAYAR' || status == 'JATUH_TEMPO';

  String get labelPeriodeTagihan => labelPeriode(periode);

  factory BillModel.fromJson(Map<String, dynamic> json) {
    final rawTunggak = json['nominalTunggak'];
    return BillModel(
      id: json['id'] as String?,
      periode: _parsePeriode(json['periode']),
      status: json['status'] as String? ?? 'BELUM_BAYAR',
      totalTagihan: _angka(json['totalTagihan']),
      pemakaianM3: _angkaOpsional(json['pemakaianM3']),
      jmlHargaAir: _angkaOpsional(json['jmlHargaAir']),
      beaBeban: _angkaOpsional(json['beaBeban']),
      beaAdmin: _angkaOpsional(json['beaAdmin']),
      airKotor: _angkaOpsional(json['airKotor']),
      lainLain: _angkaOpsional(json['lainLain']),
      denda: _angkaOpsional(json['denda']),
      tanggalJatuhTempo: _tanggal(json['tanggalJatuhTempo']),
      tanggalBayar: _tanggal(json['tanggalBayar']),
      standLalu: _angkaOpsional(json['standLalu']),
      standAkhir: _angkaOpsional(json['standAkhir']),
      nominalTunggak: rawTunggak is String ? BigInt.tryParse(rawTunggak) : null,
    );
  }

  static int _parsePeriode(Object? raw) {
    if (raw is num) return raw.toInt();
    if (raw is String) return thblDariIso(raw);
    return 0;
  }

  static int _angka(Object? raw) => (raw as num?)?.toInt() ?? 0;

  static int? _angkaOpsional(Object? raw) => (raw as num?)?.toInt();

  static DateTime? _tanggal(Object? raw) =>
      raw is String ? DateTime.tryParse(raw) : null;
}

/// Identitas pelanggan pada hasil cek tagihan publik. Alamat sudah
/// disamarkan server — tampilkan apa adanya.
class CustomerInfo {
  const CustomerInfo({
    required this.nomorLangganan,
    required this.nama,
    this.alamat,
    this.rt,
    this.rw,
    this.status,
    this.tarifGolongan,
  });

  final String nomorLangganan;
  final String nama;
  final String? alamat;
  final String? rt;
  final String? rw;
  final String? status;
  final String? tarifGolongan;

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    final tarif = json['tarifGolongan'];
    return CustomerInfo(
      nomorLangganan: json['nomorLangganan'] as String? ?? '',
      nama: json['nama'] as String? ?? '',
      alamat: json['alamat'] as String?,
      rt: json['rt']?.toString(),
      rw: json['rw']?.toString(),
      status: json['status'] as String?,
      tarifGolongan: tarif is Map
          ? (tarif['kodeAsli'] ?? tarif['kode'])?.toString()
          : tarif?.toString(),
    );
  }
}

/// Hasil lengkap POST /api/public/cek-tagihan.
class CekTagihanResult {
  const CekTagihanResult({
    required this.pelanggan,
    required this.tagihan,
    required this.totalTunggakan,
  });

  final CustomerInfo pelanggan;

  /// Maksimal 12 periode terakhir (kebijakan server).
  final List<BillModel> tagihan;
  final int totalTunggakan;

  factory CekTagihanResult.fromJson(Map<String, dynamic> json) {
    final rows = json['tagihan'];
    return CekTagihanResult(
      pelanggan: CustomerInfo.fromJson(
        json['pelanggan'] as Map<String, dynamic>? ?? const {},
      ),
      tagihan: rows is List
          ? rows
                .whereType<Map<String, dynamic>>()
                .map(BillModel.fromJson)
                .toList()
          : const [],
      totalTunggakan: BillModel._angka(json['totalTunggakan']),
    );
  }
}
