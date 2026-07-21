import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_panel.dart';
import 'rute_repository.dart';
import 'tarif_repository.dart';

/// Download Data — padanan `DownloadDataActivity` Aurora: unduh SEKALIGUS
/// semua yang dibutuhkan untuk kerja offline seharian — paket rute
/// (pelanggan + stand lalu + riwayat 3 periode) dan master tarif untuk
/// estimasi uang air. Menampilkan keadaan data yang tersimpan sekarang,
/// mengonfirmasi penggantian, lalu mengunduh dengan progres.
///
/// Antrean hasil catat yang belum terkirim TIDAK tersentuh unduhan (tabel
/// terpisah) — mengunduh ulang aman, tidak menghapus hasil kerja.
class DownloadDataScreen extends StatefulWidget {
  const DownloadDataScreen({super.key});

  @override
  State<DownloadDataScreen> createState() => _DownloadDataScreenState();
}

class _DownloadDataScreenState extends State<DownloadDataScreen> {
  final _rute = RuteRepository.create();
  final _tarif = TarifRepository();

  RuteSaya? _paket;
  int _jumlahTarif = 0;
  int _tertunda = 0;
  bool _memuat = true;
  bool _mengunduh = false;
  String? _galat;
  String? _hasil;

  @override
  void initState() {
    super.initState();
    _muatKeadaan();
  }

  /// Keadaan data lokal saat ini (tanpa memaksa unduh) — pakai cache bila
  /// ada supaya layar tetap informatif saat offline. Rute + antrean dulu
  /// (itu yang menentukan tampilan utama), lalu jumlah tarif terpisah:
  /// pembacaan master tarif menyentuh cache SQLite yang bisa lambat/menahan,
  /// jangan sampai menahan seluruh layar di balik spinner.
  Future<void> _muatKeadaan() async {
    try {
      final paket = await _rute.ruteSaya(segarkan: false);
      final tertunda = await _rute.jumlahTertunda();
      if (!mounted) return;
      setState(() {
        _paket = paket;
        _tertunda = tertunda;
        _memuat = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _memuat = false;
        _galat = e.message;
      });
    }
    try {
      final tarif = await _tarif.jumlahTersimpan();
      if (mounted) setState(() => _jumlahTarif = tarif);
    } on Object {
      // biarkan 0 — estimasi bukan inti layar unduh.
    }
  }

