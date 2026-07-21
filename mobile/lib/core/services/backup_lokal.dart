import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';

import 'publikasi_galeri.dart';

/// Satu bundel cadangan pembacaan (satu pelanggan pada satu periode).
class BundelPembacaan {
  const BundelPembacaan({
    required this.periode,
    required this.nomorLangganan,
    required this.data,
    required this.fotoPaths,
    required this.terunggah,
  });

  final int periode;
  final String nomorLangganan;

  /// Isi meta — seluruh field pembacaan + metadata (bahan pemulihan/restore).
  final Map<String, dynamic> data;

  /// jenis (stand/segel/rumah/video) → path berkas lokal yang ADA.
  final Map<String, String> fotoPaths;

  /// true = sudah pernah sukses diunggah ke server (penanda `.terunggah`).
  final bool terunggah;
}

/// Backup data baca meter di penyimpanan perangkat — pengaman hasil kerja
/// lapangan bila aplikasi crash / DB lokal korup / perangkat rusak, sekaligus
/// bahan IMPOR di dashboard web.
///
/// Tata letak (bermerek `tirtawening/backup`, dipetakan PER TIPE supaya mudah
/// "unggah folder rumah saja" di web, dan nama berkasnya
/// `periode_tipe_nomorLangganan` supaya kelihatan & bisa dibuka galeri):
///
/// ```
/// <base>/tirtawening/backup/
///     stand/     202607_stand_00700800867.jpg
///     rumah/     202607_rumah_00700800867.jpg
///     segel/     202607_segel_00700800867.jpg
///     video/     202607_video_00700800867.mp4
///     catatan/   202607_catatan.csv        # teks pencatatan (impor "note")
///     .meta/<periode>/<nomor>.json          # payload penuh (restore)
///     .meta/<periode>/<nomor>.terunggah     # ada = sudah aman di server
///     log/       catat_202607.txt  error.log
/// ```
///
/// `.meta` sengaja diawali titik: bukan untuk dilihat manusia (restore mesin),
/// tak ikut menyampah tampilan galeri. Folder foto per-tipe + CSV catatan-lah
/// yang dibagikan/diimpor.
///
/// SEMUA method menelan errornya sendiri — backup tidak boleh menjatuhkan alur
/// utama; kegagalan backup bukan kegagalan catat.
class BackupLokal {
  BackupLokal._();

  static final BackupLokal instance = BackupLokal._();

  /// Tipe berkas bukti (folder per-tipe). `video` diperlakukan sama, ekstensi
  /// beda (mp4).
  static const _semuaJenis = ['stand', 'segel', 'rumah', 'video'];

  /// Root backup. PENTING: pakai EXTERNAL storage aplikasi
  /// (`/storage/emulated/0/Android/data/<pkg>/files/tirtawening/backup` di
  /// Android) — TANPA izin khusus dan berkasnya bisa diambil walau aplikasi
  /// CRASH saat dibuka. Jatuh ke documents dir hanya bila external tak
  /// tersedia (iOS/desktop). Publikasi ke lokasi terlihat-galeri dilakukan
  /// terpisah lewat MediaStore saat "Ekspor/Backup" ditekan.
  Future<Directory> _base() async {
    Directory? ext;
    try {
      ext = await getExternalStorageDirectory();
    } on Object {
      ext = null;
    }
    final root = ext ?? await getApplicationDocumentsDirectory();
    return Directory('${root.path}/tirtawening/backup');
  }

  /// Path folder backup untuk ditampilkan ke petugas (biar tahu di mana
  /// berkasnya bila perlu diambil manual lewat file manager/USB).
  Future<String?> lokasiFolder() async {
    try {
      return (await _base()).path;
    } on Object {
      return null;
    }
  }

