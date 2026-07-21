import 'package:flutter/widgets.dart';

import '../../../../core/theme/master_palette.dart';
import '../../../../core/theme/pdam_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/labels.dart';
import '../../../../core/widgets/logo_perusahaan.dart';
import '../langganan_warga_repository.dart';

/// "Kartu pelanggan" satu nomor langganan — biodata yang tampil di beranda
/// warga. Gradien navy SAMA keluarga dengan BerandaHero supaya terlihat
/// satu identitas visual, bukan komponen asing.
///
/// Disusun seperti KARTU RESMI sungguhan, bukan kartu ringkasan biasa:
/// kop berlogo di atas, nomor langganan sebagai tokoh utama di tengah,
/// identitas & status di kaki. Urutan itu disengaja — yang dibacakan warga
/// lewat telepon atau ditunjukkan ke petugas adalah NOMORNYA, jadi nomor
/// itulah yang harus ditemukan mata lebih dulu.
///
/// Mark perusahaan muncul dua kali dan keduanya lewat widget resmi
/// (core/widgets/logo_perusahaan.dart): logo penuh di kop, dan siluet
/// monokrom besar sebagai watermark. TIDAK memakai ikon tetes air generik
/// — kartu ini identitas pelanggan terhadap perusahaan.
///
/// Semua teks di atas gradien gelap pakai putih eksplisit (bukan token
/// tema) — kartu ini gelap di TERANG maupun gelap, seperti hero.
class KartuLangganan extends StatelessWidget {
  const KartuLangganan({super.key, required this.langganan, this.onTap});

  final LanggananWargaModel langganan;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final adaTunggakan = langganan.totalTunggakan > 0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      // Container ber-clipBehavior, BUKAN DecoratedBox + ClipPath terpisah.
      // Dengan dua lapis terpisah, tepi klip yang di-antialias menyisakan
      // piksel setengah-transparan yang MENYINGKAP bayangan gelap di
      // belakangnya — terbaca sebagai garis rambut abu-abu di sekeliling
      // kartu, dan hanya kentara di tema terang (di tema gelap garis itu
      // senada dengan latar). clipBehavior memakai path yang SAMA dengan
      // ShapeDecoration-nya, jadi gradien dan klip berbagi satu tepi.
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(PdamPalette.heroGradient1),
              Color(PdamPalette.heroGradient2),
              Color(PdamPalette.heroGradient4),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x330F172A),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Watermark: siluet logo besar, dipotong tepi kanan kartu.
            // Opacity sangat rendah — ia tekstur kertas, bukan gambar.
            // Diletakkan sebelum konten agar selalu di belakang teks.
            Positioned(
              right: -34,
              bottom: -26,
              child: Opacity(
                opacity: 0.07,
                child: const LogoPerusahaanMono(ukuran: 150),
              ),
            ),
            // Sapuan cahaya tipis dari sudut kiri-atas — memberi kesan
            // permukaan kartu memantulkan cahaya (efek yang sama sudah
            // dipakai hero lewat orb radial-nya).
            Positioned(
              left: -50,
              top: -70,
              child: Container(
                width: 170,
                height: 170,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x2638BDF8), Color(0x0038BDF8)],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _KopKartu(isUtama: langganan.isUtama),
                  const SizedBox(height: 14),
                  const _GarisRambut(),
                  const SizedBox(height: 14),
                  _NomorLangganan(nomor: langganan.nomorLangganan),
                  const SizedBox(height: 12),
                  _BarisIdentitas(langganan: langganan),
                  const SizedBox(height: 14),
                  _KakiKartu(langganan: langganan, adaTunggakan: adaTunggakan),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kop: logo resmi + nama penerbit kartu. Susunannya sengaja kembar dengan
/// `_BrandMark` milik BerandaHero — kartu dan hero harus terbaca sebagai
/// terbitan lembaga yang sama.
class _KopKartu extends StatelessWidget {
  const _KopKartu({required this.isUtama});

