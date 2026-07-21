import 'package:flutter/widgets.dart'
    show Brightness, Color, BoxConstraints, EdgeInsets, BorderRadius, Radius;
import 'package:shadcn_ui/shadcn_ui.dart';

import 'master_palette.dart';

/// Ukuran dialog SERAGAM untuk seluruh app (publik & petugas). Default
/// shadcn_ui = maxWidth 512 + padding 24, yang di layar ponsel jadi mepet ke
/// tepi kiri/kanan dan terasa terlalu besar. Di sini dibuat proporsional:
/// lebar dibatasi 380 (memberi margin sisi di HP), padding 20, sudut 16.
/// Dipakai di primaryDialogTheme & alertDialogTheme kedua tema.
const _dialogThemeProporsional = ShadDialogTheme(
  constraints: BoxConstraints(maxWidth: 380),
  padding: EdgeInsets.all(20),
  radius: BorderRadius.all(Radius.circular(16)),
);

/// Tema aplikasi: skema warna dari PALET MASTER 5 warna
/// (core/theme/master_palette.dart — Emerald 500 / Teal 300 / Sky 400 /
/// Slate 400 / Rose 500, keputusan produk 2026-07-19; preset Slate/Zinc
/// bawaan shadcn_ui maupun warna logo lama TIDAK lagi dipakai sebagai
/// acuan). Satu-satunya sumber ShadThemeData — jangan membuat
/// ShadThemeData lain di layar.
///
/// Ini yang membuat SETIAP ShadButton/ShadCard/ShadInput/ShadBadge/dst di
/// KEDUA aplikasi (publik & petugas) otomatis memakai palet master tanpa
/// perlu menimpa warna satu per satu di tiap layar.
abstract final class AppTheme {
  static ShadThemeData light() => ShadThemeData(
    brightness: Brightness.light,
    colorScheme: const ShadColorScheme(
      background: Color(0xFFFFFFFF),
      foreground: Color(MasterPalette.slate900),
      card: Color(0xFFFFFFFF),
      cardForeground: Color(MasterPalette.slate900),
      popover: Color(0xFFFFFFFF),
      popoverForeground: Color(MasterPalette.slate900),
      // Primary = Emerald 500 — tombol/aksi utama di seluruh app.
      primary: Color(MasterPalette.emerald),
      primaryForeground: Color(0xFFFFFFFF),
      // Secondary/muted = rumpun Slate — permukaan & teks redup.
      secondary: Color(MasterPalette.slate100),
      secondaryForeground: Color(MasterPalette.slate900),
      muted: Color(MasterPalette.slate100),
      mutedForeground: Color(MasterPalette.slate500),
      // Accent = rumpun Teal (tint pucat) — highlight/hover/selected.
      accent: Color(MasterPalette.teal100),
      accentForeground: Color(MasterPalette.teal700),
      // Destructive = Rose 500 — juga dipakai sebagai nada peringatan
      // (tidak ada amber di palet master).
      destructive: Color(MasterPalette.rose),
      destructiveForeground: Color(0xFFFFFFFF),
      border: Color(MasterPalette.slate200),
      input: Color(MasterPalette.slate200),
      ring: Color(MasterPalette.emerald),
      selection: Color(MasterPalette.sky200),
    ),
    primaryDialogTheme: _dialogThemeProporsional,
    alertDialogTheme: _dialogThemeProporsional,
  );

  static ShadThemeData dark() => ShadThemeData(
    brightness: Brightness.dark,
    colorScheme: const ShadColorScheme(
      background: Color(MasterPalette.slate950),
      foreground: Color(MasterPalette.slate50),
      card: Color(MasterPalette.slate900),
      cardForeground: Color(MasterPalette.slate50),
      popover: Color(MasterPalette.slate900),
      popoverForeground: Color(MasterPalette.slate50),
      // Emerald dicerahkan satu langkah tonal — kontras cukup di atas
      // latar gelap untuk teks/ikon kecil.
      primary: Color(MasterPalette.emerald400),
      primaryForeground: Color(MasterPalette.slate950),
      secondary: Color(MasterPalette.slate800),
      secondaryForeground: Color(MasterPalette.slate50),
      muted: Color(MasterPalette.slate800),
      mutedForeground: Color(MasterPalette.slate),
      accent: Color(MasterPalette.teal900),
      accentForeground: Color(MasterPalette.teal),
      destructive: Color(MasterPalette.rose400),
      destructiveForeground: Color(MasterPalette.slate950),
      border: Color(MasterPalette.slate700),
      input: Color(MasterPalette.slate700),
      ring: Color(MasterPalette.emerald400),
      selection: Color(MasterPalette.sky900),
    ),
    primaryDialogTheme: _dialogThemeProporsional,
    alertDialogTheme: _dialogThemeProporsional,
  );
}

/// Warna status "berhasil/normal" (badge Lunas, bacaan normal) — rumpun
/// Emerald palet master.
abstract final class AppStatusColors {
  static const successLight = MasterPalette.emerald;
  static const successDark = MasterPalette.emerald400; // kontras mode gelap
}

/// Palet aksen chip ikon menu/statistik — SATU sumber supaya kedua
/// aplikasi terlihat satu keluarga. SEMUA nilai kini dipetakan ke rumpun
/// palet master (master_palette.dart); nama field lama dipertahankan agar
/// puluhan pemakaian `Color(AppAccents.x)` tidak perlu diubah satu-satu:
///   biru → Sky, sian → Teal, hijau → Emerald, amber & merah → Rose
///   (peringatan dan bahaya kini satu rumpun), ungu → Slate (kategori
///   netral — violet keluar dari palet), slate → Slate.
abstract final class AppAccents {
  static const biru = MasterPalette.sky;
  static const sian = MasterPalette.teal400; // teal ditegaskan utk ikon kecil
  static const hijau = MasterPalette.emerald;
  static const amber = MasterPalette.rose;
  static const ungu = MasterPalette.slate500;
  static const merah = MasterPalette.rose;
  static const slate = MasterPalette.slate600;
}

/// Aksen emerald — status positif & aksi utama alur pencatatan meter
/// ("Simpan Hasil Baca" dkk di app petugas). Sekarang benar-benar Emerald
/// Tailwind dari palet master (dulu hijau logo).
abstract final class AppEmerald {
  static const c500 = MasterPalette.emerald;
  static const c600 = MasterPalette.emerald600;
}

/// Gradien header brand per aplikasi — dipakai SquircleIcon/BerandaHero.
/// Emerald → Sky: dua aksen utama palet master.
abstract final class AppGradients {
  static const publik = [MasterPalette.emerald, MasterPalette.sky600];
  static const petugas = [MasterPalette.emerald, MasterPalette.sky600];
}
