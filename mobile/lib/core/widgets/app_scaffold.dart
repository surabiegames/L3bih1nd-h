import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../theme/ios_style.dart';
import 'gaya_status_bar.dart';
import 'glass_panel.dart';

/// Kerangka halaman gaya iOS: latar gradien premium (PremiumBackground),
/// nav bar translusen/blur menempel atas (kembali · judul · aksi, garis
/// rambut di bawahnya — padanan `UINavigationBar`), konten di tengah
/// maks 560 — nyaman juga di tablet. (ShadApp memakai WidgetsApp, bukan
/// MaterialApp — Scaffold/SnackBar Material tidak dipakai di sini.)
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final bisaKembali = Navigator.of(context).canPop();
    final gelap = theme.brightness == Brightness.dark;
    final brightness = gelap ? Brightness.dark : Brightness.light;

    // Beda dari hero: latar layar ini MENGIKUTI tema, jadi gaya status bar
    // ikut kecerahan tema. Tanpa ini, kembali dari beranda (hero gelap) ke
    // layar terang menyisakan ikon putih di atas latar putih.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: GayaStatusBar.untukTema(theme.brightness),
      child: PremiumBackground(
        // TANPA SafeArea pembungkus — pola yang SAMA dengan beranda: kalau
        // SafeArea membungkus seluruh isi, strip setinggi status bar diisi
        // latar polos dan nav bar terlihat "menggantung" terpisah dari
        // ikon sistem. Yang benar: nav bar buram MEMANJANG ke belakang
        // status bar, dan tinggi status bar itu ditambahkan sebagai
        // padding atas di dalamnya (viewPadding, bukan padding — nilainya
        // tetap benar saat papan ketik terbuka).
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: IosStyle.secondaryBackground(
                      brightness,
                    ).withValues(alpha: 0.72),
                    border: Border(
                      bottom: BorderSide(color: IosStyle.separator(brightness)),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      4,
                      MediaQuery.viewPaddingOf(context).top + 4,
                      12,
                      4,
                    ),
                    child: Row(
                      children: [
                        if (bisaKembali)
                          ShadIconButton.ghost(
                            icon: Icon(
                              CupertinoIcons.chevron_left,
                              size: 22,
                              color: IosStyle.systemBlue,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          )
                        else
                          const SizedBox(width: 8),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: theme.textTheme.large.copyWith(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              if (subtitle != null)
                                Text(
                                  subtitle!,
                                  style: theme.textTheme.muted.copyWith(
                                    fontSize: 11.5,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        ?trailing,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SafeArea(
                top: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: body,
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
