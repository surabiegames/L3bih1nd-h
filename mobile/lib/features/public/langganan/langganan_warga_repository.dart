import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';

/// Satu nomor langganan yang tertaut ke akun warga — baris dari
/// GET /api/v1/langganan-saya (lihat FLUTTER.md "Langganan warga").
/// Alamat sudah disamarkan SERVER (bintang di ekor) — tampilkan apa adanya,
/// jangan coba "membersihkan" bintangnya.
class LanggananWargaModel {
  const LanggananWargaModel({
    required this.id,
    required this.isUtama,
    required this.nomorLangganan,
    required this.nama,
    required this.alamat,
    this.rt,
    this.rw,
    required this.status,
    this.golonganKode,
    this.golonganKategori,
    required this.jumlahTagihanBelumBayar,
    required this.totalTunggakan,
  });

  final String id;
  final bool isUtama;
  final String nomorLangganan;
  final String nama;
  final String alamat;
  final String? rt;
  final String? rw;
  final String status;
  final String? golonganKode;
  final String? golonganKategori;
  final int jumlahTagihanBelumBayar;
  final num totalTunggakan;

  factory LanggananWargaModel.fromJson(Map<String, dynamic> json) {
    final golongan = json['tarifGolongan'];
    return LanggananWargaModel(
      id: json['id'] as String? ?? '',
      isUtama: json['isUtama'] as bool? ?? false,
      nomorLangganan: json['nomorLangganan'] as String? ?? '',
      nama: json['nama'] as String? ?? '',
      alamat: json['alamat'] as String? ?? '',
      rt: json['rt'] as String?,
      rw: json['rw'] as String?,
      status: json['status'] as String? ?? 'AKTIF',
      golonganKode: golongan is Map<String, dynamic>
          ? golongan['kodeAsli'] as String?
          : null,
      golonganKategori: golongan is Map<String, dynamic>
          ? golongan['kategori'] as String?
          : null,
      jumlahTagihanBelumBayar:
          (json['jumlahTagihanBelumBayar'] as num?)?.toInt() ?? 0,
      totalTunggakan: json['totalTunggakan'] as num? ?? 0,
    );
  }

  String get alamatLengkap {
    final rtRw = [
      if (rt != null && rt!.isNotEmpty) 'RT $rt',
      if (rw != null && rw!.isNotEmpty) 'RW $rw',
    ].join(' ');
    return rtRw.isEmpty ? alamat : '$alamat $rtRw';
  }
}

/// Identitas ringkas hasil GET /api/public/pelanggan/:nomorLangganan —
/// dipakai kartu pratinjau "ini pelanggan Anda?" di form daftar &
/// tambah langganan, SEBELUM nomor benar-benar ditautkan.
class PelangganRingkas {
  const PelangganRingkas({
    required this.nomorLangganan,
    required this.nama,
    required this.alamat,
    required this.status,
  });

  final String nomorLangganan;
  final String nama;
  final String alamat;
  final String status;

  factory PelangganRingkas.fromJson(Map<String, dynamic> json) =>
      PelangganRingkas(
        nomorLangganan: json['nomorLangganan'] as String? ?? '',
        nama: json['nama'] as String? ?? '',
        alamat: json['alamat'] as String? ?? '',
        status: json['status'] as String? ?? 'AKTIF',
      );
}

/// Sumber data langganan tertaut akun warga yang sedang login.
abstract interface class LanggananWargaRepository {
  factory LanggananWargaRepository.create() => ApiConfig.isDemo
      ? DemoLanggananWargaRepository()
      : ApiLanggananWargaRepository(ApiClient.instance);

  Future<List<LanggananWargaModel>> ambil();

  /// Tautkan nomor tambahan (maks. 5 per akun di server; 409 bila sudah
  /// tertaut, 404 pesan seragam bila nomor tidak dikenal).
  Future<LanggananWargaModel> tambah(String nomorLangganan);

  Future<void> hapus(String id);

  Future<void> jadikanUtama(String id);

  /// Pratinjau identitas via endpoint PUBLIK (tanpa login) — rate limit
  /// server 20/5 menit per IP: panggil hanya saat nomor sudah genap 11
  /// digit, jangan per ketukan keyboard.
  Future<PelangganRingkas> pratinjau(String nomorLangganan);
}

class ApiLanggananWargaRepository implements LanggananWargaRepository {
  ApiLanggananWargaRepository(this._api);

  final ApiClient _api;

  static const _path = '${ApiConfig.v1Path}/langganan-saya';

  @override
  Future<List<LanggananWargaModel>> ambil() => _api.get(
    _path,
    parse: (data) => data is List
        ? data
              .whereType<Map<String, dynamic>>()
              .map(LanggananWargaModel.fromJson)
              .toList()
        : <LanggananWargaModel>[],
  );

  @override
  Future<LanggananWargaModel> tambah(String nomorLangganan) => _api.post(
    _path,
    body: {'nomorLangganan': nomorLangganan},
    parse: (data) =>
        LanggananWargaModel.fromJson(data as Map<String, dynamic>? ?? const {}),
  );

  @override
  Future<void> hapus(String id) => _api.delete('$_path/$id', parse: (_) {});

