import 'json_utils.dart';

/// Tarif air progresif per blok pemakaian, dari
/// `GET aurora_api/dev/download_watertarif.php`. Empat blok
/// (bottom/top/cost 1–4) menentukan harga per m³ sesuai rentang pemakaian.
class WaterTarif {
  const WaterTarif({
    this.wtId,
    this.trfTypeId,
    this.wtBottom1,
    this.wtTop1,
    this.wtCost1,
    this.wtBottom2,
    this.wtTop2,
    this.wtCost2,
    this.wtBottom3,
    this.wtTop3,
    this.wtCost3,
    this.wtBottom4,
    this.wtTop4,
    this.wtCost4,
  });

  final String? wtId;
  final String? trfTypeId;
  final String? wtBottom1;
  final String? wtTop1;
  final String? wtCost1;
  final String? wtBottom2;
  final String? wtTop2;
  final String? wtCost2;
  final String? wtBottom3;
  final String? wtTop3;
  final String? wtCost3;
  final String? wtBottom4;
  final String? wtTop4;
  final String? wtCost4;

  factory WaterTarif.fromJson(Map<String, dynamic> json) => WaterTarif(
    wtId: asString(json['wt_id']),
    trfTypeId: asString(json['trfType_id']),
    wtBottom1: asString(json['wt_bottom1']),
    wtTop1: asString(json['wt_top1']),
    wtCost1: asString(json['wt_cost1']),
    wtBottom2: asString(json['wt_bottom2']),
    wtTop2: asString(json['wt_top2']),
    wtCost2: asString(json['wt_cost2']),
    wtBottom3: asString(json['wt_bottom3']),
    wtTop3: asString(json['wt_top3']),
    wtCost3: asString(json['wt_cost3']),
    wtBottom4: asString(json['wt_bottom4']),
    wtTop4: asString(json['wt_top4']),
    wtCost4: asString(json['wt_cost4']),
  );

  Map<String, dynamic> toJson() => {
    'wt_id': wtId,
    'trfType_id': trfTypeId,
    'wt_bottom1': wtBottom1,
    'wt_top1': wtTop1,
    'wt_cost1': wtCost1,
    'wt_bottom2': wtBottom2,
    'wt_top2': wtTop2,
    'wt_cost2': wtCost2,
    'wt_bottom3': wtBottom3,
    'wt_top3': wtTop3,
    'wt_cost3': wtCost3,
    'wt_bottom4': wtBottom4,
    'wt_top4': wtTop4,
    'wt_cost4': wtCost4,
  };
}
