import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_panel.dart';
import 'antrean_upload_screen.dart';
import 'catat_meter_screen.dart';
import 'rute_repository.dart';
import 'scan_qr_screen.dart';

/// Baca Meter — daftar pelanggan rute petugas (RBM), urut kunjungan,
/// dengan tab Belum/Sudah dibaca (pola `daftarPelangganUnRead/Read`
/// Aurora) dan scan QR pelanggan (pola Scan & Get).
/// Tombol muat = UNDUH rute dari server (paket target + stand lalu) yang
/// di-cache untuk kerja offline; hasil catat yang antre offline dikirim
/// ulang otomatis setiap kali layar ini memuat.
class DaftarPelangganScreen extends StatefulWidget {
  const DaftarPelangganScreen({super.key});

  @override
  State<DaftarPelangganScreen> createState() => _DaftarPelangganScreenState();
}

class _DaftarPelangganScreenState extends State<DaftarPelangganScreen> {
  final _repo = RuteRepository.create();
  final _kontrolCari = TextEditingController();

  RuteSaya? _paket;
  String? _galat;
  String _kunci = '';
  int _tertunda = 0;

  /// false = tab "Belum Dibaca" (default kerja lapangan), true = "Sudah".
  bool _tabSudah = false;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  @override
  void dispose() {
    _kontrolCari.dispose();
    super.dispose();
  }

  Future<void> _muat() async {
    setState(() {
      _paket = null;
      _galat = null;
    });
    try {
      // Sinkron dulu: laporan yang antre offline dikirim sebelum paket
      // diunduh ulang, supaya progres dari server sudah memuat hasilnya.
      await _repo.kirimTertunda();
      final paket = await _repo.ruteSaya();
      final tertunda = await _repo.jumlahTertunda();
      if (!mounted) return;
      setState(() {
        _paket = paket;
        _tertunda = tertunda;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _galat = e.message);
    }
  }

  /// Daftar tab aktif (belum/sudah dibaca) SEBELUM kata kunci pencarian —
  /// juga menjadi urutan kunjungan untuk navigasi next/prev di layar catat.
  List<PelangganRute> get _daftarTab {
    final semua = _paket?.pelanggan ?? const <PelangganRute>[];
    return [
      for (final p in semua)
        if (p.sudahDicatat == _tabSudah) p,
    ];
  }

  List<PelangganRute> get _tersaring {
    final daftar = _daftarTab;
    if (_kunci.isEmpty) return daftar;
    final k = _kunci.toLowerCase();
    return daftar
        .where(
          (p) =>
              p.nomorLangganan.contains(k) ||
              p.nama.toLowerCase().contains(k) ||
              (p.alamat ?? '').toLowerCase().contains(k),
        )
        .toList();
  }

  Future<void> _bukaCatat(PelangganRute pelanggan) async {
    // Urutan kunjungan = daftar tab saat ini; navigasi next/prev dan
    // "lanjut ke berikutnya" di layar catat mengikuti urutan jalan ini.
    final urutan = _daftarTab;
    await Navigator.of(context).push<bool>(
      PageRouteBuilder(
        pageBuilder: (_, _, _) =>
            CatatMeterScreen(pelanggan: pelanggan, urutanKunjungan: urutan),
        transitionsBuilder: (_, animasi, _, child) =>
            FadeTransition(opacity: animasi, child: child),
      ),
    );
    // Selalu muat ulang: layar catat bisa berpindah-pindah pelanggan
    // (next/prev) sebelum kembali, hasilnya tidak terwakili satu bool.
    if (mounted) _muat();
  }

  /// Scanner butuh kamera perangkat — hanya Android/iOS (dev desktop tetap
  /// bisa memakai pencarian teks).
  bool get _bisaScan => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> _bukaAntrean() async {
    await Navigator.of(context).push<void>(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const AntreanUploadScreen(),
        transitionsBuilder: (_, animasi, _, child) =>
            FadeTransition(opacity: animasi, child: child),
      ),
    );
    if (mounted) _muat();
  }

  /// Scan QR → cocokkan dengan paket rute lokal (offline penuh, pola
  /// Scan & Get Aurora): persis nomor langganan, atau akhiran kode yang
  /// tercetak di kartu meter.
  Future<void> _scanQr() async {
    final hasil = await Navigator.of(context).push<String>(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const ScanQrScreen(),
        transitionsBuilder: (_, animasi, _, child) =>
            FadeTransition(opacity: animasi, child: child),
      ),
    );
    if (hasil == null || !mounted) return;

