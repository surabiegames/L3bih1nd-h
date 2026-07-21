import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/api_client.dart';
import '../network/api_config.dart';
import '../services/notifikasi_service.dart';

/// Akun petugas hasil login (subset payload /api/mobile/auth/login §4.1
/// FLUTTER.md — cukup yang dipakai UI).
class PetugasAkun {
  const PetugasAkun({
    required this.id,
    required this.name,
    this.email,
    this.role = 'STAFF',
  });

  final String id;
  final String name;
  final String? email;
  final String role;

  factory PetugasAkun.fromJson(Map<String, dynamic> json) => PetugasAkun(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? 'Petugas',
    email: json['email'] as String?,
    role: json['role'] as String? ?? 'STAFF',
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
  };
}

/// Sesi login aplikasi petugas — SATU-SATUNYA pemegang Bearer token.
///
/// Token disimpan di flutter_secure_storage (Keychain/Keystore — aturan
/// FLUTTER.md §4.3: JANGAN SharedPreferences). Umur token 7 hari tanpa
/// refresh: `pulihkan()` menolak token yang sudah lewat `expiresAt`, dan
/// respons 401 dari server mana pun memicu [onSesiBerakhir] (dipasang di
/// akar aplikasi untuk mengarahkan ke layar login).
class SesiPetugas {
  SesiPetugas._();

  static final SesiPetugas instance = SesiPetugas._();

  static const _storage = FlutterSecureStorage();
  static const _kunciToken = 'accessToken';
  static const _kunciKedaluwarsa = 'expiresAt';
  static const _kunciAkun = 'akun';

  PetugasAkun? akun;

  /// Dipanggil ApiClient saat server menjawab 401 (token kedaluwarsa /
  /// dicabut) — akar aplikasi memakai ini untuk kembali ke layar login.
  void Function()? onSesiBerakhir;

  /// Pulihkan sesi tersimpan saat aplikasi dibuka. `true` = token masih
  /// berlaku dan sudah terpasang di ApiClient. TIDAK memanggil jaringan —
  /// petugas lapangan harus tetap bisa membuka aplikasi (dan rute yang
  /// ter-cache) tanpa sinyal; validasi sesungguhnya terjadi alami saat
  /// request pertama (401 → onSesiBerakhir).
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
        akun = PetugasAkun.fromJson(
          jsonDecode(akunJson) as Map<String, dynamic>,
        );
      }
      ApiClient.instance.setAccessToken(token);
      // Daftarkan (ulang) token perangkat untuk push — best-effort, tak
      // memblokir pembukaan aplikasi (no-op tanpa Firebase/demo).
      unawaited(NotifikasiService.instance.daftarkanPerangkat());
      return true;
    } on Object {
      // Keystore rusak/tak tersedia dianggap belum login — jangan crash
      // di pintu masuk aplikasi.
      return false;
    }
  }

  /// Login username/email + password → simpan token + profil.
  /// Pesan gagal dari server SENGAJA seragam (anti user-enumeration) —
  /// tampilkan apa adanya, jangan menebak sebabnya.
  Future<PetugasAkun> masuk({
    required String identifier,
    required String password,
  }) async {
    final data = await ApiClient.instance.post(
      '${ApiConfig.mobileAuthPath}/login',
      body: {'identifier': identifier, 'password': password},
      parse: (data) => data as Map<String, dynamic>,
    );
    final token = data['accessToken'] as String? ?? '';
    final user = data['user'];
    final profil = user is Map<String, dynamic>
        ? PetugasAkun.fromJson(user)
        : const PetugasAkun(id: '', name: 'Petugas');

    ApiClient.instance.setAccessToken(token);
    akun = profil;
    await _storage.write(key: _kunciToken, value: token);
    await _storage.write(
      key: _kunciKedaluwarsa,
      value: data['expiresAt'] as String?,
    );
    await _storage.write(key: _kunciAkun, value: jsonEncode(profil.toJson()));
    // Daftarkan token perangkat untuk push (best-effort, no-op tanpa Firebase).
    await NotifikasiService.instance.daftarkanPerangkat();
    return profil;
  }

  Future<void> keluar() async {
    // Lepas token perangkat SELAGI Bearer masih terpasang (best-effort).
    await NotifikasiService.instance.hapusPerangkat();
    akun = null;
    ApiClient.instance.setAccessToken(null);
    await _storage.delete(key: _kunciToken);
    await _storage.delete(key: _kunciKedaluwarsa);
    await _storage.delete(key: _kunciAkun);
  }
}
