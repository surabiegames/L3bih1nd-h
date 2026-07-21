import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:flutter/widgets.dart';

import '../../../../core/theme/pdam_palette.dart';
import '../../../../core/widgets/gaya_status_bar.dart';
import '../../../../core/widgets/logo_perusahaan.dart';
import 'hero_ripple_painter.dart';

/// Header hero navy khas beranda warga: gradien gelap, riak air + cahaya
/// orb di latar, baris brand + slot aksi kanan (notifikasi/akun), sapaan,
/// dan slot konten bebas di bawahnya (mis. kartu status tagihan/tiket).
///
/// TANGGUNG JAWAB TUNGGAL: chrome visual + tata letak. Tidak tahu apa pun
/// soal data pelanggan atau navigasi — semua itu diserahkan lewat
/// parameter, supaya widget ini bisa dipakai ulang di layar lain kelak
/// (mis. header akun) tanpa modifikasi.
class BerandaHero extends StatelessWidget {
  const BerandaHero({
    super.key,
    required this.sapaan,
    required this.nama,
    required this.trailing,
    this.content,
    this.chip,
  });

  /// Baris kecil di atas nama, mis. "Selamat pagi," atau "Selamat datang,".
  final String sapaan;

  /// Nama pengguna (atau label anonim, mis. "Warga Tirtawening").
  final String nama;

  /// Slot kanan atas — biasanya tombol notifikasi/akun.
  final Widget trailing;

  /// Konten tambahan di bawah sapaan (mis. kartu ringkasan). Opsional.
  final Widget? content;

  /// Chip kecil di sebelah brand mark (mis. penanda "MODE DEMO"). Opsional.
  final Widget? chip;

  @override
  Widget build(BuildContext context) {
    // Hero inilah yang berada di belakang status bar, dan ia SELALU navy
    // gelap — termasuk saat tema sistem terang. Tanpa AnnotatedRegion,
    // Android memakai ikon gelap bawaan dan jam/sinyal/baterai hilang di
    // tema terang. Lihat core/widgets/gaya_status_bar.dart.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: GayaStatusBar.diAtasGelap,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(PdamPalette.heroGradient1),
                Color(PdamPalette.heroGradient2),
                Color(PdamPalette.heroGradient3),
                Color(PdamPalette.heroGradient4),
              ],
              stops: PdamPalette.heroGradientStops,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: -60,
                right: -60,
                child: SizedBox(
                  width: 260,
                  height: 260,
                  child: CustomPaint(painter: const HeroRipplePainter()),
                ),
              ),
              Positioned(
                top: -40,
                right: -20,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0x3838BDF8), Color(0x0038BDF8)],
                    ),
                  ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  // Tanpa slot konten, hero tidak perlu setinggi itu —
                  // kaki 32 di sana untuk memberi napas di bawah kartu
                  // status. Pengguna yang sudah masuk tidak mengirim
                  // `content` (identitasnya sudah dibawa KartuLangganan),
                  // jadi hero mengerut alih-alih menyisakan ruang kosong.
                  padding: EdgeInsets.fromLTRB(
                    24,
                    8,
                    24,
                    content == null ? 22 : 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const _BrandMark(),
                              if (chip != null) ...[
                                const SizedBox(width: 10),
                                chip!,
                              ],
                            ],
                          ),
                          trailing,
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        sapaan,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color(0x8CFFFFFF),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        nama,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(PdamPalette.white),
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (content != null) ...[
                        const SizedBox(height: 24),
                        content!,
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Logo resmi perusahaan, bukan ikon tetes generik — lihat
        // core/widgets/logo_perusahaan.dart. `diAtasGelap: true` eksplisit:
        // hero SELALU bergradien gelap apa pun tema sistem.
        const LogoPerusahaan(ukuran: 38, diAtasGelap: true),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PERUMDA',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0x8CFFFFFF),
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'Tirtawening',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(PdamPalette.white),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
