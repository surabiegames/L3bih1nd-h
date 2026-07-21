import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_panel.dart';
import 'antrean_upload_screen.dart';
import 'catat_meter_screen.dart';
import 'pelanggan_rute_screen.dart';
import 'rute_repository.dart';
import 'scan_qr_screen.dart';

/// Baca Meter — LANGKAH 1: pilih rute yang dikerjakan hari ini. Petugas bisa
/// memegang beberapa rute; layar ini menampilkannya sebagai kartu (kode,
/// seksi, progres per rute). Ketuk satu rute → daftar pelanggannya urut nomor
/// urut (`PelangganRuteScreen`, pola daftarPelanggan Aurora). Tombol muat =
/// UNDUH rute dari server (paket target + stand lalu) yang di-cache untuk
/// kerja offline; hasil catat yang antre offline dikirim ulang otomatis
/// setiap kali layar ini dimuat.
class DaftarPelangganScreen extends StatefulWidget {
  const DaftarPelangganScreen({super.key});

  @override
  State<DaftarPelangganScreen> createState() => _DaftarPelangganScreenState();
}

class _DaftarPelangganScreenState extends State<DaftarPelangganScreen> {
  final _repo = RuteRepository.create();

  RuteSaya? _paket;
  String? _galat;
  int _tertunda = 0;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  /// [paksa] true = UNDUH ulang dari server (tombol download); false = baca
  /// cache lokal (buka layar / kembali dari rute — instan, tanpa jaringan).
  Future<void> _muat({bool paksa = false}) async {
    setState(() {
      // Kosongkan (spinner) hanya saat UNDUH jaringan; baca cache biarkan data
      // lama tampil sampai yang baru datang — mulus, tanpa kedip.
      if (paksa) _paket = null;
      _galat = null;
    });
    try {
      // TIDAK auto-upload: hasil catat menunggu di antrean sampai petugas
      // menekan Upload (model Aurora — kontrol kuota/foto, unggah batch).
      final paket = await _repo.ruteSaya(segarkan: paksa);
      final tertunda = await _repo.jumlahTertunda();
      if (!mounted) return;
      setState(() {
        _paket = paket;
        _tertunda = tertunda;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _galat = e.message);
    }
  }

  int _targetRute(RuteRingkas r) => [
    for (final p in _paket?.pelanggan ?? const <PelangganRute>[])
      if (p.ruteKode == r.kode) p,
  ].length;

  int _terbacaRute(RuteRingkas r) => [
    for (final p in _paket?.pelanggan ?? const <PelangganRute>[])
      if (p.ruteKode == r.kode && p.sudahDicatat) p,
  ].length;

  Future<void> _bukaRute(RuteRingkas rute) async {
    await Navigator.of(context).push<void>(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => PelangganRuteScreen(rute: rute),
        transitionsBuilder: (_, animasi, _, child) =>
            FadeTransition(opacity: animasi, child: child),
      ),
    );
    // Kembali dari rute: segarkan progres (catat bisa menambah terbaca).
    if (mounted) _muat();
  }

  Future<void> _bukaAntrean() async {
    await Navigator.of(context).push<void>(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const AntreanUploadScreen(),
        transitionsBuilder: (_, animasi, _, child) =>
            FadeTransition(opacity: animasi, child: child),
      ),
    );
    if (mounted) _muat();
  }

  bool get _bisaScan => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Scan QR → cari pelanggan lintas SEMUA rute (pola Scan & Get Aurora),
  /// lalu langsung buka layar catat (urutan next/prev = teman serute yang
  /// belum dibaca).
  Future<void> _scanQr() async {
    final paket = _paket;
    if (paket == null) return;
    final hasil = await Navigator.of(context).push<String>(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const ScanQrScreen(),
        transitionsBuilder: (_, animasi, _, child) =>
            FadeTransition(opacity: animasi, child: child),
      ),
    );
    if (hasil == null || !mounted) return;

    final digit = hasil.replaceAll(RegExp(r'\D'), '');
    final cocok = paket.pelanggan.where(
      (p) =>
          p.nomorLangganan == hasil ||
          (digit.isNotEmpty &&
              (p.nomorLangganan == digit || p.nomorLangganan.endsWith(digit))),
    );
    if (cocok.isEmpty) {
      await showShadDialog<void>(
        context: context,
        builder: (context) => ShadDialog.alert(
          title: const Text('Tidak Ditemukan'),
          description: Text(
            'Kode "$hasil" tidak cocok dengan pelanggan mana pun di rute '
            'Anda. Pastikan rute sudah diunduh, atau buka rutenya manual.',
          ),
          actions: [
            ShadButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
      return;
    }
    final target = cocok.first;
    final urutan = [
      for (final p in paket.pelanggan)
        if (p.ruteKode == target.ruteKode && !p.sudahDicatat) p,
    ];
    await Navigator.of(context).push<bool>(
      PageRouteBuilder(
        pageBuilder: (_, _, _) =>
            CatatMeterScreen(pelanggan: target, urutanKunjungan: urutan),
        transitionsBuilder: (_, animasi, _, child) =>
            FadeTransition(opacity: animasi, child: child),
      ),
    );
    if (mounted) _muat();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final paket = _paket;
    final periode = paket?.periode ?? periodeCatatSekarang();

    return AppScaffold(
      title: 'Baca Meter',
      subtitle: 'Pilih rute · ${labelPeriode(periode)}',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_bisaScan)
            ShadIconButton.ghost(
              icon: const Icon(CupertinoIcons.qrcode_viewfinder),
              onPressed: paket == null ? null : _scanQr,
            ),
          ShadIconButton.ghost(
            icon: const Icon(CupertinoIcons.cloud_download),
            onPressed: () => _muat(paksa: true),
          ),
        ],
      ),
      body: switch ((paket, _galat)) {
        (null, null) => const Center(child: CircularProgressIndicator()),
        (null, final String galat) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ShadAlert.destructive(
                icon: const Icon(CupertinoIcons.exclamationmark_circle),
                title: const Text('Gagal mengunduh rute'),
                description: Text(galat),
              ),
              const SizedBox(height: 12),
              ShadButton.outline(
                onPressed: () => _muat(paksa: true),
                leading: const Icon(CupertinoIcons.arrow_clockwise),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        (final RuteSaya p, _) when p.rutes.isEmpty => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.map_pin_slash,
                size: 40,
                color: theme.colorScheme.mutedForeground,
              ),
              const SizedBox(height: 10),
              Text(
                'Rute belum ditugaskan ke akun Anda.\n'
                'Penugasan rute diatur admin di dashboard web '
                '(menu Pemetaan Rute) — hubungi admin bila belum ada.',
                textAlign: TextAlign.center,
                style: theme.textTheme.muted,
              ),
            ],
          ),
        ),
        (final RuteSaya p, _) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            _RingkasanCatat(paket: p, tertunda: _tertunda, onBukaAntrean: _bukaAntrean),
            const SizedBox(height: 14),
            Text(
              'Rute Anda hari ini',
              style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            for (final rute in p.rutes) ...[
              _KartuRute(
                rute: rute,
                target: _targetRute(rute),
                terbaca: _terbacaRute(rute),
                onTap: () => _bukaRute(rute),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      },
    );
  }
}

