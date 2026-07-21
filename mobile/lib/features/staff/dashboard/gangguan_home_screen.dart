import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/theme/master_palette.dart';
import '../../../core/models/complaint_ticket_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/labels.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/squircle_icon.dart';
import '../../../core/widgets/status_badge.dart';
import '../../public/cek_tagihan/cek_tagihan_screen.dart';
import '../pengaduan/pengaduan_staff_repository.dart';
import '../pengaduan/pengaduan_staff_screen.dart';
import 'workspace_widgets.dart';

/// Ruang kerja PETUGAS GANGGUAN: tiket pengaduan yang ditugaskan,
/// urutan prioritas berdasarkan SLA, dan aplikasi kerja gaya Launchpad.
class GangguanHomeScreen extends StatefulWidget {
  const GangguanHomeScreen({super.key});

  @override
  State<GangguanHomeScreen> createState() => _GangguanHomeScreenState();
}

class _GangguanHomeScreenState extends State<GangguanHomeScreen> {
  final _repo = PengaduanStaffRepository.create();

  List<ComplaintTicketModel>? _tiket;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    try {
      final rows = await _repo.tiketSaya();
      if (!mounted) return;
      setState(() => _tiket = rows);
    } catch (_) {
      if (!mounted) return;
      setState(() => _tiket = const []);
    }
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

  /// Prioritas penanganan: pelanggar SLA dulu, lalu sisa waktu tersedikit.
  List<ComplaintTicketModel> get _prioritas {
    const aktif = {'DITUGASKAN', 'DIPROSES', 'DIBUKA_KEMBALI'};
    final rows =
        (_tiket ?? const <ComplaintTicketModel>[])
            .where((t) => aktif.contains(t.status))
            .toList()
          ..sort((a, b) {
            if (a.lewatSla != b.lewatSla) return a.lewatSla ? -1 : 1;
            return (a.sla?.sisaMenit ?? 1 << 30).compareTo(
              b.sla?.sisaMenit ?? 1 << 30,
            );
          });
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final tiket = _tiket;
    const aktifSet = {'DITUGASKAN', 'DIPROSES', 'DIBUKA_KEMBALI'};
    final aktif = tiket?.where((t) => aktifSet.contains(t.status)).length ?? 0;
    final lewatSla = tiket?.where((t) => t.lewatSla).length ?? 0;
    final terjeda =
        tiket?.where((t) => t.status == 'MENUNGGU_PELANGGAN').length ?? 0;

    return WorkspaceScaffold(
      judul: 'Petugas Gangguan',
      subjudul: 'Tiket pengaduan & tindak lanjut',
      onSegarkan: _muat,
      children: [
        // ── Statistik ringkas
        Row(
          children: [
            Expanded(
              child: CompactStat(
                label: 'Tiket Aktif',
                nilai: tiket == null ? '…' : '$aktif',
                ikon: CupertinoIcons.ticket_fill,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CompactStat(
                label: 'Lewat SLA',
                nilai: tiket == null ? '…' : '$lewatSla',
                ikon: CupertinoIcons.clock,
                bahaya: lewatSla > 0,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CompactStat(
                label: 'Terjeda',
                nilai: tiket == null ? '…' : '$terjeda',
                ikon: CupertinoIcons.pause_circle,
              ),
            ),
          ],
        ),

        // ── Aplikasi (Launchpad)
        const WorkspaceSection(judul: 'Aplikasi'),
        GlassPanel(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: LaunchpadItem(
                  ikon: CupertinoIcons.wrench_fill,
                  label: 'Tiket Saya',
                  gradasi: const [
                    Color(MasterPalette.rose400),
                    Color(MasterPalette.rose600),
                  ],
                  badge: lewatSla > 0 ? '$lewatSla' : null,
                  onTap: () => _buka(() => const PengaduanStaffScreen()),
                ),
              ),
              Expanded(
                child: LaunchpadItem(
                  ikon: CupertinoIcons.doc_text_fill,
                  label: 'Info Tagihan',
                  gradasi: const [
                    Color(MasterPalette.teal400),
                    Color(MasterPalette.teal700),
                  ],
                  onTap: () => _buka(() => const CekTagihanScreen()),
                ),
              ),
              const Expanded(
                child: LaunchpadItem(
                  ikon: CupertinoIcons.map_pin_ellipse,
                  label: 'Peta Gangguan',
                  gradasi: [
                    Color(MasterPalette.sky),
                    Color(MasterPalette.sky700),
                  ],
                  aktif: false,
                ),
              ),
              const Expanded(
                child: LaunchpadItem(
                  ikon: CupertinoIcons.chart_bar,
                  label: 'Statistik',
                  gradasi: [
                    Color(MasterPalette.slate),
                    Color(MasterPalette.slate600),
                  ],
                  aktif: false,
                ),
              ),
            ],
          ),
        ),

        // ── Prioritas SLA
        WorkspaceSection(
          judul: 'Prioritas Penanganan',
          aksi: GestureDetector(
            onTap: () => _buka(() => const PengaduanStaffScreen()),
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
        if (tiket == null)
          GlassPanel(child: Text('Memuat tiket…', style: theme.textTheme.muted))
        else if (_prioritas.isEmpty)
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
                    'Tidak ada tiket aktif — antrean bersih.',
                    style: theme.textTheme.muted,
                  ),
                ),
              ],
            ),
          )
        else
          for (final t in _prioritas.take(3)) ...[
            GlassPanel(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              onTap: () => _buka(() => const PengaduanStaffScreen()),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 40,
                    decoration: BoxDecoration(
                      color: t.lewatSla
                          ? theme.colorScheme.destructive
                          : const Color(AppStatusColors.successLight),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.judul,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.small.copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${t.nomorTiket} · '
                          '${labelDari(labelJenisPengaduan, t.jenis)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.muted.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(
                    label: labelDari(labelStatusPengaduan, t.status),
                    tone: toneStatusPengaduan(t.status),
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