    final digit = hasil.replaceAll(RegExp(r'\D'), '');
    final semua = _paket?.pelanggan ?? const <PelangganRute>[];
    final cocok = semua.where(
      (p) =>
          p.nomorLangganan == hasil ||
          (digit.isNotEmpty &&
              (p.nomorLangganan == digit || p.nomorLangganan.endsWith(digit))),
    );
    if (cocok.isEmpty) {
      await showShadDialog<void>(
        context: context,
        builder: (context) => ShadDialog.alert(
          title: const Text('Tidak Ditemukan'),
          description: Text(
            'Kode "$hasil" tidak cocok dengan pelanggan mana pun di rute '
            'Anda. Pastikan rute sudah diunduh, atau cari manual.',
          ),
          actions: [
            ShadButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
      return;
    }
    await _bukaCatat(cocok.first);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final paket = _paket;
    final periode = paket?.periode ?? periodeCatatSekarang();

    return AppScaffold(
      title: 'Baca Meter',
      subtitle: 'Rute kunjungan · ${labelPeriode(periode)}',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_bisaScan)
            ShadIconButton.ghost(
              icon: const Icon(CupertinoIcons.qrcode_viewfinder),
              onPressed: paket == null ? null : _scanQr,
            ),
          ShadIconButton.ghost(
            icon: const Icon(CupertinoIcons.cloud_download),
            onPressed: _muat,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (paket != null && paket.ruteKode != null) ...[
                  _KartuProgres(
                    paket: paket,
                    tertunda: _tertunda,
                    onBukaAntrean: _bukaAntrean,
                  ),
                  const SizedBox(height: 12),
                ],
                ShadInput(
                  controller: _kontrolCari,
                  placeholder: const Text(
                    'Cari nomor langganan / nama / alamat…',
                  ),
                  leading: const Icon(CupertinoIcons.search, size: 16),
                  onChanged: (v) => setState(() => _kunci = v.trim()),
                ),
                const SizedBox(height: 8),
                // Tab Belum/Sudah dibaca (pola read/unread Aurora) — hitungan
                // mengikuti paket, bukan hasil saring, supaya stabil.
                if (paket != null && paket.ruteKode != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _TombolTab(
                          label:
                              'Belum Dibaca (${paket.target - paket.terbaca})',
                          aktif: !_tabSudah,
                          onTap: () => setState(() => _tabSudah = false),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _TombolTab(
                          label: 'Sudah Dibaca (${paket.terbaca})',
                          aktif: _tabSudah,
                          onTap: () => setState(() => _tabSudah = true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          Expanded(
            child: switch ((paket, _galat)) {
              (null, null) => const Center(child: CircularProgressIndicator()),
              (null, final String galat) => Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ShadAlert.destructive(
                      icon: const Icon(CupertinoIcons.exclamationmark_circle),
                      title: const Text('Gagal mengunduh rute'),
                      description: Text(galat),
                    ),
                    const SizedBox(height: 12),
                    ShadButton.outline(
                      onPressed: _muat,
                      leading: const Icon(CupertinoIcons.arrow_clockwise),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
              (final RuteSaya p, _) when p.ruteKode == null => Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.map_pin_slash,
                      size: 40,
                      color: theme.colorScheme.mutedForeground,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Rute belum ditugaskan ke akun Anda.\n'
                      'Penugasan rute diatur admin di dashboard web '
                      '(menu Pencatat) — hubungi admin bila belum ada.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.muted,
                    ),
                  ],
                ),
              ),
              _ =>
                _tersaring.isEmpty
                    ? Center(
                        child: Text(
                          _kunci.isNotEmpty
                              ? 'Tidak ada pelanggan yang cocok.'
                              : _tabSudah
                              ? 'Belum ada yang dicatat periode ini.'
                              : 'Semua pelanggan rute sudah dibaca. 🎉',
                          style: theme.textTheme.muted,
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: _tersaring.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) => _BarisPelanggan(
                          pelanggan: _tersaring[i],
                          onTap: () => _bukaCatat(_tersaring[i]),
                        ),
                      ),
            },
          ),
        ],
      ),
    );
  }
}

class _TombolTab extends StatelessWidget {
  const _TombolTab({
    required this.label,
    required this.aktif,
    required this.onTap,
  });

