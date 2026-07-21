import 'package:flutter/services.dart';

/// Gaya status bar sistem (jam, sinyal, baterai) untuk permukaan di bawahnya.
///
/// KENAPA ADA: aplikasi ini memakai `ShadApp` (di atas `WidgetsApp`), bukan
/// `MaterialApp` + `AppBar`. Material-lah yang biasanya menyetel
/// `SystemUiOverlayStyle` otomatis per-AppBar; tanpa itu Android memakai
/// gaya bawaan dari `LaunchTheme` (`Theme.Light.NoTitleBar`) — ikon GELAP.
/// Di tema terang, hero beranda tetap bergradien navy, jadi ikon gelap itu
/// jatuh di atas latar gelap dan praktis tak terlihat.
///
/// Aturannya: yang menentukan bukan tema aplikasi, melainkan warna
/// permukaan yang benar-benar berada di belakang status bar.
class GayaStatusBar {
  const GayaStatusBar._();

  /// Untuk permukaan GELAP (hero navy, kartu gradien) — ikon putih.
  /// `statusBarIconBrightness` = Android, `statusBarBrightness` = iOS, dan
  /// keduanya memakai konvensi terbalik: iOS meminta kecerahan LATAR.
  static const diAtasGelap = SystemUiOverlayStyle(
    statusBarColor: Color(0x00000000),
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  /// Untuk permukaan TERANG — ikon hitam.
  static const diAtasTerang = SystemUiOverlayStyle(
    statusBarColor: Color(0x00000000),
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );

  /// Pilih dari kecerahan tema, untuk layar biasa yang latarnya memang
  /// mengikuti tema (mis. AppScaffold).
  static SystemUiOverlayStyle untukTema(Brightness brightness) =>
      brightness == Brightness.dark ? diAtasGelap : diAtasTerang;
}
