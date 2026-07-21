import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/auth/sesi_petugas.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/services/backup_lokal.dart';
import '../../../core/services/kompres_foto.dart';
import '../../../core/services/lokasi_service.dart';
import '../../../core/services/ocr_stand.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/labels.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/squircle_icon.dart';
import 'rute_repository.dart';
import 'tarif_repository.dart';

/// Catat Meter — layar entri stand untuk satu pelanggan rute. Anatomi dan
/// guard-nya mengikuti `CatatStandFragment` Aurora yang terbukti di
/// lapangan:
/// stand lalu → stand akhir dengan pemakaian + deviasi live, kondisi
/// kelainan, kondisi segel, usulan perubahan data, 3 slot foto
/// (kompres 600px + watermark waktu+petugas) + video, jarak GPS live ke
/// titik pelanggan, riwayat 3 periode, estimasi uang air progresif, dialog
/// konfirmasi lengkap sebelum simpan, dan navigasi sebelum/berikutnya
/// mengikuti urutan jalan.
class CatatMeterScreen extends StatefulWidget {
  const CatatMeterScreen({
    super.key,
    required this.pelanggan,
    this.urutanKunjungan = const [],
  });

  final PelangganRute pelanggan;

  /// Daftar pelanggan tab aktif, urut kunjungan — dasar tombol
  /// sebelum/berikutnya (pola next/prev `WAKTU_CATAT` Aurora).
  final List<PelangganRute> urutanKunjungan;

  @override
  State<CatatMeterScreen> createState() => _CatatMeterScreenState();
}

class _CatatMeterScreenState extends State<CatatMeterScreen> {
  final _repo = RuteRepository.create();
  final _tarifRepo = TarifRepository();
  final _lokasi = const LokasiService();
  final _kontrolStand = TextEditingController();
  final _kontrolPerubahan = TextEditingController();
  late final _kontrolNoHp = TextEditingController(
    text: widget.pelanggan.notelp ?? '',
  );
  final _pemilihFoto = ImagePicker();

  int? _standLalu;
  bool _memuatStand = true;
  String _kondisi = 'NORMAL';
  String _kategori = 'ONSITE';

  /// null = tidak diperiksa; true/false = kondisi segel yang ditemukan.
  bool? _isSegel;

  /// jenis (stand/segel/rumah/video) -> path berkas lokal siap unggah.
  final Map<String, String> _fotoPaths = {};
  String? _sedangMemproses;
  bool _mengirim = false;
  String? _galat;

  TarifGolonganMobile? _tarif;
  Position? _posisi;
  StreamSubscription<Position>? _subPosisi;

  /// Ambang peringatan deviasi di UI. Nilai resmi milik server (endpoint
  /// stats); ini hanya peringatan dini sebelum kirim.
  static const _ambangPeringatan = 50;

  @override
  void initState() {
    super.initState();
    _muatStandLalu();
    _muatTarif();
    _mulaiGps();
    _kontrolStand.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _subPosisi?.cancel();
    _kontrolStand.dispose();
    _kontrolPerubahan.dispose();
    _kontrolNoHp.dispose();
    super.dispose();
  }

  Future<void> _muatStandLalu() async {
    try {
      final stand = await _repo.standTerakhir(widget.pelanggan);
      if (!mounted) return;
      setState(() {
        _standLalu = stand ?? widget.pelanggan.standLalu;
        _memuatStand = false;
      });
    } on ApiException {
      if (!mounted) return;
      // Prefill hanya kenyamanan — biarkan kosong bila riwayat tak terbaca.
      setState(() {
        _standLalu = widget.pelanggan.standLalu;
        _memuatStand = false;
      });
    }
  }

  Future<void> _muatTarif() async {
    final tarif = await _tarifRepo.untukGolongan(
      widget.pelanggan.golonganTarif,
    );
    if (!mounted) return;
    setState(() => _tarif = tarif);
  }

