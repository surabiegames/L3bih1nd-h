import 'json_utils.dart';
import 'response_user.dart';

/// Akun petugas pencatat (writer) — bentuk domain dari [ResponseUser].
/// Di aplikasi lama ini entitas greenDAO lokal; kunci JSON di bawah untuk
/// cache lokal, bukan kontrak API.
class Petugas {
  const Petugas({
    this.wrId,
    this.wrUserName,
    this.wrName,
    this.wrPass,
    this.wrIsLogin,
  });

  final String? wrId;
  final String? wrUserName;
  final String? wrName;
  final String? wrPass;
  final String? wrIsLogin;

  /// Pemetaan yang sama dengan DownloadPetugasActivity aplikasi lama
  /// (hanya baris `var_id == "2"` yang merupakan petugas):
  /// `param1` → id, `param2` → username, `param3` → nama, `param4` → password.
  factory Petugas.fromResponse(ResponseUser r) => Petugas(
    wrId: r.param1,
    wrUserName: r.param2,
    wrName: r.param3,
    wrPass: r.param4,
  );

  factory Petugas.fromJson(Map<String, dynamic> json) => Petugas(
    wrId: asString(json['wrId']),
    wrUserName: asString(json['wrUserName']),
    wrName: asString(json['wrName']),
    wrPass: asString(json['wrPass']),
    wrIsLogin: asString(json['wrIsLogin']),
  );

  Map<String, dynamic> toJson() => {
    'wrId': wrId,
    'wrUserName': wrUserName,
    'wrName': wrName,
    'wrPass': wrPass,
    'wrIsLogin': wrIsLogin,
  };
}