  final String label;
  final bool aktif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: aktif ? const Color(AppEmerald.c600) : theme.colorScheme.muted,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: aktif
                ? const Color(AppEmerald.c600)
                : theme.colorScheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: aktif
                ? const Color(0xFFFFFFFF)
                : theme.colorScheme.mutedForeground,
          ),
        ),
      ),
    );
  }
}

class _KartuProgres extends StatelessWidget {
  const _KartuProgres({
    required this.paket,
    required this.tertunda,
    this.onBukaAntrean,
  });

  final RuteSaya paket;
  final int tertunda;

  /// Chip "N antre" membuka layar Antrean Upload (baris bermasalah
  /// kelihatan pesannya di sana).
  final VoidCallback? onBukaAntrean;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final rasio = paket.target == 0 ? 0.0 : paket.terbaca / paket.target;
    final unduh = paket.diunduhPada;
    return GlassPanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(AppEmerald.c600),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  paket.ruteKode ?? 'Rute Anda',
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (paket.dariCache) ...[
                const SizedBox(width: 6),
                _ChipKecil(
                  ikon: CupertinoIcons.wifi_slash,
                  label: 'Offline',
                  bahaya: true,
                ),
              ],
              if (tertunda > 0) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onBukaAntrean,
                  child: _ChipKecil(
                    ikon: CupertinoIcons.cloud_upload,
                    label: '$tertunda antre',
                  ),
                ),
              ],
              const Spacer(),
              Text(
                '${paket.terbaca} dari ${paket.target} target',
                style: theme.textTheme.muted,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ShadProgress(value: rasio, color: const Color(AppEmerald.c600)),
          if (unduh != null) ...[
            const SizedBox(height: 8),
            Text(
              'Terunduh ${formatWaktuLokal(unduh)}'
              '${paket.dariCache ? ' · data terakhir sebelum sinyal hilang' : ''}',
              style: theme.textTheme.muted.copyWith(fontSize: 10.5),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChipKecil extends StatelessWidget {
  const _ChipKecil({
    required this.ikon,
    required this.label,
    this.bahaya = false,
  });

  final IconData ikon;
  final String label;
  final bool bahaya;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final warna = bahaya
        ? theme.colorScheme.destructive
        : theme.colorScheme.mutedForeground;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: theme.colorScheme.muted,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, size: 11, color: warna),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.muted.copyWith(
              fontSize: 10.5,
              color: bahaya ? theme.colorScheme.destructive : null,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarisPelanggan extends StatelessWidget {
  const _BarisPelanggan({required this.pelanggan, required this.onTap});

  final PelangganRute pelanggan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final selesai = pelanggan.sudahDicatat;
    return GlassPanel(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selesai
                  ? const Color(AppEmerald.c600)
                  : theme.colorScheme.secondary,
              shape: BoxShape.circle,
            ),
            child: selesai
                ? const Icon(
                    CupertinoIcons.checkmark,
                    size: 16,
                    color: Color(0xFFFFFFFF),
                  )
                : Text(
                    '${pelanggan.urutan ?? '-'}',
                    style: theme.textTheme.small,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pelanggan.nama, style: theme.textTheme.small),
                const SizedBox(height: 1),
                Text(
                  '${pelanggan.nomorLangganan}'
                  '${pelanggan.nomorMeter == null ? '' : ' · ${pelanggan.nomorMeter}'}'
                  '${pelanggan.status == null || pelanggan.status == 'AKTIF' ? '' : ' · ${pelanggan.status}'}',
                  style: theme.textTheme.muted.copyWith(fontSize: 11.5),
                ),
                if (pelanggan.alamat != null)
                  Text(
                    pelanggan.alamat!,
                    style: theme.textTheme.muted.copyWith(fontSize: 11.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (pelanggan.standLalu != null)
                Text(
                  'Lalu: ${pelanggan.standLalu}',
                  style: theme.textTheme.muted.copyWith(fontSize: 11),
                ),
              const SizedBox(height: 2),
              Icon(
                selesai
                    ? CupertinoIcons.checkmark_seal_fill
                    : CupertinoIcons.chevron_right,
                size: 16,
                color: selesai
                    ? const Color(AppEmerald.c600)
                    : theme.colorScheme.mutedForeground,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
