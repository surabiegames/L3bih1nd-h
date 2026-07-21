import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';

/// Satu bundel cadangan pembacaan (folder per pelanggan per periode).
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

  /// Isi catatan.json — seluruh field pembacaan + metadata.
  final Map<String, dynamic> data;

  /// jenis (stand/segel/rumah/video) → path berkas lokal yang ADA.
  final Map<String, String> fotoPaths;

  /// true = sudah pernah sukses diunggah ke server (penanda `.terunggah`).
  final bool terunggah;
}

/// Backup data baca meter di internal storage — pengaman hasil kerja lapangan
/// bila aplikasi crash / DB lokal korup / perangkat rusak. Setiap catat menulis
/// BUNDEL LENGKAP per pembacaan (tiruan folder backup Aurora), termapping rapi:
///
/// ```
/// <AppDocuments>/backup/pembacaan/<periode>/<nomorLangganan>/
///     catatan.json   # SELURUH field pembacaan + metadata
///     stand.jpg  segel.jpg  rumah.jpg  video.mp4
///     .terunggah     # ada = sudah aman di server
/// ```
///
/// Bundel INDEPENDEN dari antrean SQLite, jadi bisa dipakai memulihkan hasil
/// kerja (ke antrean upload) atau diekspor sebagai ZIP untuk diimpor di web.
///
/// SEMUA method menelan errornya sendiri — backup tidak boleh menjatuhkan alur
/// utama; kegagalan backup bukan kegagalan catat.
class BackupLokal {
  BackupLokal._();

  static final BackupLokal instance = BackupLokal._();

  static const _jenisFoto = {'stand', 'segel', 'rumah'};

