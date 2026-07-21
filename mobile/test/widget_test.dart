// Uji asap dua aplikasi dalam mode demo (tanpa API_BASE_URL, tanpa
// jaringan): beranda publik + alur cek tagihan & lacak tiket, portal
// petugas (ruang kerja pencatat/gangguan) + alur rute baca meter
// (catat stand), verifikasi, dan tiket gangguan.

import 'package:flutter/widgets.dart' show Scrollable;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_ui/shadcn_ui.dart' show ShadButton, ShadInput;

import 'package:wipel5/app/petugas_app.dart';
import 'package:wipel5/app/publik_app.dart';
import 'package:wipel5/core/auth/sesi_warga.dart';
import 'package:wipel5/features/public/langganan/langganan_warga_repository.dart';

/// Gulir target ke viewport lalu ketuk. ListView membangun anak secara
/// lazy — widget di bawah lipatan viewport test (800px) belum ada sebelum
/// digulir, jadi scrollUntilVisible dulu (membangun sambil menggulir),
/// baru ensureVisible (meluruskan penuh agar tap mengenai target).
Future<void> ketuk(WidgetTester tester, Finder target) async {
  if (tester.any(find.byType(Scrollable)) && !tester.any(target)) {
    await tester.scrollUntilVisible(
      target,
      120,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    Intl.defaultLocale = 'id_ID';
    await initializeDateFormatting('id_ID');
  });

  group('aplikasi publik', () {
    testWidgets('beranda menampilkan empat layanan mandiri', (tester) async {
      await tester.pumpWidget(const PublikApp());
      await tester.pumpAndSettle();

      // Brand mark memisah "PERUMDA" (label kecil) dari "Tirtawening" (nama)
      // jadi dua Text terpisah — lihat _BrandMark di beranda_hero.dart.
      expect(find.text('PERUMDA'), findsOneWidget);
      expect(find.text('Tirtawening'), findsOneWidget);
      expect(find.text('Cek Tagihan'), findsOneWidget);
      expect(find.text('Lapor Meter'), findsOneWidget);
      // Shortcut gaya launcher memakai label ringkas 'Pengaduan' (layar
      // tujuannya tetap bernama Lapor Pengaduan).
      expect(find.text('Pengaduan'), findsOneWidget);
      expect(find.text('Lacak Tiket'), findsOneWidget);
    });

    testWidgets('alur cek tagihan: nomor demo menampilkan hasil', (
      tester,
    ) async {
      await tester.pumpWidget(const PublikApp());
      await tester.pumpAndSettle();
      await ketuk(tester, find.text('Cek Tagihan'));

      await tester.enterText(find.byType(ShadInput).first, '00000100119');
      await ketuk(tester, find.widgetWithText(ShadButton, 'Cek Tagihan'));

      expect(find.text('ASEP SURYADI'), findsOneWidget);
      expect(find.text('Total Tunggakan'), findsOneWidget);
    });

    testWidgets('alur lacak tiket: nomor valid menampilkan linimasa', (
      tester,
    ) async {
      await tester.pumpWidget(const PublikApp());
      await tester.pumpAndSettle();
      await ketuk(tester, find.text('Lacak Tiket'));

      await tester.enterText(find.byType(ShadInput).first, 'TW-2607-ABC123');
      await ketuk(tester, find.widgetWithText(ShadButton, 'Lacak'));

      expect(find.text('Pipa bocor di depan rumah'), findsOneWidget);

      // Kartu status SELESAI (default demo) menambah baris "Penyelesaian"
      // + kartu AksiPelapor sebelum linimasa — cukup tinggi untuk mendorong
      // "Linimasa Penanganan" ke luar viewport+cacheExtent awal ListView di
      // test (SliverList lazy membangun anak, sama seperti dijelaskan di
      // ketuk() di atas). Gulir dulu, baru periksa.
      await tester.scrollUntilVisible(
        find.text('Linimasa Penanganan'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Linimasa Penanganan'), findsOneWidget);
    });

    testWidgets('masuk demo menampilkan kartu langganan di beranda', (
      tester,
    ) async {
      // SesiWarga singleton — bersihkan sesi demo agar tidak bocor ke uji
      // lain (jangan lewat keluar(): itu menyentuh secure storage yang
      // tidak tersedia di lingkungan uji).
      addTearDown(() {
        SesiWarga.instance.akun = null;
        LanggananSayaCache.reset();
      });

      await tester.pumpWidget(const PublikApp());
      await tester.pumpAndSettle();

      // Tab Akun → form masuk (mode demo: kredensial apa pun diterima).
      await ketuk(tester, find.text('Akun'));
      await tester.enterText(find.byType(ShadInput).at(0), 'demo@warga.id');
      await tester.enterText(find.byType(ShadInput).at(1), 'rahasia123');
      await tester.tap(find.widgetWithText(ShadButton, 'Masuk'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Kembali ke beranda — kartu biodata langganan utama tampil.
      await tester.tap(find.text('Beranda'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Kop kartu: penerbit + jenis kartu (menggantikan label tunggal
      // "KARTU LANGGANAN" pada versi kartu sebelumnya).
      expect(find.text('PERUMDA TIRTAWENING'), findsOneWidget);
      expect(find.text('Kartu Langganan'), findsOneWidget);
      // SectionHeader menampilkan judul dalam huruf kapital.
      expect(find.text('LANGGANAN SAYA'), findsOneWidget);
      expect(find.text('Utama'), findsOneWidget);
    });
  });

  group('aplikasi petugas', () {
    testWidgets('portal memisahkan ruang kerja pencatat & gangguan', (
      tester,
    ) async {
      await tester.pumpWidget(const PetugasApp());
      await tester.pumpAndSettle();

      expect(find.text('Portal Petugas'), findsOneWidget);
      expect(find.text('Pencatat Meter'), findsOneWidget);
      expect(find.text('Petugas Gangguan'), findsOneWidget);

      // Masuk ruang kerja pencatat — launchpad & statistik tampil.
      // Pump melewati latensi demo repo (≤500 ms) agar tidak ada timer
      // tertunda saat tes berakhir.
      await ketuk(tester, find.text('Pencatat Meter'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      // Chart progres target rute (SL sudah/belum dicatat) sebagai pusat.
      expect(find.text('Sudah Dicatat'), findsOneWidget);
      expect(find.text('Belum Dicatat'), findsOneWidget);
      expect(find.textContaining('sambungan langganan (SL)'), findsOneWidget);
      expect(find.text('Baca Meter'), findsOneWidget);
      // Fokus aplikasi pencatat: unduh/unggah data — bukan pilih rute atau
      // verifikasi (rute dipetakan admin; verifikasi ranah kantor).
      expect(find.text('Download'), findsOneWidget);
      expect(find.text('Upload'), findsOneWidget);
      expect(find.text('Pilih Rute'), findsNothing);
      expect(find.text('Verifikasi'), findsNothing);
    });

    testWidgets('tugas gangguan menampilkan tiket dan status SLA', (
      tester,
    ) async {
      await tester.pumpWidget(const PetugasApp());
      await tester.pumpAndSettle();
      await ketuk(tester, find.text('Petugas Gangguan'));
      await ketuk(tester, find.text('Tiket Saya'));

      expect(find.text('TW-2607-K3W9QD'), findsOneWidget);
      expect(find.textContaining('Lewat SLA'), findsWidgets);
    });

    testWidgets(
      'alur baca meter: catat stand pelanggan menambah progres rute',
      (tester) async {
        await tester.pumpWidget(const PetugasApp());
        await tester.pumpAndSettle();
        await ketuk(tester, find.text('Pencatat Meter'));
        await ketuk(tester, find.text('Baca Meter'));

        expect(find.textContaining('target'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('DADANG SUPRIATNA'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await ketuk(tester, find.text('DADANG SUPRIATNA'));

        // Stand lalu ter-prefill dari riwayat; input stand baru → pemakaian
        // dihitung langsung.
        expect(find.text('2210'), findsOneWidget);
        await tester.enterText(find.byType(ShadInput).first, '2229');
        await tester.pumpAndSettle();
        expect(find.textContaining('19'), findsWidgets);

        await ketuk(
          tester,
          find.widgetWithText(ShadButton, 'Simpan Hasil Baca'),
        );
        await ketuk(tester, find.widgetWithText(ShadButton, 'Simpan'));

        // Alur jalan: setelah tersimpan, layar menawarkan pelanggan
        // berikutnya yang belum dibaca — kembali ke daftar untuk memeriksa
        // progres.
        await ketuk(
          tester,
          find.widgetWithText(ShadButton, 'Kembali ke Daftar'),
        );

        // Kembali ke daftar — baris DADANG kini tercatat (progres bertambah).
        expect(find.text('3 dari 8 target'), findsOneWidget);
      },
    );

    testWidgets(
      'baca meter multi-rute: daftar dikelompokkan per rute dengan header',
      (tester) async {
        await tester.pumpWidget(const PetugasApp());
        await tester.pumpAndSettle();
        await ketuk(tester, find.text('Pencatat Meter'));
        await ketuk(tester, find.text('Baca Meter'));

        // Petugas demo memegang 2 rute → badge "2 rute" + header per rute.
        expect(find.text('2 rute'), findsWidgets);
        expect(find.text('Rute R-042'), findsOneWidget);
        expect(find.text('Rute R-043'), findsOneWidget);
      },
    );

    testWidgets('riwayat menampilkan hasil catat sendiri dengan status', (
      tester,
    ) async {
      await tester.pumpWidget(const PetugasApp());
      await tester.pumpAndSettle();
      await ketuk(tester, find.text('Pencatat Meter'));
      await ketuk(tester, find.text('Riwayat'));

      // Baris demo yang sudah tercatat (minimal ASEP & RINA; test catat
      // sebelumnya bisa menambah baris — state demo dibagi satu proses)
      // tampil dengan status verifikasinya.
      expect(find.text('ASEP SURYADI'), findsOneWidget);
      expect(find.text('RINA MARLINA'), findsOneWidget);
      expect(find.text('Diverifikasi'), findsWidgets);
      expect(find.text('Menunggu Verifikasi'), findsWidgets);
    });

    testWidgets('upload data kosong menampilkan keadaan aman', (tester) async {
      await tester.pumpWidget(const PetugasApp());
      await tester.pumpAndSettle();
      await ketuk(tester, find.text('Pencatat Meter'));
      await ketuk(tester, find.text('Upload'));

      expect(find.text('Semua hasil catat sudah terunggah.'), findsOneWidget);
    });

    testWidgets('download data menampilkan keadaan data tersimpan', (
      tester,
    ) async {
      await tester.pumpWidget(const PetugasApp());
      await tester.pumpAndSettle();
      await ketuk(tester, find.text('Pencatat Meter'));
      await ketuk(tester, find.text('Download'));

      // Keadaan data lokal (demo: rute R-042 dengan 8 pelanggan) + tombol
      // unduh eksplisit.
      expect(find.text('Data tersimpan di perangkat'), findsOneWidget);
      expect(find.text('Pelanggan rute'), findsOneWidget);
      expect(
        find.widgetWithText(ShadButton, 'Unduh Ulang Data Terbaru'),
        findsOneWidget,
      );
    });
  });
}
