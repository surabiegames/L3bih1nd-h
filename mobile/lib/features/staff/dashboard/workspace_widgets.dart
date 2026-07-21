import 'dart:math' as math;

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass_panel.dart';

/// Kerangka halaman ruang kerja petugas gaya macOS: latar premium,
/// bar atas ramping (kembali · judul · segarkan), konten ListView di
/// tengah (maks 560, nyaman juga di tablet).
class WorkspaceScaffold extends StatelessWidget {
  const WorkspaceScaffold({
    super.key,
    required this.judul,
    required this.subjudul,
    required this.children,
    this.onSegarkan,
  });

  final String judul;
  final String subjudul;
  final List<Widget> children;
  final VoidCallback? onSegarkan;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return PremiumBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: Row(
                children: [
                  ShadIconButton.ghost(
                    icon: const Icon(CupertinoIcons.chevron_left, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          judul,
                          style: theme.textTheme.large.copyWith(fontSize: 16),
                        ),
                        Text(
                          subjudul,
                          style: theme.textTheme.muted.copyWith(fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                  if (onSegarkan != null)
                    ShadIconButton.ghost(
                      icon: const Icon(
                        CupertinoIcons.arrow_clockwise,
                        size: 16,
                      ),
                      onPressed: onSegarkan,
                    ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    children: children,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Judul seksi kecil untuk ruang kerja (huruf kapital berjarak).
class WorkspaceSection extends StatelessWidget {
  const WorkspaceSection({super.key, required this.judul, this.aksi});

  final String judul;
  final Widget? aksi;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              judul.toUpperCase(),
              style: theme.textTheme.muted.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ?aksi,
        ],
      ),
    );
  }
}

/// Indikator penyimpanan antrean — padanan bar "sisa memori" dashboard
/// Aurora, difokuskan ulang ke risiko lapangan yang sebenarnya: berapa
/// banyak hasil catat (dengan foto bukti) menumpuk BELUM terunggah dan
/// berapa besar berkasnya di perangkat. Aurora memperingatkan saat catat
/// belum-upload melewati 500; ambang yang sama dipakai di sini.
class IndikatorPenyimpanan extends StatelessWidget {
  const IndikatorPenyimpanan({
    super.key,
    required this.jumlahAntrean,
    required this.totalByteFoto,
  });

  /// Jumlah laporan di antrean offline (belum terunggah).
  final int jumlahAntrean;

  /// Total ukuran foto bukti yang masih tersimpan lokal (byte).
  final int totalByteFoto;

  static const _ambangPerhatian = 400;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final aman = jumlahAntrean == 0;
    final perhatian = jumlahAntrean >= _ambangPerhatian;
    final warna = perhatian
        ? theme.colorScheme.destructive
        : aman
        ? const Color(AppStatusColors.successLight)
        : theme.colorScheme.foreground;
    final judul = aman
        ? 'Penyimpanan aman'
        : perhatian
        ? 'Segera upload — antrean menumpuk'
        : 'Antrean menunggu upload';
    final rincian = aman
        ? 'Tidak ada hasil catat yang menunggu diunggah.'
        : '$jumlahAntrean laporan · ${formatUkuranByte(totalByteFoto)} foto '
              'bukti tersimpan di perangkat.';
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(
            aman
                ? CupertinoIcons.checkmark_seal_fill
                : perhatian
                ? CupertinoIcons.exclamationmark_triangle_fill
                : CupertinoIcons.tray_full_fill,
            size: 22,
            color: warna,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: theme.textTheme.small.copyWith(
                    fontSize: 13,
                    color: warna,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  rincian,
                  style: theme.textTheme.muted.copyWith(fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Statistik kompak ala widget macOS: angka + label, ringkas dan rendah.
class CompactStat extends StatelessWidget {
  const CompactStat({
    super.key,
    required this.label,
    required this.nilai,
    required this.ikon,
    this.bahaya = false,
  });

  final String label;
  final String nilai;
  final IconData ikon;
  final bool bahaya;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final warna = bahaya
        ? theme.colorScheme.destructive
        : theme.colorScheme.foreground;
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                ikon,
                size: 13,
                color: bahaya
                    ? theme.colorScheme.destructive
                    : theme.colorScheme.mutedForeground,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.muted.copyWith(fontSize: 10.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            nilai,
            style: theme.textTheme.h4.copyWith(color: warna, fontSize: 19),
          ),
        ],
      ),
    );
  }
}

/// Cincin progres target pencatatan — chart magnitude bagian-dari-keutuhan:
/// SL yang SUDAH dicatat terhadap TOTAL target rute. Busur emerald (selesai)
/// di atas jalur netral (belum), persen di tengah. Identitas TIDAK
/// bergantung warna semata — angka & legend teks selalu menyertainya
/// (padanan progress bar dashboard Aurora, dibuat lebih terbaca).
class RingProgresTarget extends StatelessWidget {
  const RingProgresTarget({
    super.key,
    required this.terbaca,
    required this.target,
    this.ukuran = 172,
  });

  /// SL yang sudah dicatat pada periode berjalan.
  final int terbaca;

  /// Total SL target rute (semua sambungan langganan di rute ini).
  final int target;
  final double ukuran;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final rasio = target == 0 ? 0.0 : (terbaca / target).clamp(0.0, 1.0);
    final persen = (rasio * 100).round();
    final belum = (target - terbaca).clamp(0, target);
    return Column(
      children: [
        SizedBox(
          width: ukuran,
          height: ukuran,
          child: CustomPaint(
            painter: _RingPainter(
              rasio: rasio,
              track: theme.colorScheme.muted,
              isiAwal: const Color(AppEmerald.c500),
              isiAkhir: const Color(AppEmerald.c600),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$persen%',
                    style: theme.textTheme.h1.copyWith(
                      fontSize: 40,
                      height: 1,
                      color: const Color(AppEmerald.c600),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'terbaca',
                    style: theme.textTheme.muted.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Legend + hitungan — identitas lewat teks, bukan warna saja.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendRing(
              warna: const Color(AppEmerald.c600),
              label: 'Sudah Dicatat',
              nilai: terbaca,
            ),
            const SizedBox(width: 20),
            _LegendRing(
              warna: theme.colorScheme.muted,
              garisTepi: theme.colorScheme.border,
              label: 'Belum Dicatat',
              nilai: belum,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Target rute: $target sambungan langganan (SL)',
          style: theme.textTheme.muted.copyWith(fontSize: 11.5),
        ),
      ],
    );
  }
}

class _LegendRing extends StatelessWidget {
  const _LegendRing({
    required this.warna,
    required this.label,
    required this.nilai,
    this.garisTepi,
  });

  final Color warna;
  final Color? garisTepi;
  final String label;
  final int nilai;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: warna,
            shape: BoxShape.circle,
            border: garisTepi == null ? null : Border.all(color: garisTepi!),
          ),
        ),
        const SizedBox(width: 6),
        Text('$nilai', style: theme.textTheme.small.copyWith(fontSize: 13)),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.muted.copyWith(fontSize: 11.5)),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.rasio,
    required this.track,
    required this.isiAwal,
    required this.isiAkhir,
  });

  final double rasio;
  final Color track;
  final Color isiAwal;
  final Color isiAkhir;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 16.0;
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) - stroke) / 2;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (rasio <= 0) return;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const mulai = -math.pi / 2; // dari atas, searah jarum jam
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: mulai,
        endAngle: mulai + 2 * math.pi,
        colors: [isiAwal, isiAkhir],
      ).createShader(rect);
    canvas.drawArc(rect, mulai, 2 * math.pi * rasio, false, arcPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.rasio != rasio ||
      old.track != track ||
      old.isiAwal != isiAwal ||
      old.isiAkhir != isiAkhir;
}
