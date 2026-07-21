import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/db/database_lokal.dart';
import 'rbm_models.dart';

/// Akses SQLite untuk modul Baca Meter — padanan `DataBaseHelper` +
/// `QueryHelper` Aurora dalam satu kelas Dart. Seluruh SQL modul ini ada di
/// sini; repository tidak menyentuh database langsung.
class RbmDao {
  RbmDao([DatabaseLokal? db]) : _dbLokal = db ?? DatabaseLokal.instance;

  final DatabaseLokal _dbLokal;

  static const _kunciMetaPaket = 'rbm.paket_meta';
  static const _kunciMetaWaktu = 'rbm.paket_waktu';

  // ── Paket rute ─────────────────────────────────────────────────────────

  /// Simpan paket unduhan rute: ganti seluruh isi (pola DownloadDataActivity
  /// Aurora — `deleteAll` lalu insert; unduhan baru adalah kebenaran baru).
  /// Berjalan dalam SATU transaksi: gagal di tengah = paket lama tetap utuh.
  Future<void> simpanPaket(RuteSaya paket, {DateTime? diunduhPada}) async {
    final db = await _dbLokal.buka();
    final metaJson = jsonEncode({...paket.toJson()}..remove('pelanggan'));
    await db.transaction((tx) async {
      await tx.delete('pelanggan_rute');
      final batch = tx.batch();
      for (final p in paket.pelanggan) {
        batch.insert('pelanggan_rute', {
          'nomor_langganan': p.nomorLangganan,
          'pelanggan_id': p.id,
          'nama': p.nama,
          'alamat': p.alamat,
          'urutan': p.urutan,
          'periode': paket.periode,
          'sudah_dicatat': p.sudahDicatat ? 1 : 0,
          'data_json': jsonEncode(p.toJson()),
        });
      }
      batch.insert('meta', {
        'kunci': _kunciMetaPaket,
        'nilai': metaJson,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      batch.insert('meta', {
        'kunci': _kunciMetaWaktu,
        'nilai': (diunduhPada ?? DateTime.now()).toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      await batch.commit(noResult: true);
    });
  }

  /// Baca paket dari lokal. Baris yang antre di outbox otomatis tampil
  /// sudahDicatat (petugas tidak boleh mencatat dua kali hanya karena
  /// laporannya belum tersinkron) — di Aurora ini status BILL_IS_UPLOAD=1.
  Future<RuteSaya?> bacaPaket() async {
    final db = await _dbLokal.buka();
    final meta = await db.query(
      'meta',
      where: 'kunci = ?',
      whereArgs: [_kunciMetaPaket],
      limit: 1,
    );
    if (meta.isEmpty) return null;

    final rows = await db.rawQuery('''
      SELECT p.data_json,
             p.sudah_dicatat,
             EXISTS(SELECT 1 FROM antrean_laporan a
                    WHERE a.nomor_langganan = p.nomor_langganan) AS antre
      FROM pelanggan_rute p
      ORDER BY p.urutan IS NULL, p.urutan, p.nomor_langganan
    ''');

    final pelanggan = <PelangganRute>[];
    for (final row in rows) {
      try {
        var p = PelangganRute.fromJson(
          jsonDecode(row['data_json'] as String) as Map<String, dynamic>,
        );
        final tercatat =
            (row['sudah_dicatat'] as int? ?? 0) == 1 ||
            (row['antre'] as int? ?? 0) == 1;
        if (tercatat != p.sudahDicatat) p = p.copyWith(sudahDicatat: tercatat);
        pelanggan.add(p);
      } on Object {
        // Satu baris korup tidak menular ke baris lain — inti alasan pindah
        // dari blob SharedPreferences ke tabel.
        continue;
      }
    }

    final waktu = await db.query(
      'meta',
      where: 'kunci = ?',
      whereArgs: [_kunciMetaWaktu],
      limit: 1,
    );
    final paketMeta =
        jsonDecode(meta.first['nilai'] as String) as Map<String, dynamic>;
    return RuteSaya.fromJson(
      {...paketMeta, 'pelanggan': const []},
      diunduhPada: waktu.isEmpty
          ? null
          : DateTime.tryParse(waktu.first['nilai'] as String),
      dariCache: true,
    ).salinDenganPelanggan(pelanggan);
  }

  /// Tandai satu pelanggan tercatat (setelah laporan terkirim/antre).
  Future<void> tandaiDicatat(String nomorLangganan) async {
    final db = await _dbLokal.buka();
    await db.update(
      'pelanggan_rute',
      {'sudah_dicatat': 1},
      where: 'nomor_langganan = ?',
      whereArgs: [nomorLangganan],
    );
  }

  /// Pencarian lokal ala `pencarianData` Aurora: nama / nomor langganan /
  /// alamat, satu kotak cari. Berfungsi penuh saat offline.
  Future<List<PelangganRute>> cari(String kueri) async {
    final db = await _dbLokal.buka();
    final q = '%${kueri.trim()}%';
    final rows = await db.query(
      'pelanggan_rute',
      columns: ['data_json'],
      where: 'nama LIKE ? OR nomor_langganan LIKE ? OR alamat LIKE ?',
      whereArgs: [q, q, q],
      orderBy: 'urutan IS NULL, urutan, nomor_langganan',
      limit: 100,
    );
    final hasil = <PelangganRute>[];
    for (final row in rows) {
      try {
        hasil.add(
          PelangganRute.fromJson(
            jsonDecode(row['data_json'] as String) as Map<String, dynamic>,
          ),
        );
      } on Object {
        continue;
      }
    }
    return hasil;
  }

  // ── Antrean offline (outbox) ───────────────────────────────────────────

  Future<void> tambahAntrean(CatatTertunda entri) async {
    final db = await _dbLokal.buka();
    // UNIQUE(nomor_langganan, periode) ON CONFLICT REPLACE di skema —
    // catat ulang pelanggan yang sama menimpa antrean lamanya.
    await db.insert('antrean_laporan', {
      'nomor_langganan': entri.nomorLangganan,
      'periode': entri.periode,
      'payload_json': jsonEncode(entri.payload),
      'foto_paths_json': jsonEncode(entri.fotoPaths),
      'dibuat_pada': entri.dibuatPada.toIso8601String(),
    });
  }

  Future<List<CatatTertunda>> daftarAntrean() async {
    final db = await _dbLokal.buka();
    final rows = await db.query('antrean_laporan', orderBy: 'id');
    final hasil = <CatatTertunda>[];
    for (final row in rows) {
      try {
        hasil.add(
          CatatTertunda(
            idAntrean: row['id'] as int,
            payload: (jsonDecode(row['payload_json'] as String) as Map)
                .cast<String, Object?>(),
            fotoPaths: (jsonDecode(row['foto_paths_json'] as String) as Map)
                .cast<String, String>(),
            dibuatPada:
                DateTime.tryParse(row['dibuat_pada'] as String? ?? '') ??
                DateTime.now(),
            percobaan: row['percobaan'] as int? ?? 0,
            pesanGagal: row['pesan_gagal'] as String?,
          ),
        );
      } on Object {
        continue;
      }
    }
    return hasil;
  }

  Future<void> hapusAntrean(int id) async {
    final db = await _dbLokal.buka();
    await db.delete('antrean_laporan', where: 'id = ?', whereArgs: [id]);
  }

  /// Catat kegagalan per baris (dari respons per-record /batch) — baris
  /// tetap di antrean dengan pesannya, tidak menghilang diam-diam.
  Future<void> tandaiGagal(int id, String pesan) async {
    final db = await _dbLokal.buka();
    await db.rawUpdate(
      'UPDATE antrean_laporan SET percobaan = percobaan + 1, pesan_gagal = ? WHERE id = ?',
      [pesan, id],
    );
  }

  Future<int> jumlahAntrean() async {
    final db = await _dbLokal.buka();
    final hasil = await db.rawQuery(
      'SELECT COUNT(*) AS n FROM antrean_laporan',
    );
    return (hasil.first['n'] as int?) ?? 0;
  }

  // ── Meta kunci-nilai (cache kecil lain: master tarif, dsb.) ───────────

  Future<void> simpanMeta(String kunci, String nilai) async {
    final db = await _dbLokal.buka();
    await db.insert('meta', {
      'kunci': kunci,
      'nilai': nilai,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> bacaMeta(String kunci) async {
    final db = await _dbLokal.buka();
    final rows = await db.query(
      'meta',
      where: 'kunci = ?',
      whereArgs: [kunci],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['nilai'] as String?;
  }

  // ── Migrasi dari penyimpanan lama ──────────────────────────────────────

  static const _kunciPrefsCacheLama = 'rbm.cache';
  static const _kunciPrefsWaktuLama = 'rbm.cache.waktu';
  static const _kunciPrefsAntreanLama = 'rbm.antrean';

  /// Impor sekali dari SharedPreferences (penyimpanan versi sebelumnya) lalu
  /// hapus kuncinya. Antrean WAJIB ikut — itu hasil kerja petugas yang belum
  /// terunggah; kehilangan saat update aplikasi tidak bisa diterima.
  Future<void> migrasiDariPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final cacheLama = prefs.getString(_kunciPrefsCacheLama);
    if (cacheLama != null) {
      try {
        final paket = RuteSaya.fromJson(
          jsonDecode(cacheLama) as Map<String, dynamic>,
          diunduhPada: DateTime.tryParse(
            prefs.getString(_kunciPrefsWaktuLama) ?? '',
          ),
        );
        if ((await bacaPaket()) == null) await simpanPaket(paket);
      } on Object {
        // cache lama korup — relakan, paket bisa diunduh ulang.
      }
    }

    final antreanLama = prefs.getString(_kunciPrefsAntreanLama);
    if (antreanLama != null) {
      try {
        final daftar = (jsonDecode(antreanLama) as List)
            .whereType<Map<String, dynamic>>()
            .map(CatatTertunda.fromJson);
        for (final entri in daftar) {
          await tambahAntrean(entri);
        }
      } on Object {
        // antrean lama korup per-blob — tidak ada yang bisa diselamatkan.
      }
    }

    await prefs.remove(_kunciPrefsCacheLama);
    await prefs.remove(_kunciPrefsWaktuLama);
    await prefs.remove(_kunciPrefsAntreanLama);
  }
}
