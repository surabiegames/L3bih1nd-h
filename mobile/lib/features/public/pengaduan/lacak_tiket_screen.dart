import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/models/complaint_ticket_model.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/master_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/labels.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/status_badge.dart';
import 'lapor_pengaduan_repository.dart';

enum _ModeAksiPelapor { pilih, nilai, buka }

/// Lacak Tiket — publik. Nomor tiket TW-YYMM-XXXXXX menjadi kunci akses;
/// menampilkan status terkini + linimasa publik penanganan.
///
/// `nomorAwal` (opsional): dipakai LaporanSayaScreen (akun warga) untuk
/// taut-langsung ke satu tiket — isi otomatis lalu langsung cari, supaya
/// baris di "Laporan Saya" benar-benar sekali tap ke detailnya, memakai
/// ULANG layar ini alih-alih menduplikasi tampilan detail tiket.
class LacakTiketScreen extends StatefulWidget {
  const LacakTiketScreen({super.key, this.nomorAwal});

  final String? nomorAwal;

  @override
  State<LacakTiketScreen> createState() => _LacakTiketScreenState();
}

class _LacakTiketScreenState extends State<LacakTiketScreen> {
  final _formKey = GlobalKey<ShadFormState>();
  final _repo = LaporPengaduanRepository.create();

  bool _memuat = false;
  String? _galat;
  LacakTiketResult? _hasil;

  @override
  void initState() {
    super.initState();
    final awal = widget.nomorAwal?.trim();
    if (awal != null && awal.isNotEmpty) {
      // Form belum ter-mount di frame ini — jadwalkan sesudah frame
      // pertama supaya _formKey.currentState sudah terpasang.
      WidgetsBinding.instance.addPostFrameCallback((_) => _lacak(awal));
    }
  }

