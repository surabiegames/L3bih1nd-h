import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/auth/sesi_warga.dart';
import '../../../../core/models/complaint_ticket_model.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/labels.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../akun/laporan_saya_repository.dart';
import '../../pengaduan/lacak_tiket_screen.dart';

/// Blok "Tiket Aktif" di beranda — menjawab pertanyaan pertama pengguna
/// aplikasi pengaduan: *bagaimana laporan saya?*
///
/// SENGAJA hanya tiket yang masih berjalan dan maksimal [_maksTampil] baris:
/// beranda adalah ringkasan, bukan daftar. Riwayat lengkap (termasuk yang
/// sudah ditutup) tetap milik layar Laporan Saya — baris di sini membuka
/// LacakTiketScreen yang sudah punya seluruh detail + aksi, tidak
/// diduplikasi.
///
/// Anonim = tidak tampil sama sekali (beranda anonim tidak berubah), sama
/// seperti LanggananSayaSection.
class TiketAktifSection extends StatefulWidget {
  const TiketAktifSection({super.key, this.onBukaSemua});

  /// Dipanggil saat pengguna menekan "Lihat semua". Null = dorong layar
  /// Laporan Saya sendiri; diisi MainShellScreen supaya BERPINDAH TAB —
  /// pola sama seperti `onBukaAkun` di beranda.
  final VoidCallback? onBukaSemua;

  @override
  State<TiketAktifSection> createState() => _TiketAktifSectionState();
}

class _TiketAktifSectionState extends State<TiketAktifSection> {
  static const _maksTampil = 2;

  List<ComplaintTicketModel>? _data;
  String? _galat;

  @override
  void initState() {
    super.initState();
    if (SesiWarga.instance.sudahMasuk) _muat();
  }

  Future<void> _muat() async {
    setState(() => _galat = null);
    try {
      await LaporanSayaCache.muat();
      if (mounted) setState(() => _data = LaporanSayaCache.aktif);
    } on ApiException catch (e) {
      // Sesi kedaluwarsa TIDAK ditampilkan sebagai galat merah di beranda:
      // blok ini pelengkap, dan layar Laporan Saya sudah menangani alur
      // "masuk lagi" dengan benar. Beranda cukup diam.
      if (mounted) setState(() => _galat = e.isUnauthorized ? null : e.message);
    }
  }

  Future<void> _bukaTiket(String nomorTiket) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => LacakTiketScreen(nomorAwal: nomorTiket),
        transitionsBuilder: (_, animasi, _, child) =>
            FadeTransition(opacity: animasi, child: child),
      ),
    );
    // Status bisa berubah di layar itu (konfirmasi/buka kembali) — muat
    // ulang paksa supaya beranda tidak menampilkan status basi.
    if (!mounted) return;
    await LaporanSayaCache.muat(paksa: true);
    if (mounted) setState(() => _data = LaporanSayaCache.aktif);
  }

  void _bukaSemua() {
    if (widget.onBukaSemua != null) {
      widget.onBukaSemua!();
      return;
    }
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const LacakTiketScreen(),
        transitionsBuilder: (_, animasi, _, child) =>
            FadeTransition(opacity: animasi, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!SesiWarga.instance.sudahMasuk) return const SizedBox.shrink();
    final theme = ShadTheme.of(context);
    final data = _data;

    // Belum selesai memuat, atau memang tidak ada tiket berjalan: blok ini
    // hilang sepenuhnya. TIDAK memakai rongga penahan tinggi seperti
    // LanggananSayaSection — di sana kartu hampir selalu ada (akun selalu
    // lahir tertaut satu langganan), di sini ketiadaan justru hal yang
    // normal, jadi rongga kosong akan lebih sering salah daripada benar.
    if (_galat != null || data == null || data.isEmpty) {
      return const SizedBox.shrink();
    }

    final tampil = data.take(_maksTampil).toList();
    final sisa = data.length - tampil.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: SectionHeader(judul: 'Tiket Aktif')),
            GestureDetector(
              onTap: _bukaSemua,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    Text(
                      'Lihat semua',
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
        for (final t in tampil) ...[
          _BarisTiket(tiket: t, onTap: () => _bukaTiket(t.nomorTiket)),
          const SizedBox(height: 8),
        ],
        if (sisa > 0)
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 4),
            child: Text(
              '+$sisa tiket berjalan lainnya',
              style: theme.textTheme.muted.copyWith(fontSize: 11.5),
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }
}

/// Satu baris ringkas tiket: judul + status + jenis/waktu. SLA sengaja
/// tidak ditampilkan di sini — `sisaMenit` dihitung server dan menua
/// selama layar terbuka, jadi angka mundur di beranda cepat jadi bohong.
/// Tenggatnya tetap akurat di LacakTiketScreen yang memuat ulang.
class _BarisTiket extends StatelessWidget {
  const _BarisTiket({required this.tiket, required this.onTap});

  final ComplaintTicketModel tiket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tiket.judul,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.small.copyWith(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(
                        label: labelDari(labelStatusPengaduan, tiket.status),
                        tone: toneStatusPengaduan(tiket.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${tiket.nomorTiket} · '
                    '${labelDari(labelJenisPengaduan, tiket.jenis)}'
                    '${tiket.createdAt == null ? '' : ' · ${formatWaktuLokal(tiket.createdAt!)}'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.muted.copyWith(fontSize: 11.5),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              CupertinoIcons.chevron_right,
              size: 15,
              color: theme.colorScheme.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}
