Act as an Elite Enterprise Flutter Developer and Software Architect. I need you to scaffold and build a production-grade multi-tenant Utility Supporting Application (Mobile/Tablet focus) that bridges our web admin system and the end-users. 

The application must use the 'shadcn_ui' package exclusively for the design system, strictly adhering to the Shadcn UI Docs styling principles (Slate/Zinc theme, crisp borders, professional padding, and clear typographic hierarchy).

### 1. SYSTEM ARCHITECTURE & FOLDER STRUCTURE
Generate a Feature-First, Clean Architecture directory structure under `lib/`. Do not use placeholders. Create actual files with standard configurations:
- `lib/core/theme/`: ShadTheme configurations (Dark/Light mode using ShadThemeData).
- `lib/core/network/`: Base API Client setup for syncing data with the Main Web App.
- `lib/features/public/`: Modules for Cek Tagihan, Lapor Meter, and Lapor Pengaduan.
- `lib/features/staff/`: Supporting modules for Staff/Field Officers: Pembacaan Meter (Verification/Manual Entry) and Laporan Pengaduan (Handling Queue).

### 2. CORE WIDGET & SCREEN REQUIREMENTS (SHADCN UI SPECIFIC)
Please generate complete, production-ready Flutter widget files for the following screens:

A. PUBLIC APP MODULES:
1. Cek Tagihan Screen:
   - Implement a form using `ShadInput` for Customer ID validation.
   - Display billing history and breakdown using a structured list of `ShadCard` with clear typography, status indicators via `ShadBadge` (Lunas, Belum Bayar), and details toggle.
2. Lapor Meter Mandiri Screen:
   - A highly functional form containing `ShadInput` (numeric only for current meter reading figures).
   - An elegant placeholder box using custom borders for Image Upload (Camera input indicator).
   - Validation handling and a submission trigger via `ShadButton.text` that spawns a professional confirmation `ShadDialog`.
3. Lapor Pengaduan Screen:
   - Form utilizing `ShadSelect` for choosing complaint categories (e.g., Kebocoran, Akurasi Meter, Gangguan Aliran).
   - Description area using `ShadInput` configured for multiline/textarea, paired with `ShadButton` for submission.

B. STAFF/OFFICER APP MODULES (Supporting the Web App):
1. Pembacaan & Verifikasi Meter Screen:
   - A dual-tab view using `ShadTabs` split into: "Antrean Verifikasi (Self-Reports)" and "Input Manual Lapangan".
   - The queue list must display incoming consumer readings with target discrepancies flags using specific `ShadBadge` colors (Alert/Destructive for extreme jumps, Success for normal).
2. Laporan Pengaduan Staff Management Screen:
   - A high-density interface displaying active tickets assigned to the officer.
   - Include rapid action buttons using `ShadIconButton` or context menus via `ShadPopover` to transition ticket status (Open -> In Progress -> Resolved).

### 3. TECHNICAL SPECIFICATIONS & EXECUTION STEP
- Initialize the application in `lib/main.dart` wrapping the root widget within `ShadApp` instead of MaterialApp, pre-configured with modern theme attributes.
- Ensure all input components are fully validated with clean state management hooks or standard TextEditingControllers.
- Write strict TypeScript-equivalent type-safe Dart models for: `BillModel`, `MeterReadingModel`, and `ComplaintTicketModel`.

Please execute this comprehensively. Start by modifying 'pubspec.yaml' to ensure 'shadcn_ui' is present, then generate the base 'main.dart', followed by the core data models, and finally build out the individual features step-by-step. Do not omit code or use "// TODO: implement".

---

## Status implementasi (2026-07-17, revisi 2: dua aplikasi terpisah)

Satu codebase menghasilkan **dua aplikasi terpisah** (flavor Android dengan
applicationId, nama, dan ikon launcher berbeda):

| | Publik — "Tirtawening" | Petugas — "Tirtawening Petugas" |
|---|---|---|
| applicationId | `id.tirtawening.publik` | `id.tirtawening.petugas` |
| Entrypoint | `lib/main_publik.dart` | `lib/main_petugas.dart` |
| Ikon | tetes air, biru air | tetes air + busur gauge, slate gelap |
| Isi | Cek Tagihan, Lapor Meter, Lapor Pengaduan, Lacak Tiket | Portal (ruang kerja Pencatat Meter / Petugas Gangguan), Baca Meter (RBM), Verifikasi Laporan, Tugas Gangguan, Info Tagihan |

Desain modul petugas mengikuti pola industri aplikasi catat meter
PDAM/utilitas (RBM rute baca meter, stand lalu + validasi deviasi sebelum
kirim, kondisi meter/kelainan, foto bukti) dan dipetakan langsung ke skema
backend `LaporanHarianPetugas` (kolom `persentase`, `kondisi`,
`fotoStandUrl`/`fotoSegelUrl`/`fotoRumahUrl`, relasi `Rute`).

### Menjalankan

