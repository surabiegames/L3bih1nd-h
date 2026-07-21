import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/auth/sesi_warga.dart';
import '../../../core/models/complaint_ticket_model.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/services/kompres_foto.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/labels.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/kotak_foto_bukti.dart';
import '../akun/daftar_warga_screen.dart';
import '../akun/laporan_saya_repository.dart';
import '../langganan/langganan_warga_repository.dart';
import 'lapor_pengaduan_repository.dart';

/// Lapor Pengaduan — publik, tanpa login. Pelapor tidak harus pelanggan
/// (mis. warga melihat pipa bocor di jalan). Balasan berisi nomor tiket
/// TW-YYMM-XXXXXX untuk melacak status.
class LaporPengaduanScreen extends StatefulWidget {
  const LaporPengaduanScreen({super.key});

  @override
  State<LaporPengaduanScreen> createState() => _LaporPengaduanScreenState();
}

class _LaporPengaduanScreenState extends State<LaporPengaduanScreen> {
  final _formKey = GlobalKey<ShadFormState>();
  final _repo = LaporPengaduanRepository.create();
  final _pemilihFoto = ImagePicker();

  String? _jenis;
  String? _fotoPath;
  String? _videoPath;
  bool _mengirim = false;
  String? _galat;

  /// Durasi maksimal klip video bukti — SEJALAN dengan validasi web & batas
  /// server (video 50 MB). "30–60 detik saja": batas atas ditegakkan lewat
  /// maxDuration image_picker; klip lebih pendek tetap diterima.
  static const _maksDurasiVideo = Duration(seconds: 60);

  bool get _wajibKoordinat => _jenis == 'KEBOCORAN';

  /// Ambil foto bukti (OPSIONAL — beda dari foto meter yang wajib) dari
  /// kamera atau galeri, lalu kompres sendiri sebelum diunggah. Alasan
  /// kompresinya ada di dalam.
  Future<void> _ambilFoto() async {
    final sudahAda = _fotoPath != null;
    final aksi = await showShadDialog<String>(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Foto Bukti'),
        description: const Text(
          'Satu foto kondisi di lapangan sangat membantu petugas menyiapkan '
          'alat sebelum berangkat.',
        ),
        actions: [
          if (sudahAda)
            ShadButton.destructive(
              onPressed: () => Navigator.of(context).pop('hapus'),
              child: const Text('Hapus'),
            ),
          ShadButton.outline(
            onPressed: () => Navigator.of(context).pop('galeri'),
            child: const Text('Galeri'),
          ),
          ShadButton(
            onPressed: () => Navigator.of(context).pop('kamera'),
            child: const Text('Kamera'),
          ),
        ],
      ),
    );
    if (aksi == null || !mounted) return;

