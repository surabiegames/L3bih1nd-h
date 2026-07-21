/// Kesalahan API dalam bentuk yang siap ditampilkan ke pengguna.
///
/// `message` dari backend SELALU bahasa Indonesia dan layak tampil langsung
/// (kontrak envelope backend) — jangan menerjemahkan ulang atau menebak sebab
/// gagal login (pesan sengaja seragam, anti user-enumeration).
class ApiException implements Exception {
  const ApiException(this.status, this.code, this.message, {this.details});

  /// HTTP status; 0 bila kegagalan jaringan (tidak sampai ke server).
  final int status;

  /// Kode mesin: BAD_REQUEST, UNAUTHORIZED, FORBIDDEN, NOT_FOUND, CONFLICT,
  /// VALIDATION_ERROR, RATE_LIMITED, atau NETWORK_ERROR buatan client.
  final String code;

  /// Pesan bahasa Indonesia siap tampil.
  final String message;

  /// Untuk VALIDATION_ERROR (422): daftar {path, message} per field.
  final List<FieldError>? details;

  bool get isUnauthorized => status == 401;
  bool get isRateLimited => status == 429;
  bool get isConflict => status == 409;

  @override
  String toString() => 'ApiException($status $code): $message';
}

class FieldError {
  const FieldError({required this.path, required this.message});

  final String path;
  final String message;

  static FieldError? fromJson(Object? json) {
    if (json is! Map) return null;
    final path = json['path'];
    final message = json['message'];
    if (message is! String) return null;
    return FieldError(
      path: path is List ? path.join('.') : '${path ?? ''}',
      message: message,
    );
  }
}
