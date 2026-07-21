import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/auth/sesi_petugas.dart';
import '../core/network/api_client.dart';
import '../core/network/api_config.dart';
import '../core/theme/app_theme.dart';
import '../features/staff/auth/login_screen.dart';
import '../features/staff/portal/portal_screen.dart';

/// Aplikasi PETUGAS "Tirtawening Petugas" — pendukung pembacaan meter di
/// lapangan: rute baca meter (RBM), catat stand + foto bukti, unduh/unggah
/// data offline, dan penanganan tiket gangguan. Verifikasi laporan TIDAK di
/// sini — itu ranah supervisor ke atas / admin kantor di dashboard web.
/// Pintu masuk: GerbangPetugas (pulihkan sesi → Portal / Login); mode demo
/// langsung ke PortalScreen tanpa login.
class PetugasApp extends StatefulWidget {
  const PetugasApp({super.key});

  @override
  State<PetugasApp> createState() => _PetugasAppState();
}

class _PetugasAppState extends State<PetugasApp> {
  final _navigator = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Sesi berakhir di tengah kerja (token 7 hari kedaluwarsa / dicabut):
    // buang sesi lokal lalu kembali ke layar login dari mana pun.
    ApiClient.instance.onUnauthorized = () {
      SesiPetugas.instance.keluar();
      _navigator.currentState?.pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const LoginScreen(),
          transitionsBuilder: (_, animasi, _, child) =>
              FadeTransition(opacity: animasi, child: child),
        ),
        (_) => false,
      );
    };
  }

  @override
  void dispose() {
    ApiClient.instance.onUnauthorized = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      title: 'Tirtawening Petugas',
      navigatorKey: _navigator,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: ApiConfig.isDemo ? const PortalScreen() : const GerbangPetugas(),
    );
  }
}
