import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/labels.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_panel.dart';
import 'rute_repository.dart';

/// Antrean Upload — padanan `UploadMenuActivity`/`UploadDataActionActivity`
/// Aurora: seluruh hasil catat yang belum sampai server terlihat di sini
/// berikut pesan gagal per baris dari respons batch, dan bisa dikirim
/// ulang manual. Foto/video tiap baris ikut terunggah ulang otomatis saat
/// kirim (menggantikan menu ReUploadPhoto/ReUploadVideo Aurora — nama
/// berkas deterministik di server: unggah ulang menimpa, tidak menggandakan).
class AntreanUploadScreen extends StatefulWidget {
  const AntreanUploadScreen({super.key});

  @override
  State<AntreanUploadScreen> createState() => _AntreanUploadScreenState();
}

class _AntreanUploadScreenState extends State<AntreanUploadScreen> {
  final _repo = RuteRepository.create();

  List<CatatTertunda>? _antrean;
  String? _galat;
  String? _info;
  bool _mengirim = false;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    try {
      final antrean = await _repo.daftarTertunda();
      if (!mounted) return;
      setState(() {
        _antrean = antrean;
        _galat = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _galat = e.message);
    }
  }

  Future<void> _kirimSemua() async {
    setState(() {
      _mengirim = true;
      _galat = null;
      _info = null;
    });
    try {
      final sebelum = _antrean?.length ?? 0;
      final terkirim = await _repo.kirimTertunda();
      await _muat();
      if (!mounted) return;
      setState(() {
        _mengirim = false;
        _info = terkirim == 0 && sebelum > 0
            ? 'Tidak ada yang terkirim — periksa sinyal, lalu coba lagi. '
                  'Baris bermasalah menampilkan pesan servernya di bawah.'
            : 'Terkirim $terkirim dari $sebelum laporan.';
      });
    } on ApiException catch (e) {
      await _muat();
      if (!mounted) return;
      setState(() {
        _mengirim = false;
        _galat = e.message;
      });
    }
  }

  Future<void> _hapus(CatatTertunda entri) async {
    final lanjut = await showShadDialog<bool>(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Hapus dari Antrean?'),
        description: Text(
          'Laporan ${entri.nomorLangganan} (${labelPeriode(entri.periode)}) '
          'BELUM sampai server — menghapusnya berarti hasil catat ini '
          'hilang dan pelanggan kembali berstatus belum dibaca.',
        ),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ShadButton.destructive(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (lanjut != true || !mounted) return;
    final id = entri.idAntrean;
    if (id != null) await _repo.hapusTertunda(id);
    await _muat();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final antrean = _antrean;

    return AppScaffold(
      title: 'Upload Data',
      subtitle: 'Kirim hasil catat yang belum sampai server',
      trailing: ShadIconButton.ghost(
        icon: const Icon(CupertinoIcons.arrow_clockwise),
        onPressed: _mengirim ? null : _muat,
      ),
      body: antrean == null
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
                            antrean.isEmpty
                                ? CupertinoIcons.checkmark_circle_fill
                                : CupertinoIcons.cloud_upload_fill,
                            size: 18,
                            color: antrean.isEmpty
                                ? const Color(AppEmerald.c600)
                                : theme.colorScheme.foreground,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              antrean.isEmpty
                                  ? 'Semua hasil catat sudah terunggah.'
                                  : '${antrean.length} laporan menunggu '
                                        'dikirim.',
                              style: theme.textTheme.small,
                            ),
                          ),
                        ],
                      ),
                      if (antrean.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        ShadButton(
                          onPressed: _mengirim ? null : _kirimSemua,
                          backgroundColor: const Color(AppEmerald.c600),
                          hoverBackgroundColor: const Color(AppEmerald.c500),
                          leading: _mengirim
                              ? const SizedBox.square(
                                  dimension: 15,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  CupertinoIcons.cloud_upload,
                                  size: 16,
                                ),
                          child: Text(
                            _mengirim ? 'Mengirim…' : 'Kirim Semua Sekarang',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Foto & video tiap laporan ikut terunggah ulang '
                          'otomatis. Antrean juga dikirim sendiri setiap '
                          'kali layar Baca Meter dibuka saat online.',
                          style: theme.textTheme.muted.copyWith(fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_info != null) ...[
                  const SizedBox(height: 10),
                  ShadAlert(
                    icon: const Icon(CupertinoIcons.info_circle),
                    title: const Text('Hasil kirim'),
                    description: Text(_info!),
                  ),
                ],
                if (_galat != null) ...[
                  const SizedBox(height: 10),
                  ShadAlert.destructive(
                    icon: const Icon(CupertinoIcons.exclamationmark_circle),
                    title: const Text('Gagal'),
                    description: Text(_galat!),
                  ),
                ],
                const SizedBox(height: 12),
                for (final entri in antrean) ...[
                  _BarisAntrean(
                    entri: entri,
                    onHapus: _mengirim ? null : () => _hapus(entri),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
    );
  }
}

class _BarisAntrean extends StatelessWidget {
  const _BarisAntrean({required this.entri, this.onHapus});

  final CatatTertunda entri;
  final VoidCallback? onHapus;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final standAkhir = (entri.payload['standAkhir'] as num?)?.toInt();
    final kondisi = entri.payload['kondisi'] as String?;
    final bermasalah = entri.pesanGagal != null;
    return GlassPanel(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(entri.nomorLangganan, style: theme.textTheme.small),
              ),
              Text(
                labelPeriode(entri.periode),
                style: theme.textTheme.muted.copyWith(fontSize: 11.5),
              ),
              const SizedBox(width: 6),
              ShadIconButton.ghost(
                icon: Icon(
                  CupertinoIcons.trash,
                  size: 15,
                  color: theme.colorScheme.destructive,
                ),
                onPressed: onHapus,
              ),
            ],
          ),
          Text(
            [
              if (standAkhir != null) 'Stand $standAkhir',
              if (kondisi != null) labelDari(labelKondisiMeter, kondisi),
              if (entri.fotoPaths.isNotEmpty)
                '${entri.fotoPaths.length} berkas',
              'dicatat ${formatWaktuLokal(entri.dibuatPada)}',
            ].join(' · '),
            style: theme.textTheme.muted.copyWith(fontSize: 11.5),
          ),
          if (bermasalah) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.exclamationmark_triangle_fill,
                  size: 12,
                  color: theme.colorScheme.destructive,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Ditolak server (percobaan ke-${entri.percobaan}): '
                    '${entri.pesanGagal}',
                    style: theme.textTheme.muted.copyWith(
                      fontSize: 11,
                      color: theme.colorScheme.destructive,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
