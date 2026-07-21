import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/theme/master_palette.dart';
import '../../../core/auth/sesi_petugas.dart';
import '../../../core/network/api_config.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/logo_perusahaan.dart';
import '../../../core/widgets/squircle_icon.dart';
import '../auth/login_screen.dart';
import '../baca_meter/rute_repository.dart';
import '../dashboard/gangguan_home_screen.dart';
import '../dashboard/pencatat_home_screen.dart';
import '../pengaduan/pengaduan_staff_repository.dart';

/// Angka ringkas portal — dimuat toleran (bagian yang gagal dihitung 0,
/// portal tidak boleh gagal tampil hanya karena satu sumber data mati).
class _AngkaPortal {
  const _AngkaPortal({
    this.ruteTerbaca = 0,
    this.ruteTotal = 0,
    this.dicatatSaya = 0,
    this.antreKirim = 0,
    this.tiketAktif = 0,
    this.tiketLewatSla = 0,
  });

  final int ruteTerbaca;
  final int ruteTotal;
  final int dicatatSaya;
  final int antreKirim;
  final int tiketAktif;
  final int tiketLewatSla;
}

/// Portal Petugas — pintu masuk yang MEMISAHKAN dua peran lapangan:
/// Pencatat Meter (rute baca + catat stand) dan Petugas Gangguan (tiket
/// pengaduan). Verifikasi laporan BUKAN di sini — itu ranah supervisor ke
/// atas / admin kantor di dashboard web. Gaya macOS: latar gradien premium,
/// panel kaca, ikon squircle.
class PortalScreen extends StatefulWidget {
  const PortalScreen({super.key});

  @override
  State<PortalScreen> createState() => _PortalScreenState();
}

class _PortalScreenState extends State<PortalScreen> {
  final _pengaduan = PengaduanStaffRepository.create();
  final _rute = RuteRepository.create();

  late Future<_AngkaPortal> _angka;

  @override
  void initState() {
    super.initState();
    _angka = _muatAngka();
  }

  Future<_AngkaPortal> _muatAngka() async {
    final hasil = await Future.wait<Object?>([
      _pengaduan.tiketSaya().then<Object?>((v) => v).catchError((_) => null),
      // Cache (segarkan:false) — data rute sudah diunduh; portal tak perlu
      // menembak jaringan tiap dibuka (penyebab lemot berpindah layar).
      _rute.ruteSaya(segarkan: false).then<Object?>((v) => v).catchError((_) => null),
      _rute.jumlahTertunda().then<Object?>((v) => v).catchError((_) => 0),
    ]);
    final tiket = hasil[0] as List<dynamic>?;
    final rute = hasil[1] as RuteSaya?;
    final antreKirim = hasil[2] as int? ?? 0;
    const statusAktif = {'DITUGASKAN', 'DIPROSES', 'DIBUKA_KEMBALI'};
    return _AngkaPortal(
      ruteTerbaca: rute?.terbaca ?? 0,
      ruteTotal: rute?.target ?? 0,
      dicatatSaya: rute?.dicatatSaya ?? 0,
      antreKirim: antreKirim,
      tiketAktif:
          tiket?.where((t) => statusAktif.contains(t.status)).length ?? 0,
      tiketLewatSla: tiket?.where((t) => t.lewatSla == true).length ?? 0,
    );
  }

  void _segarkan() {
    final baru = _muatAngka();
    setState(() {
      _angka = baru;
    });
  }

  Future<void> _keluar() async {
    final yakin = await showShadDialog<bool>(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Keluar dari Akun'),
        description: const Text(
          'Sesi dan rute yang terunduh di perangkat ini akan dihapus.',
        ),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ShadButton.destructive(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (yakin != true || !mounted) return;

    await SesiPetugas.instance.keluar();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const LoginScreen(),
        transitionsBuilder: (_, animasi, _, child) =>
            FadeTransition(opacity: animasi, child: child),
      ),
      (_) => false,
    );
  }

