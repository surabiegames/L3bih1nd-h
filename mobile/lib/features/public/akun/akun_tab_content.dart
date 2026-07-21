import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/auth/sesi_warga.dart';
import '../langganan/kelola_langganan_screen.dart';
import '../langganan/langganan_warga_repository.dart';
import 'laporan_saya_repository.dart';
import 'widgets/daftar_warga_form.dart';
import 'widgets/masuk_warga_form.dart';

/// Konten tab "Akun" pada MainShellScreen — TANPA Scaffold/back-chevron
/// (shell yang menyediakan chrome). Mengelola toggle masuk/daftar sendiri
/// lewat state lokal (bukan push layar baru, karena ini sudah tab, bukan
/// rute berdiri sendiri), dan menampilkan profil + tombol keluar begitu
/// sudah login.
///
/// `onBerubah` dipanggil setiap kali sesi berubah (masuk/daftar/keluar)
/// supaya MainShellScreen bisa me-remount tab lain yang datanya
/// bergantung pada status login (lihat catatan _sesiVersion di
/// main_shell_screen.dart).
class AkunTabContent extends StatefulWidget {
  const AkunTabContent({super.key, required this.onBerubah});

  final VoidCallback onBerubah;

  @override
  State<AkunTabContent> createState() => _AkunTabContentState();
}

class _AkunTabContentState extends State<AkunTabContent> {
  bool _modeDaftar = false;

  Future<void> _keluar() async {
    await SesiWarga.instance.keluar();
    // Langganan tertaut DAN tiket milik sesi yang barusan berakhir —
    // jangan sampai terbaca akun berikutnya.
    LanggananSayaCache.reset();
    LaporanSayaCache.reset();
    if (mounted) widget.onBerubah();
  }

  void _bukaKelolaLangganan() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const KelolaLanggananScreen(),
        transitionsBuilder: (_, animasi, _, child) =>
            FadeTransition(opacity: animasi, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final akun = SesiWarga.instance.akun;
    final theme = ShadTheme.of(context);

    if (akun != null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ShadCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        CupertinoIcons.person_crop_circle_fill,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(akun.name, style: theme.textTheme.large),
                          if (akun.email != null)
                            Text(
                              akun.email!,
                              style: theme.textTheme.muted,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ShadButton.outline(
                  width: double.infinity,
                  leading: const Icon(CupertinoIcons.creditcard),
                  onPressed: _bukaKelolaLangganan,
                  child: const Text('Kelola Nomor Langganan'),
                ),
                const SizedBox(height: 10),
                ShadButton.outline(
                  width: double.infinity,
                  leading: const Icon(CupertinoIcons.square_arrow_right),
                  onPressed: _keluar,
                  child: const Text('Keluar'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(_modeDaftar ? 'Daftar Akun' : 'Masuk', style: theme.textTheme.h4),
        const SizedBox(height: 4),
        Text(
          _modeDaftar
              ? 'Tautkan nomor langganan Anda — biodata & tunggakan tampil di beranda, laporan tersimpan otomatis.'
              : 'Pantau semua laporan pengaduan yang pernah Anda kirim.',
          style: theme.textTheme.muted,
        ),
        const SizedBox(height: 20),
        if (_modeDaftar)
          DaftarWargaForm(
            onSukses: (_) => widget.onBerubah(),
            onTukarKeMasuk: () => setState(() => _modeDaftar = false),
          )
        else
          MasukWargaForm(
            onSukses: (_) => widget.onBerubah(),
            onTukarKeDaftar: () => setState(() => _modeDaftar = true),
          ),
      ],
    );
  }
}