  Future<Directory> _dir(String sub) async {
    final dir = Directory('${(await _base()).path}/$sub');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<Directory> _dirLog() => _dir('log');

  /// Nama berkas datar `periode_tipe_nomor.ext` (jpg untuk foto, mp4 video).
  String _namaBerkas(int periode, String jenis, String nomorLangganan) {
    final ext = jenis == 'video' ? 'mp4' : 'jpg';
    return '${periode}_${jenis}_$nomorLangganan.$ext';
  }

  /// Path lengkap salinan foto/video satu pembacaan (di folder per-tipe).
  Future<String> _pathFoto(int periode, String jenis, String nomor) async {
    final dir = await _dir(jenis);
    return '${dir.path}/${_namaBerkas(periode, jenis, nomor)}';
  }

  /// Salin foto/video bukti ke folder per-tipe sebagai
  /// `202607_stand_00700800867.jpg`, dst. Cache image picker bisa dibersihkan
  /// OS kapan saja; salinan ini yang jadi path utama (diunggah). Kembalikan
  /// path salinan, atau null bila gagal.
  Future<String?> simpanSalinanFoto({
    required String jenis,
    required int periode,
    required String nomorLangganan,
    required String sumberPath,
  }) async {
    try {
      final sumber = File(sumberPath);
      if (!await sumber.exists()) return null;
      final tujuan = await _pathFoto(periode, jenis, nomorLangganan);
      await sumber.copy(tujuan);
      return tujuan;
    } on Object {
      return null;
    }
  }

  // ── Meta pembacaan (restore) + CSV catatan (impor teks) ─────────────────

  Future<Directory> _dirMeta(int periode) async => _dir('.meta/$periode');

  /// Tulis meta pembacaan — SELURUH field + metadata (bahan restore), lalu
  /// regenerasi CSV catatan periode itu supaya ringkasan teks selalu sinkron.
  Future<void> simpanCatatan({
    required int periode,
    required String nomorLangganan,
    required Map<String, dynamic> data,
  }) async {
    try {
      final dir = await _dirMeta(periode);
      final berkas = File('${dir.path}/$nomorLangganan.json');
      await berkas.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
      await _tulisCsvCatatan(periode);
    } on Object {
      // sengaja ditelan — lihat doc kelas.
    }
  }

  /// Regenerasi `catatan/<periode>_catatan.csv` dari seluruh meta periode itu.
  /// Satu baris per pembacaan — inilah yang diimpor sebagai "note/teks" di web.
  Future<void> _tulisCsvCatatan(int periode) async {
    final metaDir = await _dirMeta(periode);
    if (!await metaDir.exists()) return;
    const kolom = [
      'periode',
      'nomorLangganan',
      'nomorMeter',
      'ruteKode',
      'standAwal',
      'standAkhir',
      'pemakaianLalu',
      'kondisi',
      'isSegel',
      'usulanPerubahan',
      'notelpBaru',
      'latCatat',
      'longCatat',
      'namaPetugas',
      'tanggalCatat',
    ];
    final baris = <String>[kolom.map(_csvSel).join(',')];
    await for (final f in metaDir.list()) {
      if (f is! File || !f.path.endsWith('.json')) continue;
      try {
        final d = (jsonDecode(await f.readAsString()) as Map).cast<String, dynamic>();
        baris.add(kolom.map((k) => _csvSel(d[k])).join(','));
      } on Object {
        continue; // meta korup — lewati baris
      }
    }
    final csvDir = await _dir('catatan');
    await File('${csvDir.path}/${periode}_catatan.csv')
        .writeAsString('${baris.join('\r\n')}\r\n');
  }

  /// Eskape satu sel CSV (RFC 4180): bungkus tanda kutip bila mengandung
  /// koma/kutip/baris-baru, gandakan kutip di dalam.
  String _csvSel(Object? v) {
    if (v == null) return '';
    final s = '$v';
    if (s.contains(RegExp('[",\r\n]'))) return '"${s.replaceAll('"', '""')}"';
    return s;
  }

  /// Tandai satu pembacaan sudah aman di server (penanda kosong `.terunggah`)
  /// — dipakai pemulihan untuk melewati pembacaan yang sudah terunggah.
  Future<void> tandaiTerunggah(int periode, String nomorLangganan) async {
    try {
      final dir = await _dirMeta(periode);
      await File('${dir.path}/$nomorLangganan.terunggah').writeAsString('');
    } on Object {
      // ditelan.
    }
  }

  /// Seluruh bundel cadangan di perangkat (untuk layar Cadangan & pemulihan).
  /// Dibangun dari meta pembacaan; foto ditemukan lewat konvensi nama di
  /// folder per-tipe.
  Future<List<BundelPembacaan>> daftarBundel() async {
    try {
      final metaRoot = await _dir('.meta');
      if (!await metaRoot.exists()) return const [];
      final hasil = <BundelPembacaan>[];
      await for (final entriPeriode in metaRoot.list()) {
        if (entriPeriode is! Directory) continue;
        final periode = int.tryParse(entriPeriode.path.split(Platform.pathSeparator).last);
        if (periode == null) continue;
        await for (final entri in entriPeriode.list()) {
          if (entri is! File || !entri.path.endsWith('.json')) continue;
          final nomor = entri.uri.pathSegments.last.replaceAll('.json', '');
          Map<String, dynamic> data;
          try {
            data = (jsonDecode(await entri.readAsString()) as Map).cast<String, dynamic>();
          } on Object {
            continue; // meta korup — lewati
          }
          final foto = <String, String>{};
          for (final jenis in _semuaJenis) {
            final f = File(await _pathFoto(periode, jenis, nomor));
            if (await f.exists()) foto[jenis] = f.path;
          }
          hasil.add(BundelPembacaan(
            periode: periode,
            nomorLangganan: nomor,
            data: data,
            fotoPaths: foto,
            terunggah: await File('${entriPeriode.path}/$nomor.terunggah').exists(),
          ));
        }
      }
      hasil.sort((a, b) => b.periode.compareTo(a.periode));
      return hasil;
    } on Object {
      return const [];
    }
  }

  /// Zip layout IMPORTABLE (folder foto per-tipe + catatan CSV) ke berkas temp
  /// untuk dibagikan/diimpor di web. `.meta` & `log` TIDAK disertakan (internal
  /// restore, bukan bahan impor). Kembalikan path ZIP, atau null bila kosong.
  Future<String?> eksporZip() async {
    try {
      final base = await _base();
      if (!await base.exists()) return null;
      final subImportable = [..._semuaJenis, 'catatan'];
      final encoder = ZipFileEncoder();
      final tmp = await getTemporaryDirectory();
      final cap = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
      final path = '${tmp.path}/tirtawening-backup-$cap.zip';
      encoder.create(path);
      var adaIsi = false;
      for (final sub in subImportable) {
        final dir = Directory('${base.path}/$sub');
        if (!await dir.exists()) continue;
        if (await dir.list().isEmpty) continue;
        adaIsi = true;
        // includeDirName: entri jadi `stand/…`, `catatan/…` — bentuk yang
        // diurai server saat impor.
        await encoder.addDirectory(dir, includeDirName: true);
      }
      await encoder.close();
      if (!adaIsi) {
        try {
          await File(path).delete();
        } on Object {
          // abaikan
        }
        return null;
      }
      return path;
    } on Object {
      return null;
    }
  }

  /// Publikasikan foto bukti + CSV catatan ke koleksi publik lewat MediaStore
  /// (`Pictures/tirtawening/backup/<tipe>` & `Download/tirtawening/backup/
  /// catatan`) supaya TERLIHAT di Galeri/File TANPA izin runtime (Android
  /// 10+). Idempoten (nama+path sama tidak digandakan). Video sengaja tidak
  /// ikut (besar; tetap ada di app-external & ZIP). Kembalikan jumlah berkas
  /// yang dipublikasikan/sudah ada; 0 bila platform tak mendukung.
  Future<int> publikasiKeGaleri() async {
    const galeri = PublikasiGaleri();
    var n = 0;
    try {
      final base = await _base();
      for (final jenis in ['stand', 'segel', 'rumah']) {
        final dir = Directory('${base.path}/$jenis');
        if (!await dir.exists()) continue;
        await for (final f in dir.list()) {
          if (f is! File || !f.path.endsWith('.jpg')) continue;
          final ok = await galeri.simpan(
            bytes: await f.readAsBytes(),
            displayName: f.uri.pathSegments.last,
            relativePath: 'Pictures/tirtawening/backup/$jenis',
            mime: 'image/jpeg',
            isImage: true,
          );
          if (ok) n++;
        }
      }
      final catatan = Directory('${base.path}/catatan');
      if (await catatan.exists()) {
        await for (final f in catatan.list()) {
          if (f is! File || !f.path.endsWith('.csv')) continue;
          final ok = await galeri.simpan(
            bytes: await f.readAsBytes(),
            displayName: f.uri.pathSegments.last,
            relativePath: 'Download/tirtawening/backup/catatan',
            mime: 'text/csv',
            isImage: false,
          );
          if (ok) n++;
        }
      }
    } on Object {
      // publikasi galeri gagal tak boleh menjatuhkan ekspor.
    }
    return n;
  }

  /// Satu baris pipe-delimited per penyimpanan catat (log lapangan cepat-baca):
  /// `nomor|stand|kondisi|petugas|longlat|waktu|`.
  Future<void> catatLog({
    required int periode,
    required String nomorLangganan,
    required String standAkhir,
    required String kondisi,
    String? petugas,
    String? longlat,
  }) async {
    try {
      final dir = await _dirLog();
      final berkas = File('${dir.path}/catat_$periode.txt');
      final baris = [
        nomorLangganan,
        standAkhir,
        kondisi,
        petugas ?? '',
        longlat ?? '',
        DateTime.now().toIso8601String(),
        '',
      ].join('|');
      await berkas.writeAsString('$baris\n', mode: FileMode.append);
    } on Object {
      // ditelan.
    }
  }

  /// Catat kejadian tak terduga.
  Future<void> catatError(String pesan) async {
    try {
      final dir = await _dirLog();
      final berkas = File('${dir.path}/error.log');
      await berkas.writeAsString(
        '${DateTime.now().toIso8601String()} $pesan\n',
        mode: FileMode.append,
      );
    } on Object {
      // ditelan.
    }
  }
}
