/// Konfigurasi koneksi ke backend web (Next.js + Hono).
///
/// Base URL TIDAK di-hardcode — diberikan saat build:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000
///
/// Tanpa dart-define, aplikasi berjalan dalam MODE DEMO: repository memakai
/// data contoh dalam memori sehingga seluruh UI tetap bisa dijalankan dan
/// diuji tanpa backend.
abstract final class ApiConfig {
  static const String baseUrl = String.fromEnvironment('API_BASE_URL');

  /// true bila tidak ada API_BASE_URL — repository beralih ke data demo.
  static bool get isDemo => baseUrl.isEmpty;

  /// Endpoint publik (tanpa login): cek tagihan, lapor meter, pengaduan.
  static const String publicPath = '/api/public';

  /// Endpoint bisnis (wajib Bearer token): modul petugas.
  static const String v1Path = '/api/v1';

  /// Pintu masuk mobile (tanpa token): tukar kredensial → Bearer token.
  static const String mobileAuthPath = '/api/mobile/auth';
}
