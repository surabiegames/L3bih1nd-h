import 'package:dio/dio.dart';

import 'api_config.dart';
import 'api_exception.dart';

/// Klien API terpusat — satu-satunya tempat envelope backend dibongkar.
///
/// Kontrak envelope (berlaku untuk SEMUA endpoint):
///   sukses : { "success": true,  "data": ..., "meta"?: {...} }
///   gagal  : { "success": false, "error": { "code", "message", "details"? } }
class ApiClient {
  ApiClient._()
    : dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
          // Terima juga status error supaya envelope { error } tetap
          // terbaca — penanganan gagal ada di _unwrap, bukan exception Dio.
          validateStatus: (_) => true,
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _accessToken;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._();

  final Dio dio;

  String? _accessToken;

  /// Pasang token Bearer hasil POST /api/mobile/auth/login|google.
  /// Token berumur 7 hari, tanpa refresh — saat 401, hapus dan login ulang.
  void setAccessToken(String? token) => _accessToken = token;

  /// Dipanggil sekali setiap kali endpoint /api/v1 menjawab 401 SAAT token
  /// terpasang (kedaluwarsa/dicabut). TIDAK terpicu oleh 401 dari endpoint
  /// login sendiri (kredensial salah bukan sesi berakhir).
  void Function()? onUnauthorized;

  Future<T> get<T>(
    String path, {
    Map<String, Object?>? query,
    required T Function(Object? data) parse,
  }) async {
    final response = await _send(
      () => dio.get<Object?>(path, queryParameters: _bersihkanQuery(query)),
    );
    return _unwrap(response, parse);
  }

  Future<Paged<T>> getList<T>(
    String path, {
    Map<String, Object?>? query,
    required T Function(Map<String, dynamic> row) parseRow,
  }) async {
    final response = await _send(
      () => dio.get<Object?>(path, queryParameters: _bersihkanQuery(query)),
    );
    final body = _bodySukses(response);
    final data = body['data'];
    final rows = data is List
        ? data.whereType<Map<String, dynamic>>().map(parseRow).toList()
        : <T>[];
    return Paged(rows, PageMeta.fromJson(body['meta']));
  }

  Future<T> post<T>(
    String path, {
    Object? body,
    required T Function(Object? data) parse,
  }) async {
    final response = await _send(() => dio.post<Object?>(path, data: body));
    return _unwrap(response, parse);
  }

  Future<T> patch<T>(
    String path, {
    Object? body,
    required T Function(Object? data) parse,
  }) async {
    final response = await _send(() => dio.patch<Object?>(path, data: body));
    return _unwrap(response, parse);
  }

  Future<T> delete<T>(
    String path, {
    required T Function(Object? data) parse,
  }) async {
    final response = await _send(() => dio.delete<Object?>(path));
    return _unwrap(response, parse);
  }

  /// Kirim multipart/form-data (foto bukti dsb.). Server memvalidasi berkas
  /// lewat magic bytes dan memilih sendiri nama/ekstensinya.
  Future<T> postMultipart<T>(
    String path, {
    required FormData form,
    required T Function(Object? data) parse,
  }) async {
    final response = await _send(() => dio.post<Object?>(path, data: form));
    return _unwrap(response, parse);
  }

  Future<Response<Object?>> _send(
    Future<Response<Object?>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException {
      throw const ApiException(
        0,
        'NETWORK_ERROR',
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    }
  }

  Map<String, dynamic> _bodySukses(Response<Object?> response) {
    final body = response.data;
    if (body is Map<String, dynamic> && body['success'] == true) return body;
    throw _sebagaiError(response);
  }

  T _unwrap<T>(Response<Object?> response, T Function(Object? data) parse) {
    return parse(_bodySukses(response)['data']);
  }

  ApiException _sebagaiError(Response<Object?> response) {
    if (response.statusCode == 401 &&
        _accessToken != null &&
        response.requestOptions.path.startsWith(ApiConfig.v1Path)) {
      onUnauthorized?.call();
    }
    final body = response.data;
    final error = body is Map<String, dynamic> ? body['error'] : null;
    if (error is Map<String, dynamic>) {
      final rawDetails = error['details'];
      return ApiException(
        response.statusCode ?? 0,
        error['code'] as String? ?? 'UNKNOWN',
        error['message'] as String? ?? 'Terjadi kesalahan.',
        details: rawDetails is List
            ? rawDetails.map(FieldError.fromJson).nonNulls.toList()
            : null,
      );
    }
    return ApiException(
      response.statusCode ?? 0,
      'UNKNOWN',
      'Terjadi kesalahan pada server (${response.statusCode}).',
    );
  }

  /// Buang entri null supaya query string bersih (?status=&q= membingungkan
  /// validator backend).
  Map<String, Object?>? _bersihkanQuery(Map<String, Object?>? query) {
    if (query == null) return null;
    final bersih = {
      for (final e in query.entries)
        if (e.value != null) e.key: e.value,
    };
    return bersih.isEmpty ? null : bersih;
  }
}

/// Hasil endpoint list — selalu berpaginasi di backend.
class Paged<T> {
  const Paged(this.rows, this.meta);

  final List<T> rows;
  final PageMeta meta;
}

class PageMeta {
  const PageMeta({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int pageSize;
  final int total;
  final int totalPages;

  factory PageMeta.fromJson(Object? json) {
    if (json is! Map) return const PageMeta.satuHalaman(0);
    return PageMeta(
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 20,
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }

  const PageMeta.satuHalaman(int jumlah)
    : page = 1,
      pageSize = jumlah,
      total = jumlah,
      totalPages = 1;
}
