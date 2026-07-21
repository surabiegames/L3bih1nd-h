import 'master_palette.dart';

/// core/theme/pdam_palette.dart — token warna hero beranda WARGA (app
/// publik): hero riak air, grid aksi cepat, dock navigasi.
///
/// SELURUH nilai kini alias ke PALET MASTER 5 warna
/// (core/theme/master_palette.dart, keputusan produk 2026-07-19) — file
/// ini dipertahankan hanya supaya widget hero lama tidak perlu diubah
/// nama tokennya; nilai navy/amber/orange/purple/cyan mockup lama sudah
/// dipetakan ke rumpun Slate/Sky/Rose/Teal.
abstract final class PdamPalette {
  static const navy = MasterPalette.slate900;
  static const navyMid = MasterPalette.slate800;
  static const sky = MasterPalette.sky500;
  static const skyLight = MasterPalette.sky; // Sky 400 (master)
  static const ice = MasterPalette.sky50;
  static const white = 0xFFFFFFFF;
  static const amber = MasterPalette.rose; // peringatan = rumpun Rose
  static const emerald = MasterPalette.emerald;
  static const red = MasterPalette.rose;
  static const orange = MasterPalette.rose400;
  static const purple = MasterPalette.slate500; // kategori netral
  static const cyan = MasterPalette.teal400;

  static const text1 = MasterPalette.slate900;
  static const text2 = MasterPalette.slate600;
  static const text3 = MasterPalette.slate; // Slate 400 (master)

  /// Gradien hero — gelap rumpun Slate menuju rumpun Sky (menggantikan
  /// navy mockup lama), 4 titik berhenti. Konstanta terpisah satu-satu
  /// (bukan daftar yang diindeks) supaya tetap bisa dipakai langsung di
  /// `const Color(...)`.
  static const heroGradient1 = MasterPalette.slate900;
  static const heroGradient2 = 0xFF12324E; // transisi slate-900 → sky-900
  static const heroGradient3 = MasterPalette.sky900;
  static const heroGradient4 = MasterPalette.sky800;
  static const heroGradientStops = [0.0, 0.45, 0.7, 1.0];
}
