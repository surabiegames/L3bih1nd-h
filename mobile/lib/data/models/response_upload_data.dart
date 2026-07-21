import 'json_utils.dart';

/// Satu baris hasil `POST aurora_api/sync/dev_store_data.php` — status
/// per-record dari batch upload data meter (field `usersJSON`).
class ResponseUploadData {
  const ResponseUploadData({this.id, this.status});

  final String? id;
  final String? status;

  factory ResponseUploadData.fromJson(Map<String, dynamic> json) =>
      ResponseUploadData(
        id: asString(json['id']),
        status: asString(json['status']),
      );

  Map<String, dynamic> toJson() => {'id': id, 'status': status};
}