  final bool isUtama;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const LogoPerusahaan(ukuran: 30, diAtasGelap: true),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PERUMDA TIRTAWENING',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0x8CFFFFFF),
                  letterSpacing: 1.3,
                ),
              ),
              SizedBox(height: 1),
              Text(
                'Kartu Langganan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(PdamPalette.white),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        if (isUtama) const _ChipKartu(label: 'Utama'),
      ],
    );
  }
}

/// Garis rambut pemisah kop dan badan kartu — memudar di kedua ujung
/// supaya tidak terlihat seperti border kotak yang kaku.
class _GarisRambut extends StatelessWidget {
  const _GarisRambut();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0x00FFFFFF), Color(0x2EFFFFFF), Color(0x00FFFFFF)],
        ),
      ),
    );
  }
}

/// Nomor langganan — tokoh utama kartu.
class _NomorLangganan extends StatelessWidget {
  const _NomorLangganan({required this.nomor});

  final String nomor;

  /// Kelompok 5-3-3 supaya 11 digit terbaca, seperti nomor kartu.
  /// Bertahan pada nomor yang lebih pendek dari 11 digit (data lama):
  /// `substring` mentah akan melempar RangeError, jadi format cantik ini
  /// dilewati saja alih-alih merusak seluruh kartu.
  String get _terformat {
    if (nomor.length != 11) return nomor;
    return '${nomor.substring(0, 5)} ${nomor.substring(5, 8)} '
        '${nomor.substring(8)}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'NOMOR LANGGANAN',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Color(0x8CE0F2FE),
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _terformat,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 20,
            letterSpacing: 2.6,
            fontWeight: FontWeight.w700,
            color: Color(PdamPalette.white),
            // Angka tabular: lebar tiap digit sama, jadi nomor tidak
            // "bergoyang" saat kartu digeser di PageView.
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

/// Nama + alamat pemegang kartu.
class _BarisIdentitas extends StatelessWidget {
  const _BarisIdentitas({required this.langganan});

  final LanggananWargaModel langganan;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          langganan.nama,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFFFFFFFF),
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          langganan.alamatLengkap,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11.5, color: Color(0x99E0F2FE)),
        ),
      ],
    );
  }
}

/// Kaki kartu: status & golongan di kiri, tunggakan di kanan.
class _KakiKartu extends StatelessWidget {
  const _KakiKartu({required this.langganan, required this.adaTunggakan});

  final LanggananWargaModel langganan;
  final bool adaTunggakan;

  @override
  Widget build(BuildContext context) {
    // Chip dan tunggakan menempati BARIS TERPISAH, bukan kiri-kanan pada
    // baris yang sama. Terukur (test/kartu_langganan_test.dart): dengan
    // keduanya berebut ruang horizontal, kartu selebar 320 pada isi
    // terpanjang tumbuh 226 -> 293 karena masing-masing membungkus ke
    // bawah — dan tinggi kartu di sini WAJIB tetap (PageView di
    // LanggananSayaSection memakai tinggi pasti). Dipisah begini, tiap
    // baris punya lebar penuh dan tingginya tidak lagi bergantung isi.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _ChipKartu(
              label: labelStatusPelanggan[langganan.status] ?? langganan.status,
              warna: langganan.status == 'AKTIF'
                  ? const Color(0x2910B981)
                  : const Color(0x29F43F5E),
            ),
            if (langganan.golonganKode != null) ...[
              const SizedBox(width: 6),
              Flexible(
                child: _ChipKartu(label: 'Gol. ${langganan.golonganKode}'),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                adaTunggakan
                    ? 'Tunggakan · ${langganan.jumlahTagihanBelumBayar} tagihan'
                    : 'Tunggakan',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: Color(0x99E0F2FE),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              adaTunggakan
                  ? formatRupiah(langganan.totalTunggakan)
                  : 'Tidak ada',
              maxLines: 1,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: adaTunggakan
                    ? const Color(MasterPalette.rose300)
                    : const Color(MasterPalette.emerald300),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Chip kecil translusen di atas kartu gelap.
class _ChipKartu extends StatelessWidget {
  const _ChipKartu({required this.label, this.warna});

  final String label;
  final Color? warna;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: warna ?? const Color(0x1FFFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x24FFFFFF)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: Color(MasterPalette.sky100),
        ),
      ),
    );
  }
}
