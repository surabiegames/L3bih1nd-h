import 'dart:convert';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import 'rbm_dao.dart';

/// Master tarif air untuk ESTIMASI di layar catat — padanan unduhan
/// `download_watertarif.php` + `calculateTagihan()` Aurora.
///
/// Estimasi, bukan tagihan: angka resmi selalu dihitung server saat closing
/// (aturan keras proyek — device tidak menentukan rupiah). Gunanya sama
/// dengan di Aurora: petugas bisa langsung menjawab "kira-kira berapa
/// tagihan saya bulan ini?" di depan pelanggan.
class BlokTarifMobile {
  const BlokTarifMobile({
    required this.blok,
    required this.batasAwalM3,
    this.batasAkhirM3,
    required this.hargaPerM3,
  });

  final int blok;
  final int batasAwalM3;

  /// null = blok terakhir (tanpa batas atas).
  final int? batasAkhirM3;
  final int hargaPerM3;

  factory BlokTarifMobile.fromJson(Map<String, dynamic> json) =>
      BlokTarifMobile(
        blok: (json['blok'] as num?)?.toInt() ?? 0,
        batasAwalM3: (json['batasAwalM3'] as num?)?.toInt() ?? 0,
        batasAkhirM3: (json['batasAkhirM3'] as num?)?.toInt(),
        hargaPerM3: (json['hargaPerM3'] as num?)?.toInt() ?? 0,
      );

  Map<String, Object?> toJson() => {
    'blok': blok,
    'batasAwalM3': batasAwalM3,
    'batasAkhirM3': batasAkhirM3,
    'hargaPerM3': hargaPerM3,
  };
}

class TarifGolonganMobile {
  const TarifGolonganMobile({required this.kodeAsli, required this.blok});

  /// Kode yang sama dengan `PelangganRute.golonganTarif` (mis. "2A2").
  final String kodeAsli;
  final List<BlokTarifMobile> blok;

  factory TarifGolonganMobile.fromJson(Map<String, dynamic> json) =>
      TarifGolonganMobile(
        kodeAsli: json['kodeAsli'] as String? ?? '',
        blok:
            (json['blokTarif'] as List? ?? const [])
                .whereType<Map<String, dynamic>>()
                .map(BlokTarifMobile.fromJson)
                .toList()
              ..sort((a, b) => a.blok.compareTo(b.blok)),
      );

  Map<String, Object?> toJson() => {
    'kodeAsli': kodeAsli,
    'blokTarif': [for (final b in blok) b.toJson()],
  };
}

/// Hitung estimasi uang air progresif — logika yang sama dengan
/// `calculateTagihan()` Aurora: tiap blok konsumsi dikenai harganya sendiri
/// (bukan seluruh pemakaian dikali harga blok tertinggi).
/// null = golongan tarif tidak dikenal / pemakaian tidak valid.
int? estimasiUangAir(TarifGolonganMobile? tarif, int pemakaianM3) {
  if (tarif == null || tarif.blok.isEmpty || pemakaianM3 <= 0) return null;
  var total = 0;
  for (final b in tarif.blok) {
    // Blok "11–20 m³" (batasAwal 11, batasAkhir 20) menampung 10 m³:
    // pemakaian di atas batasAwal-1 sampai batasAkhir.
    final dasar = b.batasAwalM3 - 1;
    if (pemakaianM3 <= dasar) break;
    final atas = b.batasAkhirM3 ?? pemakaianM3;
    final kena = (pemakaianM3 < atas ? pemakaianM3 : atas) - dasar;
    if (kena > 0) total += kena * b.hargaPerM3;
  }
  return total;
}

/// Sumber master tarif: unduh sekali dari `GET /api/v1/tarif`, cache di
/// SQLite (tabel meta) supaya estimasi tetap jalan saat offline.
class TarifRepository {
  TarifRepository({ApiClient? api, RbmDao? dao})
    : _api = api ?? ApiClient.instance,
      _dao = dao ?? RbmDao();

  final ApiClient _api;
  final RbmDao _dao;

  static const _kunciCache = 'rbm.tarif';

  Map<String, TarifGolonganMobile>? _dalamMemori;

  /// Tarif per kodeAsli. Urutan sumber: memori → server (segarkan cache) →
  /// cache SQLite. Peta kosong bila semuanya gagal — estimasi tinggal
  /// tidak tampil, alur catat TIDAK terganggu.
  Future<Map<String, TarifGolonganMobile>> semua() async {
    final ada = _dalamMemori;
    if (ada != null) return ada;

    if (!ApiConfig.isDemo) {
      try {
        final hasil = await _api.getList(
          '${ApiConfig.v1Path}/tarif',
          // hanyaAktif: hanya blok tarif yang berlaku sekarang — tanpa ini
          // golongan yang pernah ganti tarif membawa blok generasi lama
          // (nomor blok ganda) dan estimasi progresif salah hitung.
          query: {'pageSize': 100, 'hanyaAktif': true},
          parseRow: TarifGolonganMobile.fromJson,
        );
        final peta = {for (final t in hasil.rows) t.kodeAsli: t};
        if (peta.isNotEmpty) {
          await _dao.simpanMeta(
            _kunciCache,
            jsonEncode([for (final t in peta.values) t.toJson()]),
          );
          return _dalamMemori = peta;
        }
      } on ApiException {
        // offline / belum boleh — jatuh ke cache di bawah.
      }
    }

    try {
      final mentah = await _dao.bacaMeta(_kunciCache);
      if (mentah != null) {
        final daftar = (jsonDecode(mentah) as List)
            .whereType<Map<String, dynamic>>()
            .map(TarifGolonganMobile.fromJson);
        return _dalamMemori = {for (final t in daftar) t.kodeAsli: t};
      }
    } on Object {
      // cache korup — relakan.
    }
    return _dalamMemori = const {};
  }

  Future<TarifGolonganMobile?> untukGolongan(String? kodeAsli) async {
    if (kodeAsli == null) return null;
    return (await semua())[kodeAsli];
  }

  /// Paksa unduh ulang master tarif dari server (abaikan cache memori) —
  /// dipakai layar Download Data. Mengembalikan jumlah golongan terunduh
  /// (0 = server tak menjawab / mode demo; estimasi tetap jalan dari cache
  /// lama bila ada).
  Future<int> unduh() async {
    _dalamMemori = null;
    return (await semua()).length;
  }

  /// Jumlah golongan tarif di cache saat ini tanpa memaksa unduh (0 = belum
  /// pernah diunduh).
  Future<int> jumlahTersimpan() async => (await semua()).length;
}
