import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Backup teks & salinan foto di penyimpanan internal aplikasi — tiruan pola
/// `DirUtil.catatTxt()` / `generateNoteOnSD()` / folder `backup_*` Aurora:
/// setiap penyimpanan catat meninggalkan jejak yang bisa dibaca manusia,
/// sehingga kalau database lokal korup atau aplikasi crash, hasil kerja
/// seharian petugas masih bisa direkonstruksi.
///
/// SEMUA method menelan errornya sendiri (catat ke debug saja) — backup tidak
/// boleh menjatuhkan alur utama; kegagalan backup bukan kegagalan catat.
class BackupLokal {
  BackupLokal._();

  static final BackupLokal instance = BackupLokal._();

  Future<Directory> _direktori(String sub) async {
    final dok = await getApplicationDocumentsDirectory();
    final dir = Directory('${dok.path}/backup/$sub');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Satu baris pipe-delimited per penyimpanan catat, per periode — format
  /// sama dengan `catatTxt` Aurora supaya kebiasaan membaca log lapangan
  /// tidak berubah:
  /// `nomorLangganan|standAkhir|kondisi|petugas|longlat|waktu|`
  Future<void> catatLog({
    required int periode,
    required String nomorLangganan,
    required String standAkhir,
    required String kondisi,
    String? petugas,
    String? longlat,
  }) async {
    try {
      final dir = await _direktori('log');
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
      // sengaja ditelan — lihat doc kelas.
    }
  }

  /// Catat kejadian tak terduga (padanan `generateNoteOnSD`): bahan
  /// investigasi saat petugas melapor "tadi errornya begini".
  Future<void> catatError(String pesan) async {
    try {
      final dir = await _direktori('log');
      final berkas = File('${dir.path}/error.log');
      await berkas.writeAsString(
        '${DateTime.now().toIso8601String()} $pesan\n',
        mode: FileMode.append,
      );
    } on Object {
      // sengaja ditelan.
    }
  }

  /// Salin foto bukti ke folder backup per jenis (backup_stand/segel/rumah
  /// ala Aurora) dengan nama deterministik `periode_jenis_nomor.jpg` —
  /// cache image picker bisa dibersihkan OS kapan saja, salinan ini tidak.
  /// Mengembalikan path salinan, atau null bila gagal.
  Future<String?> simpanSalinanFoto({
    required String jenis,
    required int periode,
    required String nomorLangganan,
    required String sumberPath,
  }) async {
    try {
      final sumber = File(sumberPath);
      if (!await sumber.exists()) return null;
      final dir = await _direktori('foto_$jenis');
      final tujuan = '${dir.path}/${periode}_${jenis}_$nomorLangganan.jpg';
      await sumber.copy(tujuan);
      return tujuan;
    } on Object {
      return null;
    }
  }
}
