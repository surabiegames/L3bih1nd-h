import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wipel5/core/theme/app_theme.dart';
import 'package:wipel5/features/public/langganan/langganan_warga_repository.dart';
import 'package:wipel5/features/public/langganan/widgets/kartu_langganan.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// KartuLangganan dipakai di dua tempat dengan tinggi TETAP (rongga saat
/// memuat + PageView multi-kartu di LanggananSayaSection, konstanta
/// `_tinggiKartu`). Angka itu tidak bisa ditebak dari kode — kalau kartu
/// tumbuh melewatinya, Flutter menampilkan garis overflow kuning di
/// beranda. Uji ini mengukur tinggi sebenarnya supaya perubahan isi kartu
/// ketahuan di sini, bukan di layar pengguna.
const _tinggiKartuDiSection = 240.0;

LanggananWargaModel _contoh({
  String nama = 'Bapak Contoh Nama Pelanggan',
  String alamat = 'Jl. Contoh Alamat Yang Panjang No. 123',
  String nomor = '00000100119',
  String status = 'AKTIF',
  String? golongan = '2A',
  num tunggakan = 0,
  int jumlahTagihan = 0,
  bool utama = true,
}) => LanggananWargaModel(
  id: 'x',
  isUtama: utama,
  nomorLangganan: nomor,
  nama: nama,
  alamat: alamat,
  status: status,
  golonganKode: golongan,
  jumlahTagihanBelumBayar: jumlahTagihan,
  totalTunggakan: tunggakan,
);

Future<double> _tinggiKartu(
  WidgetTester tester,
  LanggananWargaModel langganan, {
  double lebar = 360,
}) async {
  await tester.pumpWidget(
    ShadApp(
      theme: AppTheme.light(),
      home: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: lebar,
          child: KartuLangganan(langganan: langganan),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return tester.getSize(find.byType(KartuLangganan)).height;
}

void main() {
  testWidgets('kartu muat dalam tinggi tetap milik LanggananSayaSection', (
    tester,
  ) async {
    final tinggi = await _tinggiKartu(tester, _contoh());
    expect(
      tinggi,
      lessThanOrEqualTo(_tinggiKartuDiSection),
      reason:
          'Kartu ($tinggi) melebihi _tinggiKartu di langganan_saya_section.dart '
          '($_tinggiKartuDiSection) — beranda akan overflow.',
    );
  });

  testWidgets('kartu tidak overflow pada layar sempit dengan isi terpanjang', (
    tester,
  ) async {
    // Kasus terburuk: nama & alamat panjang, tunggakan (label kaki jadi
    // "Tunggakan (12 tagihan)"), chip status + golongan, di lebar 320 —
    // ponsel kecil yang masih lazim.
    final tinggi = await _tinggiKartu(
      tester,
      _contoh(
        nama: 'Hj. Nama Pelanggan Yang Sangat Panjang Sekali Binti Fulan',
        alamat: 'Jl. Nama Jalan Panjang Sekali Gang Melati III No. 456 RT 07',
        status: 'TIDAK_AKTIF',
        tunggakan: 3012345,
        jumlahTagihan: 12,
      ),
      lebar: 320,
    );
    expect(tinggi, lessThanOrEqualTo(_tinggiKartuDiSection));
    expect(tester.takeException(), isNull);
  });

  testWidgets('nomor non-11-digit tidak melempar RangeError', (tester) async {
    // Data lama bisa punya nomor lebih pendek; format 5-3-3 dilewati,
    // kartu tetap tampil apa adanya.
    await _tinggiKartu(tester, _contoh(nomor: '12345'));
    expect(find.text('12345'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
