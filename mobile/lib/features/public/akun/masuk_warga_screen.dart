import 'package:flutter/widgets.dart';

import '../../../core/widgets/app_scaffold.dart';
import 'daftar_warga_screen.dart';
import 'laporan_saya_screen.dart';
import 'widgets/masuk_warga_form.dart';

/// Layar penuh "Masuk" — chrome halaman (AppScaffold) + navigasi push di
/// sekitar MasukWargaForm. Logika/validasi sesungguhnya ada di
/// widgets/masuk_warga_form.dart (dipakai ulang juga oleh tab Akun pada
/// MainShellScreen tanpa duplikasi).
class MasukWargaScreen extends StatelessWidget {
  const MasukWargaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Masuk',
      subtitle: 'Akun warga — pantau semua laporan Anda',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          MasukWargaForm(
            onSukses: (_) => Navigator.of(context).pushAndRemoveUntil(
              PageRouteBuilder(
                pageBuilder: (_, _, _) => const LaporanSayaScreen(),
                transitionsBuilder: (_, animasi, _, child) =>
                    FadeTransition(opacity: animasi, child: child),
              ),
              (route) => route.isFirst,
            ),
            onTukarKeDaftar: () => Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, _, _) => const DaftarWargaScreen(),
                transitionsBuilder: (_, animasi, _, child) =>
                    FadeTransition(opacity: animasi, child: child),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
