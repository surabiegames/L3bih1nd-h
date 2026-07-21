/// core/theme/master_palette.dart — PALET MASTER kedua aplikasi.
///
/// Padanan "CSS global" (`:root { --color-... }`) versi Dart: SATU file
/// berisi seluruh nilai warna yang boleh dipakai; file lain (tema shadcn,
/// token iOS, widget) hanya MERUJUK ke sini, tidak mendefinisikan hex
/// sendiri.
///
/// LIMA WARNA PATEN (keputusan produk 2026-07-19 — menggantikan palet
/// warna logo/brand lama):
///
///   1. Emerald 500 `#10B981` — aksi utama (tombol primer), status sukses
///   2. Teal 300    `#5EEAD4` — highlight/aksen kategori (accent shadcn)
///   3. Sky 400     `#38BDF8` — info, tautan, aksen biru, hero
///   4. Slate 400   `#94A3B8` — netral: teks redup, border, latar, chrome
///   5. Rose 500    `#F43F5E` — destruktif DAN peringatan (tidak ada lagi
///                              amber/merah lain di aplikasi)
///
/// ATURAN: warna apa pun di kode HARUS berasal dari salah satu rumpun di
/// atas — master-nya langsung, atau TURUNAN TONAL serumpun di bawah ini
/// (tangga terang-gelap Tailwind dari hue yang SAMA; dibutuhkan untuk
/// kontras teks, gradien, dan mode gelap — ini bukan "warna baru").
/// Putih/hitam/alpha-nya tetap boleh sebagai netral absolut. JANGAN
/// menambah hue lain (amber, violet, cyan, navy brand lama, dst.).
///
/// Konstanta bertipe `int` (bukan `Color`) supaya bisa dipakai baik lewat
/// `Color(MasterPalette.sky)` maupun disalurkan ke konstanta `int` lama
/// (AppAccents/PdamPalette) tanpa konversi.
abstract final class MasterPalette {
  // ── 5 MASTER ─────────────────────────────────────────────────────────
  static const emerald = 0xFF10B981; // Emerald 500
  static const teal = 0xFF5EEAD4; // Teal 300
  static const sky = 0xFF38BDF8; // Sky 400
  static const slate = 0xFF94A3B8; // Slate 400
  static const rose = 0xFFF43F5E; // Rose 500

  // ── Turunan tonal rumpun EMERALD ─────────────────────────────────────
  static const emerald50 = 0xFFECFDF5;
  static const emerald100 = 0xFFD1FAE5;
  static const emerald300 = 0xFF6EE7B7;
  static const emerald400 = 0xFF34D399;
  static const emerald600 = 0xFF059669;
  static const emerald700 = 0xFF047857;
  static const emerald800 = 0xFF065F46;
  static const emerald900 = 0xFF064E3B;

  // ── Turunan tonal rumpun TEAL ────────────────────────────────────────
  static const teal100 = 0xFFCCFBF1;
  static const teal400 = 0xFF2DD4BF;
  static const teal600 = 0xFF0D9488;
  static const teal700 = 0xFF0F766E;
  static const teal900 = 0xFF134E4A;

  // ── Turunan tonal rumpun SKY ─────────────────────────────────────────
  static const sky50 = 0xFFF0F9FF;
  static const sky100 = 0xFFE0F2FE;
  static const sky200 = 0xFFBAE6FD;
  static const sky300 = 0xFF7DD3FC;
  static const sky500 = 0xFF0EA5E9;
  static const sky600 = 0xFF0284C7;
  static const sky700 = 0xFF0369A1;
  static const sky800 = 0xFF075985;
  static const sky900 = 0xFF0C4A6E;
  static const sky950 = 0xFF082F49;

  // ── Turunan tonal rumpun SLATE ───────────────────────────────────────
  static const slate50 = 0xFFF8FAFC;
  static const slate100 = 0xFFF1F5F9;
  static const slate200 = 0xFFE2E8F0;
  static const slate300 = 0xFFCBD5E1;
  static const slate500 = 0xFF64748B;
  static const slate600 = 0xFF475569;
  static const slate700 = 0xFF334155;
  static const slate800 = 0xFF1E293B;
  static const slate900 = 0xFF0F172A;
  static const slate950 = 0xFF020617;

  // ── Turunan tonal rumpun ROSE ────────────────────────────────────────
  static const rose100 = 0xFFFFE4E6;
  static const rose200 = 0xFFFECDD3;
  static const rose300 = 0xFFFDA4AF;
  static const rose400 = 0xFFFB7185;
  static const rose600 = 0xFFE11D48;
  static const rose700 = 0xFFBE123C;
  static const rose900 = 0xFF881337;
}