```
# Pengembangan cepat (Linux/desktop, mode demo tanpa backend)
flutter run -d linux -t lib/main_publik.dart
flutter run -d linux -t lib/main_petugas.dart

# Android (dua APK terpisah)
flutter run  --flavor publik  -t lib/main_publik.dart
flutter run  --flavor petugas -t lib/main_petugas.dart
flutter build apk --flavor petugas -t lib/main_petugas.dart

# Terhubung backend LOKAL (laptop harus menyala & sejaringan dengan HP;
# `next dev` WAJIB -H 0.0.0.0, kalau tidak ia hanya mendengarkan localhost).
# IP-nya juga harus terdaftar di android/app/src/main/res/xml/
# network_security_config.xml — Android memblokir HTTP polos sejak API 28.
flutter run -t lib/main_petugas.dart --dart-define=API_BASE_URL=http://<ip>:3000

# Terhubung backend TER-DEPLOY (default yang dipakai untuk APK uji).
# HTTPS, jadi TIDAK bergantung network_security_config maupun laptop menyala.
flutter build apk --flavor publik  -t lib/main_publik.dart  --release \
  --dart-define=API_BASE_URL=https://perumda.vercel.app
flutter build apk --flavor petugas -t lib/main_petugas.dart --release \
  --dart-define=API_BASE_URL=https://perumda.vercel.app
```

- Mode demo (tanpa `API_BASE_URL`): data contoh dalam memori; nomor
  langganan demo `00000100119`; nomor tiket demo format `TW-YYMM-XXXXXX`.
- **URL backend TIDAK ditanam sebagai nilai bawaan di `ApiConfig`** —
  sengaja. Tanpa `--dart-define`, aplikasi HARUS jatuh ke mode demo:
  seluruh `test/widget_test.dart` (25 uji) menjalankan `PublikApp`/
  `PetugasApp` apa adanya dan bergantung pada repository demo. Memberi
  `defaultValue` pada `String.fromEnvironment` akan membuat uji-uji itu
  menembak server sungguhan. URL produksi tinggal di README ini dan di
  perintah build, bukan di dalam kode.
- Build Linux desktop TIDAK butuh `libsecret-1-dev`: implementasi resmi
  `flutter_secure_storage_linux` digantikan stub lokal
  (`packages/flutter_secure_storage_linux_stub`, dipasang lewat
  `dependency_overrides`) yang menyimpan ke JSON 0600 di XDG data dir.
  Dev-only — jangan rilis build Linux ke pengguna; Android/iOS tetap
  memakai Keystore/Keychain asli.
- Logo DI DALAM aplikasi (hero beranda publik, portal & login petugas):
  widget `LogoPerusahaan` (`core/widgets/logo_perusahaan.dart`) yang
  menampilkan `assets/images/logo.png` — salinan 1:1 `public/images/
  logo.png` — sebagai SIGNATURE murni tanpa chip/kontainer: kedalaman
  dari bayangan ambien Slate + halo Sky tipis khusus latar gelap
  (menggantikan ikon tetes air generik, lalu chip putih, 2026-07-19).
  Kalau logo berubah: salin ulang file + jalankan ulang pipeline ikon
  launcher di bawah.
- Ikon launcher: sumbernya SATU-SATUNYA `public/images/logo.png` (logo
  resmi perusahaan, di root repo Next.js — bukan diciptakan ulang di
  mobile/). `python3 mobile/scripts/generate_launcher_icons.py` menyalinnya
  jadi 4 PNG flat gaya macOS (tanpa gradien/drop-shadow) di
  `assets/icons/` — publik latar putih, petugas latar biru asli logo
  (`#0F75BC`), supaya kedua app tetap satu keluarga visual tapi beda
  sekilas di home screen. Lalu regenerate aset per-platform:
  `dart run flutter_launcher_icons -f flutter_launcher_icons-publik.yaml`
  dan `-f flutter_launcher_icons-petugas.yaml` (keduanya SEBENARNYA
  memproses dua flavor sekaligus — flutter_launcher_icons mendeteksi
  productFlavors dari Gradle dan membaca kedua file yaml berdasarkan nama,
  `-f` di sini kosmetik). `ios: false` di kedua yaml SENGAJA: proyek ini
  belum di-scaffold dengan platform iOS (`flutter create --platforms=ios .`
  belum pernah dijalankan, cek `.metadata`) — set true hanya setelah itu
  dijalankan dengan sengaja.
- Uji: `flutter test` (7 uji alur kedua aplikasi), `flutter analyze` bersih.

### Struktur

```
lib/
  main.dart / main_publik.dart / main_petugas.dart
  app/            # bootstrap + akar ShadApp per aplikasi
  core/           # theme (+aksen/gradien), network, models, utils,
                  # widgets (AppScaffold, GlassPanel/PremiumBackground,
                  # SquircleIcon/LaunchpadItem, BrandHeader, MenuTile, …)
  features/
    public/       # home launcher, cek_tagihan, lapor_meter, pengaduan (+lacak)
    staff/        # portal (pintu masuk), dashboard (home ruang kerja),
                  # baca_meter (rute+catat), pembacaan (verifikasi),
                  # pengaduan (tiket gangguan)
```

