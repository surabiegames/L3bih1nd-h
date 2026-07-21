import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Kompresi + watermark foto bukti — tiruan `ImageUtility.compressPhoto`
/// Aurora dengan angka yang sama persis (terbukti cukup tajam untuk membaca
/// angka stand di panel verifikasi, dan cukup kecil untuk sinyal lapangan):
///   1. resize ke lebar 600 px (rasio dipertahankan),
///   2. watermark teks kuning transparan: `yyyy-MM-dd HH:mm` + keterangan
///      (username petugas) di 2/3 tinggi foto — bukti foto diambil saat itu,
///      bukan daur ulang bulan lalu,
///   3. JPEG kualitas 80 (hasil puluhan–ratusan KB, bukan foto kamera 3–8 MB).
///
/// Pakai package `image` (Dart murni, tanpa platform channel) dan dijalankan
/// di isolate (`compute`) supaya UI tidak beku saat memproses.
class KompresFoto {
  const KompresFoto();

  static const _lebarTarget = 600;
  static const _kualitasJpeg = 80;

  /// Proses [sumberPath] dan tulis hasilnya ke [tujuanPath] (JPEG).
  /// Mengembalikan path tujuan; melempar bila berkas sumber tidak terbaca.
  /// [lebarTarget] menimpa 600 px bawaan; [watermark] false mematikan
  /// stempel waktu.
  ///
  /// Dua konteks yang butuh setelan berbeda:
  ///  * FOTO METER (petugas & lapor mandiri) — 600 px + watermark, angka
  ///    Aurora yang sudah terbukti terbaca di panel verifikasi, dan
  ///    stempel waktunya justru inti buktinya.
  ///  * FOTO PENGADUAN — lebih lebar & TANPA watermark: yang difoto bisa
  ///    kebocoran di ujung gang atau air keruh dalam ember, jadi detail
  ///    lebih berguna daripada stempel, dan teks kuning di tengah gambar
  ///    justru menutupi barang buktinya.
  Future<String> proses({
    required String sumberPath,
    required String tujuanPath,
    required String keterangan,
    int? lebarTarget,
    bool watermark = true,
  }) async {
    await compute(
      _kerjakan,
      _TugasKompres(
        sumberPath: sumberPath,
        tujuanPath: tujuanPath,
        keterangan: keterangan,
        lebarTarget: lebarTarget ?? _lebarTarget,
        watermark: watermark,
      ),
    );
    return tujuanPath;
  }
}

class _TugasKompres {
  const _TugasKompres({
    required this.sumberPath,
    required this.tujuanPath,
    required this.keterangan,
    required this.lebarTarget,
    required this.watermark,
  });

  final String sumberPath;
  final String tujuanPath;
  final String keterangan;
  final int lebarTarget;
  final bool watermark;
}

Future<void> _kerjakan(_TugasKompres tugas) async {
  final bytes = await File(tugas.sumberPath).readAsBytes();
  final mentah = img.decodeImage(bytes);
  if (mentah == null) {
    throw StateError(
      'Berkas bukan gambar yang bisa dibaca: ${tugas.sumberPath}',
    );
  }

  // bakeOrientation: terapkan rotasi EXIF sebelum resize — tanpa ini foto
  // portrait dari banyak kamera Android tampil miring di dashboard.
  var foto = img.bakeOrientation(mentah);
  if (foto.width > tugas.lebarTarget) {
    foto = img.copyResize(foto, width: tugas.lebarTarget);
  }

  if (!tugas.watermark) {
    await File(
      tugas.tujuanPath,
    ).writeAsBytes(img.encodeJpg(foto, quality: KompresFoto._kualitasJpeg));
    return;
  }

  final kini = DateTime.now();
  String dua(int v) => v.toString().padLeft(2, '0');
  final stempel =
      '${kini.year}-${dua(kini.month)}-${dua(kini.day)} ${dua(kini.hour)}:${dua(kini.minute)}';
  final warna = img.ColorRgba8(255, 255, 0, 180);
  final x = foto.width ~/ 3;
  final y = (foto.height ~/ 3) * 2;
  img.drawString(foto, stempel, font: img.arial24, x: x, y: y, color: warna);
  img.drawString(
    foto,
    tugas.keterangan,
    font: img.arial24,
    x: x,
    y: y + 30,
    color: warna,
  );

  await File(
    tugas.tujuanPath,
  ).writeAsBytes(img.encodeJpg(foto, quality: KompresFoto._kualitasJpeg));
}
