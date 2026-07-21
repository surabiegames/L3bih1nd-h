import 'package:flutter/widgets.dart';

import '../../../../core/theme/pdam_palette.dart';

/// Cincin riak air di latar BerandaHero — murni dekoratif, diisolasi jadi
/// CustomPainter sendiri supaya bisa diuji/diganti tanpa menyentuh layout
/// hero (single responsibility: cuma menggambar, tidak tahu apa pun soal
/// konten di atasnya).
class HeroRipplePainter extends CustomPainter {
  const HeroRipplePainter({this.jumlahCincin = 4});

  final int jumlahCincin;

  @override
  void paint(Canvas canvas, Size size) {
    final pusat = Offset(size.width / 2, size.height / 2);
    final cat = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var i = 0; i < jumlahCincin; i++) {
      cat.color = const Color(
        PdamPalette.sky,
      ).withValues(alpha: 0.18 - i * 0.04);
      canvas.drawCircle(pusat, 60.0 + i * 40, cat);
    }
  }

  @override
  bool shouldRepaint(covariant HeroRipplePainter oldDelegate) =>
      oldDelegate.jumlahCincin != jumlahCincin;
}
