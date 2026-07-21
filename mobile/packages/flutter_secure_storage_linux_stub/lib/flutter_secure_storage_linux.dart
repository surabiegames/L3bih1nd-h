// Stub dev-only pengganti flutter_secure_storage_linux — lihat alasan di
// pubspec.yaml paket ini. Menyimpan pasangan kunci-nilai sebagai JSON di
// $XDG_DATA_HOME/tirtawening-petugas/secure_storage.json (permission 0600).
// Android/iOS tidak lewat sini — mereka memakai implementasi Keystore/
// Keychain asli dari paket flutter_secure_storage.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';

class FlutterSecureStorageLinuxStub extends FlutterSecureStoragePlatform {
  /// Dipanggil runtime Flutter saat plugin terdaftar (dartPluginClass).
  static void registerWith() {
    FlutterSecureStoragePlatform.instance = FlutterSecureStorageLinuxStub();
  }

  File get _berkas {
    final dataDir = Platform.environment['XDG_DATA_HOME'] ??
        '${Platform.environment['HOME'] ?? '.'}/.local/share';
    return File('$dataDir/tirtawening-petugas/secure_storage.json');
  }

  Map<String, String> _baca() {
    try {
      final isi = _berkas.readAsStringSync();
      return (jsonDecode(isi) as Map).cast<String, String>();
    } on Object {
      return {};
    }
  }

  Future<void> _tulis(Map<String, String> data) async {
    final berkas = _berkas;
    await berkas.parent.create(recursive: true);
    await berkas.writeAsString(jsonEncode(data));
    // Hanya pemilik yang boleh membaca — sejauh yang bisa dijanjikan
    // penyimpanan berkas polos (ini memang stub dev, bukan Keystore).
    await Process.run('chmod', ['600', berkas.path]);
  }

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    final data = _baca();
    data[key] = value;
    await _tulis(data);
  }

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async =>
      _baca()[key];

  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async =>
      _baca().containsKey(key);

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async {
    final data = _baca();
    data.remove(key);
    await _tulis(data);
  }

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async =>
      _baca();

  @override
  Future<void> deleteAll({required Map<String, String> options}) async {
    try {
      await _berkas.delete();
    } on Object {
      // Berkas belum ada = sudah bersih.
    }
  }
}
