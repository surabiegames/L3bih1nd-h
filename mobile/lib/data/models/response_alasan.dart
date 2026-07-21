import 'json_utils.dart';

/// Baris mentah dari `GET aurora_api/data_alasan.php`.
///
/// Endpoint legacy memakai kolom generik `param0..param4` + `var_id`;
/// pemetaan yang dipakai aplikasi lama (DownloadDataActivity):
/// `param1` → id alasan, `param2` → nama alasan, `var_id == "0"` penanda
/// baris header/khusus. Lihat [Alasan] untuk bentuk domain-nya.
class ResponseAlasan {
  const ResponseAlasan({
    this.varId,
    this.param0,
    this.param1,
    this.param2,
    this.param3,
    this.param4,
  });

  final String? varId;
  final String? param0;
  final String? param1;
  final String? param2;
  final String? param3;
  final String? param4;

  factory ResponseAlasan.fromJson(Map<String, dynamic> json) => ResponseAlasan(
    varId: asString(json['var_id']),
    param0: asString(json['param0']),
    param1: asString(json['param1']),
    param2: asString(json['param2']),
    param3: asString(json['param3']),
    param4: asString(json['param4']),
  );

  Map<String, dynamic> toJson() => {
    'var_id': varId,
    'param0': param0,
    'param1': param1,
    'param2': param2,
    'param3': param3,
    'param4': param4,
  };
}
