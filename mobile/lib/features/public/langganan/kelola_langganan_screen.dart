import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, LengthLimitingTextInputFormatter;
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/master_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/labels.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_badge.dart';
import 'langganan_warga_repository.dart';
import 'widgets/pratinjau_pelanggan.dart';

/// Kelola nomor langganan tertaut akun warga: lihat semua, tambah (maks. 5,
/// dibatasi server), jadikan utama, lepas tautan. Setiap mutasi menyegarkan
/// LanggananSayaCache supaya beranda ikut terbarui saat kembali.
class KelolaLanggananScreen extends StatefulWidget {
  const KelolaLanggananScreen({super.key});

  @override
  State<KelolaLanggananScreen> createState() => _KelolaLanggananScreenState();
}

class _KelolaLanggananScreenState extends State<KelolaLanggananScreen> {
  final _repo = LanggananWargaRepository.create();
  final _nomorController = TextEditingController();

  List<LanggananWargaModel>? _data;
  String? _galatMuat;
  String? _galatTambah;
  bool _menambah = false;
  String _nomorBaru = '';

  /// id baris yang sedang diproses (jadikan utama / hapus) — tombolnya
  /// dinonaktifkan supaya tidak dobel-tap.
  String? _idSibuk;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  @override
  void dispose() {
    _nomorController.dispose();
    super.dispose();
  }

  Future<void> _muat({bool paksa = false}) async {
    setState(() => _galatMuat = null);
    try {
      final data = await LanggananSayaCache.muat(paksa: paksa);
      if (mounted) setState(() => _data = data);
    } on ApiException catch (e) {
      if (mounted) setState(() => _galatMuat = e.message);
    }
  }

  Future<void> _tambah() async {
    if (!RegExp(r'^\d{11}$').hasMatch(_nomorBaru)) {
      setState(() => _galatTambah = 'Nomor langganan harus 11 digit angka.');
      return;
    }
    setState(() {
      _menambah = true;
      _galatTambah = null;
    });
    try {
      await _repo.tambah(_nomorBaru);
      _nomorController.clear();
      _nomorBaru = '';
      await _muat(paksa: true);
    } on ApiException catch (e) {
      if (mounted) setState(() => _galatTambah = e.message);
    } finally {
      if (mounted) setState(() => _menambah = false);
    }
  }

  Future<void> _jadikanUtama(LanggananWargaModel l) async {
    setState(() => _idSibuk = l.id);
    try {
      await _repo.jadikanUtama(l.id);
      await _muat(paksa: true);
    } on ApiException catch (e) {
      if (mounted) _tampilkanGalat(e.message);
    } finally {
      if (mounted) setState(() => _idSibuk = null);
    }
  }

