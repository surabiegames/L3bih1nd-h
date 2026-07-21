import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Tile menu gaya launcher (grid 2 kolom): chip ikon berwarna, judul,
/// deskripsi singkat. Dipakai di beranda kedua aplikasi.
class MenuTile extends StatelessWidget {
  const MenuTile({
    super.key,
    required this.ikon,
    required this.judul,
    required this.deskripsi,
    required this.warna,
    required this.onTap,
    this.badge,
  });

  final IconData ikon;
  final String judul;
  final String deskripsi;

  /// Warna chip ikon (latar); ikon selalu putih.
  final Color warna;
  final VoidCallback onTap;

  /// Badge kecil di pojok (mis. jumlah antrean).
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        // ContinuousRectangleBorder (superellipse iOS/macOS), bukan
        // BorderRadius.circular biasa — lihat catatan yang sama di
        // GlassPanel.
        decoration: ShapeDecoration(
          color: theme.colorScheme.card,
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: theme.colorScheme.border),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: ShapeDecoration(
                    color: warna,
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: Icon(ikon, size: 21, color: const Color(0xFFFFFFFF)),
                ),
                const Spacer(),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.destructive,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        color: theme.colorScheme.destructiveForeground,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  Icon(
                    CupertinoIcons.arrow_up_right,
                    size: 16,
                    color: theme.colorScheme.mutedForeground,
                  ),
              ],
            ),
            const Spacer(),
            Text(judul, style: theme.textTheme.small.copyWith(fontSize: 14)),
            const SizedBox(height: 3),
            Text(
              deskripsi,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.muted.copyWith(fontSize: 11.5),
            ),
          ],
        ),
      ),
    );
  }
}
