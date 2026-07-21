import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/auth/sesi_warga.dart';
import '../../../core/network/api_config.dart';
import '../../../core/theme/master_palette.dart';
import '../../../core/widgets/brand_header.dart' show HeaderChip;
import '../../../core/widgets/section_header.dart';
import '../akun/laporan_saya_screen.dart';
import '../akun/masuk_warga_screen.dart';
import '../cek_tagihan/cek_tagihan_screen.dart';
import '../langganan/widgets/langganan_saya_section.dart';
import '../lapor_meter/lapor_meter_screen.dart';
import '../pengaduan/lacak_tiket_screen.dart';
import '../pengaduan/lapor_pengaduan_screen.dart';
import '../../../core/widgets/ilustrasi_layanan.dart';
import 'widgets/beranda_hero.dart';
import 'widgets/catatan_layanan.dart';
import 'widgets/quick_action_grid.dart';
import 'widgets/tiket_aktif_section.dart';

/// Beranda aplikasi PUBLIK — hero navy + grid layanan gaya launcher.
///
/// `onBukaAkun`: dipanggil saat pengguna menekan slot akun di hero.
/// Null = layar ini dibuka berdiri sendiri (dorong MasukWargaScreen/
/// LaporanSayaScreen sebagai layar baru); diisi MainShellScreen supaya
/// tekanan yang sama justru BERPINDAH TAB ke "Akun" alih-alih menumpuk
/// layar di atas shell. Pola sama seperti `onBukaAkun` pada bottom dock —
/// beranda tidak perlu tahu ia sedang jadi tab atau layar mandiri.
class BerandaPublikScreen extends StatefulWidget {
  const BerandaPublikScreen({super.key, this.onBukaAkun, this.onBukaLaporan});

  final VoidCallback? onBukaAkun;

  /// Dipanggil dari "Lihat semua" pada blok Tiket Aktif. Sama polanya
  /// dengan [onBukaAkun]: null = dorong layar baru, diisi MainShellScreen
  /// supaya BERPINDAH TAB ke "Laporan".
  final VoidCallback? onBukaLaporan;

  @override
  State<BerandaPublikScreen> createState() => _BerandaPublikScreenState();
}

