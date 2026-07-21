import 'dart:io';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/services/notifikasi_service.dart';
import '../../../core/theme/master_palette.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/squircle_icon.dart';
import '../info_tagihan/info_tagihan_screen.dart';
import '../notifikasi/notifikasi_screen.dart';
import '../baca_meter/antrean_upload_screen.dart';
import '../baca_meter/catat_meter_screen.dart';
import '../baca_meter/daftar_pelanggan_screen.dart';
import '../baca_meter/download_data_screen.dart';
import '../baca_meter/riwayat_screen.dart';
import '../baca_meter/rute_repository.dart';
import 'workspace_widgets.dart';

/// Ruang kerja PENCATAT METER. Pusatnya: CHART PROGRES rute yang DITUGASKAN
/// ke akun ini (rute dipetakan admin di dashboard web — pencatat tidak
/// memilih sendiri) — berapa SL target sudah dicatat vs belum. Di bawahnya:
/// aplikasi kerja (baca meter, download/upload data, riwayat, info tagihan)
/// dan "Lanjutkan Rute". Verifikasi laporan TIDAK di sini (ranah
/// supervisor/admin kantor).
class PencatatHomeScreen extends StatefulWidget {
  const PencatatHomeScreen({super.key});

  @override
  State<PencatatHomeScreen> createState() => _PencatatHomeScreenState();
}

class _PencatatHomeScreenState extends State<PencatatHomeScreen> {
  final _rute = RuteRepository.create();

