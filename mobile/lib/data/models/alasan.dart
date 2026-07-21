import 'json_utils.dart';
import 'response_alasan.dart';

/// Alasan meter tidak terbaca (rumah kosong, meter rusak, dst.) — bentuk
/// domain dari [ResponseAlasan]. Di aplikasi lama ini entitas greenDAO
/// lokal; kunci JSON di bawah untuk cache lokal, bukan kontrak API.
class Alasan {
  const Alasan({this.alId, this.alName});

  final String? alId;
  final String? alName;

  /// Pemetaan yang sama dengan DownloadDataActivity aplikasi lama:
  /// `param1` → id, `param2` → nama.
  factory Alasan.fromResponse(ResponseAlasan r) =>
      Alasan(alId: r.param1, alName: r.param2);

  factory Alasan.fromJson(Map<String, dynamic> json) =>
      Alasan(alId: asString(json['alId']), alName: asString(json['alName']));

  Map<String, dynamic> toJson() => {'alId': alId, 'alName': alName};

  @override
  String toString() => alName ?? '';
}
