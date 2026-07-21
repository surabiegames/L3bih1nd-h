import 'json_utils.dart';

/// Amplop `{ "result": {...} }` yang dipakai aplikasi lama untuk
/// membungkus kredensial/aksi (mis. payload login yang dikirim sebagai JSON).
class ResponseJson {
  const ResponseJson({this.result});

  final Result? result;

  factory ResponseJson.fromJson(Map<String, dynamic> json) => ResponseJson(
    result: json['result'] is Map<String, dynamic>
        ? Result.fromJson(json['result'] as Map<String, dynamic>)
        : null,
  );

  Map<String, dynamic> toJson() => {'result': result?.toJson()};
}

/// Isi [ResponseJson]: kredensial + kode aksi (`act`) dan parameter bebas.
class Result {
  const Result({
    this.username,
    this.password,
    this.act,
    this.groupRef,
    this.param1,
    this.param2,
    this.param3,
    this.param4,
  });

  final String? username;
  final String? password;
  final String? act;
  final String? groupRef;
  final String? param1;
  final String? param2;
  final String? param3;
  final String? param4;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    username: asString(json['username']),
    password: asString(json['password']),
    act: asString(json['act']),
    groupRef: asString(json['group_ref']),
    param1: asString(json['param_1']),
    param2: asString(json['param_2']),
    param3: asString(json['param_3']),
    param4: asString(json['param_4']),
  );

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
    'act': act,
    'group_ref': groupRef,
    'param_1': param1,
    'param_2': param2,
    'param_3': param3,
    'param_4': param4,
  };
}
