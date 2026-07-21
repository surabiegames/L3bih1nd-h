import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../theme/master_palette.dart';

/// Logo resmi PERUMDA Tirtawening (assets/images/logo.png — salinan 1:1
/// dari public/images/logo.png di repo Next.js) sebagai SIGNATURE murni:
/// tanpa chip/kontainer apa pun (keputusan desain 2026-07-19, menggantikan
/// chip squircle putih sebelumnya). SATU-SATUNYA cara menampilkan logo
/// perusahaan di kedua aplikasi — jangan menggambar ulang mark pakai ikon
/// generik (tetes air dsb.).
///
/// Kedalamannya dibangun dari dua lapis bayangan halus, bukan efek ramai:
///   1. Bayangan ambien rumpun Slate di bawah — logo terasa "duduk" di
///      atas permukaan (emboss lembut), terlihat di latar terang.
///   2. Halo Sky sangat tipis — hanya di atas latar GELAP (hero navy,
///      mode gelap), memisahkan tepi logo dari latar tanpa terlihat
///      seperti stiker menyala.
///
/// `diAtasGelap` menimpa deteksi tema: hero beranda SELALU gelap apa pun
/// tema sistemnya, jadi pemanggilnya mengirim `true` secara eksplisit.
class LogoPerusahaan extends StatelessWidget {
  const LogoPerusahaan({super.key, this.ukuran = 52, this.diAtasGelap});

  final double ukuran;

  /// Null = ikuti kecerahan tema; true/false = paksa (untuk permukaan
  /// yang warnanya tetap, mis. hero gradien gelap).
  final bool? diAtasGelap;

  @override
  Widget build(BuildContext context) {
    final gelap =
        diAtasGelap ?? ShadTheme.of(context).brightness == Brightness.dark;

    return Container(
      width: ukuran,
      height: ukuran,
      // Bentuk bayangan lingkaran mengikuti siluet logo (mark-nya bundar);
      // spread negatif menahan tepi bayangan tetap di belakang logo
      // sehingga yang terlihat hanya pendaran lembutnya.
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: gelap ? const Color(0x66020617) : const Color(0x330F172A),
            blurRadius: ukuran * 0.22,
            spreadRadius: -ukuran * 0.04,
            offset: Offset(0, ukuran * 0.09),
          ),
          if (gelap)
            const BoxShadow(
              color: Color(0x2E38BDF8), // halo Sky 400 @18%
              blurRadius: 18,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
    );
  }
}

/// Varian monokrom putih untuk konteks yang butuh logo sangat tenang di
/// atas warna pekat (mis. splash/footer). Belum dipakai di layar mana pun
/// — sengaja disiapkan agar tidak ada yang mengakali dengan ColorFilter
/// sendiri-sendiri saat kebutuhan itu muncul.
class LogoPerusahaanMono extends StatelessWidget {
  const LogoPerusahaanMono({super.key, this.ukuran = 52});

  final double ukuran;

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: const ColorFilter.mode(
        Color(MasterPalette.slate50),
        BlendMode.srcIn,
      ),
      child: Image.asset(
        'assets/images/logo.png',
        width: ukuran,
        height: ukuran,
        fit: BoxFit.contain,
      ),
    );
  }
}
