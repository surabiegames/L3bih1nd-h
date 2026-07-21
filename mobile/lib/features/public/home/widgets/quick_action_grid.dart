import 'package:flutter/widgets.dart';

import '../../../../core/widgets/ilustrasi_layanan.dart';
import '../../../../core/widgets/squircle_icon.dart';

/// Data satu shortcut layanan — murni data, tidak tahu apa pun soal
/// navigasi konkret (`onTap` diserahkan pemanggil). Memisahkan data dari
/// widget membuat grid ini bisa dipakai ulang di layar mana pun tanpa
/// menyalin markup.
class QuickAction {
  const QuickAction({
    required this.ikon,
    required this.label,
    required this.gradasi,
    required this.onTap,
    this.ilustrasi,
  });

  final IconData ikon;
  final String label;

  /// Ikon aplikasi bergaya macOS untuk slot ini. Null = pakai squircle
  /// bergradien seperti app petugas (lihat LaunchpadItem).
  final Ilustrasi? ilustrasi;

  /// Gradien dua warna ikon squircle — pola SAMA dengan kartu "ruang
  /// kerja" di app petugas (portal_screen.dart), supaya bahasa ikon kedua
  /// aplikasi konsisten satu keluarga. Domain yang sama (mis. pencatatan
  /// meter, pengaduan) sengaja memakai gradien yang SAMA persis di kedua
  /// app — lihat pemanggil.
  final List<Color> gradasi;

  final VoidCallback onTap;
}

/// Grid shortcut layanan gaya LAUNCHER ponsel: HANYA ikon squircle + nama
/// layanan di bawahnya (LaunchpadItem) — SENGAJA tanpa kartu/kontainer
/// putih di sekelilingnya (keputusan desain 2026-07-19; versi lama
/// membungkus tiap shortcut dalam kartu putih ber-deskripsi).
class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key, required this.aksi});

  final List<QuickAction> aksi;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 8,
      mainAxisSpacing: 10,
      // Ikon 52 + label sampai 2 baris — lebih tinggi daripada lebar.
      // 0.70 (bukan 0.78): terukur di Linux desktop, sel 0.78 kurang
      // ~10px saat label membungkus 2 baris (RenderFlex overflow).
      childAspectRatio: 0.70,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final a in aksi)
          LaunchpadItem(
            ikon: a.ikon,
            label: a.label,
            gradasi: a.gradasi,
            ilustrasi: a.ilustrasi,
            onTap: a.onTap,
          ),
      ],
    );
  }
}
