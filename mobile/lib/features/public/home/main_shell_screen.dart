import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/widgets.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../akun/akun_tab_content.dart';
import '../akun/laporan_saya_screen.dart';
import 'beranda_publik_screen.dart';
import 'widgets/bottom_dock.dart';

/// Shell utama app publik: 3 tab NYATA (Beranda, Laporan Saya, Akun) di
/// atas BottomDock mengambang — padanan MainShell pada mockup referensi,
/// disesuaikan ke kapabilitas API yang sungguh-sungguh ada.
///
/// SENGAJA HANYA 3 tab, bukan 5 seperti mockup (Beranda/Tagihan/Laporan/
/// Riwayat/Profil): "Tagihan" & "Riwayat Transaksi" pada mockup itu
/// mengandaikan tagihan tertaut ke akun + ada alur bayar online — dua
/// hal yang TIDAK ada di API ini (cek-tagihan tetap lookup manual per
/// nomor langganan, tidak ada endpoint pembayaran). Menambahkan tab untuk
/// fitur yang tidak nyata hanya akan jadi tombol mati.
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _index = 0;

  /// Naik setiap kali sesi warga berubah (masuk/daftar/keluar). Dipakai
  /// sebagai bagian dari `key` tab Laporan Saya/Akun supaya Flutter
  /// me-remount (initState ulang -> data dimuat ulang) tepat saat status
  /// login berubah — IndexedStack SENGAJA menjaga semua tab tetap hidup
  /// di balik layar (state tidak hilang saat pindah tab), yang tanpa
  /// mekanisme ini justru membuat tab Laporan Saya tetap menampilkan
  /// error/data basi dari sebelum pengguna masuk.
  int _sesiVersion = 0;

  void _pindahKe(int index) => setState(() => _index = index);

  void _sesiBerubah() {
    setState(() {
      _sesiVersion++;
    });
  }

  // Ikon outline (tidak aktif) vs filled (aktif) — pola khas tab bar iOS
  // (mis. SF Symbol "house" vs "house.fill").
  static const _items = [
    DockItem(
      ikon: CupertinoIcons.house,
      ikonAktif: CupertinoIcons.house_fill,
      label: 'Beranda',
    ),
    DockItem(
      ikon: CupertinoIcons.doc_text,
      ikonAktif: CupertinoIcons.doc_text_fill,
      label: 'Laporan',
    ),
    DockItem(
      ikon: CupertinoIcons.person_crop_circle,
      ikonAktif: CupertinoIcons.person_crop_circle_fill,
      label: 'Akun',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tabs = [
      BerandaPublikScreen(
        key: ValueKey('beranda-$_sesiVersion'),
        onBukaAkun: () => _pindahKe(2),
        onBukaLaporan: () => _pindahKe(1),
      ),
      // TANPA AppScaffold pembungkus — beda dari tab Akun di bawah.
      // LaporanSayaScreen SUDAH membawa AppScaffold-nya sendiri (lengkap
      // dengan tombol keluar di kanan atas); membungkusnya lagi membuat
      // judul "Laporan Saya" tampil DUA KALI, bertumpuk. AkunTabContent
      // memang isi-saja, jadi ia yang butuh pembungkus.
      _DenganRuangDock(
        child: LaporanSayaScreen(
          key: ValueKey('laporan-saya-$_sesiVersion'),
          onPerluMasuk: () => _pindahKe(2),
        ),
      ),
      _DenganRuangDock(
        child: AppScaffold(
          title: 'Akun',
          body: AkunTabContent(
            key: ValueKey('akun-$_sesiVersion'),
            onBerubah: _sesiBerubah,
          ),
        ),
      ),
    ];

    return Stack(
      children: [
        Positioned.fill(
          child: IndexedStack(index: _index, children: tabs),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: BottomDock(
            items: _items,
            currentIndex: _index,
            onTap: _pindahKe,
          ),
        ),
      ],
    );
  }
}

/// Memberi ruang kosong di bawah supaya konten tab tidak tertutup
/// BottomDock yang mengambang di atasnya. Beranda sudah mengurus jaraknya
/// sendiri (scroll sliver dengan padding bawah) — pembungkus ini hanya
/// untuk tab yang memakai AppScaffold biasa.
class _DenganRuangDock extends StatelessWidget {
  const _DenganRuangDock({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 66), child: child);
  }
}