class _BerandaPublikScreenState extends State<BerandaPublikScreen> {
  void _buka(BuildContext context, Widget Function() tujuan) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => tujuan(),
        transitionsBuilder: (_, animasi, _, child) =>
            FadeTransition(opacity: animasi, child: child),
      ),
    );
  }

  void _bukaAkun(BuildContext context) {
    if (widget.onBukaAkun != null) {
      widget.onBukaAkun!();
      return;
    }
    final sudahMasuk = SesiWarga.instance.sudahMasuk;
    _buka(
      context,
      () => sudahMasuk ? const LaporanSayaScreen() : const MasukWargaScreen(),
    );
  }

  String get _sapaan {
    final jam = DateTime.now().hour;
    if (jam < 10) return 'Selamat pagi,';
    if (jam < 15) return 'Selamat siang,';
    if (jam < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  @override
  Widget build(BuildContext context) {
    final akun = SesiWarga.instance.akun;

    return ColoredBox(
      color: ShadTheme.of(context).colorScheme.background,
      // TANPA SafeArea di sini — SENGAJA, dan ini load-bearing untuk dua hal
      // sekaligus. SafeArea dulu menyisakan strip setinggi status bar yang
      // diisi ColoredBox warna background tema, bukan hero: (1) gradien hero
      // tidak sampai ke tepi atas layar, dan (2) strip itu PUTIH di tema
      // terang sementara hero menyatakan ikon status bar putih lewat
      // AnnotatedRegion -> jam/sinyal/baterai hilang. Di tema gelap
      // kebetulan selamat karena background-nya memang gelap, sehingga bug
      // ini hanya muncul saat berpindah ke tema terang.
      //
      // Hero punya SafeArea sendiri di dalam (bottom: false) untuk menahan
      // KONTEN-nya turun di bawah status bar, jadi teks tetap aman —
      // yang naik ke belakang status bar hanya gradiennya.
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: BerandaHero(
              sapaan: _sapaan,
              nama: akun?.name ?? 'Warga Tirtawening',
              trailing: _TombolAkun(
                akun: akun,
                onTap: () => _bukaAkun(context),
              ),
              // Chip ajakan masuk HANYA untuk pengunjung anonim. Bagi
              // yang sudah masuk ia tidak menawarkan apa pun, sementara
              // KartuLangganan tepat di bawahnya sudah membawa identitas
              // yang sama — jadi hero mengerut dan panggung diserahkan ke
              // kartu (lihat kaki dinamis di BerandaHero).
              content: akun == null
                  ? _StatusAkunChip(akun: akun, onTap: () => _bukaAkun(context))
                  : null,
              chip: ApiConfig.isDemo
                  ? const HeaderChip(label: 'MODE DEMO')
                  : null,
            ),
          ),
          SliverPadding(
            // Dirapatkan dari (20, 24) — beranda sebelumnya menuntut
            // scroll hanya untuk melihat empat layanan pokoknya.
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kartu biodata langganan tertaut — hanya muncul saat
                  // sudah login (beranda anonim tidak berubah).
                  const LanggananSayaSection(),
                  // Tiket yang masih berjalan naik ke atas daftar layanan:
                  // bagi pengguna yang punya pengaduan terbuka, "bagaimana
                  // laporan saya?" mendahului "saya mau apa hari ini".
                  // Kosong/anonim -> menghilang sepenuhnya, tata letak
                  // beranda kembali seperti semula.
                  TiketAktifSection(onBukaSemua: widget.onBukaLaporan),
                  SectionHeader(judul: 'Layanan'),
                  QuickActionGrid(
                    aksi: [
                      // Gradien = rumpun palet master (master_palette.dart):
                      // Sky, Teal, Rose, Emerald — warna per domain SAMA
                      // dengan padanannya di app petugas.
                      QuickAction(
                        ikon: CupertinoIcons.doc_text_fill,
                        label: 'Cek Tagihan',
                        ilustrasi: Ilustrasi.cekTagihan,
                        // Sky — aksi finansial/administratif.
                        gradasi: const [
                          Color(MasterPalette.sky300),
                          Color(MasterPalette.sky600),
                        ],
                        onTap: () =>
                            _buka(context, () => const CekTagihanScreen()),
                      ),
                      QuickAction(
                        ikon: CupertinoIcons.gauge,
                        label: 'Lapor Meter',
                        ilustrasi: Ilustrasi.laporMeter,
                        // Teal — SAMA PERSIS dengan "Pencatat Meter" di
                        // app petugas: domain tugas yang sama.
                        gradasi: const [
                          Color(MasterPalette.teal),
                          Color(MasterPalette.teal600),
                        ],
                        onTap: () =>
                            _buka(context, () => const LaporMeterScreen()),
                      ),
                      QuickAction(
                        ikon: CupertinoIcons.chat_bubble_text_fill,
                        label: 'Pengaduan',
                        ilustrasi: Ilustrasi.pengaduan,
                        // Rose — SAMA PERSIS dengan "Petugas Gangguan" di
                        // app petugas: satu tiket, dua sisi, satu warna.
                        gradasi: const [
                          Color(MasterPalette.rose400),
                          Color(MasterPalette.rose600),
                        ],
                        onTap: () =>
                            _buka(context, () => const LaporPengaduanScreen()),
                      ),
                      QuickAction(
                        ikon: CupertinoIcons.doc_text_search,
                        label: 'Lacak Tiket',
                        ilustrasi: Ilustrasi.lacakTiket,
                        // Emerald — aksi informasional/positif.
                        gradasi: const [
                          Color(MasterPalette.emerald400),
                          Color(MasterPalette.emerald600),
                        ],
                        onTap: () =>
                            _buka(context, () => const LacakTiketScreen()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Dulu dua InfoBanner bergradien penuh (Emerald & Sky).
                  // Isinya statis dan tidak menuntut tindakan, jadi warna
                  // sejenuh itu membuatnya bersaing dengan tunggakan dan
                  // status tiket — hal yang benar-benar berubah. Sekarang
                  // tenang, dan warna pekat dipulangkan ke sana.
                  const CatatanLayanan(
                    butir: [
                      CatatanButir(
                        ikon: CupertinoIcons.info_circle,
                        judul: 'Satu laporan meter per bulan',
                        isi:
                            'laporan mandiri diverifikasi petugas sebelum '
                            'jadi angka resmi tagihan.',
                      ),
                      CatatanButir(
                        ikon: CupertinoIcons.phone,
                        judul: 'Gangguan 24 jam',
                        isi:
                            'kebocoran besar atau air mati area luas — '
                            'pilih kategori Kebocoran agar diprioritaskan.',
                      ),
                    ],
                  ),
                  // Ruang kosong di bawah supaya konten terakhir tidak
                  // tertutup BottomDock mengambang milik MainShellScreen.
                  const SizedBox(height: 82),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tombol akun di pojok kanan atas hero — ikon lonceng-notifikasi diganti
/// ikon akun karena aplikasi ini belum punya sistem notifikasi sungguhan;
/// menampilkan lonceng aktif akan menjanjikan sesuatu yang tidak ada.
class _TombolAkun extends StatelessWidget {
  const _TombolAkun({required this.akun, required this.onTap});

  final WargaAkun? akun;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0x1AFFFFFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x1FFFFFFF)),
        ),
        child: Icon(
          akun != null
              ? CupertinoIcons.person_crop_circle_fill
              : CupertinoIcons.person_add_solid,
          color: const Color(0xFFFFFFFF),
          size: 20,
        ),
      ),
    );
  }
}

/// Chip status akun di dalam hero — jujur soal keadaan sesi, bukan kartu
/// tagihan karangan (aplikasi ini tidak mengelola tagihan per-akun; cek
/// tagihan tetap lookup manual lewat nomor langganan).
class _StatusAkunChip extends StatelessWidget {
  const _StatusAkunChip({required this.akun, required this.onTap});

  final WargaAkun? akun;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final masuk = akun != null;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0x14FFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x24FFFFFF)),
        ),
        child: Row(
          children: [
            Icon(
              masuk
                  ? CupertinoIcons.checkmark_circle_fill
                  : CupertinoIcons.person_crop_circle,
              size: 18,
              color: const Color(0xFFE0F2FE),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                masuk
                    ? 'Laporan Anda tersimpan otomatis di akun ini.'
                    : 'Masuk atau daftar supaya laporan Anda tersimpan otomatis.',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFE0F2FE),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: Color(0x99FFFFFF),
            ),
          ],
        ),
      ),
    );
  }
}
