import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_panel.dart';
import 'catat_meter_screen.dart';
import 'rute_repository.dart';
import 'scan_qr_screen.dart';

/// Daftar pelanggan SATU rute yang dipilih petugas untuk dikerjakan hari ini
/// (pola `daftarPelangganUnRead/Read` Aurora). Urut nomor urut rute
/// (`noUrutRute`), tab Belum/Sudah dibaca, pencarian, dan scan QR — semuanya
/// dibatasi ke rute ini. Data dibaca dari cache lokal (rute sudah diunduh di
/// layar Baca Meter), jadi ringan & jalan offline; hasil catat langsung
/// tercermin lewat DAO.
class PelangganRuteScreen extends StatefulWidget {
  const PelangganRuteScreen({super.key, required this.rute});

  final RuteRingkas rute;

  @override
  State<PelangganRuteScreen> createState() => _PelangganRuteScreenState();
}

class _PelangganRuteScreenState extends State<PelangganRuteScreen> {
  final _repo = RuteRepository.create();
  final _kontrolCari = TextEditingController();

  RuteSaya? _paket;
  String _kunci = '';
  bool _tabSudah = false;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  @override
  void dispose() {
    _kontrolCari.dispose();
    super.dispose();
  }

  /// Baca cache lokal saja (segarkan:false) — rute sudah diunduh di layar
  /// sebelumnya; catat memperbarui DAO sehingga status langsung tampak.
  Future<void> _muat() async {
    final paket = await _repo.ruteSaya(segarkan: false);
    if (!mounted) return;
    setState(() => _paket = paket);
  }

  /// Pelanggan milik rute ini saja (sudah terurut noUrutRute dari server).
  List<PelangganRute> get _pelangganRute => [
    for (final p in _paket?.pelanggan ?? const <PelangganRute>[])
      if (p.ruteKode == widget.rute.kode) p,
  ];

  int get _target => _pelangganRute.length;
  int get _terbaca => _pelangganRute.where((p) => p.sudahDicatat).length;

  /// Daftar tab aktif (belum/sudah) — juga urutan kunjungan untuk next/prev.
  List<PelangganRute> get _daftarTab => [
    for (final p in _pelangganRute)
      if (p.sudahDicatat == _tabSudah) p,
  ];

  List<PelangganRute> get _tersaring {
    final daftar = _daftarTab;
    if (_kunci.isEmpty) return daftar;
    final k = _kunci.toLowerCase();
    return [
      for (final p in daftar)
        if (p.nomorLangganan.contains(k) ||
            p.nama.toLowerCase().contains(k) ||
            (p.alamat ?? '').toLowerCase().contains(k))
          p,
    ];
  }

  Future<void> _bukaCatat(PelangganRute pelanggan) async {
    await Navigator.of(context).push<bool>(
      PageRouteBuilder(
        pageBuilder: (_, _, _) =>
            CatatMeterScreen(pelanggan: pelanggan, urutanKunjungan: _daftarTab),
        transitionsBuilder: (_, animasi, _, child) =>
            FadeTransition(opacity: animasi, child: child),
      ),
    );
    if (mounted) _muat();
  }

