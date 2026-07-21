import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/auth/sesi_warga.dart';
import '../../../../core/network/api_exception.dart';

/// Form masuk akun warga — LOGIKA & VALIDASI SAJA, tanpa Scaffold/chrome
/// halaman. Diekstrak dari MasukWargaScreen supaya form yang sama bisa
/// ditanam di dua tempat tanpa duplikasi: layar penuh (MasukWargaScreen,
/// dipush dari mana pun) dan tab "Akun" pada MainShellScreen (ditanam
/// langsung, tanpa dorong layar baru).
///
/// Tukar email/username + password menjadi Bearer token lewat SesiWarga
/// (POST /api/mobile/auth/login — endpoint yang sama dipakai aplikasi
/// petugas, tidak membedakan role).
class MasukWargaForm extends StatefulWidget {
  const MasukWargaForm({
    super.key,
    required this.onSukses,
    this.onTukarKeDaftar,
  });

  /// Dipanggil dengan akun hasil masuk. Pemanggil yang memutuskan apa
  /// yang terjadi selanjutnya (navigasi penuh, atau sekadar setState
  /// saat form ini ditanam sebagai tab).
  final ValueChanged<WargaAkun> onSukses;

  /// Tautan "Belum punya akun? Daftar". Null = tautan disembunyikan.
  final VoidCallback? onTukarKeDaftar;

  @override
  State<MasukWargaForm> createState() => _MasukWargaFormState();
}

class _MasukWargaFormState extends State<MasukWargaForm> {
  final _formKey = GlobalKey<ShadFormState>();
  bool _mengirim = false;
  String? _galat;

  Future<void> _masuk() async {
    final form = _formKey.currentState!;
    if (!form.saveAndValidate()) return;
    final nilai = form.value;

    setState(() {
      _mengirim = true;
      _galat = null;
    });
    try {
      final akun = await SesiWarga.instance.masuk(
        identifier: (nilai['identifier'] as String).trim(),
        password: nilai['password'] as String,
      );
      if (!mounted) return;
      widget.onSukses(akun);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _galat = e.message);
    } finally {
      if (mounted) setState(() => _mengirim = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ShadForm(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ShadInputFormField(
            id: 'identifier',
            label: const Text('Email'),
            placeholder: const Text('nama@email.com'),
            keyboardType: TextInputType.emailAddress,
            validator: (v) => v.trim().isEmpty ? 'Email wajib diisi.' : null,
          ),
          const SizedBox(height: 16),
          ShadInputFormField(
            id: 'password',
            label: const Text('Password'),
            placeholder: const Text('••••••••'),
            obscureText: true,
            validator: (v) => v.isEmpty ? 'Password wajib diisi.' : null,
          ),
          const SizedBox(height: 24),
          if (_galat != null) ...[
            ShadAlert.destructive(
              icon: const Icon(CupertinoIcons.exclamationmark_circle),
              title: const Text('Tidak dapat masuk'),
              description: Text(_galat!),
            ),
            const SizedBox(height: 16),
          ],
          ShadButton(
            onPressed: _mengirim ? null : _masuk,
            leading: _mengirim
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(CupertinoIcons.arrow_right_square),
            child: Text(_mengirim ? 'Memeriksa…' : 'Masuk'),
          ),
          if (widget.onTukarKeDaftar != null) ...[
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: _mengirim ? null : widget.onTukarKeDaftar,
                child: Text.rich(
                  TextSpan(
                    text: 'Belum punya akun? ',
                    style: theme.textTheme.muted,
                    children: [
                      TextSpan(
                        text: 'Daftar',
                        style: theme.textTheme.muted.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