  Future<void> _unduh() async {
    // Konfirmasi mengganti data yang ada (pola promtReplaceData Aurora) —
    // tegaskan bahwa antrean kiriman TIDAK ikut terhapus.
    if (_paket?.ruteKode != null) {
      final lanjut = await showShadDialog<bool>(
        context: context,
        builder: (context) => ShadDialog(
          title: const Text('Unduh Ulang Data?'),
          description: Text(
            'Data rute yang tersimpan akan diganti dengan yang terbaru dari '
            'server.'
            '${_tertunda > 0 ? '\n\n$_tertunda hasil catat yang belum terkirim TIDAK akan hilang — kirim dulu lewat Upload Data bila ragu.' : ''}',
          ),
          actions: [
            ShadButton.outline(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            ShadButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Unduh'),
            ),
          ],
        ),
      );
      if (lanjut != true || !mounted) return;
    }

    setState(() {
      _mengunduh = true;
      _galat = null;
      _hasil = null;
    });
    try {
      // Rute dulu (inti kerja), lalu master tarif (pelengkap estimasi) —
      // tarif gagal tidak menggagalkan unduhan rute.
      final paket = await _rute.ruteSaya();
      var jumlahTarif = _jumlahTarif;
      try {
        jumlahTarif = await _tarif.unduh();
      } on ApiException {
        // estimasi tetap pakai cache lama — bukan penghalang.
      }
      if (!mounted) return;
      setState(() {
        _paket = paket;
        _jumlahTarif = jumlahTarif;
        _mengunduh = false;
        _hasil = paket.ruteKode == null
            ? 'Akun Anda belum ditugaskan rute — penugasan diatur admin di '
                  'dashboard web (menu Pemetaan Rute). Hubungi admin, lalu '
                  'unduh lagi.'
            : 'Berhasil: ${paket.target} pelanggan '
                  '${paket.rutes.length > 1 ? '(${paket.rutes.length} rute)' : 'rute ${paket.ruteKode}'}'
                  '${jumlahTarif > 0 ? ' + $jumlahTarif golongan tarif' : ''} '
                  'siap dipakai offline.';
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _mengunduh = false;
        _galat = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final paket = _paket;
    final adaRute = paket?.ruteKode != null;

    return AppScaffold(
      title: 'Download Data',
      subtitle: 'Unduh rute & master tarif untuk kerja offline',
      body: _memuat
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Keadaan data tersimpan
                GlassPanel(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            adaRute
                                ? CupertinoIcons.checkmark_seal_fill
                                : CupertinoIcons.tray,
                            size: 18,
                            color: adaRute
                                ? const Color(AppEmerald.c600)
                                : theme.colorScheme.mutedForeground,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              adaRute
                                  ? 'Data tersimpan di perangkat'
                                  : 'Belum ada data rute tersimpan',
                              style: theme.textTheme.small,
                            ),
                          ),
                          if (paket?.dariCache == true)
                            Text(
                              'offline',
                              style: theme.textTheme.muted.copyWith(
                                fontSize: 10.5,
                                color: theme.colorScheme.destructive,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _BarisData(
                        ikon: CupertinoIcons.map_fill,
                        label: 'Rute',
                        // Jumlah rute yang DIPETAKAN ke akun ini (bukan satu
                        // kode) — beberapa rute bisa ditugaskan sekaligus.
                        nilai: adaRute ? _ringkasRute(paket!) : '—',
                      ),
                      _BarisData(
                        ikon: CupertinoIcons.person_2_fill,
                        // Total pelanggan/SL lintas SEMUA rute (target periode).
                        label: 'Pelanggan (SL)',
                        nilai: adaRute ? '${paket!.target}' : '—',
                      ),
                      _BarisData(
                        ikon: CupertinoIcons.money_dollar_circle_fill,
                        label: 'Golongan tarif',
                        nilai: _jumlahTarif > 0 ? '$_jumlahTarif' : '—',
                      ),
                      _BarisData(
                        ikon: CupertinoIcons.cloud_upload_fill,
                        label: 'Antre kirim',
                        nilai: '$_tertunda',
                        bahaya: _tertunda > 0,
                      ),
                      if (paket?.diunduhPada != null)
                        _BarisData(
                          ikon: CupertinoIcons.clock,
                          label: 'Terunduh',
                          nilai: formatWaktuLokal(paket!.diunduhPada!),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                if (_hasil != null) ...[
                  ShadAlert(
                    icon: const Icon(CupertinoIcons.checkmark_circle),
                    title: const Text('Selesai'),
                    description: Text(_hasil!),
                  ),
                  const SizedBox(height: 12),
                ],
                if (_galat != null) ...[
                  ShadAlert.destructive(
                    icon: const Icon(CupertinoIcons.exclamationmark_circle),
                    title: const Text('Gagal mengunduh'),
                    description: Text(_galat!),
                  ),
                  const SizedBox(height: 12),
                ],

                ShadButton(
                  onPressed: _mengunduh ? null : _unduh,
                  backgroundColor: const Color(AppEmerald.c600),
                  hoverBackgroundColor: const Color(AppEmerald.c500),
                  leading: _mengunduh
                      ? const SizedBox.square(
                          dimension: 15,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          CupertinoIcons.cloud_download_fill,
                          size: 16,
                        ),
                  child: Text(
                    _mengunduh
                        ? 'Mengunduh…'
                        : adaRute
                        ? 'Unduh Ulang Data Terbaru'
                        : 'Unduh Data Sekarang',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Unduh saat masih ada sinyal (di kantor / area sinyal kuat) '
                  'sebelum berangkat. Setelah terunduh, seluruh rute bisa '
                  'dicatat tanpa jaringan; hasilnya dikirim lewat Upload Data.',
                  style: theme.textTheme.muted.copyWith(fontSize: 11),
                ),
              ],
            ),
    );
  }
}

/// Ringkas jumlah rute yang dipetakan ke akun + kodenya bila ringkas.
/// Paket lama (satu rute) hanya punya `ruteKode`; paket baru punya daftar
/// `rutes`. Contoh: "2 · R-042, R-043" atau "5 rute".
String _ringkasRute(RuteSaya paket) {
  final kode = paket.rutes.isNotEmpty
      ? paket.rutes.map((r) => r.kode).toList()
      : (paket.ruteKode != null ? [paket.ruteKode!] : const <String>[]);
  if (kode.isEmpty) return '—';
  if (kode.length <= 3) return '${kode.length} · ${kode.join(', ')}';
  return '${kode.length} rute';
}

class _BarisData extends StatelessWidget {
  const _BarisData({
    required this.ikon,
    required this.label,
    required this.nilai,
    this.bahaya = false,
  });

  final IconData ikon;
  final String label;
  final String nilai;
  final bool bahaya;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(ikon, size: 14, color: theme.colorScheme.mutedForeground),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.muted.copyWith(fontSize: 12.5),
            ),
          ),
          Text(
            nilai,
            style: theme.textTheme.small.copyWith(
              fontSize: 13,
              color: bahaya ? theme.colorScheme.destructive : null,
            ),
          ),
        ],
      ),
    );
  }
}
