import 'package:dio/dio.dart';

import '../../../core/models/meter_reading_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/formatters.dart';

/// Sumber data layar Lapor Meter Mandiri (publik).
abstract interface class LaporMeterRepository {
  factory LaporMeterRepository.create() => ApiConfig.isDemo
      ? DemoLaporMeterRepository()
      : ApiLaporMeterRepository(ApiClient.instance);

  /// Kirim laporan angka meter. Laporan SELALU masuk berstatus MENUNGGU dan
  /// periode ditentukan server (bulan berjalan) — bukan pilihan pengguna.
  /// Server membatasi satu laporan per pelanggan per bulan (400 bila ganda).
  Future<LaporMeterReceipt> kirim({
    required String nomorLangganan,
    required int standDilaporkan,
    required String namaPelapor,
    required String nomorPelapor,
    List<int>? fotoBytes,
    String? namaFoto,
  });
}

class ApiLaporMeterRepository implements LaporMeterRepository {
  ApiLaporMeterRepository(this._api);

  final ApiClient _api;

  @override
  Future<LaporMeterReceipt> kirim({
    required String nomorLangganan,
    required int standDilaporkan,
    required String namaPelapor,
    required String nomorPelapor,
    List<int>? fotoBytes,
    String? namaFoto,
  }) async {
    // Server MEWAJIBKAN foto meter sebagai bukti (validasi magic bytes di
    // sisi server). Gagalkan lebih awal dengan pesan yang sama supaya
    // pengguna tidak menunggu upload yang pasti ditolak.
    if (fotoBytes == null || fotoBytes.isEmpty) {
      throw const ApiException(
        400,
        'BAD_REQUEST',
        'Foto meter wajib dilampirkan sebagai bukti.',
      );
    }

    final form = FormData.fromMap({
      'nomorLangganan': nomorLangganan,
      'standDilaporkan': '$standDilaporkan',
      'namaPelapor': namaPelapor,
      'nomorPelapor': nomorPelapor,
      'foto': MultipartFile.fromBytes(
        fotoBytes,
        filename: namaFoto ?? 'meter.jpg',
      ),
    });

    return _api.postMultipart(
      '${ApiConfig.publicPath}/lapor-meter',
      form: form,
      parse: (data) =>
          LaporMeterReceipt.fromJson(data as Map<String, dynamic>? ?? const {}),
    );
  }
}

class DemoLaporMeterRepository implements LaporMeterRepository {
  @override
  Future<LaporMeterReceipt> kirim({
    required String nomorLangganan,
    required int standDilaporkan,
    required String namaPelapor,
    required String nomorPelapor,
    List<int>? fotoBytes,
    String? namaFoto,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final sekarang = DateTime.now();
    return LaporMeterReceipt(
      periode: thblDariDate(DateTime(sekarang.year, sekarang.month)),
      standDilaporkan: standDilaporkan,
      status: 'MENUNGGU',
      pesan:
          'Laporan meter Anda terkirim dan sedang menunggu verifikasi petugas.',
    );
  }
}
