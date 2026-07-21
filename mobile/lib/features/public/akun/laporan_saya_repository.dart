import '../../../core/models/complaint_ticket_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';

/// Sumber data layar "Laporan Saya" — GET /api/v1/pengaduan/saya, tiket yang
/// DIBUAT akun warga yang sedang login (lihat catatan di
/// server/modules/pengaduan/pengaduan.router.ts). TANPA requireRole di sisi
/// server — endpoint ini memang dibuka untuk role USER, beda dari `GET
/// /pengaduan` biasa yang STAFF_UP.
abstract interface class LaporanSayaRepository {
  factory LaporanSayaRepository.create() => ApiConfig.isDemo
      ? DemoLaporanSayaRepository()
      : ApiLaporanSayaRepository(ApiClient.instance);

  Future<List<ComplaintTicketModel>> ambil();
}

class ApiLaporanSayaRepository implements LaporanSayaRepository {
  ApiLaporanSayaRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<ComplaintTicketModel>> ambil() async {
    final hasil = await _api.getList(
      '${ApiConfig.v1Path}/pengaduan/saya',
      query: {'pageSize': 50},
      parseRow: ComplaintTicketModel.fromJson,
    );
    return hasil.rows;
  }
}

/// Cache satu-kali-per-sesi untuk tiket milik akun — pola SAMA dengan
/// LanggananSayaCache. Ada karena tiket yang sama kini dibaca dua tempat:
/// blok "Tiket Aktif" di beranda DAN layar Laporan Saya. Tanpa cache,
/// membuka app memanggil `GET /pengaduan/saya` dua kali.
///
/// Yang me-reset: perubahan sesi (masuk/keluar) dan pengiriman pengaduan
/// baru — keduanya membuat isi cache tidak lagi mewakili keadaan.
abstract final class LaporanSayaCache {
  static List<ComplaintTicketModel>? _data;

  static List<ComplaintTicketModel>? get data => _data;

  /// Tiket yang MASIH BERJALAN — yang pantas menempati ruang di beranda.
  /// DITUTUP/DITOLAK tidak menuntut apa pun lagi dari pelapor, jadi ia
  /// tinggal di layar Laporan Saya saja.
  static List<ComplaintTicketModel> get aktif => (_data ?? const [])
      .where((t) => t.status != 'DITUTUP' && t.status != 'DITOLAK')
      .toList();

  static Future<List<ComplaintTicketModel>> muat({bool paksa = false}) async {
    if (!paksa && _data != null) return _data!;
    _data = await LaporanSayaRepository.create().ambil();
    return _data!;
  }

  static void reset() => _data = null;
}

class DemoLaporanSayaRepository implements LaporanSayaRepository {
  @override
  Future<List<ComplaintTicketModel>> ambil() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final sekarang = DateTime.now();
    return [
      ComplaintTicketModel(
        id: 'saya-1',
        nomorTiket: 'TW-2607-D3M0AK',
        jenis: 'AIR_MATI',
        judul: 'Air mati sejak semalam (demo)',
        deskripsi: '',
        status: 'DITUGASKAN',
        prioritas: 'TINGGI',
        pelapor: 'Warga Demo',
        createdAt: sekarang.subtract(const Duration(hours: 5)),
        sla: SlaInfo(
          targetSelesaiAt: sekarang.add(const Duration(hours: 19)),
          sisaMenit: 19 * 60,
        ),
        ditugaskanKe: 'Petugas Demo',
      ),
      ComplaintTicketModel(
        id: 'saya-2',
        nomorTiket: 'TW-2606-P0LKA1',
        jenis: 'METER_RUSAK',
        judul: 'Angka meter tidak berputar (demo)',
        deskripsi: '',
        status: 'DITUTUP',
        prioritas: 'NORMAL',
        pelapor: 'Warga Demo',
        createdAt: sekarang.subtract(const Duration(days: 12)),
      ),
    ];
  }
}
