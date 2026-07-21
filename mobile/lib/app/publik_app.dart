import 'package:flutter/material.dart'
    show CircularProgressIndicator, ThemeMode;
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/auth/sesi_warga.dart';
import '../core/network/api_config.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_scaffold.dart';
import '../features/public/home/main_shell_screen.dart';

/// Aplikasi PUBLIK "Tirtawening" — layanan pelanggan TANPA login WAJIB:
/// cek tagihan, lapor meter mandiri, pengaduan, lacak tiket. Akun warga
/// (masuk/daftar) OPSIONAL, hanya untuk yang mau riwayat pengaduannya
/// tersimpan otomatis — lihat features/public/akun/.
class PublikApp extends StatelessWidget {
  const PublikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      title: 'Tirtawening',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: ApiConfig.isDemo ? const MainShellScreen() : const GerbangPublik(),
    );
  }
}

/// Memulihkan sesi warga tersimpan (bila ada) SEBELUM beranda pertama kali
/// tampil, supaya kartu akun tidak "berkedip" dari status keluar ke masuk
/// setelah render pertama. Login TETAP opsional — gagal/tidak ada token
/// hanya berarti beranda tampil dalam keadaan anonim, bukan diarahkan ke
/// layar masuk (beda dari GerbangPetugas yang mewajibkan login).
class GerbangPublik extends StatefulWidget {
  const GerbangPublik({super.key});

  @override
  State<GerbangPublik> createState() => _GerbangPublikState();
}

class _GerbangPublikState extends State<GerbangPublik> {
  late final Future<bool> _sesiDipulihkan = SesiWarga.instance.pulihkan();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _sesiDipulihkan,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const AppScaffold(
            title: 'Tirtawening',
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const MainShellScreen();
      },
    );
  }
}
