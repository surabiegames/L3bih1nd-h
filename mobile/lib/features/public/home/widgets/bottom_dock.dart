import 'dart:ui' show ImageFilter;

import 'package:flutter/widgets.dart';

import '../../../../core/theme/ios_style.dart';

/// Data satu item tab — murni data, tidak tahu apa pun soal widget
/// tujuan. MainShellScreen yang memutuskan apa yang tampil per index.
///
/// `ikonAktif` opsional: iOS membedakan ikon tab TIDAK aktif (outline)
/// dari yang aktif (filled) — mis. `house` vs `house_fill`. Null berarti
/// ikon yang sama dipakai di kedua keadaan (cukup untuk glyph yang
/// memang sudah "filled" secara alami).
class DockItem {
  const DockItem({required this.ikon, this.ikonAktif, required this.label});

  final IconData ikon;
  final IconData? ikonAktif;
  final String label;
}

/// Tab bar bawah gaya iOS: lebar penuh, menempel tepi bawah, latar
/// blur/translusen (bukan dock mengambang bergaya Android), garis rambut
/// tipis di atas, dan tint systemBlue untuk item aktif — padanan
/// `UITabBar` standar, bukan reka ulang bebas.
class BottomDock extends StatelessWidget {
  const BottomDock({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<DockItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final gelap = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final latar = IosStyle.secondaryBackground(
      gelap ? Brightness.dark : Brightness.light,
    );

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: latar.withValues(alpha: 0.82),
            border: Border(
              top: BorderSide(
                color: IosStyle.separator(
                  gelap ? Brightness.dark : Brightness.light,
                ),
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 50,
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: _DockButton(
                        item: items[i],
                        aktif: i == currentIndex,
                        gelap: gelap,
                        onTap: () => onTap(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockButton extends StatelessWidget {
  const _DockButton({
    required this.item,
    required this.aktif,
    required this.gelap,
    required this.onTap,
  });

  final DockItem item;
  final bool aktif;
  final bool gelap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final warna = aktif
        ? IosStyle.systemBlue
        : IosStyle.secondaryLabel(gelap ? Brightness.dark : Brightness.light);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            aktif ? (item.ikonAktif ?? item.ikon) : item.ikon,
            color: warna,
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: warna,
            ),
          ),
        ],
      ),
    );
  }
}
