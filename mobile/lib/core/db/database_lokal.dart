import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Pembuka database SQLite lokal — pondasi kerja offline aplikasi petugas.
///
/// Pola mengikuti `DataBaseHelper` aplikasi Aurora legacy (singleton, satu
/// database untuk seluruh app), tapi query per-domain TIDAK di sini:
/// tiap fitur punya DAO sendiri (mis. `features/staff/baca_meter/rbm_dao.dart`)
/// supaya lapisan core tidak bergantung ke model fitur.
///
/// Kenapa SQLite dan bukan SharedPreferences: paket rute berisi ratusan baris
/// dan antrean offline berisi hasil kerja seharian petugas — blob JSON tunggal
/// gagal parsial = SEMUA hilang, sedangkan baris tabel rusak satu tidak
/// menular. Aurora bertahan bertahun-tahun di lapangan dengan pola ini.
class DatabaseLokal {
  DatabaseLokal._();

  static final DatabaseLokal instance = DatabaseLokal._();

  static const _namaBerkas = 'wipel_petugas.db';
  static const _versi = 1;

  /// Untuk pengujian: lewati path_provider (tidak tersedia di `flutter test`)
  /// dan pakai direktori ini sebagai lokasi berkas database.
  @visibleForTesting
  static String? direktoriOverrideUntukUji;

  Database? _db;

  Future<Database> buka() async {
    final tersedia = _db;
    if (tersedia != null && tersedia.isOpen) return tersedia;

    // Desktop (pengembangan di Linux/Windows) tidak punya SQLite bawaan
    // Android/iOS — pakai implementasi FFI. Android/iOS tetap native.
    if (!kIsWeb && (Platform.isLinux || Platform.isWindows)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    // Application support (bukan documents): database internal aplikasi,
    // bukan berkas yang diakses pengguna. Backup teks manusiawi ada di
    // BackupLokal (documents).
    final dirPath =
        direktoriOverrideUntukUji ??
        (await getApplicationSupportDirectory()).path;
    final db = await openDatabase(
      '$dirPath/$_namaBerkas',
      version: _versi,
      onCreate: _buatSkema,
    );
    _db = db;
    return db;
  }

  Future<void> _buatSkema(Database db, int versi) async {
    // Paket rute yang diunduh: kolom yang di-query (urutan, pencarian,
    // status catat) dipecah jadi kolom nyata; sisanya utuh di data_json
    // supaya penambahan field dari server tidak butuh migrasi skema lokal.
    await db.execute('''
      CREATE TABLE pelanggan_rute(
        nomor_langganan TEXT PRIMARY KEY,
        pelanggan_id    TEXT NOT NULL,
        nama            TEXT NOT NULL DEFAULT '',
        alamat          TEXT,
        urutan          INTEGER,
        periode         INTEGER NOT NULL,
        sudah_dicatat   INTEGER NOT NULL DEFAULT 0,
        data_json       TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_pelanggan_rute_urutan ON pelanggan_rute(urutan)',
    );

    // Antrean offline (outbox) hasil catat yang belum sampai server.
    // UNIQUE(nomor_langganan, periode) ON CONFLICT REPLACE = idempoten
    // seperti @@unique([nomorLangganan, periode]) di server: catat ulang
    // pelanggan yang sama menimpa antreannya, tidak menggandakan.
    await db.execute('''
      CREATE TABLE antrean_laporan(
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        nomor_langganan TEXT NOT NULL,
        periode         INTEGER NOT NULL,
        payload_json    TEXT NOT NULL,
        foto_paths_json TEXT NOT NULL DEFAULT '{}',
        percobaan       INTEGER NOT NULL DEFAULT 0,
        pesan_gagal     TEXT,
        dibuat_pada     TEXT NOT NULL,
        UNIQUE(nomor_langganan, periode) ON CONFLICT REPLACE
      )
    ''');

    // Metadata kecil bergaya kunci-nilai (meta paket rute, waktu unduh, dsb.).
    await db.execute('''
      CREATE TABLE meta(
        kunci TEXT PRIMARY KEY,
        nilai TEXT NOT NULL
      )
    ''');
  }

  /// Untuk pengujian: tutup koneksi supaya berkas bisa dibuka ulang bersih.
  Future<void> tutup() async {
    await _db?.close();
    _db = null;
  }
}
