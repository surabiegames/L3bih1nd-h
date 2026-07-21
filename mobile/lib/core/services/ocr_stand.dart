import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Baca angka stand dari foto meter — padanan `MainOcrActivity` Aurora
/// (dulu Tesseract di kamera khusus, kini ML Kit on-device dari foto stand
/// yang memang sudah diambil petugas: satu jepretan = bukti + angka).
///
/// PENTING: jalankan pada foto ASLI dari kamera, SEBELUM kompres +
/// watermark [KompresFoto] — cap waktu pada watermark berisi digit yang
/// akan ikut terbaca dan mengacaukan hasil.
class OcrStand {
  const OcrStand();

  /// ML Kit hanya tersedia di Android/iOS — di desktop/web tombol OCR
  /// tidak ditampilkan (pola guard yang sama dengan scanner QR).
  static bool get tersedia => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Kandidat angka stand terbaik pada foto: barisan digit terpanjang
  /// (3–8 digit — register meter air PDAM 4–7 digit ditambah toleransi).
  /// null = tidak ada digit terbaca / OCR gagal — alur catat manual tetap
  /// jalan, ini hanya bantuan.
  Future<String?> bacaAngka(String path) async {
    if (!tersedia) return null;
    final pengenal = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final hasil = await pengenal.processImage(InputImage.fromFilePath(path));
      String? terbaik;
      for (final blok in hasil.blocks) {
        for (final baris in blok.lines) {
          // OCR meter kerap menyisipkan pemisah (spasi, titik) di antara
          // roda angka — buang non-digit per baris lalu cari run digit.
          final padat = baris.text.replaceAll(RegExp(r'[^0-9]'), '');
          for (final m in RegExp(r'\d{3,8}').allMatches(padat)) {
            final kandidat = m.group(0)!;
            if (terbaik == null || kandidat.length > terbaik.length) {
              terbaik = kandidat;
            }
          }
        }
      }
      return terbaik;
    } on Object {
      return null; // OCR gagal bukan penghalang — petugas mengetik manual.
    } finally {
      await pengenal.close();
    }
  }
}