  Future<void> _hapus(LanggananWargaModel l) async {
    final lanjut = await showShadDialog<bool>(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Lepas Tautan Langganan?'),
        description: Text(
          'Nomor ${l.nomorLangganan} (${l.nama}) akan dilepas dari akun Anda. '
          'Data pelanggannya sendiri tidak berubah — Anda bisa menautkannya '
          'kembali kapan saja.',
        ),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ShadButton.destructive(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Lepas Tautan'),
          ),
        ],
      ),
    );
    if (lanjut != true || !mounted) return;

    setState(() => _idSibuk = l.id);
    try {
      await _repo.hapus(l.id);
      await _muat(paksa: true);
    } on ApiException catch (e) {
      if (mounted) _tampilkanGalat(e.message);
    } finally {
      if (mounted) setState(() => _idSibuk = null);
    }
  }

  void _tampilkanGalat(String pesan) {
    showShadDialog<void>(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: const Text('Gagal'),
        description: Text(pesan),
        actions: [
          ShadButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final data = _data;

    return AppScaffold(
      title: 'Nomor Langganan',
      subtitle: 'Kelola langganan tertaut akun Anda',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_galatMuat != null)
            ShadAlert.destructive(
              icon: const Icon(CupertinoIcons.exclamationmark_circle),
              title: const Text('Gagal memuat'),
              description: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_galatMuat!),
                  const SizedBox(height: 8),
                  ShadButton.outline(
                    size: ShadButtonSize.sm,
                    onPressed: _muat,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            )
          else if (data == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            )
          else ...[
            for (final l in data) ...[
              _BarisLangganan(
                langganan: l,
                sibuk: _idSibuk == l.id,
                // Baris terakhir tidak bisa dilepas (aturan server: akun
                // warga selalu tertaut minimal satu langganan).
                bisaHapus: data.length > 1,
                onJadikanUtama: l.isUtama ? null : () => _jadikanUtama(l),
                onHapus: () => _hapus(l),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 12),
            const SectionHeader(judul: 'Tambah Nomor Langganan'),
            const SizedBox(height: 4),
            Text(
              'Berlangganan lebih dari satu sambungan? Tautkan nomornya di '
              'sini supaya semuanya tampil di beranda.',
              style: theme.textTheme.muted,
            ),
            const SizedBox(height: 12),
            ShadInput(
              controller: _nomorController,
              placeholder: const Text('11 digit nomor langganan'),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              onChanged: (v) => setState(() {
                _nomorBaru = v.trim();
                _galatTambah = null;
              }),
            ),
            PratinjauPelanggan(nomor: _nomorBaru),
            if (_galatTambah != null) ...[
              const SizedBox(height: 8),
              Text(
                _galatTambah!,
                style: theme.textTheme.muted.copyWith(
                  color: theme.colorScheme.destructive,
                ),
              ),
            ],
            const SizedBox(height: 12),
            ShadButton(
              onPressed: _menambah || _nomorBaru.length != 11 ? null : _tambah,
              leading: _menambah
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(CupertinoIcons.add),
              child: Text(_menambah ? 'Menautkan…' : 'Tautkan Nomor Ini'),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _BarisLangganan extends StatelessWidget {
  const _BarisLangganan({
    required this.langganan,
    required this.sibuk,
    required this.bisaHapus,
    required this.onJadikanUtama,
    required this.onHapus,
  });

  final LanggananWargaModel langganan;
  final bool sibuk;
  final bool bisaHapus;

  /// Null = sudah utama (tombol disembunyikan).
  final VoidCallback? onJadikanUtama;
  final VoidCallback onHapus;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final adaTunggakan = langganan.totalTunggakan > 0;

    return ShadCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            langganan.nama,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.small.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (langganan.isUtama) ...[
                          const SizedBox(width: 6),
                          const ShadBadge(child: Text('Utama')),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      langganan.nomorLangganan,
                      style: theme.textTheme.muted.copyWith(
                        fontSize: 12.5,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      langganan.alamatLengkap,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.muted.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label:
                    labelStatusPelanggan[langganan.status] ?? langganan.status,
                tone: langganan.status == 'AKTIF'
                    ? StatusTone.success
                    : StatusTone.warning,
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Wrap (bukan Row kaku): di lebar sempit tombol turun ke baris
          // berikutnya alih-alih meluap ke kanan (RenderFlex overflow yang
          // terukur saat uji di Linux desktop).
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                adaTunggakan
                    ? 'Tunggakan ${formatRupiah(langganan.totalTunggakan)} '
                          '(${langganan.jumlahTagihanBelumBayar} tagihan)'
                    : 'Tidak ada tunggakan',
                style: theme.textTheme.muted.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: adaTunggakan
                      ? const Color(MasterPalette.rose600)
                      : const Color(MasterPalette.emerald600),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onJadikanUtama != null)
                    ShadButton.ghost(
                      size: ShadButtonSize.sm,
                      onPressed: sibuk ? null : onJadikanUtama,
                      child: const Text('Jadikan Utama'),
                    ),
                  ShadButton.ghost(
                    size: ShadButtonSize.sm,
                    onPressed: sibuk || !bisaHapus ? null : onHapus,
                    foregroundColor: theme.colorScheme.destructive,
                    child: sibuk
                        ? const SizedBox.square(
                            dimension: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(CupertinoIcons.trash, size: 16),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
