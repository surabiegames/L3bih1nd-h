import 'json_utils.dart';
import 'pdam.dart';

/// Amplop respons cek tagihan PDAM (`POST` ke gateway H2H).
class ResponsePdam {
  const ResponsePdam({this.error, this.message, this.data});

  final String? error;
  final String? message;
  final Pdam? data;

  factory ResponsePdam.fromJson(Map<String, dynamic> json) => ResponsePdam(
    error: asString(json['error']),
    message: asString(json['message']),
    data: json['data'] is Map<String, dynamic>
        ? Pdam.fromJson(json['data'] as Map<String, dynamic>)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'error': error,
    'message': message,
    'data': data?.toJson(),
  };
}
