import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/auth/sesi_petugas.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/logo_perusahaan.dart';
import '../portal/portal_screen.dart';

/// Masuk Petugas — tukar username/email + password menjadi Bearer token
/// (POST /api/mobile/auth/login). Tidak ada tautan daftar: akun petugas
/// dibuat admin lewat dashboard web (aturan FLUTTER.md §4.2). Pesan gagal
/// dari server seragam apa pun sebabnya — tampilkan apa adanya.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _kontrolIdentitas = TextEditingController();
  final _kontrolSandi = TextEditingController();

  bool _sibuk = false;
  bool _sandiTerlihat = false;
  String? _galat;

  @override
  void dispose() {
    _kontrolIdentitas.dispose();
    _kontrolSandi.dispose();
    super.dispose();
  }

  Future<void> _masuk() async {
    final identitas = _kontrolIdentitas.text.trim();
    final sandi = _kontrolSandi.text;
    if (identitas.isEmpty || sandi.isEmpty) {
      setState(
        () => _galat = 'Isi username/email dan password terlebih dahulu.',
      );
      return;
    }

    setState(() {
      _sibuk = true;
      _galat = null;
    });
    try {
      await SesiPetugas.instance.masuk(identifier: identitas, password: sandi);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const PortalScreen(),
          transitionsBuilder: (_, animasi, _, child) =>
              FadeTransition(opacity: animasi, child: child),
        ),
        (_) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _galat = e.message;
        _sibuk = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return PremiumBackground(
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(24),
              children: [
                // Logo resmi perusahaan (sama dengan PortalScreen) — satu
                // bahasa visual sejak layar pertama yang dilihat petugas.
                const Center(child: LogoPerusahaan(ukuran: 72)),
                const SizedBox(height: 18),
                Center(
                  child: Text(
                    'PERUMDA TIRTAWENING',
                    style: theme.textTheme.muted.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text('Portal Petugas', style: theme.textTheme.h2),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'Masuk dengan akun yang didaftarkan admin.',
                    style: theme.textTheme.muted,
                  ),
                ),
                const SizedBox(height: 24),
                GlassPanel(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Username / Email', style: theme.textTheme.small),
                      const SizedBox(height: 6),
                      ShadInput(
                        controller: _kontrolIdentitas,
                        placeholder: const Text('nama.petugas'),
                        leading: const Icon(
                          CupertinoIcons.person_crop_circle_fill,
                          size: 16,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        enabled: !_sibuk,
                      ),
                      const SizedBox(height: 14),
                      Text('Password', style: theme.textTheme.small),
                      const SizedBox(height: 6),
                      ShadInput(
                        controller: _kontrolSandi,
                        placeholder: const Text('••••••••'),
                        leading: const Icon(CupertinoIcons.lock_fill, size: 16),
                        obscureText: !_sandiTerlihat,
                        enabled: !_sibuk,
                        onSubmitted: (_) => _masuk(),
                        trailing: GestureDetector(
                          onTap: () =>
                              setState(() => _sandiTerlihat = !_sandiTerlihat),
                          child: Icon(
                            _sandiTerlihat
                                ? CupertinoIcons.eye_slash
                                : CupertinoIcons.eye,
                            size: 16,
                            color: theme.colorScheme.mutedForeground,
                          ),
                        ),
                      ),
                      if (_galat != null) ...[
                        const SizedBox(height: 14),
                        ShadAlert.destructive(
                          icon: const Icon(
                            CupertinoIcons.exclamationmark_circle,
                          ),
                          title: const Text('Tidak dapat masuk'),
                          description: Text(_galat!),
                        ),
                      ],
                      const SizedBox(height: 18),
                      ShadButton(
                        onPressed: _sibuk ? null : _masuk,
                        leading: _sibuk
                            ? const SizedBox.square(
                                dimension: 15,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                CupertinoIcons.arrow_right_square,
                                size: 16,
                              ),
                        child: Text(_sibuk ? 'Memeriksa…' : 'Masuk'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Lupa password? Atur ulang lewat dashboard web.',
                    style: theme.textTheme.muted.copyWith(fontSize: 11.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Gerbang aplikasi petugas: memulihkan sesi tersimpan lalu memilih layar
/// awal — Portal (sesi hidup) atau Login. Mode demo tidak lewat sini.
class GerbangPetugas extends StatefulWidget {
  const GerbangPetugas({super.key});

  @override
  State<GerbangPetugas> createState() => _GerbangPetugasState();
}

class _GerbangPetugasState extends State<GerbangPetugas> {
  late final Future<bool> _sesiHidup = SesiPetugas.instance.pulihkan();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _sesiHidup,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const PremiumBackground(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data == true
            ? const PortalScreen()
            : const LoginScreen();
      },
    );
  }
}
