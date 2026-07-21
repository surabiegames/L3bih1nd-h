import 'dart:convert';

import 'package:dio/dio.dart';

import '../../data/models/models.dart';
import 'api_exception.dart';

/// Service HTTP untuk API legacy Aurora BDG (backend PHP `aurora_api/*`) —
/// pemetaan 1:1 dari interface Retrofit `com.aurora.bdg.api.ApiService`
/// (referensi: `mobile/Aurora BDG/bdg/api/`).
///
/// SENGAJA terpisah dari [ApiClient] (backend Next.js baru) karena
/// kontraknya beda total:
/// - tidak ada envelope `{ success, data, error }` — respons langsung
///   berupa array/objek JSON;
/// - Content-Type sering bukan `application/json` (aplikasi lama memakai
///   Gson `setLenient()`), jadi body diambil sebagai teks lalu di-decode
///   manual di [_decode];
/// - base URL berbeda per fungsi: server data ditentukan operator saat
///   runtime, gateway cek tagihan PDAM adalah host lain lagi — karena itu
///   base URL diberikan lewat konstruktor, bukan `ApiConfig`.
///
/// Semua kegagalan dilempar sebagai [ApiException] agar penanganan error
/// di UI seragam dengan klien backend baru.
class AuroraApiService {
  AuroraApiService({required String baseUrl, Dio? dio})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl.endsWith('/') ? baseUrl : '$baseUrl/',
              // Aplikasi lama memakai timeout 360 detik — download data
              // meter satu periode dan upload video memang bisa selama itu.
              connectTimeout: const Duration(seconds: 60),
              receiveTimeout: const Duration(seconds: 360),
              sendTimeout: const Duration(seconds: 360),
              // Body diambil mentah sebagai String; decoding JSON longgar
              // dilakukan sendiri di _decode (lihat catatan kelas).
              responseType: ResponseType.plain,
              validateStatus: (_) => true,
            ),
          );

  final Dio dio;

  // ---------------------------------------------------------------------
  // GET — download data master & data meter
  // ---------------------------------------------------------------------

  /// `GET aurora_api/data_alasan.php` — daftar alasan meter tak terbaca.
  Future<List<ResponseAlasan>> getAlasan() =>
      _getList('aurora_api/data_alasan.php', ResponseAlasan.fromJson);

  /// `GET aurora_api/data_user.php` — daftar akun petugas (baris
  /// `var_id == "2"`; petakan dengan [Petugas.fromResponse]).
  Future<List<ResponseUser>> getDataUser() =>
      _getList('aurora_api/data_user.php', ResponseUser.fromJson);

  /// `GET aurora_api/dev/download_tarif.php` — golongan tarif.
  Future<List<Tarif>> getTarif() =>
      _getList('aurora_api/dev/download_tarif.php', Tarif.fromJson);

  /// `GET aurora_api/dev/download_watertarif.php` — tarif air progresif.
  Future<List<WaterTarif>> getWaterTarif() =>
      _getList('aurora_api/dev/download_watertarif.php', WaterTarif.fromJson);

  /// `GET aurora_api/dev/download_wmsize.php` — ukuran water meter.
  Future<List<ResponseWmsize>> getWmsize() =>
      _getList('aurora_api/dev/download_wmsize.php', ResponseWmsize.fromJson);

  /// `GET aurora_api/dev/download_datameter.php` — seluruh data meter rute
  /// milik satu petugas untuk satu periode.
  ///
  /// [periode] format `yyyyMM` (mis. `202607`) — nama query legacy `periode`.
  Future<List<DataMeter>> getDataMeter({
    required String periode,
    required String writerId,
  }) => _getList(
    'aurora_api/dev/download_datameter.php',
    DataMeter.fromJson,
    query: {'periode': periode, 'writer_id': writerId},
  );

  // ---------------------------------------------------------------------
  // POST — cek tagihan, sinkronisasi data, upload berkas
  // ---------------------------------------------------------------------

  /// Cek tagihan PDAM lewat gateway H2H — form-urlencoded
  /// `api_key`, `data`, `id`.
  ///
  /// Di aplikasi lama ini `@POST("?")`: dikirim ke AKAR base URL gateway
  /// (bukan path `aurora_api/*`), dengan `id = "0"` untuk inquiry. Buat
  /// instance [AuroraApiService] tersendiri ber-`baseUrl` gateway saat
  /// memakai method ini.
  Future<ResponsePdam> cekTagihanPdam({
    required String apiKey,
    required String data,
    String id = '0',
  }) async {
    final body = await _postForm('', {
      'api_key': apiKey,
      'data': data,
      'id': id,
    });
    return ResponsePdam.fromJson(_asMap(body));
  }

  /// `POST aurora_api/sync/dev_store_data.php` — upload batch hasil catat
  /// meter. [usersJson] adalah array JSON (string) berisi baris-baris
  /// [DataMeter.toJson]; server membalas status per-record.
  Future<List<ResponseUploadData>> postDataMeter(String usersJson) async {
    final body = await _postForm('aurora_api/sync/dev_store_data.php', {
      'usersJSON': usersJson,
    });
    return _asList(body, ResponseUploadData.fromJson);
  }

  /// `POST aurora_api/upload_stand.php` — foto stand meter.
  Future<ResponseUploadFile> postStandFile({
    required String tahun,
    required String bulan,
    required String filePath,
  }) => _postFile(
    'aurora_api/upload_stand.php',
    tahun: tahun,
    bulan: bulan,
    filePath: filePath,
  );

  /// `POST aurora_api/upload_home.php` — foto rumah pelanggan.
  Future<ResponseUploadFile> postHomeFile({
    required String tahun,
    required String bulan,
    required String filePath,
  }) => _postFile(
    'aurora_api/upload_home.php',
    tahun: tahun,
    bulan: bulan,
    filePath: filePath,
  );

  /// `POST aurora_api/upload_segel.php` — foto segel meter.
  Future<ResponseUploadFile> postSegelFile({
    required String tahun,
    required String bulan,
    required String filePath,
  }) => _postFile(
    'aurora_api/upload_segel.php',
    tahun: tahun,
    bulan: bulan,
    filePath: filePath,
  );

  /// `POST aurora_api/upload_video.php` — video pembacaan meter.
  /// Nama part-nya tetap `image` (begitu kontrak legacy-nya, termasuk
  /// untuk video — jangan "diperbaiki" jadi `video`).
  Future<ResponseUploadFile> postVideoFile({
    required String tahun,
    required String bulan,
    required String filePath,
  }) => _postFile(
    'aurora_api/upload_video.php',
    tahun: tahun,
    bulan: bulan,
    filePath: filePath,
    contentType: 'video/*',
  );

  // ---------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------

  Future<List<T>> _getList<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, Object?>? query,
  }) async {
    final body = await _send(
      () => dio.get<String>(path, queryParameters: query),
    );
    return _asList(body, fromJson);
  }

  Future<Object?> _postForm(String path, Map<String, String> fields) => _send(
    () => dio.post<String>(
      path,
      data: fields,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    ),
  );

  Future<ResponseUploadFile> _postFile(
    String path, {
    required String tahun,
    required String bulan,
    required String filePath,
    String? contentType,
  }) async {
    final form = FormData.fromMap({
      'tahun': tahun,
      'bulan': bulan,
      'image': await MultipartFile.fromFile(
        filePath,
        contentType: contentType == null
            ? null
            : DioMediaType.parse(contentType),
      ),
    });
    final body = await _send(() => dio.post<String>(path, data: form));
    return ResponseUploadFile.fromJson(_asMap(body));
  }

  /// Jalankan request, normalkan kegagalan jaringan/HTTP jadi
  /// [ApiException], lalu decode body teks menjadi struktur JSON.
  Future<Object?> _send(Future<Response<String>> Function() request) async {
    late final Response<String> response;
    try {
      response = await request();
    } on DioException {
      throw const ApiException(
        0,
        'NETWORK_ERROR',
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    }
    final status = response.statusCode ?? 0;
    if (status < 200 || status >= 300) {
      throw ApiException(
        status,
        'HTTP_ERROR',
        'Server menjawab dengan status $status.',
      );
    }
    return _decode(response.data);
  }

  Object? _decode(String? raw) {
    final teks = raw?.trim();
    if (teks == null || teks.isEmpty) return null;
    try {
      return jsonDecode(teks);
    } on FormatException {
      throw const ApiException(
        0,
        'PARSE_ERROR',
        'Format respons server tidak dikenali.',
      );
    }
  }

  Map<String, dynamic> _asMap(Object? body) {
    if (body is Map<String, dynamic>) return body;
    throw const ApiException(
      0,
      'PARSE_ERROR',
      'Server tidak mengirim objek JSON yang diharapkan.',
    );
  }

  List<T> _asList<T>(Object? body, T Function(Map<String, dynamic>) fromJson) {
    if (body is List) {
      return body.whereType<Map<String, dynamic>>().map(fromJson).toList();
    }
    throw const ApiException(
      0,
      'PARSE_ERROR',
      'Server tidak mengirim daftar JSON yang diharapkan.',
    );
  }
}