  /// Root backup. PENTING: pakai EXTERNAL storage aplikasi
  /// (`/storage/emulated/0/Android/data/<pkg>/files/backup` di Android) —
  /// TERJANGKAU lewat USB/file manager tanpa izin khusus, dan berkasnya bisa
  /// diambil walau aplikasi CRASH saat dibuka (beda dari
  /// getApplicationDocumentsDirectory yang privat di /data/data, butuh root).
  /// Jatuh ke documents dir hanya bila external tak tersedia (iOS/desktop).
  Future<Directory> _base() async {
    Directory? ext;
    try {
      ext = await getExternalStorageDirectory();
    } on Object {
      ext = null;
    }
    final root = ext ?? await getApplicationDocumentsDirectory();
    return Directory('${root.path}/backup');
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

  Future<Directory> _dirLog() async {
    final dir = Directory('${(await _base()).path}/log');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Root semua bundel pembacaan.
  Future<Directory> _dirPembacaan() async {
    return Directory('${(await _base()).path}/pembacaan');
  }

  /// Folder satu pembacaan (dibuat bila belum ada).
  Future<Directory> _dirBundel(int periode, String nomorLangganan) async {
    final root = await _dirPembacaan();
    final dir = Directory('${root.path}/$periode/$nomorLangganan');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  String _namaBerkasFoto(String jenis) => jenis == 'video' ? 'video.mp4' : '$jenis.jpg';

  /// Salin foto/video bukti ke folder bundel pembacaan sebagai
  /// `stand.jpg`/`segel.jpg`/`rumah.jpg`/`video.mp4`. Cache image picker bisa
  /// dibersihkan OS kapan saja; salinan ini yang jadi path utama (diunggah).
  /// Kembalikan path salinan, atau null bila gagal.
  Future<String?> simpanSalinanFoto({
    required String jenis,
    required int periode,
    required String nomorLangganan,
    required String sumberPath,
  }) async {
    try {
      final sumber = File(sumberPath);
      if (!await sumber.exists()) return null;
      final dir = await _dirBundel(periode, nomorLangganan);
      final tujuan = '${dir.path}/${_namaBerkasFoto(jenis)}';
      await sumber.copy(tujuan);
      return tujuan;
    } on Object {
      return null;
    }
  }

  /// Tulis catatan.json — SELURUH field pembacaan + metadata. Ini "notes"
  /// yang bisa diimpor kembali di web bila hasil catat perlu direkonstruksi.
  Future<void> simpanCatatan({
    required int periode,
    required String nomorLangganan,
    required Map<String, dynamic> data,
  }) async {
    try {
      final dir = await _dirBundel(periode, nomorLangganan);
      final berkas = File('${dir.path}/catatan.json');
      await berkas.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    } on Object {
      // sengaja ditelan — lihat doc kelas.
    }
  }

  /// Tandai satu bundel sudah aman di server (penanda kosong `.terunggah`) —
  /// dipakai pemulihan untuk melewati pembacaan yang sudah terunggah.
  Future<void> tandaiTerunggah(int periode, String nomorLangganan) async {
    try {
      final dir = await _dirBundel(periode, nomorLangganan);
      await File('${dir.path}/.terunggah').writeAsString('');
    } on Object {
      // ditelan.
    }
  }

  /// Seluruh bundel cadangan di perangkat (untuk layar Cadangan & pemulihan).
  Future<List<BundelPembacaan>> daftarBundel() async {
    try {
      final root = await _dirPembacaan();
      if (!await root.exists()) return const [];
      final hasil = <BundelPembacaan>[];
      await for (final entriPeriode in root.list()) {
        if (entriPeriode is! Directory) continue;
        final periode = int.tryParse(entriPeriode.path.split(Platform.pathSeparator).last);
        if (periode == null) continue;
        await for (final entriPelanggan in entriPeriode.list()) {
          if (entriPelanggan is! Directory) continue;
          final nomor = entriPelanggan.path.split(Platform.pathSeparator).last;
          final berkasCatatan = File('${entriPelanggan.path}/catatan.json');
          if (!await berkasCatatan.exists()) continue;
          Map<String, dynamic> data;
          try {
            data = (jsonDecode(await berkasCatatan.readAsString()) as Map).cast<String, dynamic>();
          } on Object {
            continue; // catatan korup — lewati
          }
          final foto = <String, String>{};
          for (final jenis in [..._jenisFoto, 'video']) {
            final f = File('${entriPelanggan.path}/${_namaBerkasFoto(jenis)}');
            if (await f.exists()) foto[jenis] = f.path;
          }
          hasil.add(BundelPembacaan(
            periode: periode,
            nomorLangganan: nomor,
            data: data,
            fotoPaths: foto,
            terunggah: await File('${entriPelanggan.path}/.terunggah').exists(),
          ));
        }
      }
      hasil.sort((a, b) => b.periode.compareTo(a.periode));
      return hasil;
    } on Object {
      return const [];
    }
  }

  /// Zip SELURUH folder bundel (`pembacaan/…`) ke berkas temp untuk dibagikan/
  /// diimpor di web. Kembalikan path ZIP, atau null bila tak ada cadangan.
  Future<String?> eksporZip() async {
    try {
      final root = await _dirPembacaan();
      if (!await root.exists()) return null;
      final kosong = await root.list().isEmpty;
      if (kosong) return null;
      final tmp = await getTemporaryDirectory();
      final cap = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
      final path = '${tmp.path}/cadangan-baca-meter-$cap.zip';
      final encoder = ZipFileEncoder();
      encoder.create(path);
      // includeDirName: entri jadi `pembacaan/<periode>/<nomor>/…` — bentuk
      // yang diurai server saat impor.
      await encoder.addDirectory(root, includeDirName: true);
      await encoder.close();
      return path;
    } on Object {
      return null;
    }
  }

  /// Satu baris pipe-delimited per penyimpanan catat (log lapangan cepat-baca,
  /// format `catatTxt` Aurora): `nomor|stand|kondisi|petugas|longlat|waktu|`.
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

  /// Catat kejadian tak terduga (padanan `generateNoteOnSD`).
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
