import 'json_utils.dart';
import 'response_wmsize.dart';

/// Ukuran water meter — bentuk domain dari [ResponseWmsize] (field sama;
/// di aplikasi lama ini entitas greenDAO lokal). Kunci JSON di bawah
/// mengikuti kontrak API supaya bisa langsung dipetakan bolak-balik.
class Wmsize {
  const Wmsize({this.wmzId, this.wmzSize, this.wmzCode, this.biPemel});

  final String? wmzId;
  final String? wmzSize;
  final String? wmzCode;
  final String? biPemel;

  factory Wmsize.fromResponse(ResponseWmsize r) => Wmsize(
    wmzId: r.wmzId,
    wmzSize: r.wmzSize,
    wmzCode: r.wmzCode,
    biPemel: r.biPemel,
  );

  factory Wmsize.fromJson(Map<String, dynamic> json) => Wmsize(
    wmzId: asString(json['wmz_id']),
    wmzSize: asString(json['wmz_size']),
    wmzCode: asString(json['wmz_code']),
    biPemel: asString(json['bi_pemel']),
  );

  Map<String, dynamic> toJson() => {
    'wmz_id': wmzId,
    'wmz_size': wmzSize,
    'wmz_code': wmzCode,
    'bi_pemel': biPemel,
  };
}
