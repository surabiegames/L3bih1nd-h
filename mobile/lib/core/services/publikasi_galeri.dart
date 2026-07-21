import 'package:flutter/services.dart';

/// Jembatan ke MediaStore (lihat MainActivity.kt) — menyalin berkas backup ke
/// koleksi publik Pictures/Download supaya TERLIHAT di Galeri/File TANPA izin
/// runtime (Android 10+). Di platform/versi yang tak mendukung, semua method
/// mengembalikan false dengan tenang — alur ekspor tidak boleh jatuh karena
/// publikasi galeri gagal.
class PublikasiGaleri {
  const PublikasiGaleri();

  static const _channel = MethodChannel('id.tirtawening/galeri');

  /// Simpan [bytes] sebagai [displayName] di [relativePath] (mis.
  /// `Pictures/tirtawening/backup/rumah` untuk foto, `Download/...` untuk CSV).
  /// [isImage] menentukan koleksi (Images vs Downloads). Idempoten di sisi
  /// native (nama+path sama tidak digandakan). Kembalikan true bila
  /// tersimpan/sudah ada.
  Future<bool> simpan({
    required Uint8List bytes,
    required String displayName,
    required String relativePath,
    required String mime,
    required bool isImage,
  }) async {
    try {
      final hasil = await _channel.invokeMethod<bool>('simpanKeMediaStore', {
        'bytes': bytes,
        'displayName': displayName,
        'relativePath': relativePath,
        'mime': mime,
        'isImage': isImage,
      });
      return hasil ?? false;
    } on Object {
      return false;
    }
  }
}