### Modul Pencatat Meter — data real (2026-07-18)

Aplikasi petugas kini penuh terhubung backend (mode API, `API_BASE_URL`
di-set):

- **Login Bearer token**: layar login (username/email + password →
  `POST /api/mobile/auth/login`), token di `flutter_secure_storage`
  (`core/auth/sesi_petugas.dart`), dipulihkan saat app dibuka TANPA
  panggilan jaringan (lapangan boleh tanpa sinyal); 401 dari `/api/v1`
  otomatis kembali ke login (`ApiClient.onUnauthorized`). Logout di
  Portal. Mode demo tetap tanpa login.
- **Unduh rute (RBM)**: `GET /api/v1/laporan-harian/rute-saya` — rute yang
  ditugaskan admin ke pencatat (web: menu Pencatat, kolom `ruteId`),
  target = jumlah pelanggan, stand lalu + pemakaian lalu resmi per
  pelanggan, status sudah dicatat periode berjalan. Paket di-cache di
  `shared_preferences` (`rbm.cache`) sehingga rute tetap terbuka offline
  (chip "Offline" + waktu terunduh tampil di kartu progres).
- **Catat lengkap sesuai skema**: 22 nilai `KondisiCatat` (label selaras
  dashboard web), `KategoriPembacaan` ONSITE/OFFSITE, `tanggalCatat`
  otomatis, 3 foto bukti (stand/segel/rumah) via `image_picker`
  kamera/galeri → `POST /laporan-harian/foto` (magic bytes divalidasi
  server) → URL ikut `POST /laporan-harian`. `pencatatId` diisi server
  dari akun token.
- **Antrean offline (outbox)**: hasil catat saat tanpa sinyal tersimpan di
  perangkat (`rbm.antrean`, termasuk path foto) dan dikirim otomatis
  setiap kali layar Baca Meter dimuat ulang; baris antre tampil sebagai
  tercatat (chip "N antre"). 409/400 saat sinkron = sudah tercatat di
  server → entri dibuang, tidak dikirim ulang selamanya.

### Palet master 5 warna (2026-07-19)

Seluruh warna kedua aplikasi kini DIKUNCI ke
`lib/core/theme/master_palette.dart` (padanan "CSS global" Next.js versi
Dart): **Emerald 500** (aksi utama/sukses), **Teal 300** (aksen/highlight),
**Sky 400** (info/tautan/hero), **Slate 400** (netral: teks redup, border,
chrome), **Rose 500** (destruktif + peringatan — amber/violet/cyan/navy
lama DIHAPUS dari palet). Aturan: warna apa pun harus master-nya langsung
atau turunan tonal serumpun yang terdaftar di file itu; tema shadcn
(`app_theme.dart`), token iOS (`ios_style.dart`), dan `pdam_palette.dart`
semuanya sudah alias ke sana — JANGAN menulis hex baru di widget/layar.
Pengecualian satu-satunya: berkas logo resmi (warna logo tidak ikut
palet UI).

### Akun warga + langganan tertaut (2026-07-19)

- **Daftar WAJIB nomor langganan** (11 digit, dengan kartu pratinjau
  "ini pelanggan Anda?" via `GET /api/public/pelanggan/:nomor`) — nomor
  pertama otomatis jadi langganan UTAMA akun. Kontrak & endpoint lengkap
  di FLUTTER.md ("Langganan warga").
- **Beranda ber-biodata**: saat login, kartu "KARTU LANGGANAN" (gradien
  navy senada hero) menampilkan nama, nomor, alamat (disamarkan server),
  status, golongan, dan total tunggakan; bisa DIGESER bila akun menautkan
  lebih dari satu nomor (maks. 5). `features/public/langganan/`.
- **Kelola nomor langganan** (dari beranda "Kelola" atau tab Akun):
  tambah/lepas tautan, jadikan utama; tautan terakhir tidak bisa dilepas
  (aturan server). Cache sesi `LanggananSayaCache` juga dipakai PREFILL
  nomor utama di Cek Tagihan / Lapor Meter / Pengaduan + nama pelapor.
- **Shortcut layanan gaya launcher**: grid 4 kolom ikon squircle + nama
  di bawahnya (LaunchpadItem) — tanpa kartu/kontainer putih (keputusan
  desain 2026-07-19, menggantikan kartu putih ber-deskripsi).
- **Mode demo kini bisa "masuk"**: kredensial apa pun diterima
  (`SesiWarga._masukDemo`, tanpa storage) supaya alur beranda ber-biodata
  & kelola langganan bisa dijajal tanpa backend.

### Belum dikerjakan (sengaja, butuh keputusan/paket tambahan)

- `google_sign_in` (login Google mobile) — butuh OAuth client Android +
  env backend `AUTH_GOOGLE_MOBILE_IDS`; login password sudah jalan.
- Antrean offline memakai `shared_preferences` (JSON) — cukup untuk satu
  rute; migrasi ke drift/sqlite baru perlu bila datanya membesar.
- GPS (`geolocator`) untuk `/pelanggan/near` & koordinat kunjungan.
