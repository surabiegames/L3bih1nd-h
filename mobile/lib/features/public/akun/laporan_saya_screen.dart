import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/auth/sesi_warga.dart';
import '../../../core/models/complaint_ticket_model.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/labels.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/status_badge.dart';
import '../pengaduan/lacak_tiket_screen.dart';
import 'laporan_saya_repository.dart';
import 'masuk_warga_screen.dart';

/// Laporan Saya — daftar tiket pengaduan yang dibuat akun warga yang sedang
/// login. Baris diklik -> LacakTiketScreen(nomorAwal: ...) yang sudah punya
/// seluruh tampilan detail + aksi konfirmasi/nilai/buka-kembali — TIDAK
/// diduplikasi di sini.
///
/// `onPerluMasuk`: dipanggil setiap kali layar ini butuh mengarahkan
/// pengguna ke alur masuk — sesudah logout, ATAU saat sesi ternyata sudah
/// berakhir (401 dari server). Null = dorong MasukWargaScreen sebagai
/// layar baru (dipakai saat layar ini berdiri sendiri); diisi
/// MainShellScreen supaya kasus yang sama justru BERPINDAH TAB ke "Akun".
class LaporanSayaScreen extends StatefulWidget {
  const LaporanSayaScreen({super.key, this.onPerluMasuk});

  final VoidCallback? onPerluMasuk;

  @override
  State<LaporanSayaScreen> createState() => _LaporanSayaScreenState();
}

class _LaporanSayaScreenState extends State<LaporanSayaScreen> {
  // Lewat cache, bukan repository langsung: blok Tiket Aktif di beranda
  // membaca daftar yang SAMA, dan tanpa ini membuka aplikasi memanggil
  // `GET /pengaduan/saya` dua kali. "Coba lagi" tetap memaksa muat ulang.
  late Future<List<ComplaintTicketModel>> _tiket;

  @override
  void initState() {
    super.initState();
    _tiket = LaporanSayaCache.muat();
  }

  void _muatUlang() {
    setState(() => _tiket = LaporanSayaCache.muat(paksa: true));
  }

  void _perluMasuk(BuildContext context) {
    if (widget.onPerluMasuk != null) {
      widget.onPerluMasuk!();
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const MasukWargaScreen(),
        transitionsBuilder: (_, animasi, _, child) =>
            FadeTransition(opacity: animasi, child: child),
      ),
      (route) => route.isFirst,
    );
  }

  Future<void> _keluar() async {
    await SesiWarga.instance.keluar();
    if (!mounted) return;
    _perluMasuk(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final akun = SesiWarga.instance.akun;

    return AppScaffold(
      title: 'Laporan Saya',
      subtitle: akun?.name ?? 'Riwayat pengaduan Anda',
      trailing: ShadIconButton.ghost(
        icon: const Icon(CupertinoIcons.square_arrow_right),
        onPressed: _keluar,
      ),
      body: FutureBuilder<List<ComplaintTicketModel>>(
        future: _tiket,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final galat = snapshot.error;
            final tidakSah = galat is ApiException && galat.isUnauthorized;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ShadAlert.destructive(
                    icon: const Icon(CupertinoIcons.exclamationmark_circle),
                    title: Text(
                      tidakSah ? 'Sesi berakhir' : 'Gagal memuat laporan',
                    ),
                    description: Text(
                      tidakSah
                          ? 'Sesi Anda sudah berakhir — masuk kembali untuk melihat laporan Anda.'
                          : galat is ApiException
                          ? galat.message
                          : 'Terjadi kesalahan tak terduga.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  ShadButton.outline(
                    onPressed: tidakSah
                        ? () => _perluMasuk(context)
                        : _muatUlang,
                    leading: Icon(
                      tidakSah
                          ? CupertinoIcons.arrow_right_square
                          : CupertinoIcons.arrow_clockwise,
                    ),
                    child: Text(tidakSah ? 'Masuk Lagi' : 'Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final tiket = snapshot.requireData;
          if (tiket.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.tray_fill,
                      size: 40,
                      color: theme.colorScheme.mutedForeground,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Belum ada laporan yang tertaut ke akun ini. Pengaduan '
                      'yang Anda kirim saat sedang masuk akan muncul di sini.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.muted,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tiket.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _KartuTiketSaya(tiket: tiket[i]),
          );
        },
      ),
    );
  }
}

class _KartuTiketSaya extends StatelessWidget {
  const _KartuTiketSaya({required this.tiket});

  final ComplaintTicketModel tiket;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, _, _) =>
              LacakTiketScreen(nomorAwal: tiket.nomorTiket),
          transitionsBuilder: (_, animasi, _, child) =>
              FadeTransition(opacity: animasi, child: child),
        ),
      ),
      child: GlassPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(tiket.nomorTiket, style: theme.textTheme.muted),
                ),
                StatusBadge(
                  label: labelDari(labelStatusPengaduan, tiket.status),
                  tone: toneStatusPengaduan(tiket.status),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(tiket.judul, style: theme.textTheme.large),
            const SizedBox(height: 2),
            Text(
              '${labelDari(labelJenisPengaduan, tiket.jenis)}'
              '${tiket.createdAt == null ? '' : ' · dilaporkan ${formatWaktuLokal(tiket.createdAt!)}'}',
              style: theme.textTheme.muted,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
