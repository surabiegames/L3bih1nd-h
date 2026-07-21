import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/api_client.dart';
import '../network/api_config.dart';

/// Akun warga hasil daftar/masuk (subset payload /api/mobile/auth/login —
/// sama seperti PetugasAkun, tapi role selalu 'USER': akun ini hasil
/// pendaftaran mandiri lewat POST /api/public/auth/register, lihat
/// server/modules/publik/akun-warga.router.ts).
class WargaAkun {
  const WargaAkun({required this.id, required this.name, this.email});

  final String id;
  final String name;
  final String? email;

  factory WargaAkun.fromJson(Map<String, dynamic> json) => WargaAkun(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? 'Warga',
    email: json['email'] as String?,
  );

  Map<String, Object?> toJson() => {'id': id, 'name': name, 'email': email};
}

/// Sesi login warga di aplikasi PUBLIK — padanan SesiPetugas untuk akun
/// pelanggan/pelapor mandiri (role USER). Sengaja terpisah dari
/// SesiPetugas (kunci storage berbeda, model akun lebih ringkas) karena
/// keduanya hidup di aplikasi/entrypoint yang berbeda (main_publik.dart vs
/// main_petugas.dart) dan tidak boleh saling bergantung.
///
/// Login/daftar TETAP OPSIONAL di aplikasi publik — SesiWarga hanya
/// dipulihkan diam-diam di awal (tanpa memaksa layar login), sama seperti
/// pola pulihkan() SesiPetugas: kalau tidak ada token tersimpan, aplikasi
/// berjalan seperti biasa dalam keadaan anonim.
class SesiWarga {
  SesiWarga._();

  static final SesiWarga instance = SesiWarga._();

  static const _storage = FlutterSecureStorage();
  static const _kunciToken = 'wargaAccessToken';
  static const _kunciKedaluwarsa = 'wargaExpiresAt';
  static const _kunciAkun = 'wargaAkun';

  WargaAkun? akun;

  bool get sudahMasuk => akun != null;

  /// Pulihkan sesi tersimpan saat aplikasi dibuka. TIDAK memanggil
  /// jaringan — pola sama seperti SesiPetugas.pulihkan().
  Future<bool> pulihkan() async {
    try {
      final token = await _storage.read(key: _kunciToken);
      final kedaluwarsa = await _storage.read(key: _kunciKedaluwarsa);
      final akunJson = await _storage.read(key: _kunciAkun);
      if (token == null || token.isEmpty) return false;
      if (kedaluwarsa != null) {
        final batas = DateTime.tryParse(kedaluwarsa);
        if (batas != null && DateTime.now().isAfter(batas)) {
          await keluar();
          return false;
        }
      }
      if (akunJson != null) {
        akun = WargaAkun.fromJson(jsonDecode(akunJson) as Map<String, dynamic>);
      }
      ApiClient.instance.setAccessToken(token);
      return true;
    } on Object {
      return false;
    }
  }

  /// Daftar akun baru (POST /api/public/auth/register, tanpa login) lalu
  /// LANGSUNG masuk (POST /api/mobile/auth/login) dengan kredensial yang
  /// sama — pola sama seperti daftar-form.tsx di web: pengguna tidak perlu
  /// mengetik ulang di layar terpisah.
  ///
  /// `nomorLangganan` WAJIB (kontrak register sejak 2026-07-19): akun warga
  /// selalu lahir tertaut minimal satu nomor langganan, yang otomatis jadi
  /// langganan UTAMA — biodatanya tampil di beranda (lihat
  /// features/public/langganan/).
  Future<WargaAkun> daftar({
    required String nama,
    required String email,
    required String password,
    required String nomorLangganan,
  }) async {
    if (ApiConfig.isDemo) return _masukDemo(nama: nama, email: email);
    await ApiClient.instance.post(
      '${ApiConfig.publicPath}/auth/register',
      body: {
        'nama': nama,
        'email': email,
        'password': password,
        'nomorLangganan': nomorLangganan,
      },
      parse: (_) {},
    );
    return masuk(identifier: email, password: password);
  }

  /// Mode demo: tidak ada backend untuk menukar token, tapi seluruh alur UI
  /// (beranda ber-biodata, kelola langganan, laporan saya) tetap harus bisa
  /// dijajal — sama seperti repository demo lain. Sesi demo TIDAK ditulis ke
  /// secure storage: hilang saat app ditutup, tidak mencemari sesi asli.
  Future<WargaAkun> _masukDemo({required String nama, String? email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final profil = WargaAkun(id: 'demo-warga', name: nama, email: email);
    akun = profil;
    return profil;
  }

  /// Masuk dengan akun yang sudah ada. Pesan gagal dari server SENGAJA
  /// seragam (anti user-enumeration) — tampilkan apa adanya.
  Future<WargaAkun> masuk({
    required String identifier,
    required String password,
  }) async {
    if (ApiConfig.isDemo) {
      return _masukDemo(nama: 'Warga Demo', email: identifier);
    }
    final data = await ApiClient.instance.post(
      '${ApiConfig.mobileAuthPath}/login',
      body: {'identifier': identifier, 'password': password},
      parse: (data) => data as Map<String, dynamic>,
    );
    final token = data['accessToken'] as String? ?? '';
    final user = data['user'];
    final profil = user is Map<String, dynamic>
        ? WargaAkun.fromJson(user)
        : const WargaAkun(id: '', name: 'Warga');

    ApiClient.instance.setAccessToken(token);
    akun = profil;
    await _storage.write(key: _kunciToken, value: token);
    await _storage.write(
      key: _kunciKedaluwarsa,
      value: data['expiresAt'] as String?,
    );
    await _storage.write(key: _kunciAkun, value: jsonEncode(profil.toJson()));
    return profil;
  }

  Future<void> keluar() async {
    akun = null;
    ApiClient.instance.setAccessToken(null);
    await _storage.delete(key: _kunciToken);
    await _storage.delete(key: _kunciKedaluwarsa);
    await _storage.delete(key: _kunciAkun);
  }
}