  bool get _bisaScan => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

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
    final cocok = _pelangganRute.where(
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
            'Kode "$hasil" tidak cocok dengan pelanggan di rute '
            '${widget.rute.kode}.',
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
    await _bukaCatat(cocok.first);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final paket = _paket;
    final periode = paket?.periode ?? periodeCatatSekarang();

    return AppScaffold(
      title: 'Rute ${widget.rute.kode}',
      subtitle: '${widget.rute.seksiCater ?? 'Rute pencatatan'} · ${labelPeriode(periode)}',
      trailing: _bisaScan
          ? ShadIconButton.ghost(
              icon: const Icon(CupertinoIcons.qrcode_viewfinder),
              onPressed: paket == null ? null : _scanQr,
            )
          : null,
      body: paket == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GlassPanel(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Progres rute',
                                  style: theme.textTheme.small,
                                ),
                                const Spacer(),
                                Text(
                                  '$_terbaca dari $_target dibaca',
                                  style: theme.textTheme.muted,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ShadProgress(
                              value: _target == 0 ? 0.0 : _terbaca / _target,
                              color: const Color(AppEmerald.c600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ShadInput(
                        controller: _kontrolCari,
                        placeholder: const Text(
                          'Cari nomor langganan / nama / alamat…',
                        ),
                        leading: const Icon(CupertinoIcons.search, size: 16),
                        onChanged: (v) => setState(() => _kunci = v.trim()),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _TombolTab(
                              label: 'Belum Dibaca (${_target - _terbaca})',
                              aktif: !_tabSudah,
                              onTap: () => setState(() => _tabSudah = false),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _TombolTab(
                              label: 'Sudah Dibaca ($_terbaca)',
                              aktif: _tabSudah,
                              onTap: () => setState(() => _tabSudah = true),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                Expanded(
                  child: _tersaring.isEmpty
                      ? Center(
                          child: Text(
                            _kunci.isNotEmpty
                                ? 'Tidak ada pelanggan yang cocok.'
                                : _tabSudah
                                ? 'Belum ada yang dicatat di rute ini.'
                                : 'Semua pelanggan rute ini sudah dibaca. 🎉',
                            style: theme.textTheme.muted,
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          itemCount: _tersaring.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, i) => _BarisPelanggan(
                            pelanggan: _tersaring[i],
                            onTap: () => _bukaCatat(_tersaring[i]),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

class _TombolTab extends StatelessWidget {
  const _TombolTab({
    required this.label,
    required this.aktif,
    required this.onTap,
  });

  final String label;
  final bool aktif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: aktif ? const Color(AppEmerald.c600) : theme.colorScheme.muted,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: aktif
                ? const Color(AppEmerald.c600)
                : theme.colorScheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: aktif
                ? const Color(0xFFFFFFFF)
                : theme.colorScheme.mutedForeground,
          ),
        ),
      ),
    );
  }
}

class _BarisPelanggan extends StatelessWidget {
  const _BarisPelanggan({required this.pelanggan, required this.onTap});

  final PelangganRute pelanggan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final selesai = pelanggan.sudahDicatat;
    return GlassPanel(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selesai
                  ? const Color(AppEmerald.c600)
                  : theme.colorScheme.secondary,
              shape: BoxShape.circle,
            ),
            child: selesai
                ? const Icon(
                    CupertinoIcons.checkmark,
                    size: 16,
                    color: Color(0xFFFFFFFF),
                  )
                : Text(
                    '${pelanggan.urutan ?? '-'}',
                    style: theme.textTheme.small,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pelanggan.nama, style: theme.textTheme.small),
                const SizedBox(height: 1),
                Text(
                  '${pelanggan.nomorLangganan}'
                  '${pelanggan.nomorMeter == null ? '' : ' · ${pelanggan.nomorMeter}'}'
                  '${pelanggan.status == null || pelanggan.status == 'AKTIF' ? '' : ' · ${pelanggan.status}'}',
                  style: theme.textTheme.muted.copyWith(fontSize: 11.5),
                ),
                if (pelanggan.alamat != null)
                  Text(
                    pelanggan.alamat!,
                    style: theme.textTheme.muted.copyWith(fontSize: 11.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (pelanggan.standLalu != null)
                Text(
                  'Lalu: ${pelanggan.standLalu}',
                  style: theme.textTheme.muted.copyWith(fontSize: 11),
                ),
              const SizedBox(height: 2),
              Icon(
                selesai
                    ? CupertinoIcons.checkmark_seal_fill
                    : CupertinoIcons.chevron_right,
                size: 16,
                color: selesai
                    ? const Color(AppEmerald.c600)
                    : theme.colorScheme.mutedForeground,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
