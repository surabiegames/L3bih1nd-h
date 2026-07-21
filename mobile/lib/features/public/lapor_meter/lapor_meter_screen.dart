import 'dart:io';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/auth/sesi_warga.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/services/kompres_foto.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/kotak_foto_bukti.dart';
import '../langganan/langganan_warga_repository.dart';
import 'lapor_meter_repository.dart';

/// Lapor Meter Mandiri — pelanggan memfoto & melaporkan angka meternya
/// sendiri setiap bulan. Laporan masuk berstatus MENUNGGU sampai petugas
/// memverifikasinya menjadi pembacaan resmi.
class LaporMeterScreen extends StatefulWidget {
  const LaporMeterScreen({super.key});

  @override
  State<LaporMeterScreen> createState() => _LaporMeterScreenState();
}

class _LaporMeterScreenState extends State<LaporMeterScreen> {
  final _formKey = GlobalKey<ShadFormState>();
  final _repo = LaporMeterRepository.create();
  final _pemilihFoto = ImagePicker();

  bool _mengirim = false;
  bool _memprosesFoto = false;
  String? _galat;

  /// Path foto meter yang SUDAH dikompres + diberi stempel waktu.
  /// Server MEWAJIBKAN foto ini (POST /api/public/lapor-meter menolak
  /// 400 tanpa field `foto`), jadi tanpa ini formulir tidak bisa dikirim.
  String? _fotoPath;

  Future<void> _pilihFoto() async {
    final aksi = await showShadDialog<String>(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: const Text('Foto Meter'),
        description: const Text(
          'Ambil foto angka meter dengan jelas. Waktu pengambilan akan '
          'dicap otomatis pada foto sebagai bukti.',
        ),
        actions: [
          if (_fotoPath != null)
            ShadButton.destructive(
              onPressed: () => Navigator.of(context).pop('hapus'),
              child: const Text('Hapus'),
            ),
          ShadButton.outline(
            onPressed: () => Navigator.of(context).pop('galeri'),
            child: const Text('Galeri'),
          ),
          ShadButton(
            onPressed: () => Navigator.of(context).pop('kamera'),
            child: const Text('Kamera'),
          ),
        ],
      ),
    );
    if (aksi == null || !mounted) return;

    if (aksi == 'hapus') {
      setState(() => _fotoPath = null);
      return;
    }

