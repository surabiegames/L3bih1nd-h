import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart'
    show CircularProgressIndicator, SelectableText;
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/services/backup_lokal.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_panel.dart';
import 'rute_repository.dart';

/// Cadangan Data — pengaman hasil baca meter (tiruan folder backup Aurora).
/// Setiap catat menulis bundel lengkap (catatan.json + foto stand/segel/rumah)
/// ke internal storage. Layar ini:
///  - menampilkan bundel per periode + status terunggah,
///  - "Pulihkan ke Antrean" bila DB lokal korup/aplikasi crash (kembalikan
///    hasil catat yang belum aman ke antrean upload),
///  - "Ekspor & Bagikan ZIP" untuk dikirim ke admin → diimpor di dashboard web.
class CadanganScreen extends StatefulWidget {
  const CadanganScreen({super.key});

  @override
  State<CadanganScreen> createState() => _CadanganScreenState();
}

class _CadanganScreenState extends State<CadanganScreen> {
  final _repo = RuteRepository.create();

  List<BundelPembacaan>? _bundel;
  String? _lokasi;
  bool _sibuk = false;
  String? _info;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    final bundel = await BackupLokal.instance.daftarBundel();
    final lokasi = await BackupLokal.instance.lokasiFolder();
    if (!mounted) return;
    setState(() {
      _bundel = bundel;
      _lokasi = lokasi;
    });
  }

  Future<void> _pulihkan() async {
    setState(() {
      _sibuk = true;
      _info = null;
    });
    final n = await _repo.pulihkanDariCadangan();
    await _muat();
    if (!mounted) return;
    setState(() {
      _sibuk = false;
      _info = n == 0
          ? 'Tidak ada yang perlu dipulihkan — semua sudah di antrean atau '
                'sudah terunggah.'
          : '$n pembacaan dikembalikan ke antrean upload. Buka menu Upload '
                'untuk mengirimnya.';
    });
  }

  Future<void> _ekspor() async {
    setState(() {
      _sibuk = true;
      _info = null;
    });
    try {
      final path = await BackupLokal.instance.eksporZip();
      if (!mounted) return;
      if (path == null) {
        setState(() {
          _sibuk = false;
          _info = 'Belum ada data cadangan untuk diekspor.';
        });
        return;
      }
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(path)],
          text: 'Cadangan hasil baca meter (impor di dashboard web).',
        ),
      );
      if (mounted) setState(() => _sibuk = false);
    } on Object {
      if (mounted) {
        setState(() {
          _sibuk = false;
          _info = 'Gagal membuat/mem­bagikan ZIP cadangan.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final bundel = _bundel;
    final menunggu = bundel?.where((b) => !b.terunggah).length ?? 0;

    // Kelompokkan per periode.
    final perPeriode = <int, List<BundelPembacaan>>{};
    for (final b in bundel ?? const <BundelPembacaan>[]) {
      (perPeriode[b.periode] ??= []).add(b);
    }
    final periodes = perPeriode.keys.toList()..sort((a, b) => b.compareTo(a));

    return AppScaffold(
      title: 'Cadangan Data',
      subtitle: 'Pengaman hasil catat di perangkat',
      trailing: ShadIconButton.ghost(
        icon: const Icon(CupertinoIcons.arrow_clockwise),
        onPressed: _sibuk ? null : _muat,
      ),
      body: bundel == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GlassPanel(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.shield_lefthalf_fill,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              bundel.isEmpty
                                  ? 'Belum ada data cadangan.'
                                  : '${bundel.length} pembacaan tercadangkan · '
                                        '$menunggu belum terunggah.',
                              style: theme.textTheme.small,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tiap hasil catat otomatis disimpan (catatan + foto '
                        'stand/segel/rumah) ke penyimpanan perangkat. Aman '
                        'bila aplikasi tertutup tiba-tiba; berkasnya bisa '
                        'diambil lewat file manager/USB, dipulihkan, atau '
                        'diekspor untuk diimpor di web.',
                        style: theme.textTheme.muted.copyWith(fontSize: 11.5),
                      ),
                      if (_lokasi != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Lokasi berkas:',
                          style: theme.textTheme.muted.copyWith(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SelectableText(
                          '${_lokasi!}/pembacaan',
                          style: theme.textTheme.muted.copyWith(
                            fontSize: 10.5,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ShadButton.outline(
                              onPressed: _sibuk ? null : _pulihkan,
                              leading: const Icon(
                                CupertinoIcons.arrow_2_circlepath,
                                size: 16,
                              ),
                              child: const Text('Pulihkan'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ShadButton(
                              onPressed: _sibuk || bundel.isEmpty ? null : _ekspor,
                              backgroundColor: const Color(AppEmerald.c600),
                              hoverBackgroundColor: const Color(AppEmerald.c500),
                              leading: _sibuk
                                  ? const SizedBox.square(
                                      dimension: 15,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      CupertinoIcons.share,
                                      size: 16,
                                    ),
                              child: const Text('Ekspor ZIP'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_info != null) ...[
                  const SizedBox(height: 10),
                  ShadAlert(
                    icon: const Icon(CupertinoIcons.info_circle),
                    description: Text(_info!),
                  ),
                ],
                const SizedBox(height: 12),
                for (final periode in periodes) ...[
                  Text(
                    labelPeriode(periode),
                    style: theme.textTheme.small.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final b in perPeriode[periode]!) ...[
                    _BarisBundel(bundel: b),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 6),
                ],
              ],
            ),
    );
  }
}

class _BarisBundel extends StatelessWidget {
  const _BarisBundel({required this.bundel});

  final BundelPembacaan bundel;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final nJumlahFoto = bundel.fotoPaths.length;
    final nama = bundel.data['namaPetugas'] as String?;
    final stand = bundel.data['standAkhir'];
    return GlassPanel(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(
            bundel.terunggah
                ? CupertinoIcons.checkmark_seal_fill
                : CupertinoIcons.clock_fill,
            size: 18,
            color: bundel.terunggah
                ? const Color(AppEmerald.c600)
                : theme.colorScheme.mutedForeground,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bundel.nomorLangganan, style: theme.textTheme.small),
                const SizedBox(height: 1),
                Text(
                  [
                    if (stand != null) 'Stand $stand',
                    '$nJumlahFoto foto',
                    ?nama,
                  ].join(' · '),
                  style: theme.textTheme.muted.copyWith(fontSize: 11.5),
                ),
              ],
            ),
          ),
          Text(
            bundel.terunggah ? 'Terunggah' : 'Menunggu',
            style: theme.textTheme.muted.copyWith(
              fontSize: 11,
              color: bundel.terunggah
                  ? const Color(AppEmerald.c600)
                  : theme.colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