    if (aksi == 'hapus') {
      setState(() => _fotoPath = null);
      return;
    }
    try {
      final berkas = await _pemilihFoto.pickImage(
        source: aksi == 'kamera' ? ImageSource.camera : ImageSource.gallery,
      );
      if (berkas == null || !mounted) return;

      // Dikompres sendiri, bukan mengandalkan maxWidth/imageQuality milik
      // image_picker: pada sebagian perangkat Android kedua opsi itu
      // diabaikan diam-diam, dan foto 3-8 MB langsung ditolak server
      // (batas 5 MB, MAKS_UKURAN_BYTE di server/lib/storage.ts).
      //
      // 1280 px & TANPA watermark — beda dari foto meter: yang difoto di
      // sini bisa kebocoran atau air keruh, jadi detail lebih berharga
      // daripada stempel waktu, dan teks kuning di tengah gambar justru
      // menutupi barang buktinya.
      final tmp = await getTemporaryDirectory();
      final hasil = await const KompresFoto().proses(
        sumberPath: berkas.path,
        tujuanPath:
            '${tmp.path}/pengaduan_${DateTime.now().millisecondsSinceEpoch}.jpg',
        keterangan: '',
        lebarTarget: 1280,
        watermark: false,
      );
      if (!mounted) return;
      setState(() => _fotoPath = hasil);
    } on Object {
      if (!mounted) return;
      setState(
        () => _galat =
            'Kamera tidak tersedia di perangkat ini — gunakan pilihan Galeri.',
      );
    }
  }

  /// Ambil klip video bukti (OPSIONAL) dari kamera atau galeri. Durasi
  /// dibatasi 60 detik lewat maxDuration. Kompresi/optimasi tampilan
  /// dilakukan server (Cloudinary q_auto) — transcoding berat di HP warga
  /// dihindari (real-time, boros baterai), sama seperti keputusan di web.
  Future<void> _ambilVideo() async {
    final sudahAda = _videoPath != null;
    final aksi = await showShadDialog<String>(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Video Bukti'),
        description: const Text(
          'Klip pendek (maksimal 60 detik) — mis. suara/aliran air bocor. '
          'Membantu petugas menilai tingkat kerusakan sebelum berangkat.',
        ),
        actions: [
          if (sudahAda)
            ShadButton.destructive(
              onPressed: () => Navigator.of(context).pop('hapus'),
              child: const Text('Hapus'),
            ),
          ShadButton.outline(
            onPressed: () => Navigator.of(context).pop('galeri'),
            child: const Text('Galeri'),
          ),
          ShadButton(
            onPressed: () => Navigator.of(context).pop('kamera'),
            child: const Text('Kamera'),
          ),
        ],
      ),
    );
    if (aksi == null || !mounted) return;

    if (aksi == 'hapus') {
      setState(() => _videoPath = null);
      return;
    }
    try {
      final berkas = await _pemilihFoto.pickVideo(
        source: aksi == 'kamera' ? ImageSource.camera : ImageSource.gallery,
        maxDuration: _maksDurasiVideo,
      );
      if (berkas == null || !mounted) return;
      setState(() => _videoPath = berkas.path);
    } on Object {
      if (!mounted) return;
      setState(
        () => _galat =
            'Kamera video tidak tersedia di perangkat ini — coba pilih dari Galeri.',
      );
    }
  }

  Future<void> _kirim() async {
    final form = _formKey.currentState!;
    if (!form.saveAndValidate()) return;
    final nilai = form.value;

    setState(() {
      _mengirim = true;
      _galat = null;
    });
    try {
      final draft = ComplaintDraft(
        jenis: nilai['jenis'] as String,
        judul: (nilai['judul'] as String).trim(),
        deskripsi: (nilai['deskripsi'] as String).trim(),
        pelapor: (nilai['pelapor'] as String).trim(),
        kontakPelapor: (nilai['kontakPelapor'] as String).trim(),
        alamatKejadian: (nilai['alamatKejadian'] as String?)?.trim(),
        nomorLangganan: (nilai['nomorLangganan'] as String?)?.trim(),
        lat: _wajibKoordinat
            ? double.tryParse(nilai['lat'] as String? ?? '')
            : null,
        lng: _wajibKoordinat
            ? double.tryParse(nilai['lng'] as String? ?? '')
            : null,
      );
      final tanda = await _repo.kirim(
        draft,
        fotoPath: _fotoPath,
        videoPath: _videoPath,
      );
      // Tiket baru membuat daftar tersimpan usang — blok Tiket Aktif di
      // beranda dan layar Laporan Saya harus memuat ulang, bukan
      // menampilkan daftar tanpa tiket yang barusan dikirim.
      LaporanSayaCache.reset();
      if (!mounted) return;
      _formKey.currentState!.reset();
      setState(() {
        _jenis = null;
        _fotoPath = null;
        _videoPath = null;
      });
      // Login TETAP opsional untuk melapor (draft dikirim lewat endpoint
      // publik yang sama apa pun status login-nya) — tapi kalau kebetulan
      // sedang login, server SUDAH menautkan tiket ini ke akun (lihat
      // getSessionUserOpsional() di server/lib/session.ts), jadi pesannya
      // harus bilang itu, bukan menawarkan pendaftaran yang percuma.
      final sudahLogin = SesiWarga.instance.sudahMasuk;
      await showShadDialog<void>(
        context: context,
        builder: (context) => ShadDialog.alert(
          title: const Text('Pengaduan Diterima'),
          description: Text(
            '${tanda.pesan}\n\nNomor tiket Anda:\n${tanda.nomorTiket}'
            '${tanda.targetSelesaiAt == null ? '' : '\n\nTarget penyelesaian: '
                      '${formatTanggalUtc(tanda.targetSelesaiAt!)}'}'
            '${sudahLogin ? '\n\nLaporan ini otomatis tersimpan di akun Anda — buka "Laporan Saya" kapan saja untuk memantaunya.' : '\n\nBelum punya akun? Daftar supaya laporan Anda tersimpan otomatis dan tidak perlu mengingat nomor tiket.'}',
          ),
          actions: [
            if (!sudahLogin)
              ShadButton.outline(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, _, _) => const DaftarWargaScreen(),
                      transitionsBuilder: (_, animasi, _, child) =>
                          FadeTransition(opacity: animasi, child: child),
                    ),
                  );
                },
                child: const Text('Daftar Akun'),
              ),
            ShadButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Selesai'),
            ),
          ],
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(
        () => _galat = e.details?.isNotEmpty == true
            ? e.details!.map((d) => d.message).join('\n')
            : e.message,
      );
    } finally {
      if (mounted) setState(() => _mengirim = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Lapor Pengaduan',
      subtitle: 'Sampaikan gangguan layanan air',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ShadForm(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ShadSelectFormField<String>(
                  id: 'jenis',
                  label: const Text('Kategori Pengaduan'),
                  placeholder: const Text('Pilih kategori…'),
                  options: [
                    for (final e in labelJenisPengaduan.entries)
                      ShadOption(value: e.key, child: Text(e.value)),
                  ],
                  selectedOptionBuilder: (context, value) =>
                      Text(labelDari(labelJenisPengaduan, value)),
                  onChanged: (v) => setState(() => _jenis = v),
                  validator: (v) =>
                      v == null ? 'Pilih kategori pengaduan.' : null,
                ),
                const SizedBox(height: 16),
                ShadInputFormField(
                  id: 'judul',
                  label: const Text('Judul'),
                  placeholder: const Text('Ringkasan singkat masalah'),
                  validator: (v) =>
                      v.trim().length < 5 ? 'Judul minimal 5 karakter.' : null,
                ),
                const SizedBox(height: 16),
                ShadTextareaFormField(
                  id: 'deskripsi',
                  label: const Text('Deskripsi'),
                  placeholder: const Text(
                    'Ceritakan detailnya: sejak kapan, seberapa parah, '
                    'ciri lokasi…',
                  ),
                  validator: (v) => v.trim().length < 10
                      ? 'Ceritakan lebih detail (minimal 10 karakter).'
                      : null,
                ),
                if (_wajibKoordinat) ...[
                  const SizedBox(height: 16),
                  ShadAlert(
                    icon: const Icon(CupertinoIcons.placemark_fill),
                    title: const Text('Lokasi wajib untuk kebocoran'),
                    description: const Text(
                      'Isi koordinat titik kebocoran agar petugas dapat '
                      'menemukannya. Salin dari aplikasi peta di ponsel Anda.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ShadInputFormField(
                          id: 'lat',
                          label: const Text('Latitude'),
                          placeholder: const Text('-6.9147'),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          validator: (v) {
                            final angka = double.tryParse(v);
                            if (angka == null || angka < -90 || angka > 90) {
                              return 'Latitude tidak valid.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ShadInputFormField(
                          id: 'lng',
                          label: const Text('Longitude'),
                          placeholder: const Text('107.6098'),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          validator: (v) {
                            final angka = double.tryParse(v);
                            if (angka == null || angka < -180 || angka > 180) {
                              return 'Longitude tidak valid.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                ShadInputFormField(
                  id: 'alamatKejadian',
                  label: const Text('Alamat Kejadian (opsional)'),
                  placeholder: const Text('Jalan, RT/RW, patokan terdekat'),
                ),
                const SizedBox(height: 16),
                Text(
                  'Foto Bukti (opsional)',
                  style: ShadTheme.of(context).textTheme.small,
                ),
                const SizedBox(height: 8),
                KotakFotoBukti(
                  path: _fotoPath,
                  onTap: _mengirim ? null : _ambilFoto,
                ),
                const SizedBox(height: 4),
                Text(
                  'Satu foto kondisi di lapangan sangat membantu petugas '
                  'menyiapkan alat sebelum berangkat.',
                  style: ShadTheme.of(
                    context,
                  ).textTheme.muted.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 16),
                Text(
                  'Video Bukti (opsional)',
                  style: ShadTheme.of(context).textTheme.small,
                ),
                const SizedBox(height: 8),
                _KotakVideoBukti(
                  terisi: _videoPath != null,
                  onTap: _mengirim ? null : _ambilVideo,
                ),
                const SizedBox(height: 4),
                Text(
                  'Klip pendek 30–60 detik (maks 60) — mis. aliran air bocor. '
                  'Ditampilkan dalam kualitas teroptimasi.',
                  style: ShadTheme.of(
                    context,
                  ).textTheme.muted.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 16),
                ShadInputFormField(
                  id: 'pelapor',
                  initialValue: SesiWarga.instance.akun?.name,
                  label: const Text('Nama Pelapor'),
                  placeholder: const Text('Nama lengkap Anda'),
                  validator: (v) =>
                      v.trim().length < 2 ? 'Nama pelapor wajib diisi.' : null,
                ),
                const SizedBox(height: 16),
                ShadInputFormField(
                  id: 'kontakPelapor',
                  label: const Text('Nomor HP / Kontak'),
                  placeholder: const Text('08xxxxxxxxxx'),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v.trim().length < 5
                      ? 'Kontak wajib diisi agar petugas bisa menghubungi.'
                      : null,
                ),
                const SizedBox(height: 16),
                ShadInputFormField(
                  id: 'nomorLangganan',
                  // Prefill nomor UTAMA akun yang login — tetap opsional
                  // dan bisa dihapus (pengaduan boleh dari bukan pelanggan).
                  initialValue: LanggananSayaCache.utama?.nomorLangganan,
                  label: const Text('Nomor Langganan (opsional)'),
                  placeholder: const Text('11 digit, bila Anda pelanggan'),
                  description: const Text(
                    'Membantu petugas menautkan pengaduan ke data langganan.',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  validator: (v) => v.isNotEmpty && v.length != 11
                      ? 'Bila diisi, nomor langganan harus 11 digit.'
                      : null,
                ),
                const SizedBox(height: 24),
                if (_galat != null) ...[
                  ShadAlert.destructive(
                    icon: const Icon(CupertinoIcons.exclamationmark_circle),
                    title: const Text('Gagal mengirim'),
                    description: Text(_galat!),
                  ),
                  const SizedBox(height: 16),
                ],
                ShadButton(
                  onPressed: _mengirim ? null : _kirim,
                  leading: _mengirim
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(CupertinoIcons.paperplane_fill),
                  child: Text(_mengirim ? 'Mengirim…' : 'Kirim Pengaduan'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kotak pemilih video bukti — pola sama seperti KotakFotoBukti tapi tidak
/// menampilkan pratinjau bingkai (thumbnail video butuh paket tambahan);
/// cukup menandai "sudah terpilih". Ketuk membuka pilihan Kamera/Galeri.
class _KotakVideoBukti extends StatelessWidget {
  const _KotakVideoBukti({required this.terisi, required this.onTap});

  final bool terisi;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 96,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: theme.colorScheme.muted,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: terisi ? theme.colorScheme.primary : theme.colorScheme.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              terisi
                  ? CupertinoIcons.checkmark_circle_fill
                  : CupertinoIcons.videocam,
              size: 24,
              color: terisi
                  ? theme.colorScheme.primary
                  : theme.colorScheme.mutedForeground,
            ),
            const SizedBox(width: 8),
            Text(
              terisi ? 'Video siap dikirim · ketuk untuk ganti' : 'Ambil / pilih video',
              style: theme.textTheme.muted,
            ),
          ],
        ),
      ),
    );
  }
}