  Future<void> _lacak([String? nomorLangsung]) async {
    String? nomor = nomorLangsung;
    if (nomor == null) {
      // WAJIB validate/save DULU, baru baca form.value — ShadForm hanya
      // menyinkronkan .value saat save() dipanggil, jadi membacanya lebih
      // dulu (urutan yang sempat salah di sini) selalu mengembalikan nilai
      // basi dan diam-diam menggagalkan pencarian manual.
      final form = _formKey.currentState!;
      if (!form.saveAndValidate()) return;
      nomor = form.value['nomorTiket'] as String?;
    }
    if (nomor == null || nomor.trim().isEmpty) return;

    setState(() {
      _memuat = true;
      _galat = null;
      _hasil = null;
    });
    try {
      final hasil = await _repo.lacak(nomor);
      if (!mounted) return;
      setState(() => _hasil = hasil);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _galat = e.message);
    } finally {
      if (mounted) setState(() => _memuat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final hasil = _hasil;

    return AppScaffold(
      title: 'Lacak Tiket',
      subtitle: 'Pantau status pengaduan Anda',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ShadCard(
            title: const Text('Nomor Tiket'),
            description: const Text(
              'Masukkan nomor tiket dari tanda terima pengaduan Anda, '
              'format TW-YYMM-XXXXXX.',
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ShadForm(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ShadInputFormField(
                      id: 'nomorTiket',
                      initialValue: widget.nomorAwal,
                      placeholder: const Text('TW-2607-XXXXXX'),
                      validator: (v) =>
                          RegExp(
                            r'^TW-\d{4}-[A-Za-z0-9]{6}$',
                          ).hasMatch(v.trim().toUpperCase())
                          ? null
                          : 'Format nomor tiket: TW-YYMM-XXXXXX.',
                    ),
                    const SizedBox(height: 12),
                    ShadButton(
                      onPressed: _memuat ? null : _lacak,
                      leading: _memuat
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(CupertinoIcons.search),
                      child: Text(_memuat ? 'Mencari…' : 'Lacak'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_galat != null) ...[
            const SizedBox(height: 16),
            ShadAlert.destructive(
              icon: const Icon(CupertinoIcons.exclamationmark_circle),
              title: const Text('Tidak ditemukan'),
              description: Text(_galat!),
            ),
          ],
          if (hasil != null) ...[
            const SizedBox(height: 16),
            ShadCard(
              title: Text(hasil.judul),
              description: Text(
                '${hasil.nomorTiket} · '
                '${labelDari(labelJenisPengaduan, hasil.jenis)}',
              ),
              trailing: StatusBadge(
                label: labelDari(labelStatusPengaduan, hasil.status),
                tone: toneStatusPengaduan(hasil.status),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasil.ditugaskanKe != null)
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.person_crop_circle_fill,
                            size: 14,
                            color: theme.colorScheme.mutedForeground,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Ditangani: ${hasil.ditugaskanKe}',
                              style: theme.textTheme.muted,
                            ),
                          ),
                        ],
                      ),
                    if (hasil.sla?.targetSelesaiAt != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.clock,
                            size: 14,
                            color: (hasil.sla?.melanggar ?? false)
                                ? theme.colorScheme.destructive
                                : theme.colorScheme.mutedForeground,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Target selesai: '
                              '${formatWaktuLokal(hasil.sla!.targetSelesaiAt!)}',
                              style: theme.textTheme.muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (hasil.catatanPenyelesaian != null) ...[
                      const SizedBox(height: 8),
                      Text('Penyelesaian: ${hasil.catatanPenyelesaian}'),
                    ],
                    if (hasil.fotoPenyelesaianUrl != null &&
                        hasil.fotoPenyelesaianUrl!.startsWith('http')) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          hasil.fotoPenyelesaianUrl!,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          // Gagal muat = baris teks, bukan kotak rusak.
                          errorBuilder: (_, _, _) => Text(
                            'Foto bukti penyelesaian tersedia.',
                            style: theme.textTheme.muted,
                          ),
                        ),
                      ),
                    ],
                    if (hasil.status == 'SELESAI' &&
                        hasil.konfirmasiBatasAt != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            CupertinoIcons.timer,
                            size: 14,
                            color: Color(MasterPalette.rose600),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Konfirmasi sebelum '
                              '${formatWaktuLokal(hasil.konfirmasiBatasAt!)} — '
                              'lewat itu tiket ditutup otomatis.',
                              style: theme.textTheme.muted.copyWith(
                                color: const Color(MasterPalette.rose600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (hasil.bisaDinilai || hasil.bisaDibukaKembali) ...[
              const SizedBox(height: 16),
              _AksiPelapor(
                repo: _repo,
                nomorTiket: hasil.nomorTiket,
                bisaDinilai: hasil.bisaDinilai,
                bisaDibukaKembali: hasil.bisaDibukaKembali,
                onSelesai: _lacak,
              ),
            ],
            // Chat dipisah dari linimasa: entri aksi CHAT dirender sebagai
            // percakapan dua arah, sisanya tetap linimasa status.
            if (hasil.bisaChat ||
                hasil.riwayat.any((e) => e.aksi == 'CHAT')) ...[
              const SizedBox(height: 16),
              _ChatTiket(
                repo: _repo,
                nomorTiket: hasil.nomorTiket,
                entri: [
                  for (final e in hasil.riwayat)
                    if (e.aksi == 'CHAT') e,
                ],
                bisaChat: hasil.bisaChat,
                onTerkirim: _lacak,
              ),
            ],
            const SizedBox(height: 16),
            Text('Linimasa Penanganan', style: theme.textTheme.large),
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                final linimasa = [
                  for (final e in hasil.riwayat)
                    if (e.aksi != 'CHAT') e,
                ];
                if (linimasa.isEmpty) {
                  return Text(
                    'Belum ada pembaruan.',
                    style: theme.textTheme.muted,
                  );
                }
                return ShadCard(
                  child: Column(
                    children: [
                      for (var i = 0; i < linimasa.length; i++)
                        _BarisLinimasa(
                          entri: linimasa[i],
                          terakhir: i == linimasa.length - 1,
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Dua keputusan yang HANYA boleh diambil pelapor setelah petugas menandai
/// tiket SELESAI: mengonfirmasi (+ menilai) atau menyatakan masalahnya belum
/// beres. Padanan Flutter dari `aksi-pelapor.tsx` di web — backend
/// menegakkan hak ini (PATCH status ke DITUTUP dari sisi petugas ditolak
/// eksplisit), jadi UI mobile wajib punya jalur yang sama, bukan cuma web.
class _AksiPelapor extends StatefulWidget {
  const _AksiPelapor({
    required this.repo,
    required this.nomorTiket,
    required this.bisaDinilai,
    required this.bisaDibukaKembali,
    required this.onSelesai,
  });

  final LaporPengaduanRepository repo;
  final String nomorTiket;
  final bool bisaDinilai;
  final bool bisaDibukaKembali;

  /// Dipanggil setelah aksi berhasil — memicu pelacakan ulang tiket supaya
  /// status/linimasa di layar ikut diperbarui (pola sama seperti
  /// `onPerbarui` di web).
  final Future<void> Function() onSelesai;

  @override
  State<_AksiPelapor> createState() => _AksiPelaporState();
}

class _AksiPelaporState extends State<_AksiPelapor> {
  _ModeAksiPelapor _mode = _ModeAksiPelapor.pilih;
  int _rating = 0;
  final _kontrolKomentar = TextEditingController();
  final _kontrolAlasan = TextEditingController();
  bool _mengirim = false;
  String? _galat;

  @override
  void dispose() {
    _kontrolKomentar.dispose();
    _kontrolAlasan.dispose();
    super.dispose();
  }

  Future<void> _kirimNilai() async {
    if (_rating == 0) return;
    setState(() {
      _mengirim = true;
      _galat = null;
    });
    try {
      await widget.repo.konfirmasi(
        widget.nomorTiket,
        rating: _rating,
        komentar: _kontrolKomentar.text.trim().isEmpty
            ? null
            : _kontrolKomentar.text.trim(),
      );
      if (!mounted) return;
      await widget.onSelesai();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _galat = e.message);
    } finally {
      if (mounted) setState(() => _mengirim = false);
    }
  }

  Future<void> _kirimBukaKembali() async {
    final alasan = _kontrolAlasan.text.trim();
    if (alasan.length < 10) {
      setState(
        () => _galat =
            'Ceritakan apa yang masih bermasalah (minimal 10 karakter).',
      );
      return;
    }
    setState(() {
      _mengirim = true;
      _galat = null;
    });
    try {
      await widget.repo.bukaKembali(widget.nomorTiket, alasan: alasan);
      if (!mounted) return;
      await widget.onSelesai();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _galat = e.message);
    } finally {
      if (mounted) setState(() => _mengirim = false);
    }
  }

  Widget? _galatWidget() {
    if (_galat == null) return null;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ShadAlert.destructive(
        icon: const Icon(CupertinoIcons.exclamationmark_circle),
        title: const Text('Gagal'),
        description: Text(_galat!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    if (!widget.bisaDinilai && !widget.bisaDibukaKembali) {
      return const SizedBox.shrink();
    }

    if (_mode == _ModeAksiPelapor.nilai) {
      return ShadCard(
        title: const Text('Seberapa puas Anda dengan penanganannya?'),
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var n = 1; n <= 5; n++)
                    GestureDetector(
                      onTap: _mengirim
                          ? null
                          : () => setState(() => _rating = n),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          CupertinoIcons.star_fill,
                          size: 30,
                          // Bintang terisi = Rose palet master (amber
                          // keluar dari palet).
                          color: n <= _rating
                              ? const Color(MasterPalette.rose400)
                              : theme.colorScheme.mutedForeground.withValues(
                                  alpha: 0.4,
                                ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              ShadInput(
                controller: _kontrolKomentar,
                placeholder: const Text('Ceritakan pengalaman Anda (opsional)'),
                minLines: 2,
                maxLines: 4,
                enabled: !_mengirim,
              ),
              ?_galatWidget(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ShadButton(
                      onPressed: _mengirim || _rating == 0 ? null : _kirimNilai,
                      leading: _mengirim
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(CupertinoIcons.hand_thumbsup_fill),
                      child: Text(
                        _mengirim ? 'Mengirim…' : 'Kirim & tutup tiket',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ShadButton.ghost(
                    onPressed: _mengirim
                        ? null
                        : () => setState(() => _mode = _ModeAksiPelapor.pilih),
                    child: const Text('Batal'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (_mode == _ModeAksiPelapor.buka) {
      return ShadCard(
        title: const Text('Apa yang masih bermasalah?'),
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ShadInput(
                controller: _kontrolAlasan,
                placeholder: const Text(
                  'Mis. air sempat mengalir tapi mati lagi keesokan harinya…',
                ),
                minLines: 2,
                maxLines: 4,
                enabled: !_mengirim,
              ),
              const SizedBox(height: 6),
              Text(
                'Tiket yang sama akan dibuka kembali — riwayat penanganannya '
                'tidak hilang.',
                style: theme.textTheme.muted.copyWith(fontSize: 11),
              ),
              ?_galatWidget(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ShadButton.destructive(
                      onPressed: _mengirim ? null : _kirimBukaKembali,
                      leading: _mengirim
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(CupertinoIcons.arrow_counterclockwise),
                      child: Text(
                        _mengirim ? 'Mengirim…' : 'Buka kembali tiket',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ShadButton.ghost(
                    onPressed: _mengirim
                        ? null
                        : () => setState(() => _mode = _ModeAksiPelapor.pilih),
                    child: const Text('Batal'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return ShadCard(
      title: const Text('Apakah masalah Anda sudah benar-benar selesai?'),
      description: const Text(
        'Tiket ini baru ditutup setelah Anda yang mengonfirmasi — bukan petugas.',
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (widget.bisaDinilai)
              ShadButton(
                onPressed: () => setState(() => _mode = _ModeAksiPelapor.nilai),
                leading: const Icon(CupertinoIcons.hand_thumbsup_fill),
                child: const Text('Ya, sudah selesai'),
              ),
            if (widget.bisaDibukaKembali)
              ShadButton.outline(
                onPressed: () => setState(() => _mode = _ModeAksiPelapor.buka),
                leading: const Icon(CupertinoIcons.arrow_counterclockwise),
                child: const Text('Belum, masih bermasalah'),
              ),
          ],
        ),
      ),
    );
  }
}

class _BarisLinimasa extends StatelessWidget {
  const _BarisLinimasa({required this.entri, required this.terakhir});

  final TicketTimelineEntry entri;
  final bool terakhir;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: terakhir
                      ? theme.colorScheme.primary
                      : theme.colorScheme.mutedForeground,
                  shape: BoxShape.circle,
                ),
              ),
              if (!terakhir)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.only(top: 2),
                    color: theme.colorScheme.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: terakhir ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entri.statusKe == null
                        ? entri.aksi
                        : labelDari(labelStatusPengaduan, entri.statusKe),
                    style: theme.textTheme.small,
                  ),
                  if (entri.catatan != null) ...[
                    const SizedBox(height: 2),
                    Text(entri.catatan!, style: theme.textTheme.muted),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    '${entri.olehNama ?? '-'}'
                    '${entri.createdAt == null ? '' : ' · ${formatWaktuLokal(entri.createdAt!)}'}',
                    style: theme.textTheme.muted.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Percakapan dua arah pelapor <-> petugas pada thread tiket. Entri datang
/// dari riwayat publik aksi CHAT; pesan baru dikirim lewat
/// POST /api/public/pengaduan/:nomorTiket/chat lalu layar melacak ulang
/// (chat ikut segar). Bubble kanan = Pelapor, kiri = petugas.
class _ChatTiket extends StatefulWidget {
  const _ChatTiket({
    required this.repo,
    required this.nomorTiket,
    required this.entri,
    required this.bisaChat,
    required this.onTerkirim,
  });

  final LaporPengaduanRepository repo;
  final String nomorTiket;
  final List<TicketTimelineEntry> entri;
  final bool bisaChat;
  final Future<void> Function() onTerkirim;

  @override
  State<_ChatTiket> createState() => _ChatTiketState();
}

class _ChatTiketState extends State<_ChatTiket> {
  final _kontrol = TextEditingController();
  bool _mengirim = false;
  String? _galat;

  @override
  void dispose() {
    _kontrol.dispose();
    super.dispose();
  }

  Future<void> _kirim() async {
    final pesan = _kontrol.text.trim();
    if (pesan.isEmpty) return;
    setState(() {
      _mengirim = true;
      _galat = null;
    });
    try {
      await widget.repo.kirimChat(widget.nomorTiket, pesan: pesan);
      _kontrol.clear();
      if (!mounted) return;
      await widget.onTerkirim();
    } on ApiException catch (e) {
      if (mounted) setState(() => _galat = e.message);
    } finally {
      if (mounted) setState(() => _mengirim = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ShadCard(
      title: const Text('Percakapan dengan Petugas'),
      description: widget.bisaChat
          ? const Text(
              'Balasan petugas muncul di sini setiap kali Anda '
              'memuat ulang tiket.',
            )
          : const Text('Tiket sudah ditutup — percakapan berakhir.'),
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.entri.isEmpty)
              Text('Belum ada pesan.', style: theme.textTheme.muted)
            else
              for (final e in widget.entri) _BubbleChat(entri: e),
            if (widget.bisaChat) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ShadInput(
                      controller: _kontrol,
                      enabled: !_mengirim,
                      placeholder: const Text('Tulis pesan…'),
                      onSubmitted: (_) => _kirim(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ShadButton(
                    onPressed: _mengirim ? null : _kirim,
                    leading: _mengirim
                        ? const SizedBox.square(
                            dimension: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(CupertinoIcons.paperplane_fill, size: 15),
                    child: const Text('Kirim'),
                  ),
                ],
              ),
              if (_galat != null) ...[
                const SizedBox(height: 6),
                Text(
                  _galat!,
                  style: theme.textTheme.muted.copyWith(
                    color: theme.colorScheme.destructive,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _BubbleChat extends StatelessWidget {
  const _BubbleChat({required this.entri});

  final TicketTimelineEntry entri;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final dariPelapor = entri.olehNama == 'Pelapor';

    return Align(
      alignment: dariPelapor ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: dariPelapor
              ? const Color(MasterPalette.sky100)
              : theme.colorScheme.secondary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(dariPelapor ? 12 : 3),
            bottomRight: Radius.circular(dariPelapor ? 3 : 12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dariPelapor ? 'Anda' : (entri.olehNama ?? 'Petugas'),
              style: theme.textTheme.muted.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: dariPelapor ? const Color(MasterPalette.sky700) : null,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              entri.catatan ?? '',
              style: theme.textTheme.small.copyWith(
                fontWeight: FontWeight.w400,
                color: dariPelapor
                    ? const Color(MasterPalette.sky900)
                    : theme.colorScheme.foreground,
              ),
            ),
            if (entri.createdAt != null) ...[
              const SizedBox(height: 2),
              Text(
                formatWaktuLokal(entri.createdAt!),
                style: theme.textTheme.muted.copyWith(fontSize: 9.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
