import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../theme/app_theme.dart';
import '../theme/master_palette.dart';

/// Nada visual badge status. Dipetakan SEKALI dari kode status API di sini,
/// supaya warna status konsisten antar layar.
enum StatusTone { success, warning, danger, neutral, info }

StatusTone toneStatusTagihan(String kode) => switch (kode) {
  'SUDAH_BAYAR' => StatusTone.success,
  'JATUH_TEMPO' => StatusTone.danger,
  'BELUM_BAYAR' => StatusTone.warning,
  _ => StatusTone.neutral,
};

StatusTone toneStatusLaporan(String kode) => switch (kode) {
  'DIVERIFIKASI' || 'DIGUNAKAN' => StatusTone.success,
  'DITOLAK' => StatusTone.danger,
  'MENUNGGU' => StatusTone.warning,
  _ => StatusTone.neutral,
};

StatusTone toneStatusPengaduan(String kode) => switch (kode) {
  'SELESAI' || 'DITUTUP' => StatusTone.success,
  'DITOLAK' || 'DIBUKA_KEMBALI' => StatusTone.danger,
  'BARU' || 'TERVERIFIKASI' || 'MENUJU_LOKASI' => StatusTone.info,
  'MENUNGGU_PELANGGAN' => StatusTone.warning,
  _ => StatusTone.neutral,
};

StatusTone tonePrioritas(String kode) => switch (kode) {
  'DARURAT' => StatusTone.danger,
  'TINGGI' => StatusTone.warning,
  _ => StatusTone.neutral,
};

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.tone});

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final gelap = ShadTheme.of(context).brightness == Brightness.dark;
    final teks = Text(label);
    return switch (tone) {
      StatusTone.danger => ShadBadge.destructive(child: teks),
      StatusTone.neutral => ShadBadge.secondary(child: teks),
      StatusTone.info => ShadBadge(child: teks),
      StatusTone.success => ShadBadge(
        backgroundColor: Color(
          gelap ? AppStatusColors.successDark : AppStatusColors.successLight,
        ),
        foregroundColor: Colors.white,
        child: teks,
      ),
      // Peringatan = rumpun Rose palet master (tidak ada amber lagi);
      // dibedakan dari destructive lewat langkah tonal yang lebih terang.
      StatusTone.warning => ShadBadge(
        backgroundColor: Color(
          gelap ? MasterPalette.rose600 : MasterPalette.rose400,
        ),
        foregroundColor: Colors.white,
        child: teks,
      ),
    };
  }
}
