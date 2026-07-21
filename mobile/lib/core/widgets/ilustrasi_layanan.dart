import 'dart:ui' show ImageFilter;

import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../theme/master_palette.dart';

/// Ikon aplikasi per layanan untuk grid pintasan beranda — ilustrasi
/// bergaya ikon macOS, menggantikan squircle bergradien `SquircleIcon`
/// pada app PUBLIK.
///
/// Berkasnya dibaca LANGSUNG dari assets/icons/ — folder yang sama tempat
/// sumber ikon launcher tinggal. Sempat ada langkah turunan yang menulis
/// versi kecil ke assets/ilustrasi/, tapi itu dibuang: berkas di sini
/// sudah transparan dan sudah berukuran wajar (~125-227 KB), sehingga
/// langkah tambahan itu hanya menyisakan folder yang mudah terhapus dan
/// membuat ikon hilang diam-diam.
///
/// Catatan ukuran: aset ~499px dipakai pada ~58px. Pemborosannya ditangani
/// `cacheWidth` di bawah (bitmap di memori seukuran tampil, bukan seukuran
/// berkas); di disk selisihnya tak berarti untuk APK sebesar ini.
///
/// App PETUGAS tetap memakai `SquircleIcon`: ilustrasi ini hanya ada untuk
/// empat layanan warga, dan portal petugas punya rumpun ikonnya sendiri.
enum Ilustrasi {
  cekTagihan('cek-tagihan.png'),
  laporMeter('lapor-meter.png'),
  pengaduan('pengaduan.png'),
  lacakTiket('lacak-tiket.png');

  const Ilustrasi(this._berkas);

  final String _berkas;

  String get path => 'assets/icons/$_berkas';
}

/// Menampilkan [Ilustrasi] pada [ukuran] logis, dalam salah satu dari dua
/// mode:
///
///  * **Berubin** ([ubin] diisi) — ilustrasi duduk di dalam squircle
///    bergradien, persis bentuk pembungkus ikon aplikasi macOS. Ini yang
///    dipakai grid beranda.
///  * **Mengambang** ([ubin] null) — hanya gambarnya, dengan bayangan
///    jatuh yang mengikuti SILUET. Bayangan itu dibangun dari salinan
///    gambar yang di-blur dan dihitamkan, bukan `BoxShadow`: gambar ini
///    transparan dan tidak persegi, sedangkan BoxShadow selalu mengikuti
///    kotak widget sehingga akan tampak sebagai persegi kabur di
///    belakangnya.
///
/// Keduanya tidak pernah digabung — lihat catatan di dalam build().
class IlustrasiLayanan extends StatelessWidget {
  const IlustrasiLayanan({
    super.key,
    required this.ilustrasi,
    required this.semantik,
    this.ukuran = 58,
    this.bayangan = true,
    this.ubin,
  });

  final Ilustrasi ilustrasi;
  final String semantik;
  final double ukuran;
  final bool bayangan;

  /// Dua warna domain (rumpun palet master) untuk UBIN squircle di
  /// belakang ilustrasi — pembungkus khas ikon aplikasi macOS. Null =
  /// ilustrasi mengambang tanpa ubin.
  ///
  /// Warna ini TIDAK dipakai pekat: ilustrasinya sendiri berwarna dan
  /// bergaris tepi gelap, jadi ubin bergradien penuh (seperti SquircleIcon
  /// yang glyph-nya putih polos) akan berebut perhatian dengan isinya.
  /// Yang dipakai hanya semburat tipisnya, cukup untuk menjaga kode warna
  /// per-domain tetap sama dengan app petugas.
  final List<Color>? ubin;

  @override
  Widget build(BuildContext context) {
    final gelap = ShadTheme.of(context).brightness == Brightness.dark;
    final berubin = ubin != null;

    // Di dalam ubin, ilustrasi diberi marjin aman seperti ikon macOS —
    // isinya tidak menempel tepi squircle.
    final sisiGambar = berubin ? ukuran * 0.72 : ukuran;
    final lebarCache = (sisiGambar * MediaQuery.devicePixelRatioOf(context))
        .round();

    Widget gambar({Color? warna}) => Image.asset(
      ilustrasi.path,
      width: sisiGambar,
      height: sisiGambar,
      fit: BoxFit.contain,
      cacheWidth: lebarCache,
      color: warna,
    );

    // Bayangan siluet hanya masuk akal saat ilustrasi mengambang. Di atas
    // ubin, kedalaman sudah datang dari bayangan ubin itu sendiri —
    // menumpuk keduanya membuat gambar terlihat kotor.
    Widget isi = bayangan && !berubin
        ? Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: ukuran * 0.06,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  // srcIn: ambil SILUET gambar, buang warnanya — inilah
                  // yang membuat bayangan mengikuti bentuk, bukan kotak.
                  child: gambar(warna: const Color(0x4A0F172A)),
                ),
              ),
              gambar(),
            ],
          )
        : gambar();

    if (berubin) {
      final warna = ubin!;
      isi = Container(
        width: ukuran,
        height: ukuran,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          // Dasar terang/gelap mengikuti tema, disemburat warna domain.
          // Ilustrasinya berisi banyak putih (kertas, papan klip), jadi
          // dasar gelap pekat akan membuatnya "menyala" seperti stiker.
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gelap
                ? [
                    const Color(MasterPalette.slate800),
                    warna.last.withValues(alpha: 0.32),
                  ]
                : [const Color(0xFFFFFFFF), warna.last.withValues(alpha: 0.20)],
          ),
          // Radius 0.58 x sisi — angka yang SAMA dengan SquircleIcon,
          // supaya ubin ilustrasi dan ubin glyph app petugas sekeluarga.
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(ukuran * 0.58),
            side: BorderSide(
              color: gelap
                  ? const Color(0x1FFFFFFF)
                  : warna.last.withValues(alpha: 0.28),
            ),
          ),
          shadows: [
            BoxShadow(
              color: warna.last.withValues(alpha: gelap ? 0.28 : 0.22),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: isi,
      );
    }

    return Semantics(label: semantik, image: true, child: isi);
  }
}
