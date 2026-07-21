import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, LengthLimitingTextInputFormatter;
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/auth/sesi_warga.dart';
import '../../../../core/network/api_exception.dart';
import '../../langganan/widgets/pratinjau_pelanggan.dart';

const _panjangPasswordMin = 8;

/// Form daftar akun warga — LOGIKA & VALIDASI SAJA, tanpa Scaffold/chrome
/// halaman. Diekstrak dari DaftarWargaScreen dengan alasan yang sama
/// seperti MasukWargaForm: dipakai baik sebagai layar penuh maupun
/// ditanam di tab "Akun" (MainShellScreen).
///
/// POST /api/public/auth/register, role selalu USER. Beda dari akun
/// internal (STAFF ke atas, admin-provisioned lewat dashboard web) —
/// endpoint ini TIDAK PERNAH membuat akun berkuasa apa pun. Setelah
/// daftar, langsung masuk (SesiWarga.daftar menggabungkan register+login).
class DaftarWargaForm extends StatefulWidget {
  const DaftarWargaForm({
    super.key,
    required this.onSukses,
    this.onTukarKeMasuk,
  });

  /// Dipanggil dengan akun hasil daftar (sudah otomatis masuk).
  final ValueChanged<WargaAkun> onSukses;

  /// Tautan "Sudah punya akun? Masuk". Null = tautan disembunyikan.
  final VoidCallback? onTukarKeMasuk;

  @override
  State<DaftarWargaForm> createState() => _DaftarWargaFormState();
}

class _DaftarWargaFormState extends State<DaftarWargaForm> {
  final _formKey = GlobalKey<ShadFormState>();
  bool _mengirim = false;
  String? _galat;

  /// Nilai input nomor langganan terkini — menggerakkan kartu
  /// PratinjauPelanggan di bawah field-nya (widget itu yang memutuskan
  /// kapan layak fetch, lihat komentarnya).
  String _nomorLangganan = '';

  Future<void> _daftar() async {
    final form = _formKey.currentState!;
    if (!form.saveAndValidate()) return;
    final nilai = form.value;

    setState(() {
      _mengirim = true;
      _galat = null;
    });
    try {
      final akun = await SesiWarga.instance.daftar(
        nama: (nilai['nama'] as String).trim(),
        email: (nilai['email'] as String).trim().toLowerCase(),
        password: nilai['password'] as String,
        nomorLangganan: (nilai['nomorLangganan'] as String).trim(),
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
            id: 'nama',
            label: const Text('Nama lengkap'),
            placeholder: const Text('Nama Anda'),
            validator: (v) => v.trim().length < 2 ? 'Nama wajib diisi.' : null,
          ),
          const SizedBox(height: 16),
          ShadInputFormField(
            id: 'email',
            label: const Text('Email'),
            placeholder: const Text('nama@email.com'),
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
                v.trim().contains('@') ? null : 'Format email tidak valid.',
          ),
          const SizedBox(height: 16),
          // WAJIB (kontrak register 2026-07-19): nomor pertama otomatis jadi
          // langganan UTAMA — biodatanya yang tampil di beranda. Nomor lain
          // bisa ditambahkan belakangan lewat Kelola Nomor Langganan.
          ShadInputFormField(
            id: 'nomorLangganan',
            label: const Text('Nomor langganan'),
            placeholder: const Text('11 digit, contoh: 00000100119'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            description: const Text(
              'Ada di lembar tagihan air Anda. Bisa menambah nomor lain setelah mendaftar.',
            ),
            onChanged: (v) => setState(() => _nomorLangganan = v.trim()),
            validator: (v) => RegExp(r'^\d{11}$').hasMatch(v.trim())
                ? null
                : 'Nomor langganan harus 11 digit angka.',
          ),
          PratinjauPelanggan(nomor: _nomorLangganan),
          const SizedBox(height: 16),
          ShadInputFormField(
            id: 'password',
            label: const Text('Password'),
            placeholder: const Text('••••••••'),
            obscureText: true,
            description: Text('Minimal $_panjangPasswordMin karakter.'),
            validator: (v) => v.length < _panjangPasswordMin
                ? 'Password minimal $_panjangPasswordMin karakter.'
                : null,
          ),
          const SizedBox(height: 16),
          ShadInputFormField(
            id: 'konfirmasi',
            label: const Text('Konfirmasi password'),
            placeholder: const Text('••••••••'),
            obscureText: true,
            validator: (v) {
              final sandi = _formKey.currentState?.value['password'] as String?;
              return v != sandi ? 'Konfirmasi password tidak sama.' : null;
            },
          ),
          const SizedBox(height: 24),
          if (_galat != null) ...[
            ShadAlert.destructive(
              icon: const Icon(CupertinoIcons.exclamationmark_circle),
              title: const Text('Gagal mendaftar'),
              description: Text(_galat!),
            ),
            const SizedBox(height: 16),
          ],
          ShadButton(
            onPressed: _mengirim ? null : _daftar,
            leading: _mengirim
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(CupertinoIcons.person_add_solid),
            child: Text(_mengirim ? 'Mendaftar…' : 'Daftar akun'),
          ),
          if (widget.onTukarKeMasuk != null) ...[
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: _mengirim ? null : widget.onTukarKeMasuk,
                child: Text.rich(
                  TextSpan(
                    text: 'Sudah punya akun? ',
                    style: theme.textTheme.muted,
                    children: [
                      TextSpan(
                        text: 'Masuk',
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
