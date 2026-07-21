import 'json_utils.dart';

/// Baris dari `GET aurora_api/dev/download_wmsize.php` — ukuran water meter.
class ResponseWmsize {
  const ResponseWmsize({this.wmzId, this.wmzSize, this.wmzCode, this.biPemel});

  final String? wmzId;
  final String? wmzSize;
  final String? wmzCode;

  /// Biaya pemeliharaan meter untuk ukuran ini.
  final String? biPemel;

  factory ResponseWmsize.fromJson(Map<String, dynamic> json) => ResponseWmsize(
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