  /// GPS untuk bukti kehadiran + jarak live ke titik pelanggan. Gagal
  /// (izin ditolak, dev desktop) bukan penghalang layar — hanya jarak &
  /// latCatat yang hilang.
  Future<void> _mulaiGps() async {
    try {
      final posisi = await _lokasi.posisiSekarang();
      if (!mounted) return;
      setState(() => _posisi = posisi);
      _subPosisi = _lokasi.aliranPosisi().listen(
        (p) => mounted ? setState(() => _posisi = p) : null,
        onError: (Object _) {},
      );
    } on Object {
      // plugin lokasi tidak tersedia di platform ini — biarkan null.
    }
  }

  int? get _standAkhir => int.tryParse(_kontrolStand.text);

  int? get _pemakaian {
    final akhir = _standAkhir;
    final lalu = _standLalu;
    if (akhir == null || lalu == null) return null;
    return akhir - lalu;
  }

  double? get _deviasi {
    final pakai = _pemakaian;
    final lalu = widget.pelanggan.pemakaianLalu;
    if (pakai == null || lalu == null || lalu <= 0) return null;
    return (pakai - lalu) / lalu * 100;
  }

  bool get _mundurTanpaKondisiSah =>
      (_pemakaian ?? 0) < 0 && !kondisiSahMundur.contains(_kondisi);

  bool get _anomali => (_deviasi?.abs() ?? 0) > _ambangPeringatan;

  /// Jarak live petugas ↔ titik pelanggan (pola tv_range_location +
  /// marginMeter Aurora). null = salah satu koordinat belum ada. Angka
  /// resmi tetap dihitung server dari latCatat/longCatat.
  int? get _jarakKePelanggan {
    final pos = _posisi;
    final p = widget.pelanggan;
    if (pos == null || p.geoLat == null || p.geoLong == null) return null;
    return LokasiService.jarakMeter(
      pos.latitude,
      pos.longitude,
      p.geoLat!,
      p.geoLong!,
    ).round();
  }

  int? get _estimasiAir {
    final pakai = _pemakaian;
    if (pakai == null || pakai < 0) return null;
    return estimasiUangAir(_tarif, pakai);
  }

  /// Komponen tetap tagihan terakhir pelanggan (beban + admin) bila ada —
  /// dibawa payload rute-saya. null bila pelanggan belum pernah ditagih.
  int? get _biayaTetap {
    final b = widget.pelanggan.beaBeban;
    final a = widget.pelanggan.beaAdmin;
    if (b == null && a == null) return null;
    return (b ?? 0) + (a ?? 0);
  }

  /// Estimasi total = uang air progresif + beban + admin (pola
  /// calculateTagihan Aurora). null bila uang air tak bisa dihitung; bila
  /// komponen tetap belum diketahui, sama dengan uang air saja.
  int? get _estimasiTotal {
    final air = _estimasiAir;
    if (air == null) return null;
    return air + (_biayaTetap ?? 0);
  }

  static const _labelSlot = {
    'stand': 'Stand Meter',
    'segel': 'Segel',
    'rumah': 'Rumah',
    'video': 'Video',
  };

