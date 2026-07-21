import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart' show CircularProgressIndicator, RefreshIndicator;
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/services/notifikasi_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_scaffold.dart';

/// Inbox notifikasi petugas (`GET /api/v1/notifikasi`). Berfungsi penuh
/// tanpa Firebase: notifikasi yang ditulis server saat penugasan rute/tiket
/// tampil di sini. Ketuk baris = tandai dibaca; tombol atas = tandai semua.
class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  final _svc = NotifikasiService.instance;
  DaftarNotifikasi _daftar = DaftarNotifikasi.kosong;
  bool _memuat = true;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    final hasil = await _svc.daftar();
    if (!mounted) return;
    setState(() {
      _daftar = hasil;
      _memuat = false;
    });
  }

  Future<void> _bacaSemua() async {
    await _svc.tandaiSemua();
    await _muat();
  }

  Future<void> _buka(NotifikasiItem n) async {
    if (!n.dibaca) {
      await _svc.tandaiBaca(n.id);
      await _muat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final items = _daftar.items;

    return AppScaffold(
      title: 'Notifikasi',
      subtitle: _daftar.belumDibaca > 0
          ? '${_daftar.belumDibaca} belum dibaca'
          : 'Semua sudah dibaca',
      trailing: _daftar.belumDibaca == 0
          ? null
          : ShadButton.ghost(
              size: ShadButtonSize.sm,
              onPressed: _bacaSemua,
              child: const Text('Tandai semua'),
            ),
      body: _memuat
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _muat,
              child: items.isEmpty
                  ? ListView(
                      children: [
                        const SizedBox(height: 80),
                        Icon(
                          CupertinoIcons.bell_slash,
                          size: 40,
                          color: theme.colorScheme.mutedForeground,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada notifikasi.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.muted,
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, i) =>
                          _KartuNotifikasi(item: items[i], onTap: _buka),
                    ),
            ),
    );
  }
}

class _KartuNotifikasi extends StatelessWidget {
  const _KartuNotifikasi({required this.item, required this.onTap});

  final NotifikasiItem item;
  final Future<void> Function(NotifikasiItem) onTap;

  IconData get _ikon => switch (item.tipe) {
    'pengaduan' => CupertinoIcons.exclamationmark_bubble_fill,
    'rute' => CupertinoIcons.map_fill,
    _ => CupertinoIcons.bell_fill,
  };

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return GestureDetector(
      onTap: () => onTap(item),
      child: ShadCard(
        leading: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Icon(
            _ikon,
            size: 22,
            color: item.dibaca
                ? theme.colorScheme.mutedForeground
                : theme.colorScheme.primary,
          ),
        ),
        title: Text(item.judul),
        description: Text(item.isi),
        trailing: item.dibaca
            ? null
            : Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
        child: item.dibuatPada == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  formatWaktuLokal(item.dibuatPada!),
                  style: theme.textTheme.muted.copyWith(fontSize: 11),
                ),
              ),
      ),
    );
  }
}