  Future<void> _masuk(Widget Function() tujuan) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => tujuan(),
        transitionsBuilder: (_, animasi, _, child) => FadeTransition(
          opacity: animasi,
          child: SlideTransition(
            position: Tween(begin: const Offset(0.04, 0), end: Offset.zero)
                .animate(
                  CurvedAnimation(parent: animasi, curve: Curves.easeOutCubic),
                ),
            child: child,
          ),
        ),
      ),
    );
    if (mounted) _segarkan();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final hariIni = DateTime.now();

    return PremiumBackground(
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: FutureBuilder<_AngkaPortal>(
              future: _angka,
              builder: (context, snapshot) {
                final a = snapshot.data ?? const _AngkaPortal();
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                  children: [
                    // ── Kepala portal
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo resmi perusahaan (bukan ikon tetes generik)
                        // — lihat core/widgets/logo_perusahaan.dart.
                        const LogoPerusahaan(ukuran: 46),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PERUMDA TIRTAWENING',
                                style: theme.textTheme.muted.copyWith(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.4,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text('Portal Petugas', style: theme.textTheme.h2),
                            ],
                          ),
                        ),
                        if (ApiConfig.isDemo)
                          const _PilPortal(label: 'DEMO')
                        else
                          ShadIconButton.ghost(
                            icon: const Icon(
                              CupertinoIcons.square_arrow_right,
                              size: 17,
                            ),
                            onPressed: _keluar,
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(left: 60),
                      child: Text(
                        '${SesiPetugas.instance.akun == null ? 'Selamat bertugas' : 'Selamat bertugas, ${SesiPetugas.instance.akun!.name}'} · ${formatTanggalUtc(DateTime.utc(hariIni.year, hariIni.month, hariIni.day))}',
                        style: theme.textTheme.muted,
                      ),
                    ),
                    const SizedBox(height: 26),

                    // ── Pilih ruang kerja
                    Text(
                      'PILIH RUANG KERJA',
                      style: theme.textTheme.muted.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GlassPanel(
                      onTap: () => _masuk(() => const PencatatHomeScreen()),
                      child: _IsiKartuRuang(
                        ikon: CupertinoIcons.gauge,
                        gradasi: const [
                          Color(MasterPalette.teal),
                          Color(MasterPalette.teal600),
                        ],
                        judul: 'Pencatat Meter',
                        deskripsi:
                            'Rute baca meter, catat stand, unduh & unggah data',
                        chips: [
                          _MiniStat(
                            ikon: CupertinoIcons.map_fill,
                            label: '${a.ruteTerbaca}/${a.ruteTotal} SL',
                          ),
                          _MiniStat(
                            ikon: CupertinoIcons.doc_checkmark_fill,
                            label: '${a.dicatatSaya} dicatat',
                          ),
                          if (a.antreKirim > 0)
                            _MiniStat(
                              ikon: CupertinoIcons.cloud_upload_fill,
                              label: '${a.antreKirim} antre kirim',
                              bahaya: true,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    GlassPanel(
                      onTap: () => _masuk(() => const GangguanHomeScreen()),
                      child: _IsiKartuRuang(
                        ikon: CupertinoIcons.wrench_fill,
                        gradasi: const [
                          Color(MasterPalette.rose400),
                          Color(MasterPalette.rose600),
                        ],
                        judul: 'Petugas Gangguan',
                        deskripsi:
                            'Tiket pengaduan warga, SLA, tindak lanjut lapangan',
                        chips: [
                          _MiniStat(
                            ikon: CupertinoIcons.ticket_fill,
                            label: '${a.tiketAktif} aktif',
                          ),
                          if (a.tiketLewatSla > 0)
                            _MiniStat(
                              ikon: CupertinoIcons.clock,
                              label: '${a.tiketLewatSla} lewat SLA',
                              bahaya: true,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'Tirtawening Petugas · v1.0',
                        style: theme.textTheme.muted.copyWith(fontSize: 11),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _IsiKartuRuang extends StatelessWidget {
  const _IsiKartuRuang({
    required this.ikon,
    required this.gradasi,
    required this.judul,
    required this.deskripsi,
    required this.chips,
  });

  final IconData ikon;
  final List<Color> gradasi;
  final String judul;
  final String deskripsi;
  final List<Widget> chips;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Row(
      children: [
        SquircleIcon(ikon: ikon, gradasi: gradasi, ukuran: 56),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(judul, style: theme.textTheme.large.copyWith(fontSize: 16)),
              const SizedBox(height: 2),
              Text(
                deskripsi,
                style: theme.textTheme.muted.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 9),
              Wrap(spacing: 6, runSpacing: 6, children: chips),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          CupertinoIcons.chevron_right,
          size: 18,
          color: theme.colorScheme.mutedForeground,
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: theme.colorScheme.muted,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, size: 11.5, color: warna),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.muted.copyWith(
              fontSize: 11,
              color: bahaya ? theme.colorScheme.destructive : null,
              fontWeight: bahaya ? FontWeight.w600 : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _PilPortal extends StatelessWidget {
  const _PilPortal({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.muted,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Text(
        label,
        style: theme.textTheme.muted.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
