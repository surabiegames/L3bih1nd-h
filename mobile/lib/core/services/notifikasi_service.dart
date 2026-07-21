import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

import '../network/api_client.dart';
import '../network/api_config.dart';
import '../network/api_exception.dart';

/// Satu notifikasi in-app (inbox `GET /api/v1/notifikasi`).
class NotifikasiItem {
  const NotifikasiItem({
    required this.id,
    required this.judul,
    required this.isi,
    required this.tipe,
    required this.dibaca,
    required this.dibuatPada,
    this.data,
  });

  final String id;
  final String judul;
  final String isi;
  final String tipe;
  final bool dibaca;
  final DateTime? dibuatPada;

  /// Tautan dalam-app (mis. { tipe: "pengaduan", id: "..." }).
  final Map<String, dynamic>? data;

  factory NotifikasiItem.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? data;
    final mentah = json['data'];
    if (mentah is Map) {
      data = mentah.cast<String, dynamic>();
    } else if (mentah is String && mentah.isNotEmpty) {
      try {
        final d = jsonDecode(mentah);
        if (d is Map) data = d.cast<String, dynamic>();
      } on Object {
        data = null;
      }
    }
    return NotifikasiItem(
      id: json['id'] as String? ?? '',
      judul: json['judul'] as String? ?? '',
      isi: json['isi'] as String? ?? '',
      tipe: json['tipe'] as String? ?? 'umum',
      dibaca: json['dibacaAt'] != null,
      dibuatPada: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      data: data,
    );
  }
}

/// Hasil daftar inbox: baris + jumlah belum dibaca (dari meta respons).
class DaftarNotifikasi {
  const DaftarNotifikasi({required this.items, required this.belumDibaca});
  final List<NotifikasiItem> items;
  final int belumDibaca;

  static const kosong = DaftarNotifikasi(items: [], belumDibaca: 0);
}

/// Layanan notifikasi petugas — DUA bagian:
///
/// 1. **Token perangkat (push FCM)** — STRUKTUR sudah siap, tetapi sumber
///    token masih stub (`_tokenPerangkat` → null) karena paket
///    `firebase_messaging` sengaja BELUM dipasang: tanpa `google-services.json`
///    ia akan menggagalkan build Android. Saat Firebase disiapkan, cukup
///    kembalikan `FirebaseMessaging.instance.getToken()` di satu tempat itu —
///    seluruh alur daftar/hapus token ke backend sudah jadi. Ini padanan
///    sisi klien dari NotifierLog→NotifierFcm di server.
///
/// 2. **Inbox in-app** — SUDAH berfungsi penuh sekarang lewat
///    `GET/PATCH /api/v1/notifikasi`: notifikasi yang ditulis server
///    (penugasan rute/tiket) langsung terlihat walau push belum aktif.
class NotifikasiService {
  NotifikasiService._();
  static final NotifikasiService instance = NotifikasiService._();

  final ApiClient _api = ApiClient.instance;

  /// Token FCM perangkat. **Stub**: null sampai `firebase_messaging`
  /// dipasang. Jangan pindahkan pemanggilan Firebase ke tempat lain —
  /// cukup isi method ini.
  Future<String?> _tokenPerangkat() async => null;

  String _platform() {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    return 'android';
  }

  /// Daftarkan token perangkat ke backend (dipanggil setelah login &
  /// pemulihan sesi). No-op saat mode demo atau token belum ada (FCM belum
  /// aktif). Best-effort — kegagalan jaringan diabaikan.
  Future<void> daftarkanPerangkat() async {
    if (ApiConfig.isDemo) return;
    final token = await _tokenPerangkat();
    if (token == null || token.isEmpty) return;
    try {
      await _api.post(
        '${ApiConfig.v1Path}/perangkat/token',
        body: {'token': token, 'platform': _platform()},
        parse: (_) => null,
      );
    } on ApiException {
      // best-effort
    }
  }

  /// Lepas token saat logout — dipanggil SEBELUM Bearer token dibuang.
  Future<void> hapusPerangkat() async {
    if (ApiConfig.isDemo) return;
    final token = await _tokenPerangkat();
    if (token == null || token.isEmpty) return;
    try {
      await _api.delete(
        '${ApiConfig.v1Path}/perangkat/token',
        body: {'token': token},
        parse: (_) => null,
      );
    } on ApiException {
      // best-effort
    }
  }

  /// Daftar notifikasi + jumlah belum dibaca. Mode demo → kosong.
  Future<DaftarNotifikasi> daftar({bool belumDibaca = false}) async {
    if (ApiConfig.isDemo) return DaftarNotifikasi.kosong;
    try {
      final hasil = await _api.getList(
        '${ApiConfig.v1Path}/notifikasi',
        query: {'pageSize': 50, if (belumDibaca) 'belumDibaca': true},
        parseRow: NotifikasiItem.fromJson,
      );
      // belumDibaca dihitung dari baris halaman ini (cukup untuk badge &
      // daftar; server juga mengembalikannya di meta bila kelak dibutuhkan).
      final belum = belumDibaca
          ? hasil.rows.length
          : hasil.rows.where((n) => !n.dibaca).length;
      return DaftarNotifikasi(items: hasil.rows, belumDibaca: belum);
    } on ApiException {
      return DaftarNotifikasi.kosong;
    }
  }

  /// Jumlah belum dibaca — untuk badge lonceng. 0 saat gagal/demo.
  Future<int> jumlahBelumDibaca() async =>
      (await daftar(belumDibaca: true)).belumDibaca;

  Future<void> tandaiBaca(String id) async {
    if (ApiConfig.isDemo) return;
    try {
      await _api.patch(
        '${ApiConfig.v1Path}/notifikasi/$id/baca',
        parse: (_) => null,
      );
    } on ApiException {
      // best-effort
    }
  }

  Future<void> tandaiSemua() async {
    if (ApiConfig.isDemo) return;
    try {
      await _api.post(
        '${ApiConfig.v1Path}/notifikasi/baca-semua',
        parse: (_) => null,
      );
    } on ApiException {
      // best-effort
    }
  }
}
