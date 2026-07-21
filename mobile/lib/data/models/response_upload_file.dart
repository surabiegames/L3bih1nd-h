import 'json_utils.dart';

/// Hasil upload berkas (`upload_stand.php` / `upload_home.php` /
/// `upload_segel.php` / `upload_video.php`).
class ResponseUploadFile {
  const ResponseUploadFile({this.error, this.message, this.filePath});

  final bool? error;
  final String? message;

  /// Nama berkas di server — kunci JSON legacy-nya `file_name`.
  final String? filePath;

  factory ResponseUploadFile.fromJson(Map<String, dynamic> json) =>
      ResponseUploadFile(
        error: json['error'] is bool
            ? json['error'] as bool
            : asString(json['error']) == 'true',
        message: asString(json['message']),
        filePath: asString(json['file_name']),
      );

  Map<String, dynamic> toJson() => {
    'error': error,
    'message': message,
    'file_name': filePath,
  };
}