  /// Ambil berkas untuk satu slot. Foto langsung dikompres 600px + watermark
  /// waktu+petugas (angka persis ImageUtility Aurora) lalu disalin ke folder
  /// backup — path backup yang dipakai, bukan cache picker yang bisa
  /// dibersihkan OS sebelum antrean offline terkirim.
  Future<void> _ambilBerkas(String jenis) async {
    final sudahAda = _fotoPaths[jenis] != null;
    final video = jenis == 'video';
    final aksi = await showShadDialog<String>(
      context: context,
      builder: (context) => ShadDialog(
        title: Text(video ? 'Video Pembacaan' : 'Foto ${_labelSlot[jenis]}'),
        description: Text(
          video
              ? 'Video singkat meter berputar — bukti tambahan untuk kasus '
                    'sengketa stand.'
              : 'Foto dikompres + diberi cap waktu dan nama petugas, lalu '
                    'ikut terkirim bersama laporan.',
        ),
        // Vertikal: label aksi panjang tidak muat berjajar di dialog HP sempit.
        actionsAxis: Axis.vertical,
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
      setState(() => _fotoPaths.remove(jenis));
      return;
    }
    final sumber = aksi == 'kamera' ? ImageSource.camera : ImageSource.gallery;
    setState(() {
      _sedangMemproses = jenis;
      _galat = null;
    });
    try {
      final XFile? berkas = video
          ? await _pemilihFoto.pickVideo(
              source: sumber,
              maxDuration: const Duration(seconds: 20),
            )
          : await _pemilihFoto.pickImage(source: sumber);
      if (berkas == null || !mounted) {
        setState(() => _sedangMemproses = null);
        return;
      }

      final periode = periodeCatatSekarang();
      final nomor = widget.pelanggan.nomorLangganan;
      String hasil = berkas.path;
      // OCR pada foto ASLI (sebelum watermark — cap waktunya berisi digit
      // yang ikut terbaca) — padanan MainOcrActivity Aurora: jepretan stand
      // sekaligus mengisi angkanya.
      String? angkaOcr;
      if (jenis == 'stand') {
        angkaOcr = await const OcrStand().bacaAngka(berkas.path);
      }
      if (!video) {
        final tmp = await getTemporaryDirectory();
        hasil = await const KompresFoto().proses(
          sumberPath: berkas.path,
          tujuanPath: '${tmp.path}/${periode}_${jenis}_$nomor.jpg',
          keterangan: SesiPetugas.instance.akun?.name ?? 'PETUGAS',
        );
        // Salinan backup (folder backup_foto ala Aurora) jadi path utama —
        // bertahan sampai antrean offline benar-benar terkirim.
        hasil =
            await BackupLokal.instance.simpanSalinanFoto(
              jenis: jenis,
              periode: periode,
              nomorLangganan: nomor,
              sumberPath: hasil,
            ) ??
            hasil;
      }
      if (!mounted) return;
      setState(() {
        _fotoPaths[jenis] = hasil;
        _sedangMemproses = null;
      });
      if (angkaOcr != null) await _tawarkanHasilOcr(angkaOcr);
    } on Object {
      if (!mounted) return;
      setState(() {
        _sedangMemproses = null;
        _galat =
            'Kamera tidak tersedia di perangkat ini — gunakan pilihan Galeri.';
      });
    }
  }

  /// Tawarkan angka hasil OCR foto stand — petugas SELALU mengonfirmasi,
  /// tidak pernah diisi diam-diam (angka salah baca lebih mahal daripada
  /// mengetik ulang). Tidak muncul bila angkanya sama dengan isian.
  Future<void> _tawarkanHasilOcr(String angka) async {
    final bersih = int.tryParse(angka);
    if (bersih == null || !mounted) return;
    if (_standAkhir == bersih) return;
    final pakai = await showShadDialog<bool>(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Angka Terbaca dari Foto'),
        description: Text(
          'OCR membaca stand: $bersih\n'
          'Cocokkan dengan roda angka pada meter sebelum memakai.',
        ),
        actionsAxis: Axis.vertical,
        actions: [
          ShadButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Pakai Angka Ini'),
          ),
          ShadButton.outline(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abaikan'),
          ),
        ],
      ),
    );
    if (pakai == true && mounted) {
      setState(() => _kontrolStand.text = '$bersih');
    }
  }

  /// Guard GPS ala Aurora (checkGPS sebelum simpan) — bedanya petugas boleh
  /// memilih lanjut tanpa GPS secara sadar; server tetap mencatat laporan
  /// itu tanpa bukti kehadiran.
  Future<bool> _pastikanGps() async {
    // Mode demo (tanpa backend): tidak ada alur GPS sungguhan — jangan
    // menghalangi peragaan alur catat.
    if (ApiConfig.isDemo) return true;
    if (_posisi != null) return true;
    bool aktif;
    try {
      aktif = await _lokasi.layananAktif();
    } on Object {
      return true; // platform tanpa plugin lokasi (dev desktop): lewati.
    }
    if (aktif && _posisi != null) return true;
    if (!mounted) return false;
    final lanjut = await showShadDialog<bool>(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('GPS Belum Aktif'),
        description: const Text(
          'Posisi Anda belum terbaca — laporan akan tersimpan TANPA bukti '
          'kehadiran di lokasi. Aktifkan GPS lalu coba lagi, atau lanjut '
          'tanpa GPS.',
        ),
        actionsAxis: Axis.vertical,
        actions: [
          ShadButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Aktifkan Dulu'),
          ),
          ShadButton.outline(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Lanjut Tanpa GPS'),
          ),
        ],
      ),
    );
    if (lanjut == false) await _mulaiGps();
    return lanjut == true;
  }

  int get _indeksSaatIni => widget.urutanKunjungan.indexWhere(
    (p) => p.nomorLangganan == widget.pelanggan.nomorLangganan,
  );

  PelangganRute? get _sebelumnya {
    final i = _indeksSaatIni;
    return i > 0 ? widget.urutanKunjungan[i - 1] : null;
  }

  PelangganRute? get _berikutnya {
    final i = _indeksSaatIni;
    return i >= 0 && i + 1 < widget.urutanKunjungan.length
        ? widget.urutanKunjungan[i + 1]
        : null;
  }

  void _pindah(PelangganRute tujuan) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => CatatMeterScreen(
          pelanggan: tujuan,
          urutanKunjungan: widget.urutanKunjungan,
        ),
        transitionsBuilder: (_, animasi, _, child) =>
            FadeTransition(opacity: animasi, child: child),
      ),
    );
  }

  Future<void> _simpan() async {
    final akhir = _standAkhir;
    final lalu = _standLalu;
    // Stand kosong SAH untuk kondisi kelainan (rumah kosong, meter rusak)
    // — Aurora mengonfirmasi, tidak memblokir.
    if (akhir == null && _kondisi == 'NORMAL') {
      setState(
        () => _galat =
            'Isi angka stand, atau pilih kondisi kelainan bila '
            'meter tidak bisa dibaca.',
      );
      return;
    }
    if (lalu == null) {
      setState(
        () => _galat = 'Stand lalu tidak tersedia — catat lewat dashboard web.',
      );
      return;
    }
    if (_mundurTanpaKondisiSah) {
      setState(
        () => _galat =
            'Stand mundur hanya sah untuk kondisi meter bermasalah — '
            'pilih kondisi yang sesuai.',
      );
      return;
    }
    // Foto stand wajib untuk pembacaan Normal (pola isValidPhoto Aurora) —
    // itu bukti yang ikut jadi pembacaan resmi saat verifikasi. Kondisi
    // kelainan boleh tanpa foto stand (meter bisa tak terbaca sama sekali).
    // Mode demo dilewati: tidak ada kamera sungguhan untuk peragaan.
    if (!ApiConfig.isDemo &&
        _kondisi == 'NORMAL' &&
        _fotoPaths['stand'] == null) {
      setState(
        () => _galat =
            'Foto stand meter wajib untuk pembacaan Normal — '
            'ambil lewat slot Berkas Bukti; angka stand ikut terbaca '
            'otomatis dari foto.',
      );
      return;
    }
    if (!await _pastikanGps() || !mounted) return;

    final p = widget.pelanggan;
    final standDikirim = akhir ?? lalu; // kelainan tanpa angka: stand tetap
    final jarak = _jarakKePelanggan;
    final estimasi = _estimasiAir;
    final estimasiTotal = _estimasiTotal;
    final biayaTetap = _biayaTetap;
    final noHpBaru = _kontrolNoHp.text.trim();
    final gantiNoHp = noHpBaru.isNotEmpty && noHpBaru != (p.notelp ?? '');

    final ringkasan = [
      '${p.nama} · ${p.nomorLangganan}',
      'Stand $lalu → $standDikirim '
          '(pemakaian ${_pemakaian ?? 0} m³'
          '${_deviasi == null ? '' : ', ${_deviasi! >= 0 ? '+' : ''}${_deviasi!.toStringAsFixed(0)}% dari bulan lalu'})',
      'Keterangan: ${labelDari(labelKondisiMeter, _kondisi)} · '
          '${labelDari(labelKategoriPembacaan, _kategori)}',
      if (_isSegel != null)
        'Segel: ${_isSegel! ? 'tersegel' : 'tidak tersegel'}',
      if (jarak != null) 'Jarak ke titik pelanggan: ±$jarak m',
      if (gantiNoHp) 'No. HP diperbarui: $noHpBaru',
      if (_kontrolPerubahan.text.trim().isNotEmpty)
        'Usulan perubahan: ${_kontrolPerubahan.text.trim()}',
      'Berkas: ${_fotoPaths.isEmpty ? 'tidak ada' : _fotoPaths.keys.map((j) => _labelSlot[j]).join(', ')}',
      if (estimasi != null && biayaTetap != null)
        'Estimasi tagihan: ${formatRupiah(estimasiTotal!)} '
            '(air ${formatRupiah(estimasi)} + beban & admin '
            '${formatRupiah(biayaTetap)} — angka resmi dihitung sistem)',
      if (estimasi != null && biayaTetap == null)
        'Estimasi uang air: ${formatRupiah(estimasi)} '
            '(belum termasuk beban & admin — angka resmi dihitung sistem)',
    ].join('\n');

    final lanjut = await showShadDialog<bool>(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Konfirmasi Hasil Baca'),
        description: Text(ringkasan),
        // Aksi disusun vertikal: dua tombol berlabel ("Periksa Lagi" +
        // "Simpan") tidak muat berjajar di lebar dialog HP sempit (~340px)
        // dan meng-overflow. Vertikal = pola dialog mobile yang aman.
        actionsAxis: Axis.vertical,
        actions: [
          ShadButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Simpan'),
          ),
          ShadButton.outline(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Periksa Lagi'),
          ),
        ],
      ),
    );
    if (lanjut != true || !mounted) return;

    setState(() {
      _mengirim = true;
      _galat = null;
    });
    try {
      await _repo.catat(
        pelanggan: p,
        periode: periodeCatatSekarang(),
        standAwal: lalu,
        standAkhir: standDikirim,
        kondisi: _kondisi,
        kategori: _kategori,
        fotoPaths: Map.of(_fotoPaths),
        latCatat: _posisi?.latitude,
        longCatat: _posisi?.longitude,
        isSegel: _isSegel,
        usulanPerubahan: _kontrolPerubahan.text.trim().isEmpty
            ? null
            : _kontrolPerubahan.text.trim(),
        notelpBaru: gantiNoHp ? noHpBaru : null,
      );
      if (!mounted) return;
      // Alur jalan Aurora: selesai satu rumah → tawarkan rumah berikutnya
      // yang belum dibaca, tanpa harus kembali ke daftar. Hasil catat MASUK
      // ANTREAN upload (belum dikirim) — diunggah lewat menu Upload.
      final berikut = _berikutnyaBelumDibaca();
      if (berikut != null) {
        final lanjutJalan = await showShadDialog<bool>(
          context: context,
          builder: (context) => ShadDialog(
            title: const Text('Tersimpan'),
            description: Text(
              'Lanjut ke pelanggan berikutnya?\n'
              '${berikut.nama} · ${berikut.nomorLangganan}',
            ),
            actionsAxis: Axis.vertical,
            actions: [
              ShadButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Lanjut'),
              ),
              ShadButton.outline(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Kembali ke Daftar'),
              ),
            ],
          ),
        );
        if (!mounted) return;
        if (lanjutJalan == true) {
          _pindah(berikut);
          return;
        }
      }
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _galat = e.isConflict
            ? 'Pelanggan ini sudah dicatat untuk periode berjalan. '
                  'Kembali dan muat ulang daftar.'
            : e.message;
        _mengirim = false;
      });
    }
  }

  /// Pelanggan berikutnya yang BELUM dibaca sesudah posisi sekarang
  /// (urutan jalan) — pelanggan yang baru saja disimpan dilewati.
  PelangganRute? _berikutnyaBelumDibaca() {
    final daftar = widget.urutanKunjungan;
    final i = _indeksSaatIni;
    if (i < 0) return null;
    for (var j = i + 1; j < daftar.length; j++) {
      if (!daftar[j].sudahDicatat) return daftar[j];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final p = widget.pelanggan;
    final pemakaian = _pemakaian;
    final deviasi = _deviasi;
    final jarak = _jarakKePelanggan;
    final estimasi = _estimasiAir;
    final estimasiTotal = _estimasiTotal;
    final biayaTetap = _biayaTetap;

    return AppScaffold(
      title: 'Catat Meter',
      subtitle: labelPeriode(periodeCatatSekarang()),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Identitas pelanggan + jarak GPS live
          GlassPanel(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SquircleIcon(
                      ikon: CupertinoIcons.person_fill,
                      gradasi: [Color(AppEmerald.c500), Color(AppEmerald.c600)],
                      ukuran: 44,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.nama,
                            style: theme.textTheme.large.copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${p.nomorLangganan}'
                            '${p.nomorMeter == null ? '' : ' · Meter ${p.nomorMeter}'}'
                            '${p.golonganTarif == null ? '' : ' · Tarif ${p.golonganTarif}'}',
                            style: theme.textTheme.muted.copyWith(fontSize: 12),
                          ),
                          if (p.alamat != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  CupertinoIcons.placemark_fill,
                                  size: 14,
                                  color: theme.colorScheme.mutedForeground,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    p.alamat!,
                                    style: theme.textTheme.muted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (p.notelp != null && p.notelp!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Telp: ${p.notelp}',
                              style: theme.textTheme.muted.copyWith(
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (p.urutan != null) ...[
                      const SizedBox(width: 8),
                      ShadBadge.outline(child: Text('Urutan ${p.urutan}')),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      _posisi == null
                          ? CupertinoIcons.location_slash
                          : CupertinoIcons.location_fill,
                      size: 13,
                      color: _posisi == null
                          ? theme.colorScheme.destructive
                          : const Color(AppEmerald.c600),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _posisi == null
                            ? 'Menunggu sinyal GPS…'
                            : jarak == null
                            ? 'Posisi terekam — titik pelanggan belum dipetakan'
                            : '±$jarak m dari titik pelanggan',
                        style: theme.textTheme.muted.copyWith(fontSize: 11.5),
                      ),
                    ),
                    // Navigasi urutan jalan (pola next/prev Aurora).
                    if (widget.urutanKunjungan.isNotEmpty) ...[
                      ShadIconButton.ghost(
                        icon: const Icon(CupertinoIcons.chevron_left, size: 16),
                        onPressed: _sebelumnya == null || _mengirim
                            ? null
                            : () => _pindah(_sebelumnya!),
                      ),
                      ShadIconButton.ghost(
                        icon: const Icon(
                          CupertinoIcons.chevron_right,
                          size: 16,
                        ),
                        onPressed: _berikutnya == null || _mengirim
                            ? null
                            : () => _pindah(_berikutnya!),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Stand lalu → input stand akhir
          GlassPanel(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Stand Lalu',
                            style: theme.textTheme.muted.copyWith(
                              fontSize: 11.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _memuatStand
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  '${_standLalu ?? '-'}',
                                  style: theme.textTheme.h3,
                                ),
                        ],
                      ),
                    ),
                    Icon(
                      CupertinoIcons.arrow_right,
                      size: 20,
                      color: theme.colorScheme.mutedForeground,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Stand Akhir',
                            style: theme.textTheme.muted.copyWith(
                              fontSize: 11.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ShadInput(
                            controller: _kontrolStand,
                            placeholder: const Text('0'),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.h3,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(7),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(height: 1, color: theme.colorScheme.border),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Pemakaian: ', style: theme.textTheme.muted),
                    Text(
                      pemakaian == null ? '—' : formatM3(pemakaian),
                      style: theme.textTheme.large.copyWith(
                        color: _mundurTanpaKondisiSah
                            ? theme.colorScheme.destructive
                            : null,
                      ),
                    ),
                    if (deviasi != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _anomali
                              ? theme.colorScheme.destructive
                              : const Color(AppEmerald.c600),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${deviasi >= 0 ? '+' : ''}'
                          '${deviasi.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (estimasi != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    biayaTetap != null
                        ? 'Estimasi tagihan: ${formatRupiah(estimasiTotal!)} '
                              '(air ${formatRupiah(estimasi)} + beban & admin '
                              '${formatRupiah(biayaTetap)}) — angka resmi '
                              'dihitung sistem saat penagihan.'
                        : 'Estimasi uang air: ${formatRupiah(estimasi)} — belum '
                              'termasuk beban tetap & admin; angka resmi dihitung '
                              'sistem saat penagihan.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.muted.copyWith(fontSize: 11),
                  ),
                ],
                if (_anomali) ...[
                  const SizedBox(height: 10),
                  ShadAlert.destructive(
                    icon: const Icon(
                      CupertinoIcons.exclamationmark_triangle_fill,
                    ),
                    title: const Text('Deviasi ekstrem'),
                    description: Text(
                      'Pemakaian menyimpang lebih dari $_ambangPeringatan% '
                      'dari bulan lalu. Periksa ulang angka pada meter dan '
                      'foto stand dengan jelas — laporan ini akan ditandai '
                      'anomali di verifikasi.',
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Jalur cepat OCR (padanan MainOcrActivity Aurora): jepret stand →
          // foto bukti terisi + angka ditawarkan sekali jalan.
          if (OcrStand.tersedia) ...[
            const SizedBox(height: 8),
            ShadButton.outline(
              onPressed: _mengirim || _sedangMemproses != null
                  ? null
                  : () => _ambilBerkas('stand'),
              leading: const Icon(CupertinoIcons.viewfinder, size: 16),
              child: const Text('Foto Stand + Baca Angka Otomatis (OCR)'),
            ),
          ],
          const SizedBox(height: 12),

          // ── Riwayat 3 periode (pola period1..3 Aurora — jawaban cepat
          //    saat pelanggan menanyakan pemakaiannya)
          if (p.riwayat.isNotEmpty) ...[
            GlassPanel(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Riwayat 3 Periode', style: theme.textTheme.small),
                  const SizedBox(height: 6),
                  for (final r in p.riwayat)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              labelPeriode(r.periode),
                              style: theme.textTheme.muted.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            '${r.standLalu ?? '-'} → ${r.standAkhir ?? '-'}',
                            style: theme.textTheme.muted.copyWith(fontSize: 12),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            r.pemakaianM3 == null
                                ? '—'
                                : formatM3(r.pemakaianM3!),
                            style: theme.textTheme.small.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Keterangan catat (kondisi lengkap sesuai skema KondisiCatat)
          Text('Keterangan / Kondisi Meter', style: theme.textTheme.small),
          const SizedBox(height: 6),
          ShadSelect<String>(
            initialValue: _kondisi,
            options: [
              for (final e in labelKondisiMeter.entries)
                ShadOption(value: e.key, child: Text(e.value)),
            ],
            selectedOptionBuilder: (context, value) =>
                Text(labelDari(labelKondisiMeter, value)),
            onChanged: (v) => setState(() => _kondisi = v ?? 'NORMAL'),
          ),
          const SizedBox(height: 12),

          // ── Kategori + kondisi segel, sejajar
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kategori', style: theme.textTheme.small),
                    const SizedBox(height: 6),
                    ShadSelect<String>(
                      initialValue: _kategori,
                      options: [
                        for (final e in labelKategoriPembacaan.entries)
                          ShadOption(value: e.key, child: Text(e.value)),
                      ],
                      selectedOptionBuilder: (context, value) =>
                          Text(labelDari(labelKategoriPembacaan, value)),
                      onChanged: (v) =>
                          setState(() => _kategori = v ?? 'ONSITE'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kondisi Segel', style: theme.textTheme.small),
                    const SizedBox(height: 6),
                    ShadSelect<String>(
                      initialValue: 'tidak_diperiksa',
                      options: const [
                        ShadOption(
                          value: 'tidak_diperiksa',
                          child: Text('Tidak diperiksa'),
                        ),
                        ShadOption(value: 'ya', child: Text('Tersegel')),
                        ShadOption(
                          value: 'tidak',
                          child: Text('Tidak tersegel'),
                        ),
                      ],
                      selectedOptionBuilder: (context, value) =>
                          Text(switch (value) {
                            'ya' => 'Tersegel',
                            'tidak' => 'Tidak tersegel',
                            _ => 'Tidak diperiksa',
                          }),
                      onChanged: (v) => setState(
                        () => _isSegel = switch (v) {
                          'ya' => true,
                          'tidak' => false,
                          _ => null,
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Berkas bukti: 3 foto + video
          Text('Berkas Bukti', style: theme.textTheme.small),
          const SizedBox(height: 6),
          Row(
            children: [
              for (final (jenis, ikon) in const [
                ('stand', CupertinoIcons.gauge),
                ('segel', CupertinoIcons.lock_fill),
                ('rumah', CupertinoIcons.house_fill),
                ('video', CupertinoIcons.videocam_fill),
              ]) ...[
                Expanded(
                  child: _SlotFoto(
                    ikon: ikon,
                    label: _labelSlot[jenis]!,
                    path: _fotoPaths[jenis],
                    pratinjauGambar: jenis != 'video',
                    memproses: _sedangMemproses == jenis,
                    onTap: _mengirim || _sedangMemproses != null
                        ? null
                        : () => _ambilBerkas(jenis),
                  ),
                ),
                if (jenis != 'video') const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Foto otomatis dikompres + diberi cap waktu & nama petugas, dan '
            'disalin ke penyimpanan internal (aman walau aplikasi ditutup). '
            'Foto stand ikut jadi bukti pembacaan resmi saat verifikasi.',
            style: theme.textTheme.muted.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 16),

          // ── No. HP pelanggan (bill_nohp Aurora — boleh diperbarui di
          //    tempat saat pelanggan memberi nomor baru)
          Text('No. HP Pelanggan', style: theme.textTheme.small),
          const SizedBox(height: 6),
          ShadInput(
            controller: _kontrolNoHp,
            placeholder: const Text(
              'Perbarui bila pelanggan memberi nomor baru',
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(15),
            ],
          ),
          const SizedBox(height: 12),

          // ── Usulan dari lapangan (bill_perubahan + bill_reqnourutbaru)
          Text(
            'Usulan Perubahan Data (opsional)',
            style: theme.textTheme.small,
          ),
          const SizedBox(height: 6),
          ShadInput(
            controller: _kontrolPerubahan,
            placeholder: const Text(
              'Contoh: nama di persil beda / rumah sudah dibongkar…',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 20),

          if (_galat != null) ...[
            ShadAlert.destructive(
              icon: const Icon(CupertinoIcons.exclamationmark_circle),
              title: const Text('Tidak tersimpan'),
              description: Text(_galat!),
            ),
            const SizedBox(height: 12),
          ],
          ShadButton(
            onPressed: _mengirim || p.sudahDicatat ? null : _simpan,
            backgroundColor: const Color(AppEmerald.c600),
            hoverBackgroundColor: const Color(AppEmerald.c500),
            leading: _mengirim
                ? const SizedBox.square(
                    dimension: 15,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(CupertinoIcons.doc_on_clipboard_fill, size: 17),
            child: Text(
              p.sudahDicatat
                  ? 'Sudah Dicatat Periode Ini'
                  : _mengirim
                  ? 'Menyimpan…'
                  : 'Simpan Hasil Baca',
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotFoto extends StatelessWidget {
  const _SlotFoto({
    required this.ikon,
    required this.label,
    this.path,
    this.pratinjauGambar = true,
    this.memproses = false,
    this.onTap,
  });

  final IconData ikon;
  final String label;

  /// Path berkas yang sudah diambil — null = slot kosong.
  final String? path;

  /// false untuk video: tampilkan penanda terisi, bukan Image.file.
  final bool pratinjauGambar;
  final bool memproses;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final terisi = path != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 84,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: theme.colorScheme.muted,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: terisi
                ? const Color(AppEmerald.c600)
                : theme.colorScheme.border,
          ),
        ),
        child: memproses
            ? const Center(
                child: SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : terisi
            ? Stack(
                fit: StackFit.expand,
                children: [
                  if (pratinjauGambar)
                    Image.file(File(path!), fit: BoxFit.cover)
                  else
                    Center(
                      child: Icon(
                        ikon,
                        size: 26,
                        color: const Color(AppEmerald.c600),
                      ),
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      color: const Color(0xB3000000),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.checkmark,
                            size: 10,
                            color: Color(0xFFFFFFFF),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            label,
                            style: const TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    ikon,
                    size: 18,
                    color: theme.colorScheme.mutedForeground,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: theme.textTheme.muted.copyWith(fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Icon(
                    CupertinoIcons.camera,
                    size: 12,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ],
              ),
      ),
    );
  }
}
