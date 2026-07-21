import '../../../core/models/bill_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/formatters.dart';

/// Sumber data layar Cek Tagihan.
abstract interface class CekTagihanRepository {
  /// Mode demo (tanpa API_BASE_URL) memakai data contoh dalam memori.
  factory CekTagihanRepository.create() => ApiConfig.isDemo
      ? DemoCekTagihanRepository()
      : ApiCekTagihanRepository(ApiClient.instance);

  /// Verifikasi identitas cukup nomor langganan PERSIS 11 digit (exact
  /// match). Pesan gagal dari server sengaja seragam untuk nomor tak
  /// dikenal — jangan membeda-bedakan sebabnya di UI.
  Future<CekTagihanResult> cekTagihan(String nomorLangganan);
}

class ApiCekTagihanRepository implements CekTagihanRepository {
  ApiCekTagihanRepository(this._api);

  final ApiClient _api;

  @override
  Future<CekTagihanResult> cekTagihan(String nomorLangganan) {
    return _api.post(
      '${ApiConfig.publicPath}/cek-tagihan',
      body: {'nomorLangganan': nomorLangganan},
      parse: (data) =>
          CekTagihanResult.fromJson(data as Map<String, dynamic>? ?? const {}),
    );
  }
}

/// Data contoh: nomor langganan demo `00000100119`.
class DemoCekTagihanRepository implements CekTagihanRepository {
  static const nomorDemo = '00000100119';

  @override
  Future<CekTagihanResult> cekTagihan(String nomorLangganan) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (nomorLangganan != nomorDemo) {
      // Meniru pesan seragam server.
      throw const ApiException(
        404,
        'NOT_FOUND',
        'Data pelanggan tidak ditemukan. Periksa kembali nomor langganan Anda.',
      );
    }

    final sekarang = DateTime.now();
    final bulanIni = thblDariDate(DateTime(sekarang.year, sekarang.month));
    int periodeMundur(int n) {
      final d = dateDariThbl(bulanIni);
      return thblDariDate(DateTime.utc(d.year, d.month - n, 1));
    }

    BillModel tagihan(int mundur, int pemakaian, String status) {
      final periode = periodeMundur(mundur);
      final hargaAir = pemakaian * 7200;
      final total = hargaAir + 25000 + 5000 + (hargaAir * 25) ~/ 100;
      final awalBulan = dateDariThbl(periode);
      return BillModel(
        periode: periode,
        status: status,
        totalTagihan: total,
        pemakaianM3: pemakaian,
        jmlHargaAir: hargaAir,
        beaBeban: 25000,
        beaAdmin: 5000,
        airKotor: (hargaAir * 25) ~/ 100,
        lainLain: 0,
        denda: status == 'JATUH_TEMPO' ? 10000 : 0,
        tanggalJatuhTempo: DateTime.utc(
          awalBulan.year,
          awalBulan.month + 1,
          20,
        ),
        tanggalBayar: status == 'SUDAH_BAYAR'
            ? DateTime.utc(awalBulan.year, awalBulan.month + 1, 12)
            : null,
        standLalu: 1180 - pemakaian * (mundur + 1),
        standAkhir: 1180 - pemakaian * mundur,
      );
    }

    final daftar = [
      tagihan(0, 18, 'BELUM_BAYAR'),
      tagihan(1, 21, 'JATUH_TEMPO'),
      tagihan(2, 17, 'SUDAH_BAYAR'),
      tagihan(3, 19, 'SUDAH_BAYAR'),
      tagihan(4, 16, 'SUDAH_BAYAR'),
      tagihan(5, 20, 'SUDAH_BAYAR'),
    ];

    return CekTagihanResult(
      pelanggan: const CustomerInfo(
        nomorLangganan: nomorDemo,
        nama: 'ASEP SURYADI',
        alamat: 'Jl. Badak Singa No. ** (disamarkan)',
        rt: '03',
        rw: '05',
        status: 'AKTIF',
        tarifGolongan: '2A2',
      ),
      tagihan: daftar,
      totalTunggakan: daftar
          .where((t) => t.menunggak)
          .fold(0, (n, t) => n + t.totalTagihan),
    );
  }
}
