import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Kartu statistik ringkas untuk dashboard: nilai besar, label kecil,
/// ikon di kanan atas. `tone` mewarnai nilai + ikon (mis. merah untuk
/// "Lewat SLA").
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.nilai,
    required this.ikon,
    this.tone,
    this.keterangan,
  });

  final String label;
  final String nilai;
  final IconData ikon;
  final Color? tone;
  final String? keterangan;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final warna = tone ?? theme.colorScheme.foreground;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.muted.copyWith(fontSize: 11.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                ikon,
                size: 16,
                color: tone ?? theme.colorScheme.mutedForeground,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(nilai, style: theme.textTheme.h3.copyWith(color: warna)),
          if (keterangan != null) ...[
            const SizedBox(height: 2),
            Text(
              keterangan!,
              style: theme.textTheme.muted.copyWith(fontSize: 10.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
