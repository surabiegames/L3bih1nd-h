import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Judul seksi kecil huruf kapital berjarak — pemisah kelompok konten
/// di beranda/dashboard.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.judul, this.aksi});

  final String judul;
  final Widget? aksi;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Padding(
      // Dirapatkan dari (20, 10): judul seksi setinggi 11px tidak perlu
      // 30px ruang vertikal untuk terbaca sebagai pemisah kelompok, dan
      // di beranda ada tiga seksi sehingga selisihnya terasa sebagai
      // scroll yang tidak perlu.
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              judul.toUpperCase(),
              style: theme.textTheme.muted.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
          ),
          ?aksi,
        ],
      ),
    );
  }
}
