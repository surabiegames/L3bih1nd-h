# Aturan R8/ProGuard untuk build RELEASE.
#
# KENAPA ADA: `flutter build apk --release` gagal di task
# :app:minifyPublikReleaseWithR8 dengan "Missing classes detected while
# running R8" — google_mlkit_text_recognition (OCR angka meter di app
# petugas) memanggil pengenal teks Mandarin/Devanagari/Jepang/Korea di
# TextRecognizer.initialize(), padahal pubspec hanya menarik varian LATIN.
# Kelas-kelas itu memang TIDAK ADA di APK, dan itu benar: menariknya hanya
# untuk memuaskan R8 akan menambah beban tanpa dipakai (aplikasi ini
# membaca angka meter, bukan aksara Han).
#
# -dontwarn (bukan -keep) tepat di sini justru karena kelasnya tidak ada:
# tidak ada yang bisa dipertahankan. Yang dimatikan hanyalah peringatan
# atas referensi yang tidak pernah dieksekusi — cabang initialize() untuk
# aksara tersebut tidak pernah dipanggil kode Dart mana pun di repo ini.
#
# Isinya persis file yang dihasilkan AGP sendiri di
# build/app/outputs/mapping/<flavor>Release/missing_rules.txt — disalin ke
# sini agar ikut ter-commit, bukan diketik ulang dari tebakan.
#
# BERLAKU UNTUK KEDUA FLAVOR: publik tidak memakai OCR sama sekali, tapi
# plugin-nya tetap ikut tertaut karena satu codebase = satu daftar
# dependensi. Jadi build publik pun gagal tanpa aturan ini.
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions
