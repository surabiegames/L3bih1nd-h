import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../theme/master_palette.dart';

/// Panel "kaca" premium gaya macOS: latar semi-translusen di atas gradien
/// halaman, hairline border, sudut besar, bayangan lembut berlapis.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final gelap = theme.brightness == Brightness.dark;

    final panel = Container(
      padding: padding,
      // ContinuousRectangleBorder (superellipse), bukan BorderRadius.circular
      // biasa — sudut "continuous corner" adalah salah satu ciri paling
      // gampang dikenali dari kartu/ikon iOS & macOS, beda dari busur
      // lingkaran murni yang terasa lebih "Android/Material".
      decoration: ShapeDecoration(
        color: gelap
            ? const Color(0xB80F172A) // slate gelap translusen
            : const Color(0xE6FFFFFF), // putih translusen
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: gelap ? const Color(0x2E94A3B8) : const Color(0x66CBD5E1),
          ),
        ),
        shadows: [
          BoxShadow(
            color: gelap ? const Color(0x66000000) : const Color(0x1A0F172A),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: gelap ? const Color(0x33000000) : const Color(0x0D0F172A),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );

    return onTap == null ? panel : GestureDetector(onTap: onTap, child: panel);
  }
}

/// Latar halaman premium: gradien lembut + dua "cahaya" radial samar di
/// pojok — memberi kedalaman tanpa mengganggu konten.
class PremiumBackground extends StatelessWidget {
  const PremiumBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final gelap = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gelap
              ? const [Color(MasterPalette.slate950), Color(0xFF010409)]
              : const [
                  Color(MasterPalette.slate50),
                  Color(MasterPalette.slate100),
                ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _Cahaya(
              warna: gelap ? const Color(0x262DD4BF) : const Color(0x3338BDF8),
            ),
          ),
          Positioned(
            bottom: -140,
            left: -100,
            child: _Cahaya(
              warna: gelap ? const Color(0x1F0EA5E9) : const Color(0x265EEAD4),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _Cahaya extends StatelessWidget {
  const _Cahaya({required this.warna});

  final Color warna;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [warna, warna.withValues(alpha: 0)]),
      ),
    );
  }
}
