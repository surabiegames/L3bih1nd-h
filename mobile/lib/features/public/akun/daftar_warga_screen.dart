import 'package:flutter/widgets.dart';

import '../../../core/widgets/app_scaffold.dart';
import 'laporan_saya_screen.dart';
import 'masuk_warga_screen.dart';
import 'widgets/daftar_warga_form.dart';

/// Layar penuh "Daftar Akun" — chrome halaman (AppScaffold) + navigasi
/// push di sekitar DaftarWargaForm. Logika/validasi sesungguhnya ada di
/// widgets/daftar_warga_form.dart (dipakai ulang juga oleh tab Akun pada
/// MainShellScreen tanpa duplikasi).
class DaftarWargaScreen extends StatelessWidget {
  const DaftarWargaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Daftar Akun',
      subtitle: 'Supaya laporan Anda tersimpan otomatis',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DaftarWargaForm(
            onSukses: (_) => Navigator.of(context).pushAndRemoveUntil(
              PageRouteBuilder(
                pageBuilder: (_, _, _) => const LaporanSayaScreen(),
                transitionsBuilder: (_, animasi, _, child) =>
                    FadeTransition(opacity: animasi, child: child),
              ),
              (route) => route.isFirst,
            ),
            onTukarKeMasuk: () => Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, _, _) => const MasukWargaScreen(),
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