    setState(() {
      _memprosesFoto = true;
      _galat = null;
    });
    try {
      final berkas = await _pemilihFoto.pickImage(
        source: aksi == 'kamera' ? ImageSource.camera : ImageSource.gallery,
      );
      if (berkas == null || !mounted) {
        setState(() => _memprosesFoto = false);
        return;
      }

      // Kompresi WAJIB, bukan hiasan: foto kamera HP 3-8 MB melewati batas
      // 5 MB milik server (MAKS_UKURAN_BYTE di server/lib/storage.ts) dan
      // ditolak mentah-mentah. 600 px + kualitas 80 = puluhan KB, angka
      // yang sama dengan app petugas sehingga hasilnya sama-sama terbaca
      // di panel verifikasi.
      final tmp = await getTemporaryDirectory();
      final hasil = await const KompresFoto().proses(
        sumberPath: berkas.path,
        tujuanPath:
            '${tmp.path}/lapor_meter_${DateTime.now().millisecondsSinceEpoch}.jpg',
        keterangan: SesiWarga.instance.akun?.name ?? 'PELAPOR MANDIRI',
      );
      if (!mounted) return;
      setState(() {
        _fotoPath = hasil;
        _memprosesFoto = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _memprosesFoto = false;
        _galat =
            'Gagal mengambil foto. Coba pilih dari Galeri bila kamera tidak '
            'tersedia di perangkat ini.';
      });
    }
  }

  Future<void> _konfirmasiLaluKirim() async {
    final form = _formKey.currentState!;
    if (!form.saveAndValidate()) return;
    final nilai = form.value;

    final nomor = nilai['nomorLangganan'] as String;
    final stand = nilai['standDilaporkan'] as String;
    final nama = nilai['namaPelapor'] as String;
    final kontak = nilai['nomorPelapor'] as String;

    // Dicegat di sini, bukan dibiarkan gagal di server: pesan servernya
    // benar tapi baru muncul setelah seluruh formulir terkirim.
    if (_fotoPath == null) {
      setState(
        () => _galat =
            'Foto meter wajib dilampirkan sebagai bukti. Ketuk kotak foto '
            'di atas untuk mengambilnya.',
      );
      return;
    }

    final lanjut = await showShadDialog<bool>(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Konfirmasi Laporan'),
        description: const Text(
          'Periksa kembali data berikut sebelum dikirim. Angka meter yang '
          'keliru dapat memengaruhi tagihan Anda.',
        ),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Periksa Lagi'),
          ),
          ShadButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Kirim Laporan'),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BarisKonfirmasi(label: 'No. Langganan', nilai: nomor),
              _BarisKonfirmasi(label: 'Angka Meter', nilai: '$stand m³'),
              _BarisKonfirmasi(label: 'Pelapor', nilai: nama),
              _BarisKonfirmasi(label: 'Kontak', nilai: kontak),
            ],
          ),
        ),
      ),
    );
    if (lanjut != true || !mounted) return;

    setState(() {
      _mengirim = true;
      _galat = null;
    });
    try {
      final tanda = await _repo.kirim(
        nomorLangganan: nomor,
        standDilaporkan: int.parse(stand),
        namaPelapor: nama,
        nomorPelapor: kontak,
        fotoBytes: await File(_fotoPath!).readAsBytes(),
        namaFoto: 'meter.jpg',
      );
      if (!mounted) return;
      _formKey.currentState!.reset();
      setState(() => _fotoPath = null);
      await showShadDialog<void>(
        context: context,
        builder: (context) => ShadDialog.alert(
          title: const Text('Laporan Terkirim'),
          description: Text(
            '${tanda.pesan}\n\nPeriode: ${labelPeriode(tanda.periode)}\n'
            'Angka dilaporkan: ${tanda.standDilaporkan} m³',
          ),
          actions: [
            ShadButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Selesai'),
            ),
          ],
        ),
      );
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

    return AppScaffold(
      title: 'Lapor Meter Mandiri',
      subtitle: 'Laporkan angka meter bulan ini',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ShadForm(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ShadInputFormField(
                  id: 'nomorLangganan',
                  // Prefill nomor UTAMA akun yang login; anonim = kosong.
                  initialValue: LanggananSayaCache.utama?.nomorLangganan,
                  label: const Text('Nomor Langganan'),
                  placeholder: const Text('11 digit nomor langganan'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  validator: (v) => v.length != 11
                      ? 'Nomor langganan harus tepat 11 digit angka.'
                      : null,
                ),
                const SizedBox(height: 16),
                ShadInputFormField(
                  id: 'standDilaporkan',
                  label: const Text('Angka Meter Saat Ini (m³)'),
                  placeholder: const Text('Contoh: 1245'),
                  description: const Text(
                    'Tulis angka HITAM pada meter air, tanpa angka merah '
                    'di belakang koma.',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(7),
                  ],
                  validator: (v) {
                    if (v.isEmpty) return 'Angka meter wajib diisi.';
                    final angka = int.tryParse(v);
                    if (angka == null || angka < 0 || angka > 9999999) {
                      return 'Angka meter tidak valid.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Foto Meter', style: theme.textTheme.small),
                    Text(
                      ' *wajib',
                      style: theme.textTheme.muted.copyWith(
                        fontSize: 11,
                        color: theme.colorScheme.destructive,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                KotakFotoBukti(
                  path: _fotoPath,
                  memproses: _memprosesFoto,
                  onTap: _memprosesFoto ? null : _pilihFoto,
                ),
                const SizedBox(height: 16),
                ShadInputFormField(
                  id: 'namaPelapor',
                  initialValue: SesiWarga.instance.akun?.name,
                  label: const Text('Nama Pelapor'),
                  placeholder: const Text('Nama lengkap Anda'),
                  validator: (v) => v.trim().length < 2
                      ? 'Nama pelapor wajib diisi (minimal 2 karakter).'
                      : null,
                ),
                const SizedBox(height: 16),
                ShadInputFormField(
                  id: 'nomorPelapor',
                  label: const Text('Nomor HP'),
                  placeholder: const Text('08xxxxxxxxxx'),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v.trim().length < 5
                      ? 'Nomor HP wajib diisi agar petugas bisa menghubungi.'
                      : null,
                ),
                const SizedBox(height: 24),
                if (_galat != null) ...[
                  ShadAlert.destructive(
                    icon: const Icon(CupertinoIcons.exclamationmark_circle),
                    title: const Text('Gagal mengirim'),
                    description: Text(_galat!),
                  ),
                  const SizedBox(height: 16),
                ],
                ShadButton(
                  onPressed: _mengirim ? null : _konfirmasiLaluKirim,
                  leading: _mengirim
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(CupertinoIcons.paperplane_fill),
                  child: Text(_mengirim ? 'Mengirim…' : 'Kirim Laporan'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarisKonfirmasi extends StatelessWidget {
  const _BarisKonfirmasi({required this.label, required this.nilai});

  final String label;
  final String nilai;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: theme.textTheme.muted),
          ),
          Expanded(child: Text(nilai)),
        ],
      ),
    );
  }
}
