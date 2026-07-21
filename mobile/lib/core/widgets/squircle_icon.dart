import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'ilustrasi_layanan.dart';

/// Ikon aplikasi gaya macOS: squircle (ContinuousRectangleBorder — kurva
/// kontinu khas Apple), gradien vertikal, glyph putih, bayangan lembut.
class SquircleIcon extends StatelessWidget {
  const SquircleIcon({
    super.key,
    required this.ikon,
    required this.gradasi,
    this.ukuran = 52,
  });

  final IconData ikon;

  /// Dua warna gradien atas → bawah (gaya ikon macOS).
  final List<Color> gradasi;
  final double ukuran;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ukuran,
      height: ukuran,
      decoration: ShapeDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradasi,
        ),
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(ukuran * 0.58),
        ),
        shadows: [
          BoxShadow(
            color: gradasi.last.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(ikon, size: ukuran * 0.46, color: const Color(0xFFFFFFFF)),
    );
  }
}

/// Satu item "Launchpad": ikon squircle kecil + label di bawahnya.
/// `aktif: false` menampilkan gaya redup + tanda "Segera" (belum tersedia).
class LaunchpadItem extends StatelessWidget {
  const LaunchpadItem({
    super.key,
    required this.ikon,
    required this.label,
    required this.gradasi,
    this.ilustrasi,
    this.onTap,
    this.badge,
    this.aktif = true,
  });

  final IconData ikon;
  final String label;
  final List<Color> gradasi;

  /// Bila diisi, ilustrasi inilah yang tampil sebagai ikon aplikasi —
  /// menggantikan squircle bergradien. [ikon] & [gradasi] TETAP wajib dan
  /// dipakai sebagai cadangan bila ilustrasinya null (app petugas memakai
  /// jalur itu), jadi menghapus ilustrasi tidak pernah menyisakan slot
  /// kosong.
  final Ilustrasi? ilustrasi;

  final VoidCallback? onTap;

  /// Angka kecil merah di pojok ikon (jumlah antrean).
  final String? badge;
  final bool aktif;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return GestureDetector(
      onTap: aktif ? onTap : null,
      child: Opacity(
        opacity: aktif ? 1 : 0.45,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                if (ilustrasi != null)
                  IlustrasiLayanan(
                    ilustrasi: ilustrasi!,
                    semantik: label,
                    // Ubin squircle memakai gradien domain yang SAMA dengan
                    // SquircleIcon — pembungkusnya sekeluarga, isinya saja
                    // yang berbeda (ilustrasi vs glyph).
                    ubin: gradasi,
                  )
                else
                  SquircleIcon(ikon: ikon, gradasi: gradasi),
                if (badge != null)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: theme.colorScheme.background,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.muted.copyWith(
                fontSize: 11,
                height: 1.15,
                color: theme.colorScheme.foreground,
              ),
            ),
            if (!aktif)
              Text(
                'Segera',
                style: theme.textTheme.muted.copyWith(fontSize: 9.5),
              ),
          ],
        ),
      ),
    );
  }
}
