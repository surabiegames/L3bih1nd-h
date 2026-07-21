import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/models/complaint_ticket_model.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/labels.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/status_badge.dart';
import 'pengaduan_staff_repository.dart';

/// Kelola Pengaduan (petugas) — antrean padat tiket yang ditugaskan ke
/// petugas ini, dengan aksi cepat transisi status.
///
/// Transisi yang sah SELALU dari `transisiTersedia` server (diambil saat
/// menu aksi dibuka) — matriks transisi tidak disalin ke client.
class PengaduanStaffScreen extends StatefulWidget {
  const PengaduanStaffScreen({super.key});

  @override
  State<PengaduanStaffScreen> createState() => _PengaduanStaffScreenState();
}

class _PengaduanStaffScreenState extends State<PengaduanStaffScreen> {
  final _repo = PengaduanStaffRepository.create();

  late Future<List<ComplaintTicketModel>> _tiket;

  @override
  void initState() {
    super.initState();
    _tiket = _repo.tiketSaya();
  }

  void _muatUlang() {
    final baru = _repo.tiketSaya();
    setState(() {
      _tiket = baru;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return AppScaffold(
      title: 'Tugas Pengaduan',
      subtitle: 'Tiket yang ditugaskan ke Anda',
      trailing: ShadIconButton.ghost(
        icon: const Icon(CupertinoIcons.arrow_clockwise),
        onPressed: _muatUlang,
      ),
      body: FutureBuilder<List<ComplaintTicketModel>>(
        future: _tiket,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final galat = snapshot.error;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ShadAlert.destructive(
                    icon: const Icon(CupertinoIcons.exclamationmark_circle),
                    title: const Text('Gagal memuat tiket'),
                    description: Text(
                      galat is ApiException
                          ? galat.message
                          : 'Terjadi kesalahan tak terduga.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  ShadButton.outline(
                    onPressed: _muatUlang,
                    leading: const Icon(CupertinoIcons.arrow_clockwise),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final tiket = snapshot.requireData;
          if (tiket.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.checkmark_circle,
                    size: 40,
                    color: theme.colorScheme.mutedForeground,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tidak ada tiket aktif yang ditugaskan ke Anda.',
                    style: theme.textTheme.muted,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tiket.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _KartuTiket(
              tiket: tiket[i],
              repo: _repo,
              onBerubah: _muatUlang,
            ),
          );
        },
      ),
    );
  }
}

class _KartuTiket extends StatefulWidget {
  const _KartuTiket({
    required this.tiket,
    required this.repo,
    required this.onBerubah,
  });

  final ComplaintTicketModel tiket;
  final PengaduanStaffRepository repo;
  final VoidCallback onBerubah;

  @override
  State<_KartuTiket> createState() => _KartuTiketState();
}

class _KartuTiketState extends State<_KartuTiket> {
  final _popover = ShadPopoverController();
  Future<ComplaintTicketModel>? _detail;
  bool _sibuk = false;

  @override
  void dispose() {
    _popover.dispose();
    super.dispose();
  }

  void _bukaMenu() {
    // transisiTersedia hanya ada di detail — muat saat menu dibuka.
    final detail = widget.repo.detail(widget.tiket.id);
    setState(() {
      _detail = detail;
    });
    _popover.toggle();
  }

  Future<void> _jalankanTransisi(String status) async {
    _popover.hide();

    String? catatanPenyelesaian;
    String? fotoPenyelesaianUrl;
    if (status == 'SELESAI') {
      // Server MEWAJIBKAN catatan + foto bukti untuk SELESAI — dikumpulkan
      // di satu dialog supaya petugas tidak ditolak setelah mengetik.
      final hasil = await showShadDialog<HasilSelesai>(
        context: context,
        builder: (context) => const _DialogSelesai(),
      );
      if (hasil == null || !mounted) return;
      catatanPenyelesaian = hasil.catatan;

      setState(() => _sibuk = true);
      try {
        fotoPenyelesaianUrl = await widget.repo.unggahFotoBukti(
          widget.tiket.nomorTiket,
          hasil.pathFoto,
        );
      } on ApiException catch (e) {
        if (mounted) {
          setState(() => _sibuk = false);
          _tampilkanGalat('Gagal mengunggah foto bukti', e.message);
        }
        return;
      }
      if (!mounted) return;
    }

    setState(() => _sibuk = true);
    try {
      await widget.repo.ubahStatus(
        widget.tiket.id,
        status,
        catatanPenyelesaian: catatanPenyelesaian,
        fotoPenyelesaianUrl: fotoPenyelesaianUrl,
      );
      widget.onBerubah();
    } on ApiException catch (e) {
      if (!mounted) return;
      await showShadDialog<void>(
        context: context,
        builder: (context) => ShadDialog.alert(
          title: Text(e.isConflict ? 'Sudah Berubah' : 'Gagal'),
          description: Text(
            e.isConflict
                ? 'Status tiket sudah berubah di tempat lain. '
                      'Daftar akan dimuat ulang.'
                : e.message,
          ),
          actions: [
            ShadButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Mengerti'),
            ),
          ],
        ),
      );
      if (e.isConflict) widget.onBerubah();
    } finally {
      if (mounted) setState(() => _sibuk = false);
    }
  }

  Future<void> _tambahCatatan() async {
    _popover.hide();
    final kontrol = TextEditingController();
    final catatan = await showShadDialog<String>(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Catatan Tindak Lanjut'),
        description: const Text(
          'Catatan internal (tidak tampil ke warga) tanpa mengubah status.',
        ),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ShadButton(
            onPressed: () {
              final teks = kontrol.text.trim();
              if (teks.length >= 5) Navigator.of(context).pop(teks);
            },
            child: const Text('Simpan Catatan'),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ShadInput(
            controller: kontrol,
            placeholder: const Text('Isi catatan (min. 5 karakter)'),
          ),
        ),
      ),
    );
    if (catatan == null || !mounted) return;

    setState(() => _sibuk = true);
    try {
      await widget.repo.tambahCatatan(widget.tiket.id, catatan);
    } on ApiException catch (e) {
      if (!mounted) return;
      await showShadDialog<void>(
        context: context,
        builder: (context) => ShadDialog.alert(
          title: const Text('Gagal'),
          description: Text(e.message),
          actions: [
            ShadButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Mengerti'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _sibuk = false);
    }
  }

  Future<void> _kirimChat() async {
    _popover.hide();
    final kontrol = TextEditingController();
    final pesan = await showShadDialog<String>(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Chat dengan Pelapor'),
        description: const Text(
          'Pesan ini TAMPIL di halaman pelacakan pelapor sebagai balasan '
          'percakapan.',
        ),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ShadButton(
            onPressed: () {
              final teks = kontrol.text.trim();
              if (teks.isNotEmpty) Navigator.of(context).pop(teks);
            },
            child: const Text('Kirim'),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ShadInput(
            controller: kontrol,
            placeholder: const Text('Tulis pesan untuk pelapor…'),
          ),
        ),
      ),
    );
    if (pesan == null || !mounted) return;

    setState(() => _sibuk = true);
    try {
      await widget.repo.kirimChat(widget.tiket.id, pesan);
    } on ApiException catch (e) {
      if (mounted) _tampilkanGalat('Gagal mengirim pesan', e.message);
    } finally {
      if (mounted) setState(() => _sibuk = false);
    }
  }

  void _tampilkanGalat(String judul, String pesan) {
    showShadDialog<void>(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: Text(judul),
        description: Text(pesan),
        actions: [
          ShadButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  String _teksSla(SlaInfo? sla) {
    if (sla == null) return 'SLA -';
    if (sla.terjeda) return 'SLA terjeda (menunggu pelapor)';
    final menit = sla.sisaMenit;
    if (menit == null) return 'SLA -';
    final absolut = menit.abs();
    final jam = absolut ~/ 60;
    final sisaMenit = absolut % 60;
    final durasi = jam > 0 ? '$jam j $sisaMenit m' : '$sisaMenit m';
    return menit < 0 ? 'Lewat SLA $durasi' : 'Sisa SLA $durasi';
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final t = widget.tiket;
    final slaMerah = t.lewatSla;

    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
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
                            t.nomorTiket,
                            style: theme.textTheme.muted,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(
                          label: labelDari(labelPrioritas, t.prioritas),
                          tone: tonePrioritas(t.prioritas),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(t.judul, style: theme.textTheme.large),
                    const SizedBox(height: 2),
                    Text(
                      '${labelDari(labelJenisPengaduan, t.jenis)}'
                      '${t.alamatKejadian == null ? '' : ' · ${t.alamatKejadian}'}'
                      '${t.nomorLangganan == null ? '' : ' · ${t.nomorLangganan}'}',
                      style: theme.textTheme.muted,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (_sibuk)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                ShadPopover(
                  controller: _popover,
                  popover: (context) => _MenuAksi(
                    detail: _detail,
                    onTransisi: _jalankanTransisi,
                    onCatatan: _tambahCatatan,
                    onChat: _kirimChat,
                  ),
                  child: ShadIconButton.ghost(
                    icon: const Icon(CupertinoIcons.ellipsis_vertical),
                    onPressed: _bukaMenu,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              StatusBadge(
                label: labelDari(labelStatusPengaduan, t.status),
                tone: toneStatusPengaduan(t.status),
              ),
              const SizedBox(width: 8),
              Icon(
                CupertinoIcons.clock,
                size: 13,
                color: slaMerah
                    ? theme.colorScheme.destructive
                    : theme.colorScheme.mutedForeground,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${_teksSla(t.sla)}'
                  '${t.createdAt == null ? '' : ' · masuk ${formatWaktuLokal(t.createdAt!)}'}',
                  style: theme.textTheme.muted.copyWith(
                    color: slaMerah ? theme.colorScheme.destructive : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Isi popover aksi: transisi status dari server + catatan internal.
class _MenuAksi extends StatelessWidget {
  const _MenuAksi({
    required this.detail,
    required this.onTransisi,
    required this.onCatatan,
    required this.onChat,
  });

  final Future<ComplaintTicketModel>? detail;
  final void Function(String status) onTransisi;
  final VoidCallback onCatatan;
  final VoidCallback onChat;

  static const _ikonTransisi = <String, IconData>{
    'TERVERIFIKASI': CupertinoIcons.checkmark_seal,
    'MENUJU_LOKASI': CupertinoIcons.location_fill,
    'DIPROSES': CupertinoIcons.wrench_fill,
    'SELESAI': CupertinoIcons.checkmark,
    'MENUNGGU_PELANGGAN': CupertinoIcons.clock,
    'DITOLAK': CupertinoIcons.nosign,
  };

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return SizedBox(
      width: 240,
      child: FutureBuilder<ComplaintTicketModel>(
        future: detail,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          final transisi = snapshot.hasError
              ? const <String>[]
              : snapshot.requireData.transisiTersedia;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (snapshot.hasError)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    snapshot.error is ApiException
                        ? (snapshot.error as ApiException).message
                        : 'Gagal memuat aksi.',
                    style: theme.textTheme.muted,
                  ),
                )
              else if (transisi.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Tidak ada transisi tersedia — tiket menunggu pihak lain '
                    '(pelapor/atasan).',
                    style: theme.textTheme.muted,
                  ),
                )
              else
                for (final status in transisi)
                  ShadButton.ghost(
                    mainAxisAlignment: MainAxisAlignment.start,
                    leading: Icon(
                      _ikonTransisi[status] ?? CupertinoIcons.arrow_right,
                      size: 16,
                    ),
                    onPressed: () => onTransisi(status),
                    child: Text(labelDari(labelStatusPengaduan, status)),
                  ),
              Container(
                height: 1,
                color: theme.colorScheme.border,
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
              ShadButton.ghost(
                mainAxisAlignment: MainAxisAlignment.start,
                leading: const Icon(
                  CupertinoIcons.chat_bubble_2_fill,
                  size: 16,
                ),
                onPressed: onChat,
                child: const Text('Chat dengan Pelapor'),
              ),
              ShadButton.ghost(
                mainAxisAlignment: MainAxisAlignment.start,
                leading: const Icon(
                  CupertinoIcons.chat_bubble_text_fill,
                  size: 16,
                ),
                onPressed: onCatatan,
                child: const Text('Catatan Internal'),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Hasil dialog "Tandai Selesai": ringkasan pekerjaan + path foto bukti.
class HasilSelesai {
  const HasilSelesai({required this.catatan, required this.pathFoto});

  final String catatan;
  final String pathFoto;
}

/// Dialog SELESAI — catatan penyelesaian DAN foto bukti sama-sama wajib
/// (aturan server; dikumpulkan sekaligus di sini supaya tidak ditolak
/// setelah mengetik). Foto dari kamera atau galeri via image_picker, pola
/// sama dengan foto bukti catat meter.
class _DialogSelesai extends StatefulWidget {
  const _DialogSelesai();

  @override
  State<_DialogSelesai> createState() => _DialogSelesaiState();
}

class _DialogSelesaiState extends State<_DialogSelesai> {
  final _kontrol = TextEditingController();
  String? _pathFoto;

  @override
  void dispose() {
    _kontrol.dispose();
    super.dispose();
  }

  Future<void> _pilihFoto(ImageSource sumber) async {
    final foto = await ImagePicker().pickImage(
      source: sumber,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (foto != null && mounted) setState(() => _pathFoto = foto.path);
  }

  bool get _lengkap => _kontrol.text.trim().length >= 5 && _pathFoto != null;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ShadDialog(
      title: const Text('Tandai Selesai'),
      description: const Text(
        'Ringkasan pekerjaan + foto bukti WAJIB — pelapor melihat keduanya '
        'di halaman pelacakan sebelum mengonfirmasi.',
      ),
      actions: [
        ShadButton.outline(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ShadButton(
          onPressed: _lengkap
              ? () => Navigator.of(context).pop(
                  HasilSelesai(
                    catatan: _kontrol.text.trim(),
                    pathFoto: _pathFoto!,
                  ),
                )
              : null,
          child: const Text('Tandai Selesai'),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ShadInput(
              controller: _kontrol,
              onChanged: (_) => setState(() {}),
              placeholder: const Text('Apa yang dikerjakan? (min. 5 karakter)'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ShadButton.outline(
                    size: ShadButtonSize.sm,
                    leading: const Icon(CupertinoIcons.camera, size: 15),
                    onPressed: () => _pilihFoto(ImageSource.camera),
                    child: const Text('Kamera'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ShadButton.outline(
                    size: ShadButtonSize.sm,
                    leading: const Icon(CupertinoIcons.photo, size: 15),
                    onPressed: () => _pilihFoto(ImageSource.gallery),
                    child: const Text('Galeri'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _pathFoto == null
                  ? 'Belum ada foto bukti.'
                  : 'Foto siap: ${_pathFoto!.split('/').last}',
              style: theme.textTheme.muted.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
