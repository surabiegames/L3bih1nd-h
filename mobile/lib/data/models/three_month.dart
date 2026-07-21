import 'json_utils.dart';

/// Riwayat 3 periode terakhir (stand, pemakaian, tagihan) — model lokal
/// untuk layar detail pelanggan; di API legacy data ini datang rata
/// (flat) di dalam `DataMeter` (period1..period3).
class ThreeMonth {
  const ThreeMonth({
    this.period1,
    this.period1Stand1,
    this.period1Stand2,
    this.period1Usage,
    this.period1Tagihan,
    this.period2,
    this.period2Stand1,
    this.period2Stand2,
    this.period2Usage,
    this.period2Tagihan,
    this.period3,
    this.period3Stand1,
    this.period3Stand2,
    this.period3Usage,
    this.period3Tagihan,
  });

  final String? period1;
  final String? period1Stand1;
  final String? period1Stand2;
  final String? period1Usage;
  final String? period1Tagihan;
  final String? period2;
  final String? period2Stand1;
  final String? period2Stand2;
  final String? period2Usage;
  final String? period2Tagihan;
  final String? period3;
  final String? period3Stand1;
  final String? period3Stand2;
  final String? period3Usage;
  final String? period3Tagihan;

  factory ThreeMonth.fromJson(Map<String, dynamic> json) => ThreeMonth(
    period1: asString(json['period1']),
    period1Stand1: asString(json['period1_stand1']),
    period1Stand2: asString(json['period1_stand2']),
    period1Usage: asString(json['period1_usage']),
    period1Tagihan: asString(json['period1_tagihan']),
    period2: asString(json['period2']),
    period2Stand1: asString(json['period2_stand1']),
    period2Stand2: asString(json['period2_stand2']),
    period2Usage: asString(json['period2_usage']),
    period2Tagihan: asString(json['period2_tagihan']),
    period3: asString(json['period3']),
    period3Stand1: asString(json['period3_stand1']),
    period3Stand2: asString(json['period3_stand2']),
    period3Usage: asString(json['period3_usage']),
    period3Tagihan: asString(json['period3_tagihan']),
  );

  Map<String, dynamic> toJson() => {
    'period1': period1,
    'period1_stand1': period1Stand1,
    'period1_stand2': period1Stand2,
    'period1_usage': period1Usage,
    'period1_tagihan': period1Tagihan,
    'period2': period2,
    'period2_stand1': period2Stand1,
    'period2_stand2': period2Stand2,
    'period2_usage': period2Usage,
    'period2_tagihan': period2Tagihan,
    'period3': period3,
    'period3_stand1': period3Stand1,
    'period3_stand2': period3Stand2,
    'period3_usage': period3Usage,
    'period3_tagihan': period3Tagihan,
  };
}
