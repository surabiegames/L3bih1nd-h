/// Konfigurasi koneksi ke backend web (Next.js + Hono).
///
/// URL produksi TERTANAM di kode (`_urlProduksi`) — build produksi tidak perlu
/// flag apa pun. Untuk menunjuk backend lain (dev lokal / staging), timpa saat
/// build:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000
///
/// MODE DEMO (data contoh in-memory, tanpa backend) diaktifkan EKSPLISIT:
///   flutter build apk --dart-define=DEMO=true
/// Sebelumnya demo = "tidak ada API_BASE_URL", tapi itu membuat build produksi
/// tak punya default; kini produksi adalah bawaannya.
abstract final class ApiConfig {
  /// URL produksi resmi (backend ter-deploy di Vercel).
  static const String _urlProduksi = 'https://perumda.vercel.app';

  /// Penimpa opsional saat build (dev/staging). Kosong = pakai produksi.
  static const String _override = String.fromEnvironment('API_BASE_URL');

  /// Aktif hanya bila `--dart-define=DEMO=true`.
  static const bool _demo = bool.fromEnvironment('DEMO');

  /// Base URL efektif: penimpa bila diberikan, selain itu produksi.
  static String get baseUrl => _override.isNotEmpty ? _override : _urlProduksi;

  /// true = repository memakai data demo in-memory (bukan menembak backend).
  static bool get isDemo => _demo;

  /// Endpoint publik (tanpa login): cek tagihan, lapor meter, pengaduan.
  static const String publicPath = '/api/public';

  /// Endpoint bisnis (wajib Bearer token): modul petugas.
  static const String v1Path = '/api/v1';

  /// Pintu masuk mobile (tanpa token): tukar kredensial → Bearer token.
  static const String mobileAuthPath = '/api/mobile/auth';
}