  @override
  Future<void> jadikanUtama(String id) =>
      _api.patch('$_path/$id/utama', parse: (_) {});

  @override
  Future<PelangganRingkas> pratinjau(String nomorLangganan) => _api.get(
    '${ApiConfig.publicPath}/pelanggan/$nomorLangganan',
    parse: (data) =>
        PelangganRingkas.fromJson(data as Map<String, dynamic>? ?? const {}),
  );
}

/// Demo: daftar dalam memori yang benar-benar bisa ditambah/dihapus supaya
/// alur kelola langganan bisa dijajal tanpa backend. `static` agar bertahan
/// antar instansiasi repository (satu sesi app), pola sama seperti data
/// demo modul lain.
class DemoLanggananWargaRepository implements LanggananWargaRepository {
  static final List<LanggananWargaModel> _data = [
    const LanggananWargaModel(
      id: 'demo-1',
      isUtama: true,
      nomorLangganan: '00000100119',
      nama: 'Warga Demo',
      alamat: 'Jl. Bada************',
      rt: '003',
      rw: '005',
      status: 'AKTIF',
      golonganKode: '2A1',
      golonganKategori: 'RUMAH_TANGGA',
      jumlahTagihanBelumBayar: 1,
      totalTunggakan: 78500,
    ),
  ];

  static int _urut = 1;

  @override
  Future<List<LanggananWargaModel>> ambil() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return List.of(_data);
  }

  @override
  Future<LanggananWargaModel> tambah(String nomorLangganan) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (_data.any((l) => l.nomorLangganan == nomorLangganan)) {
      throw const ApiException(
        409,
        'CONFLICT',
        'Nomor langganan ini sudah tertaut ke akun Anda.',
      );
    }
    final baru = LanggananWargaModel(
      id: 'demo-baru-${_urut++}',
      isUtama: _data.isEmpty,
      nomorLangganan: nomorLangganan,
      nama: 'Pelanggan Demo Tambahan',
      alamat: 'Jl. Cont************',
      status: 'AKTIF',
      golonganKode: '2A2',
      golonganKategori: 'RUMAH_TANGGA',
      jumlahTagihanBelumBayar: 0,
      totalTunggakan: 0,
    );
    _data.add(baru);
    return baru;
  }

  @override
  Future<void> hapus(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (_data.length <= 1) {
      throw const ApiException(
        400,
        'BAD_REQUEST',
        'Nomor langganan terakhir tidak bisa dihapus — akun warga harus tetap tertaut ke minimal satu langganan.',
      );
    }
    final dihapus = _data.indexWhere((l) => l.id == id);
    if (dihapus == -1) return;
    final utama = _data[dihapus].isUtama;
    _data.removeAt(dihapus);
    if (utama && _data.isNotEmpty) {
      _gantiUtama(_data.first.id);
    }
  }

  @override
  Future<void> jadikanUtama(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _gantiUtama(id);
  }

  void _gantiUtama(String id) {
    for (var i = 0; i < _data.length; i++) {
      final l = _data[i];
      _data[i] = LanggananWargaModel(
        id: l.id,
        isUtama: l.id == id,
        nomorLangganan: l.nomorLangganan,
        nama: l.nama,
        alamat: l.alamat,
        rt: l.rt,
        rw: l.rw,
        status: l.status,
        golonganKode: l.golonganKode,
        golonganKategori: l.golonganKategori,
        jumlahTagihanBelumBayar: l.jumlahTagihanBelumBayar,
        totalTunggakan: l.totalTunggakan,
      );
    }
  }

  @override
  Future<PelangganRingkas> pratinjau(String nomorLangganan) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (nomorLangganan != '00000100119' &&
        !nomorLangganan.startsWith('000002')) {
      throw const ApiException(
        404,
        'VERIFIKASI_GAGAL',
        'Nomor langganan tidak ditemukan. Periksa kembali nomor Anda.',
      );
    }
    return PelangganRingkas(
      nomorLangganan: nomorLangganan,
      nama: nomorLangganan == '00000100119'
          ? 'Warga Demo'
          : 'Pelanggan Demo Tambahan',
      alamat: 'Jl. Bada************',
      status: 'AKTIF',
    );
  }
}

/// Cache dalam memori daftar langganan akun yang sedang login — supaya
/// kartu biodata beranda tidak refetch tiap pindah tab, dan supaya layar
/// lain (Cek Tagihan / Lapor Meter / Pengaduan) bisa mem-prefill nomor
/// utama SECARA SINKRON tanpa menunggu jaringan. Direset saat keluar/ganti
/// sesi (lihat pemanggil di akun_tab_content.dart).
abstract final class LanggananSayaCache {
  static List<LanggananWargaModel>? _data;

  static List<LanggananWargaModel>? get data => _data;

  /// Langganan utama (fallback: baris pertama) — nilai prefill formulir.
  static LanggananWargaModel? get utama => _data == null || _data!.isEmpty
      ? null
      : _data!.firstWhere((l) => l.isUtama, orElse: () => _data!.first);

  static Future<List<LanggananWargaModel>> muat({bool paksa = false}) async {
    if (!paksa && _data != null) return _data!;
    _data = await LanggananWargaRepository.create().ambil();
    return _data!;
  }

  static void reset() => _data = null;
}