/// Ringkasan lintas rute di atas daftar: total dibaca + antre kirim + waktu
/// unduh terakhir.
class _RingkasanCatat extends StatelessWidget {
  const _RingkasanCatat({
    required this.paket,
    required this.tertunda,
    this.onBukaAntrean,
  });

  final RuteSaya paket;
  final int tertunda;
  final VoidCallback? onBukaAntrean;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final rasio = paket.target == 0 ? 0.0 : paket.terbaca / paket.target;
    final unduh = paket.diunduhPada;
    return GlassPanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(AppEmerald.c600),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${paket.rutes.length} rute',
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (paket.dariCache) ...[
                const SizedBox(width: 6),
                _ChipKecil(
                  ikon: CupertinoIcons.wifi_slash,
                  label: 'Offline',
                  bahaya: true,
                ),
              ],
              if (tertunda > 0) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onBukaAntrean,
                  child: _ChipKecil(
                    ikon: CupertinoIcons.cloud_upload,
                    label: '$tertunda antre',
                  ),
                ),
              ],
              const Spacer(),
              Text(
                '${paket.terbaca} dari ${paket.target} target',
                style: theme.textTheme.muted,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ShadProgress(value: rasio, color: const Color(AppEmerald.c600)),
          if (unduh != null) ...[
            const SizedBox(height: 8),
            Text(
              'Terunduh ${formatWaktuLokal(unduh)}'
              '${paket.dariCache ? ' · data terakhir sebelum sinyal hilang' : ''}',
              style: theme.textTheme.muted.copyWith(fontSize: 10.5),
            ),
          ],
        ],
      ),
    );
  }
}

/// Kartu satu rute — ketuk untuk membuka daftar pelanggannya.
class _KartuRute extends StatelessWidget {
  const _KartuRute({
    required this.rute,
    required this.target,
    required this.terbaca,
    required this.onTap,
  });

  final RuteRingkas rute;
  final int target;
  final int terbaca;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final selesai = target > 0 && terbaca >= target;
    final rasio = target == 0 ? 0.0 : terbaca / target;
    return GlassPanel(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selesai
                      ? const Color(AppEmerald.c600)
                      : theme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  selesai
                      ? CupertinoIcons.checkmark_seal_fill
                      : CupertinoIcons.map_fill,
                  size: 20,
                  color: selesai
                      ? const Color(0xFFFFFFFF)
                      : theme.colorScheme.mutedForeground,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rute ${rute.kode}',
                      style: theme.textTheme.small.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (rute.seksiCater != null)
                      Text(
                        rute.seksiCater!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.muted.copyWith(fontSize: 11.5),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$terbaca/$target',
                style: theme.textTheme.small.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selesai
                      ? const Color(AppEmerald.c600)
                      : theme.colorScheme.foreground,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: theme.colorScheme.mutedForeground,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ShadProgress(value: rasio, color: const Color(AppEmerald.c600)),
        ],
      ),
    );
  }
}

class _ChipKecil extends StatelessWidget {
  const _ChipKecil({
    required this.ikon,
    required this.label,
    this.bahaya = false,
  });

  final IconData ikon;
  final String label;
  final bool bahaya;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final warna = bahaya
        ? theme.colorScheme.destructive
        : theme.colorScheme.mutedForeground;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: theme.colorScheme.muted,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, size: 11, color: warna),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.muted.copyWith(
              fontSize: 10.5,
              color: bahaya ? theme.colorScheme.destructive : null,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
