import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/auth/sesi_warga.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/section_header.dart';
import '../kelola_langganan_screen.dart';
import '../langganan_warga_repository.dart';
import 'kartu_langganan.dart';

/// Blok "Langganan Saya" di beranda warga: kartu biodata langganan UTAMA,
/// digeser horizontal bila akun menautkan lebih dari satu nomor. Hanya
/// tampil saat sudah login — beranda anonim tidak berubah.
///
/// Data lewat LanggananSayaCache (sekali fetch per sesi; layar Kelola yang
/// menyegarkannya setelah mutasi) — beranda cukup membaca ulang cache saat
/// kembali dari layar itu.
class LanggananSayaSection extends StatefulWidget {
  const LanggananSayaSection({super.key});

  @override
  State<LanggananSayaSection> createState() => _LanggananSayaSectionState();
}

/// Tinggi KartuLangganan. Dipakai dua kali — rongga penahan saat memuat
/// dan tinggi PageView multi-kartu — jadi satu konstanta, bukan dua angka
/// yang harus diingat untuk diubah bersamaan tiap kali kartu berubah.
///
/// Angkanya DIUKUR, bukan ditaksir: `test/kartu_langganan_test.dart`
/// merender kartu pada isi terpanjang di layar 320 dan gagal bila kartu
/// melewatinya. Ubah isi kartu -> jalankan uji itu -> perbarui angka ini.
const double _tinggiKartu = 240;

class _LanggananSayaSectionState extends State<LanggananSayaSection> {
  List<LanggananWargaModel>? _data;
  String? _galat;
  int _halaman = 0;

  @override
  void initState() {
    super.initState();
    if (SesiWarga.instance.sudahMasuk) _muat();
  }

  Future<void> _muat() async {
    setState(() => _galat = null);
    try {
      final data = await LanggananSayaCache.muat();
      if (mounted) setState(() => _data = data);
    } on ApiException catch (e) {
      if (mounted) setState(() => _galat = e.message);
    }
  }

  Future<void> _bukaKelola() async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const KelolaLanggananScreen(),
        transitionsBuilder: (_, animasi, _, child) =>
            FadeTransition(opacity: animasi, child: child),
      ),
    );
    // Layar Kelola menyegarkan cache; baca ulang hasilnya begitu kembali.
    if (mounted) setState(() => _data = LanggananSayaCache.data ?? _data);
  }

  @override
  Widget build(BuildContext context) {
    if (!SesiWarga.instance.sudahMasuk) return const SizedBox.shrink();
    final theme = ShadTheme.of(context);

    if (_galat != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: ShadCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.exclamationmark_circle,
                size: 18,
                color: theme.colorScheme.destructive,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(_galat!, style: theme.textTheme.muted)),
              ShadButton.ghost(
                size: ShadButtonSize.sm,
                onPressed: _muat,
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final data = _data;
    if (data == null) {
      // Memuat: rongga setinggi kartu supaya layout tidak melompat.
      return const SizedBox(height: _tinggiKartu);
    }
    if (data.isEmpty) {
      // Akun lama (dibuat sebelum nomor langganan wajib) — ajak menautkan.
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: ShadCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.creditcard,
                size: 22,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tautkan nomor langganan Anda supaya biodata & tunggakan tampil di sini.',
                  style: theme.textTheme.muted,
                ),
              ),
              ShadButton(
                size: ShadButtonSize.sm,
                onPressed: _bukaKelola,
                child: const Text('Tautkan'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: SectionHeader(judul: 'Langganan Saya')),
            GestureDetector(
              onTap: _bukaKelola,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    Text(
                      'Kelola',
                      style: theme.textTheme.small.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      CupertinoIcons.chevron_right,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (data.length == 1)
          KartuLangganan(langganan: data.first, onTap: _bukaKelola)
        else ...[
          SizedBox(
            height: _tinggiKartu,
            child: PageView.builder(
              itemCount: data.length,
              controller: PageController(viewportFraction: 0.94),
              onPageChanged: (i) => setState(() => _halaman = i),
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: KartuLangganan(langganan: data[i], onTap: _bukaKelola),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < data.length; i++)
                  Container(
                    width: i == _halaman ? 16 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: i == _halaman
                          ? theme.colorScheme.primary
                          : theme.colorScheme.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 6),
      ],
    );
  }
}
