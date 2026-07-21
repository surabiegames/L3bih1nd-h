import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/labels.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_panel.dart';
import 'rute_repository.dart';

/// Riwayat — seluruh hasil catat AKUN INI periode berjalan: hitungan hari
/// ini (padanan `tv_today_reading` Aurora), baris yang masih antre di
/// perangkat, dan status verifikasi berjenjang tiap laporan di server —
/// petugas bisa membuktikan hasil kerjanya tanpa membuka dashboard web.
class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  final _repo = RuteRepository.create();

  List<LaporanSaya>? _rows;
  String? _galat;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    setState(() {
      _rows = null;
      _galat = null;
    });
    try {
      final rows = await _repo.riwayatSaya();
      // Terbaru dulu; baris ANTRE (belum terkirim) selalu di atas supaya
      // pekerjaan yang belum aman kelihatan lebih dulu.
      rows.sort((a, b) {
        final antreA = a.statusVerif == 'ANTRE' ? 0 : 1;
        final antreB = b.statusVerif == 'ANTRE' ? 0 : 1;
        if (antreA != antreB) return antreA - antreB;
        final tA = a.tanggalCatat?.millisecondsSinceEpoch ?? 0;
        final tB = b.tanggalCatat?.millisecondsSinceEpoch ?? 0;
        return tB.compareTo(tA);
      });
      if (!mounted) return;
      setState(() => _rows = rows);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _galat = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final rows = _rows;
    final hariIni = rows?.where((r) => r.hariIni).length ?? 0;

    return AppScaffold(
      title: 'Riwayat Catat',
      subtitle: labelPeriode(periodeCatatSekarang()),
      trailing: ShadIconButton.ghost(
        icon: const Icon(CupertinoIcons.arrow_clockwise),
        onPressed: _muat,
      ),
      body: switch ((rows, _galat)) {
        (null, null) => const Center(child: CircularProgressIndicator()),
        (null, final String galat) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ShadAlert.destructive(
                icon: const Icon(CupertinoIcons.exclamationmark_circle),
                title: const Text('Gagal memuat riwayat'),
                description: Text(galat),
              ),
              const SizedBox(height: 12),
              ShadButton.outline(
                onPressed: _muat,
                leading: const Icon(CupertinoIcons.arrow_clockwise),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        (final List<LaporanSaya> daftar, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GlassPanel(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: _AngkaRingkas(label: 'Hari Ini', nilai: '$hariIni'),
                  ),
                  Expanded(
                    child: _AngkaRingkas(
                      label: 'Periode Ini',
                      nilai: '${daftar.length}',
                    ),
                  ),
                  Expanded(
                    child: _AngkaRingkas(
                      label: 'Belum Terkirim',
                      nilai:
                          '${daftar.where((r) => r.statusVerif == 'ANTRE').length}',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (daftar.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Text(
                  'Belum ada hasil catat pada periode ini.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.muted,
                ),
              )
            else
              for (final r in daftar) ...[
                _BarisRiwayat(laporan: r),
                const SizedBox(height: 8),
              ],
          ],
        ),
      },
    );
  }
}

class _AngkaRingkas extends StatelessWidget {
  const _AngkaRingkas({required this.label, required this.nilai});

  final String label;
  final String nilai;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Column(
      children: [
        Text(nilai, style: theme.textTheme.h3),
        const SizedBox(height: 2),
        Text(label, style: theme.textTheme.muted.copyWith(fontSize: 11)),
      ],
    );
  }
}

class _BarisRiwayat extends StatelessWidget {
  const _BarisRiwayat({required this.laporan});

  final LaporanSaya laporan;

  (Color, String) _tampilanStatus(ShadThemeData theme) =>
      switch (laporan.statusVerif) {
        'ANTRE' => (theme.colorScheme.destructive, 'Belum Terkirim'),
        'DIVERIFIKASI' => (const Color(AppEmerald.c600), 'Diverifikasi'),
        'DITOLAK' => (theme.colorScheme.destructive, 'Ditolak'),
        _ => (theme.colorScheme.mutedForeground, 'Menunggu Verifikasi'),
      };

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final (warnaStatus, labelStatus) = _tampilanStatus(theme);
    return GlassPanel(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  laporan.namaPelanggan ?? laporan.nomorLangganan,
                  style: theme.textTheme.small,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: warnaStatus),
                ),
                child: Text(
                  labelStatus,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: warnaStatus,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            [
              laporan.nomorLangganan,
              if (laporan.standAwal != null || laporan.standAkhir != null)
                '${laporan.standAwal ?? '-'} → ${laporan.standAkhir ?? '-'}',
              if (laporan.pemakaian != null) formatM3(laporan.pemakaian!),
              if (laporan.kondisi != null)
                labelDari(labelKondisiMeter, laporan.kondisi!),
            ].join(' · '),
            style: theme.textTheme.muted.copyWith(fontSize: 11.5),
          ),
          if (laporan.tanggalCatat != null) ...[
            const SizedBox(height: 2),
            Text(
              formatWaktuLokal(laporan.tanggalCatat!),
              style: theme.textTheme.muted.copyWith(fontSize: 10.5),
            ),
          ],
          if (laporan.pesanGagal != null) ...[
            const SizedBox(height: 4),
            Text(
              'Ditolak server: ${laporan.pesanGagal}',
              style: theme.textTheme.muted.copyWith(
                fontSize: 11,
                color: theme.colorScheme.destructive,
              ),
            ),
          ],
          if (laporan.catatanVerif != null &&
              laporan.catatanVerif!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Catatan verifikator: ${laporan.catatanVerif}',
              style: theme.textTheme.muted.copyWith(fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}