  RuteSaya? _paket;
  int _tertunda = 0;
  int _byteFoto = 0;
  int _notifBelumDibaca = 0;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    final hasil = await Future.wait<Object?>([
      _rute.ruteSaya().then<Object?>((v) => v).catchError((_) => null),
      _rute.jumlahTertunda().then<Object?>((v) => v).catchError((_) => 0),
      _rute
          .daftarTertunda()
          .then<Object?>((v) => v)
          .catchError((_) => const <CatatTertunda>[]),
      NotifikasiService.instance
          .jumlahBelumDibaca()
          .then<Object?>((v) => v)
          .catchError((_) => 0),
    ]);
    if (!mounted) return;
    final antrean = (hasil[2] as List?)?.cast<CatatTertunda>() ?? const [];
    setState(() {
      _paket = hasil[0] as RuteSaya?;
      _tertunda = hasil[1] as int? ?? 0;
      _byteFoto = _hitungByteFoto(antrean);
      _notifBelumDibaca = hasil[3] as int? ?? 0;
    });
  }

  /// Total ukuran foto bukti yang masih tersimpan lokal di seluruh antrean
  /// (berkas hilang/terhapus diabaikan). Murni lokal, tanpa paket native.
  static int _hitungByteFoto(List<CatatTertunda> antrean) {
    var total = 0;
    for (final entri in antrean) {
      for (final path in entri.fotoPaths.values) {
        final berkas = File(path);
        if (berkas.existsSync()) total += berkas.lengthSync();
      }
    }
    return total;
  }

  Future<void> _buka(Widget Function() tujuan) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => tujuan(),
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
    final berikutnya = (paket?.pelanggan ?? const <PelangganRute>[]).where(
      (p) => !p.sudahDicatat,
    );

    return WorkspaceScaffold(
      judul: 'Pencatat Meter',
      subjudul: 'Progres rute yang ditugaskan ke Anda',
      onSegarkan: _muat,
      children: [
        // ── Chart progres target rute (pusat layar)
        _KartuTargetRute(paket: paket, tertunda: _tertunda),
        const SizedBox(height: 10),

        // ── Indikator penyimpanan antrean (padanan bar memori Aurora)
        IndikatorPenyimpanan(jumlahAntrean: _tertunda, totalByteFoto: _byteFoto),
        const SizedBox(height: 4),

        // ── Aplikasi (Launchpad). Padanan menu Aurora: Daftar Pelanggan ·
        //    Download · Upload · Cek Tagihan, + Riwayat.
        const WorkspaceSection(judul: 'Aplikasi'),
        GlassPanel(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: LaunchpadItem(
                      ikon: CupertinoIcons.gauge,
                      label: 'Baca Meter',
                      gradasi: const [
                        Color(MasterPalette.teal),
                        Color(MasterPalette.teal600),
                      ],
                      onTap: () => _buka(() => const DaftarPelangganScreen()),
                    ),
                  ),
                  Expanded(
                    child: LaunchpadItem(
                      ikon: CupertinoIcons.cloud_download_fill,
                      label: 'Download',
                      gradasi: const [
                        Color(MasterPalette.emerald400),
                        Color(MasterPalette.emerald700),
                      ],
                      onTap: () => _buka(() => const DownloadDataScreen()),
                    ),
                  ),
                  Expanded(
                    child: LaunchpadItem(
                      ikon: CupertinoIcons.cloud_upload_fill,
                      label: 'Upload',
                      gradasi: const [
                        Color(MasterPalette.rose400),
                        Color(MasterPalette.rose700),
                      ],
                      badge: _tertunda > 0 ? '$_tertunda' : null,
                      onTap: () => _buka(() => const AntreanUploadScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: LaunchpadItem(
                      ikon: CupertinoIcons.clock_fill,
                      label: 'Riwayat',
                      gradasi: const [
                        Color(MasterPalette.slate),
                        Color(MasterPalette.slate600),
                      ],
                      onTap: () => _buka(() => const RiwayatScreen()),
                    ),
                  ),
                  Expanded(
                    child: LaunchpadItem(
                      ikon: CupertinoIcons.doc_text_fill,
                      label: 'Info Tagihan',
                      gradasi: const [
                        Color(MasterPalette.sky300),
                        Color(MasterPalette.sky700),
                      ],
                      onTap: () => _buka(() => const InfoTagihanScreen()),
                    ),
                  ),
                  Expanded(
                    child: LaunchpadItem(
                      ikon: CupertinoIcons.bell_fill,
                      label: 'Notifikasi',
                      gradasi: const [
                        Color(MasterPalette.teal),
                        Color(MasterPalette.sky700),
                      ],
                      badge: _notifBelumDibaca > 0 ? '$_notifBelumDibaca' : null,
                      onTap: () => _buka(() => const NotifikasiScreen()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Lanjutkan rute
        WorkspaceSection(
          judul: 'Lanjutkan Rute',
          aksi: paket?.ruteKode == null
              ? null
              : GestureDetector(
                  onTap: () => _buka(() => const DaftarPelangganScreen()),
                  child: Text(
                    'Lihat semua',
                    style: theme.textTheme.muted.copyWith(
                      fontSize: 11.5,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        ),
        if (paket == null)
          GlassPanel(child: Text('Memuat rute…', style: theme.textTheme.muted))
        else if (paket.ruteKode == null)
          GlassPanel(
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.map_pin_slash,
                  size: 18,
                  color: theme.colorScheme.mutedForeground,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Rute belum ditugaskan ke akun Anda — penugasan diatur '
                    'admin di dashboard web (menu Pencatat).',
                    style: theme.textTheme.muted,
                  ),
                ),
              ],
            ),
          )
        else if (berikutnya.isEmpty)
          GlassPanel(
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.checkmark_circle,
                  size: 18,
                  color: const Color(AppStatusColors.successLight),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Seluruh rute sudah dibaca. Kerja bagus!',
                    style: theme.textTheme.muted,
                  ),
                ),
              ],
            ),
          )
        else
          for (final p in berikutnya.take(3)) ...[
            GlassPanel(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              onTap: () => _buka(() => CatatMeterScreen(pelanggan: p)),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.muted,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.border),
                    ),
                    child: Text(
                      '${p.urutan ?? '-'}',
                      style: theme.textTheme.muted.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.foreground,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.nama,
                          style: theme.textTheme.small.copyWith(fontSize: 13),
                        ),
                        if (p.alamat != null)
                          Text(
                            p.alamat!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.muted.copyWith(fontSize: 11),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (p.standLalu != null)
                    Text(
                      'Lalu ${p.standLalu}',
                      style: theme.textTheme.muted.copyWith(fontSize: 11),
                    ),
                  const SizedBox(width: 6),
                  Icon(
                    CupertinoIcons.chevron_right,
                    size: 15,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}

/// Kartu pusat: identitas rute yang DITUGASKAN + cincin progres target SL +
/// hitungan pendukung (dicatat saya periode ini, antre kirim).
class _KartuTargetRute extends StatelessWidget {
  const _KartuTargetRute({required this.paket, required this.tertunda});

  final RuteSaya? paket;
  final int tertunda;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    if (paket == null) {
      return const GlassPanel(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (paket!.ruteKode == null) {
      // Belum ditugaskan rute — tidak ada chart, arahkan ke admin.
      return GlassPanel(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(
              CupertinoIcons.map_pin_slash,
              size: 34,
              color: theme.colorScheme.mutedForeground,
            ),
            const SizedBox(height: 10),
            Text(
              'Belum ada rute ditugaskan',
              style: theme.textTheme.large.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              'Rute pencatatan dipetakan admin ke tiap petugas di dashboard '
              'web (menu Pencatat). Hubungi admin bila rute Anda belum '
              'muncul, lalu tarik-segarkan halaman ini.',
              textAlign: TextAlign.center,
              style: theme.textTheme.muted.copyWith(fontSize: 12),
            ),
          ],
        ),
      );
    }

    final p = paket!;
    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        children: [
          // Identitas rute yang ditugaskan.
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(AppEmerald.c600),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  p.rutes.length > 1 ? '${p.rutes.length} rute' : p.ruteKode!,
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.rutes.length > 1
                          ? '${p.rutes.length} rute · ${p.target} SL'
                          : (p.seksiCater ?? 'Rute pencatatan Anda'),
                      style: theme.textTheme.small.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      labelPeriode(p.periode),
                      style: theme.textTheme.muted.copyWith(fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              if (p.dariCache)
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.wifi_slash,
                      size: 12,
                      color: theme.colorScheme.destructive,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Offline',
                      style: theme.textTheme.muted.copyWith(
                        fontSize: 10.5,
                        color: theme.colorScheme.destructive,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 18),

          // Cincin progres target SL (pusat).
          RingProgresTarget(terbaca: p.terbaca, target: p.target),
          const SizedBox(height: 18),

          // Hitungan pendukung.
          Row(
            children: [
              Expanded(
                child: CompactStat(
                  label: 'Dicatat Saya (periode)',
                  nilai: '${p.dicatatSaya}',
                  ikon: CupertinoIcons.doc_checkmark_fill,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CompactStat(
                  label: 'Antre Kirim',
                  nilai: '$tertunda',
                  ikon: CupertinoIcons.cloud_upload_fill,
                  bahaya: tertunda > 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
