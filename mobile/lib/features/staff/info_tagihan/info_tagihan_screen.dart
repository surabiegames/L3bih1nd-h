import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/models/bill_model.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../public/cek_tagihan/cek_tagihan_hasil.dart';
import '../../public/cek_tagihan/cek_tagihan_repository.dart';
import '../baca_meter/scan_qr_screen.dart';

/// Info Tagihan — alat petugas lapangan untuk memeriksa rekening pelanggan
/// di tempat (padanan Check Tagihan Aurora). Berbagi sumber data & tampilan
/// hasil dengan layar Cek Tagihan publik (`/api/public/cek-tagihan`, jalan
/// walau petugas terautentikasi), ditambah pengisian nomor lewat scan QR
/// kartu meter — sehingga petugas tak perlu mengetik 11 digit di lapangan.
class InfoTagihanScreen extends StatefulWidget {
  const InfoTagihanScreen({super.key});

  @override
  State<InfoTagihanScreen> createState() => _InfoTagihanScreenState();
}

class _InfoTagihanScreenState extends State<InfoTagihanScreen> {
  final _formKey = GlobalKey<ShadFormState>();
  final _kontrol = TextEditingController();
  final _repo = CekTagihanRepository.create();

  bool _memuat = false;
  String? _galat;
  CekTagihanResult? _hasil;

  /// Scanner hanya di Android/iOS (pola guard OcrStand/ScanQr).
  static bool get _scanTersedia =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  void dispose() {
    _kontrol.dispose();
    super.dispose();
  }

  Future<void> _cek() async {
    final form = _formKey.currentState!;
    if (!form.saveAndValidate()) return;
    final nomor = form.value['nomorLangganan'] as String;
    await _jalankan(nomor);
  }

  Future<void> _jalankan(String nomor) async {
    setState(() {
      _memuat = true;
      _galat = null;
      _hasil = null;
    });
    try {
      final hasil = await _repo.cekTagihan(nomor);
      if (!mounted) return;
      setState(() => _hasil = hasil);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _galat = e.message);
    } finally {
      if (mounted) setState(() => _memuat = false);
    }
  }

  Future<void> _scanQr() async {
    final hasil = await Navigator.of(context).push<String>(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const ScanQrScreen(),
        transitionsBuilder: (_, animasi, _, child) =>
            FadeTransition(opacity: animasi, child: child),
      ),
    );
    if (hasil == null || !mounted) return;
    final digit = hasil.replaceAll(RegExp(r'\D'), '');
    if (digit.length < 11) {
      setState(
        () => _galat =
            'QR tidak memuat nomor langganan 11 digit yang valid.',
      );
      return;
    }
    final nomor = digit.substring(digit.length - 11);
    _kontrol.text = nomor;
    await _jalankan(nomor);
  }

  @override
  Widget build(BuildContext context) {
    final hasil = _hasil;

    return AppScaffold(
      title: 'Info Tagihan',
      subtitle: 'Cek rekening pelanggan di lapangan',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ShadCard(
            title: const Text('Nomor Langganan'),
            description: const Text(
              'Ketik 11 digit nomor langganan, atau pindai QR pada kartu '
              'meter pelanggan.',
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ShadForm(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ShadInputFormField(
                      id: 'nomorLangganan',
                      controller: _kontrol,
                      placeholder: const Text('Contoh: 00000100119'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      validator: (v) {
                        if (v.length != 11) {
                          return 'Nomor langganan harus tepat 11 digit angka.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    ShadButton(
                      onPressed: _memuat ? null : _cek,
                      leading: _memuat
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(CupertinoIcons.search),
                      child: Text(_memuat ? 'Memeriksa…' : 'Cek Tagihan'),
                    ),
                    if (_scanTersedia) ...[
                      const SizedBox(height: 8),
                      ShadButton.outline(
                        onPressed: _memuat ? null : _scanQr,
                        leading: const Icon(CupertinoIcons.qrcode_viewfinder),
                        child: const Text('Pindai QR'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (_galat != null) ...[
            const SizedBox(height: 16),
            ShadAlert.destructive(
              icon: const Icon(CupertinoIcons.exclamationmark_circle),
              title: const Text('Pemeriksaan gagal'),
              description: Text(_galat!),
            ),
          ],
          if (hasil != null) ...[
            const SizedBox(height: 16),
            HasilCekTagihanView(hasil: hasil),
          ],
        ],
      ),
    );
  }
}
