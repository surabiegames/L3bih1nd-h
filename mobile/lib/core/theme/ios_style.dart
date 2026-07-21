import 'package:flutter/widgets.dart';

import 'master_palette.dart';

/// core/theme/ios_style.dart — token warna & bentuk gaya iOS, dipakai
/// BERSAMA kedua aplikasi (publik + petugas) lewat widget bersama
/// (AppScaffold, GlassPanel, BottomDock/tab bar, MenuTile, BrandHeader).
///
/// SENGAJA terpisah dari `AppTheme`/`ShadColorScheme`: file itu tetap
/// sumber warna untuk komponen shadcn_ui (ShadButton/ShadCard/dst.) yang
/// sudah teruji dan TIDAK dibongkar — token di sini hanya dipakai widget
/// kustom (Container/BoxDecoration manual) yang memang merender chrome
/// (nav bar, tab bar, kartu) dengan gaya sistem iOS: warna semantik
/// (systemBackground, label, separator, dst — nama & nilai mengikuti
/// konvensi Apple Human Interface Guidelines), sudut "continuous" ala
/// squircle (ContinuousRectangleBorder, bukan BorderRadius.circular
/// biasa), dan latar blur/translusen pada bar navigasi.
///
/// SELURUH nilai kini dipetakan ke PALET MASTER 5 warna
/// (core/theme/master_palette.dart, keputusan produk 2026-07-19):
/// abu-abu iOS diganti rumpun Slate, warna "sistem" diganti master
/// Sky/Emerald/Rose. Nama field Apple dipertahankan supaya widget chrome
/// yang sudah memakainya tidak perlu diubah.
abstract final class IosStyle {
  // ── Terang (rumpun Slate) ───────────────────────────────────────────
  static const systemBackgroundLight = Color(0xFFFFFFFF);
  static const secondarySystemBackgroundLight = Color(MasterPalette.slate100);
  static const tertiarySystemBackgroundLight = Color(0xFFFFFFFF);
  static const labelLight = Color(MasterPalette.slate900);
  static const secondaryLabelLight = Color(0x99334155); // slate-700 @60%
  static const separatorLight = Color(0x4A475569); // slate-600 @29%

  // ── Gelap (rumpun Slate) ────────────────────────────────────────────
  static const systemBackgroundDark = Color(MasterPalette.slate950);
  static const secondarySystemBackgroundDark = Color(MasterPalette.slate900);
  static const tertiarySystemBackgroundDark = Color(MasterPalette.slate800);
  static const labelDark = Color(MasterPalette.slate50);
  static const secondaryLabelDark = Color(0x99E2E8F0); // slate-200 @60%
  static const separatorDark = Color(0x5A94A3B8); // slate-400 @35%

  // ── Master-as-system-color ──────────────────────────────────────────
  static const systemBlue = Color(MasterPalette.sky); // Sky 400
  static const systemGreen = Color(MasterPalette.emerald); // Emerald 500
  static const systemRed = Color(MasterPalette.rose); // Rose 500

  /// Sudut "continuous corner" ala iOS (superellipse) — beda dari
  /// BorderRadius.circular biasa (busur lingkaran murni): transisi sisi
  /// datar ke lengkung lebih halus, ciri khas ikon & kartu iOS/macOS.
  static ShapeBorder continuousCorner(double radius) =>
      ContinuousRectangleBorder(borderRadius: BorderRadius.circular(radius));

  static Color background(Brightness b) =>
      b == Brightness.dark ? systemBackgroundDark : systemBackgroundLight;
  static Color secondaryBackground(Brightness b) => b == Brightness.dark
      ? secondarySystemBackgroundDark
      : secondarySystemBackgroundLight;
  static Color label(Brightness b) =>
      b == Brightness.dark ? labelDark : labelLight;
  static Color secondaryLabel(Brightness b) =>
      b == Brightness.dark ? secondaryLabelDark : secondaryLabelLight;
  static Color separator(Brightness b) =>
      b == Brightness.dark ? separatorDark : separatorLight;
}
