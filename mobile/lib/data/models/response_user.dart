import 'json_utils.dart';

/// Baris mentah dari `GET aurora_api/data_user.php`.
///
/// Kolom generik `param0..param6` + `var_id`; pemetaan yang dipakai aplikasi
/// lama (DownloadPetugasActivity) untuk baris `var_id == "2"`:
/// `param1` → wrId, `param2` → wrUserName, `param3` → wrName,
/// `param4` → wrPass. Lihat [Petugas] untuk bentuk domain-nya.
class ResponseUser {
  const ResponseUser({
    this.varId,
    this.param0,
    this.param1,
    this.param2,
    this.param3,
    this.param4,
    this.param5,
    this.param6,
  });

  final String? varId;
  final String? param0;
  final String? param1;
  final String? param2;
  final String? param3;
  final String? param4;
  final String? param5;
  final String? param6;

  factory ResponseUser.fromJson(Map<String, dynamic> json) => ResponseUser(
    varId: asString(json['var_id']),
    param0: asString(json['param0']),
    param1: asString(json['param1']),
    param2: asString(json['param2']),
    param3: asString(json['param3']),
    param4: asString(json['param4']),
    param5: asString(json['param5']),
    param6: asString(json['param6']),
  );

  Map<String, dynamic> toJson() => {
    'var_id': varId,
    'param0': param0,
    'param1': param1,
    'param2': param2,
    'param3': param3,
    'param4': param4,
    'param5': param5,
    'param6': param6,
  };
}
