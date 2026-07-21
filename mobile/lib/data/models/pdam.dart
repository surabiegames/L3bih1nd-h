import 'json_utils.dart';

/// Data tagihan PDAM dari gateway H2H (dibungkus [ResponsePdam]).
/// Kunci JSON legacy memakai HURUF BESAR — jangan diubah.
class Pdam {
  const Pdam({
    this.billerRef,
    this.sessionId,
    this.tanggal,
    this.noResi,
    this.namaPam,
    this.noPelanggan,
    this.standMeter,
    this.kodeTarif,
    this.jatuhTempo,
    this.nama,
    this.alamat,
    this.pemakaian,
    this.rincianTagihan,
    this.denda,
    this.admin,
    this.retribusi,
    this.totalTagihan,
    this.terbilang,
    this.status,
    this.keterangan,
    this.tanggalReprint,
    this.tanggalTrx,
  });

  final String? billerRef;
  final String? sessionId;
  final String? tanggal;
  final String? noResi;
  final String? namaPam;
  final String? noPelanggan;
  final String? standMeter;
  final String? kodeTarif;
  final String? jatuhTempo;
  final String? nama;
  final String? alamat;
  final String? pemakaian;
  final List<PdamRincian>? rincianTagihan;
  final int? denda;
  final int? admin;
  final int? retribusi;
  final int? totalTagihan;
  final String? terbilang;
  final String? status;
  final String? keterangan;
  final String? tanggalReprint;
  final String? tanggalTrx;

  factory Pdam.fromJson(Map<String, dynamic> json) => Pdam(
    billerRef: asString(json['BILLER_REF']),
    sessionId: asString(json['session_id']),
    tanggal: asString(json['TANGGAL']),
    noResi: asString(json['NO_RESI']),
    namaPam: asString(json['NAMA_PAM']),
    noPelanggan: asString(json['NO_PELANGGAN']),
    standMeter: asString(json['STAND_METER']),
    kodeTarif: asString(json['KODE_TARIF']),
    jatuhTempo: asString(json['JATUH_TEMPO']),
    nama: asString(json['NAMA']),
    alamat: asString(json['ALAMAT']),
    pemakaian: asString(json['PEMAKAIAN']),
    rincianTagihan: json['RINCIAN_TAGIHAN'] is List
        ? (json['RINCIAN_TAGIHAN'] as List)
              .whereType<Map<String, dynamic>>()
              .map(PdamRincian.fromJson)
              .toList()
        : null,
    denda: asInt(json['DENDA']),
    admin: asInt(json['ADMIN']),
    retribusi: asInt(json['RETRIBUSI']),
    totalTagihan: asInt(json['TOTAL_TAGIHAN']),
    terbilang: asString(json['TERBILANG']),
    status: asString(json['STATUS']),
    keterangan: asString(json['KETERANGAN']),
    tanggalReprint: asString(json['TANGGAL_REPRINT']),
    tanggalTrx: asString(json['TANGGAL_TRX']),
  );

  Map<String, dynamic> toJson() => {
    'BILLER_REF': billerRef,
    'session_id': sessionId,
    'TANGGAL': tanggal,
    'NO_RESI': noResi,
    'NAMA_PAM': namaPam,
    'NO_PELANGGAN': noPelanggan,
    'STAND_METER': standMeter,
    'KODE_TARIF': kodeTarif,
    'JATUH_TEMPO': jatuhTempo,
    'NAMA': nama,
    'ALAMAT': alamat,
    'PEMAKAIAN': pemakaian,
    'RINCIAN_TAGIHAN': rincianTagihan?.map((r) => r.toJson()).toList(),
    'DENDA': denda,
    'ADMIN': admin,
    'RETRIBUSI': retribusi,
    'TOTAL_TAGIHAN': totalTagihan,
    'TERBILANG': terbilang,
    'STATUS': status,
    'KETERANGAN': keterangan,
    'TANGGAL_REPRINT': tanggalReprint,
    'TANGGAL_TRX': tanggalTrx,
  };
}

/// Rincian tagihan per periode di dalam [Pdam].
class PdamRincian {
  const PdamRincian({this.periode, this.nominal, this.pinalti});

  final String? periode;
  final String? nominal;
  final String? pinalti;

  factory PdamRincian.fromJson(Map<String, dynamic> json) => PdamRincian(
    periode: asString(json['PERIODE']),
    nominal: asString(json['NOMINAL']),
    pinalti: asString(json['PINALTI']),
  );

  Map<String, dynamic> toJson() => {
    'PERIODE': periode,
    'NOMINAL': nominal,
    'PINALTI': pinalti,
  };
}
