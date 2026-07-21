import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/services/backup_lokal.dart';
import '../../../core/utils/formatters.dart';
import 'rbm_dao.dart';
import 'rbm_models.dart';

export 'rbm_models.dart';

/// Sumber data modul Baca Meter (petugas pencatat).
///
/// Alur offline-first mengikuti Aurora legacy yang terbukti di lapangan:
/// unduh paket rute → simpan SQLite → catat offline (antrean/outbox) →
/// sinkronisasi borongan lewat `POST /laporan-harian/batch` (respons
/// per-record; DUPLIKAT = sukses idempoten). Penyimpanan lokal ada di
/// [RbmDao]; setiap penyimpanan catat meninggalkan jejak [BackupLokal].
abstract interface class RuteRepository {
  factory RuteRepository.create() => ApiConfig.isDemo
      ? DemoRuteRepository()
      : ApiRuteRepository(ApiClient.instance);

  /// Unduh paket rute petugas (GET /laporan-harian/rute-saya) lalu simpan
  /// ke SQLite. Bila server tak terjangkau dan cache ada, kembali dari
  /// cache (`dariCache: true`) — petugas tetap bisa bekerja offline.
  /// Baris yang antre di outbox otomatis tampil sudah dicatat.
  Future<RuteSaya> ruteSaya({bool segarkan = true});

  /// Stand resmi terakhir pelanggan (prefill stand lalu). Prefer nilai dari
  /// paket rute (sudah dihitung server); jatuh ke riwayat PembacaanMeter
  /// bila paket tidak memuatnya.
  Future<int?> standTerakhir(PelangganRute pelanggan);

  /// Pencarian lokal (nama / nomor langganan / alamat) — berfungsi penuh
  /// offline, pola `pencarianData` Aurora.
  Future<List<PelangganRute>> cari(String kueri);

  /// Kirim hasil catat lengkap ke antrean verifikasi (POST /laporan-harian;
  /// berkas lewat POST /laporan-harian/foto lebih dulu). Tanpa jaringan →
  /// masuk antrean offline dan dikirim ulang oleh [kirimTertunda].
  ///
  /// [latCatat]/[longCatat] = posisi GPS saat menyimpan (server menghitung
  /// jarak ke titik pelanggan — bukti kehadiran). [fotoPaths] menerima
  /// jenis `stand|segel|rumah|video`.
  Future<HasilCatat> catat({
    required PelangganRute pelanggan,
    required int periode,
    required int standAwal,
    required int standAkhir,
    required String kondisi,
    String kategori = 'ONSITE',
    Map<String, String> fotoPaths = const {},
    double? latCatat,
    double? longCatat,
    bool? isSegel,
    String? usulanPerubahan,
    int? usulanNoUrut,
    String? notelpBaru,
  });

  /// Kirim ulang seluruh antrean offline lewat endpoint batch. Mengembalikan
  /// jumlah laporan yang berhasil terkirim (TERSIMPAN + DUPLIKAT); berhenti
  /// diam-diam saat jaringan masih mati. Baris GAGAL tetap di antrean
  /// dengan pesan servernya.
  Future<int> kirimTertunda();

  /// Jumlah laporan yang masih menunggu sinyal.
  Future<int> jumlahTertunda();

  /// Isi antrean offline (untuk layar status upload ala Aurora: baris
  /// bermasalah kelihatan pesannya, tidak menghilang diam-diam).
  Future<List<CatatTertunda>> daftarTertunda();

  /// Hapus satu baris antrean offline — HANYA dari layar antrean atas
  /// keputusan sadar petugas (itu hasil kerja yang belum terunggah);
  /// baris pelanggan terkait kembali berstatus belum dibaca.
  Future<void> hapusTertunda(int idAntrean);

  /// Seluruh hasil catat akun ini pada periode berjalan: baris antrean
  /// lokal (ANTRE) + laporan di server dengan status verifikasinya —
  /// layar Riwayat, padanan daftar read + today reading Aurora. Offline →
  /// dibangun dari cache lokal.
  Future<List<LaporanSaya>> riwayatSaya();
}

class ApiRuteRepository implements RuteRepository {
  ApiRuteRepository(this._api, {RbmDao? dao, BackupLokal? backup})
    : _dao = dao ?? RbmDao(),
      _backup = backup ?? BackupLokal.instance;

  final ApiClient _api;
  final RbmDao _dao;
  final BackupLokal _backup;

  bool _migrasiSelesai = false;

  /// Impor cache/antrean dari SharedPreferences versi lama — sekali per
  /// proses; antrean adalah hasil kerja petugas, tidak boleh hilang karena
  /// update aplikasi.
  Future<void> _pastikanMigrasi() async {
    if (_migrasiSelesai) return;
    await _dao.migrasiDariPrefs();
    _migrasiSelesai = true;
  }

  // ── Paket rute ────────────────────────────────────────────────────────

  @override
  Future<RuteSaya> ruteSaya({bool segarkan = true}) async {
    await _pastikanMigrasi();
    if (!segarkan) {
      final tersimpan = await _dao.bacaPaket();
      if (tersimpan != null) return tersimpan;
    }
    try {
      final data = await _api.get(
        '${ApiConfig.v1Path}/laporan-harian/rute-saya',
        parse: (data) => data as Map<String, dynamic>,
      );
      final kini = DateTime.now();
      final paket = RuteSaya.fromJson(
        data,
        diunduhPada: kini,
        periodeFallback: periodeCatatSekarang(),
      );
      await _dao.simpanPaket(paket, diunduhPada: kini);
      // Baca balik dari DAO supaya status antrean langsung diterapkan.
      return (await _dao.bacaPaket()) ?? paket;
    } on ApiException catch (e) {
      // Server tak terjangkau → pakai unduhan terakhir. Error lain (401,
      // 403, dst.) tetap dilempar — itu bukan soal sinyal.
      if (e.status != 0) rethrow;
      final tersimpan = await _dao.bacaPaket();
      if (tersimpan == null) rethrow;
      return tersimpan;
    }
  }

  @override
  Future<List<PelangganRute>> cari(String kueri) => _dao.cari(kueri);

  @override
  Future<int?> standTerakhir(PelangganRute pelanggan) async {
    if (pelanggan.standLalu != null) return pelanggan.standLalu;
    if (pelanggan.riwayat.isNotEmpty) return pelanggan.riwayat.first.standAkhir;
    try {
      final riwayat = await _api.getList(
        '${ApiConfig.v1Path}/pembacaan',
        query: {'pelangganId': pelanggan.id, 'pageSize': 1},
        parseRow: (row) => row,
      );
      if (riwayat.rows.isEmpty) return null;
      return (riwayat.rows.first['standAkhir'] as num?)?.toInt();
    } on ApiException catch (e) {
      if (e.status == 0) return null; // offline: prefill saja yang hilang
      rethrow;
    }
  }

  // ── Kirim hasil catat ─────────────────────────────────────────────────

  @override
  Future<HasilCatat> catat({
    required PelangganRute pelanggan,
    required int periode,
    required int standAwal,
    required int standAkhir,
    required String kondisi,
    String kategori = 'ONSITE',
    Map<String, String> fotoPaths = const {},
    double? latCatat,
    double? longCatat,
    bool? isSegel,
    String? usulanPerubahan,
    int? usulanNoUrut,
    String? notelpBaru,
  }) async {
    await _pastikanMigrasi();
    final payload = <String, Object?>{
      'nomorLangganan': pelanggan.nomorLangganan,
      'pelangganId': pelanggan.id,
      'periode': periode,
      'standAwal': standAwal,
      'standAkhir': standAkhir,
      'kondisi': kondisi,
      'kategori': kategori,
      'pemakaianLalu': pelanggan.pemakaianLalu,
      'tanggalCatat': DateTime.now().toUtc().toIso8601String(),
      if (pelanggan.nomorMeter != null) 'nomorMeter': pelanggan.nomorMeter,
      'latCatat': ?latCatat,
      'longCatat': ?longCatat,
      'isSegel': ?isSegel,
      if (usulanPerubahan != null && usulanPerubahan.isNotEmpty)
        'usulanPerubahan': usulanPerubahan,
      'usulanNoUrut': ?usulanNoUrut,
      // Pembaruan No. HP dari lapangan (bill_nohp Aurora) — server yang
      // menerapkannya ke Pelanggan.notelp.
      if (notelpBaru != null && notelpBaru.isNotEmpty) 'notelpBaru': notelpBaru,
      // pemakaian & jarakMeter TIDAK dikirim — server yang menghitung
      // (aturan keras). pencatatId juga tidak — dari akun token.
    };

    // Jejak backup DULU (pola Aurora: catatTxt sebelum yakin terkirim) —
    // apa pun nasib jaringan berikutnya, hasil kerja sudah tercatat.
    await _backup.catatLog(
      periode: periode,
      nomorLangganan: pelanggan.nomorLangganan,
      standAkhir: '$standAkhir',
      kondisi: kondisi,
      longlat: latCatat != null && longCatat != null
          ? '$longCatat,$latCatat'
          : null,
    );

    try {
      await _kirimLaporan(payload, fotoPaths);
      await _dao.tandaiDicatat(pelanggan.nomorLangganan);
      return HasilCatat.terkirim;
    } on ApiException catch (e) {
      if (e.status != 0) rethrow; // 4xx/5xx: bukan soal sinyal, tampilkan.
      await _dao.tambahAntrean(
        CatatTertunda(
          payload: payload,
          fotoPaths: fotoPaths,
          dibuatPada: DateTime.now(),
        ),
      );
      return HasilCatat.tersimpanOffline;
    }
  }

  /// Unggah berkas satu per satu lalu kirim laporan dengan URL-nya.
  Future<void> _kirimLaporan(
    Map<String, Object?> payload,
    Map<String, String> fotoPaths,
  ) async {
    final body = await _payloadDenganUrlBerkas(payload, fotoPaths);
    await _api.post(
      '${ApiConfig.v1Path}/laporan-harian',
      body: body,
      parse: (_) {},
    );
  }

  static const _namaFieldUrl = {
    'stand': 'fotoStandUrl',
    'segel': 'fotoSegelUrl',
    'rumah': 'fotoRumahUrl',
    'video': 'videoUrl',
  };

  Future<Map<String, Object?>> _payloadDenganUrlBerkas(
    Map<String, Object?> payload,
    Map<String, String> fotoPaths,
  ) async {
    final hasil = {...payload};
    for (final e in fotoPaths.entries) {
      final field = _namaFieldUrl[e.key];
      if (field == null) continue;
      final url = await _unggahBerkas(
        nomorLangganan: payload['nomorLangganan'] as String,
        periode: (payload['periode'] as num).toInt(),
        jenis: e.key,
        path: e.value,
      );
      if (url != null) hasil[field] = url;
    }
    return hasil;
  }

  /// null = berkas lokal sudah tidak ada (mis. cache picker terhapus) —
  /// laporan tetap dikirim tanpa berkas itu, jangan gagal total.
  Future<String?> _unggahBerkas({
    required String nomorLangganan,
    required int periode,
    required String jenis,
    required String path,
  }) async {
    final MultipartFile berkas;
    try {
      berkas = await MultipartFile.fromFile(path);
    } on Object {
      return null;
    }
    final hasil = await _api.postMultipart(
      '${ApiConfig.v1Path}/laporan-harian/foto',
      form: FormData.fromMap({
        'nomorLangganan': nomorLangganan,
        'periode': periode,
        'jenis': jenis,
        'foto': berkas,
      }),
      parse: (data) => data as Map<String, dynamic>,
    );
    return hasil['url'] as String?;
  }

  // ── Antrean offline → sinkronisasi batch ──────────────────────────────

  @override
  Future<int> kirimTertunda() async {
    await _pastikanMigrasi();
    final antre = await _dao.daftarAntrean();
    if (antre.isEmpty) return 0;

    // Tahap 1: unggah berkas tiap baris (nama deterministik di server —
    // unggah ulang menimpa, bukan menggandakan). Sinyal putus di tengah →
    // berhenti; antrean utuh untuk percobaan berikutnya.
    final siap = <CatatTertunda>[];
    final payloads = <Map<String, Object?>>[];
    try {
      for (final entri in antre) {
        payloads.add(
          await _payloadDenganUrlBerkas(entri.payload, entri.fotoPaths),
        );
        siap.add(entri);
      }
    } on ApiException catch (e) {
      if (e.status != 0) rethrow;
      if (siap.isEmpty) return 0; // masih offline total
    }

    // Tahap 2: panggilan batch — kontrak per-record, satu baris bermasalah
    // tidak membatalkan yang lain (pola dev_store_data Aurora). Server
    // membatasi 300 baris per panggilan, jadi antrean panjang (petugas
    // seharian penuh offline — Aurora memakai ambang 500) dipecah beruntun;
    // sinyal putus di tengah aman: baris yang belum terjawab tetap antre.
    const maksPerBatch = 300;
    final perRecord = <Map<String, dynamic>>[];
    try {
      for (var awal = 0; awal < payloads.length; awal += maksPerBatch) {
        final potong = payloads.sublist(
          awal,
          awal + maksPerBatch > payloads.length
              ? payloads.length
              : awal + maksPerBatch,
        );
        final hasil = await _api.post(
          '${ApiConfig.v1Path}/laporan-harian/batch',
          body: {'laporan': potong},
          parse: (data) => data as Map<String, dynamic>,
        );
        perRecord.addAll(
          (hasil['hasil'] as List? ?? const [])
              .whereType<Map<String, dynamic>>(),
        );
      }
    } on ApiException catch (e) {
      if (e.status != 0) rethrow;
      if (perRecord.isEmpty) return 0; // masih offline — coba lagi nanti
      // sebagian batch sempat terjawab — proses yang ada.
    }

    var terkirim = 0;
    for (var i = 0; i < siap.length; i++) {
      final entri = siap[i];
      final status = i < perRecord.length
          ? perRecord[i]['status'] as String?
          : null;
      // TERSIMPAN dan DUPLIKAT sama-sama berarti server sudah memegang
      // laporan ini (DUPLIKAT = unggahan ulang setelah sinyal putus).
      if (status == 'TERSIMPAN' || status == 'DUPLIKAT') {
        if (entri.idAntrean != null) await _dao.hapusAntrean(entri.idAntrean!);
        await _dao.tandaiDicatat(entri.nomorLangganan);
        terkirim++;
      } else {
        final pesan =
            (i < perRecord.length ? perRecord[i]['pesan'] as String? : null) ??
            'Baris ditolak server.';
        if (entri.idAntrean != null) {
          await _dao.tandaiGagal(entri.idAntrean!, pesan);
        }
        await _backup.catatError('batch gagal ${entri.nomorLangganan}: $pesan');
      }
    }
    return terkirim;
  }

  @override
  Future<int> jumlahTertunda() async {
    await _pastikanMigrasi();
    return _dao.jumlahAntrean();
  }

  @override
  Future<List<CatatTertunda>> daftarTertunda() async {
    await _pastikanMigrasi();
    return _dao.daftarAntrean();
  }

  @override
  Future<void> hapusTertunda(int idAntrean) async {
    await _pastikanMigrasi();
    await _dao.hapusAntrean(idAntrean);
  }

  // ── Riwayat hasil catat saya ──────────────────────────────────────────

  @override
  Future<List<LaporanSaya>> riwayatSaya() async {
    await _pastikanMigrasi();
    final periode = periodeCatatSekarang();
    try {
      var pencatatId = (await _dao.bacaPaket())?.pencatatId;
      // Instal baru tanpa cache: unduh paket dulu — sekaligus tahu
      // pencatatId untuk filter server.
      pencatatId ??= (await ruteSaya()).pencatatId;
      if (pencatatId == null) return _riwayatLokal(periode);
      final hasil = await _api.getList(
        '${ApiConfig.v1Path}/laporan-harian',
        query: {'pencatatId': pencatatId, 'periode': periode, 'pageSize': 300},
        parseRow: LaporanSaya.fromJson,
      );
      // Baris yang masih antre di perangkat belum ada di server —
      // digabung supaya riwayat = seluruh hasil kerja, terkirim atau belum.
      return [...await _antreSebagaiRiwayat(), ...hasil.rows];
    } on ApiException catch (e) {
      if (e.status != 0) rethrow;
      return _riwayatLokal(periode);
    }
  }

  Future<List<LaporanSaya>> _antreSebagaiRiwayat() async => [
    for (final entri in await _dao.daftarAntrean())
      LaporanSaya(
        nomorLangganan: entri.nomorLangganan,
        periode: entri.periode,
        standAwal: (entri.payload['standAwal'] as num?)?.toInt(),
        standAkhir: (entri.payload['standAkhir'] as num?)?.toInt(),
        kondisi: entri.payload['kondisi'] as String?,
        tanggalCatat: DateTime.tryParse(
          entri.payload['tanggalCatat'] as String? ?? '',
        ),
        statusVerif: 'ANTRE',
        pesanGagal: entri.pesanGagal,
      ),
  ];

  /// Riwayat versi offline: antrean + baris paket yang sudah tercatat
  /// (detail laporannya ikut ter-cache dari unduhan rute terakhir).
  Future<List<LaporanSaya>> _riwayatLokal(int periode) async {
    final antre = await _antreSebagaiRiwayat();
    final nomorAntre = {for (final a in antre) a.nomorLangganan};
    final paket = await _dao.bacaPaket();
    return [
      ...antre,
      for (final p in paket?.pelanggan ?? const <PelangganRute>[])
        if (p.sudahDicatat && !nomorAntre.contains(p.nomorLangganan))
          LaporanSaya(
            id: p.laporan?['id'] as String?,
            nomorLangganan: p.nomorLangganan,
            namaPelanggan: p.nama,
            periode: periode,
            standAwal: p.standLalu,
            standAkhir: (p.laporan?['standAkhir'] as num?)?.toInt(),
            kondisi: p.laporan?['kondisi'] as String?,
            tanggalCatat: DateTime.tryParse(
              p.laporan?['tanggalCatat'] as String? ?? '',
            ),
            statusVerif: 'MENUNGGU',
          ),
    ];
  }
}

/// Rute contoh R-042 untuk mode demo — termasuk baris yang sudah dicatat
/// supaya progres rute terlihat.
class DemoRuteRepository implements RuteRepository {
  static final List<PelangganRute> _rute = _buatRuteAwal();

  static List<PelangganRute> _buatRuteAwal() {
    PelangganRute p(
      int urutan,
      String nomor,
      String nama,
      String alamat,
      String meter,
      int standLalu,
      int pemakaianLalu, {
      bool sudah = false,
      String ruteKode = 'R-042',
    }) => PelangganRute(
      id: 'demo-$nomor',
      nomorLangganan: nomor,
      nama: nama,
      alamat: alamat,
      nomorMeter: meter,
      meterId: 'demo-meter-$nomor',
      ruteKode: ruteKode,
      urutan: urutan,
      noUrutRute: urutan,
      standLalu: standLalu,
      pemakaianLalu: pemakaianLalu,
      status: 'AKTIF',
      sudahDicatat: sudah,
    );

    return [
      p(
        1,
        '00000100119',
        'ASEP SURYADI',
        'Jl. Badak Singa No. 12',
        'WM-88121',
        1162,
        17,
        sudah: true,
      ),
      p(
        2,
        '00000100253',
        'RINA MARLINA',
        'Jl. Badak Singa No. 14',
        'WM-88134',
        845,
        22,
        sudah: true,
      ),
      p(
        3,
        '00000100307',
        'DADANG SUPRIATNA',
        'Jl. Badak Singa No. 18',
        'WM-88160',
        2210,
        19,
      ),
      p(
        4,
        '00000100415',
        'EUIS KURNIASIH',
        'Jl. Cisitu Lama No. 3',
        'WM-88177',
        530,
        12,
      ),
      p(
        5,
        '00000100522',
        'YAYAN HERYANA',
        'Jl. Cisitu Lama No. 7',
        'WM-88191',
        1755,
        25,
      ),
      // Rute kedua (R-043) — untuk menguji alur multi-rute (pengelompokan).
      p(
        6,
        '00000100639',
        'NENG SITI AMINAH',
        'Jl. Cisitu Lama No. 11',
        'WM-88205',
        990,
        15,
        ruteKode: 'R-043',
      ),
      p(
        7,
        '00000100744',
        'UJANG ROHMAT',
        'Jl. Cisitu Indah IV No. 2',
        'WM-88218',
        3120,
        31,
        ruteKode: 'R-043',
      ),
      p(
        8,
        '00000100851',
        'LILIS SURYANI',
        'Jl. Cisitu Indah IV No. 6',
        'WM-88229',
        640,
        9,
        ruteKode: 'R-043',
      ),
    ];
  }

  @override
  Future<RuteSaya> ruteSaya({bool segarkan = true}) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    RuteRingkas ringkas(String id, String kode, int urutan) {
      final baris = _rute.where((p) => p.ruteKode == kode);
      return RuteRingkas(
        id: id,
        kode: kode,
        seksiCater: 'Seksi Cater Bandung Utara',
        urutan: urutan,
        target: baris.length,
        terbaca: baris.where((p) => p.sudahDicatat).length,
      );
    }

    return RuteSaya(
      // Dua rute demo yang "ditugaskan" ke akun ini (di app nyata: dari admin
      // lewat halaman Pemetaan Rute).
      ruteKode: 'R-042',
      rutes: [ringkas('demo-r042', 'R-042', 0), ringkas('demo-r043', 'R-043', 1)],
      seksiCater: 'Seksi Cater Bandung Utara',
      periode: periodeCatatSekarang(),
      target: _rute.length,
      terbaca: _rute.where((p) => p.sudahDicatat).length,
      pelanggan: List.of(_rute),
      dicatatSaya: _rute.where((p) => p.sudahDicatat).length,
      namaPencatat: 'DEMO',
      pencatatId: 'demo-pencatat',
      diunduhPada: DateTime.now(),
    );
  }

  @override
  Future<int?> standTerakhir(PelangganRute pelanggan) async =>
      pelanggan.standLalu;

  @override
  Future<List<PelangganRute>> cari(String kueri) async {
    final q = kueri.trim().toLowerCase();
    return _rute
        .where(
          (p) =>
              p.nama.toLowerCase().contains(q) ||
              p.nomorLangganan.contains(q) ||
              (p.alamat ?? '').toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Future<HasilCatat> catat({
    required PelangganRute pelanggan,
    required int periode,
    required int standAwal,
    required int standAkhir,
    required String kondisi,
    String kategori = 'ONSITE',
    Map<String, String> fotoPaths = const {},
    double? latCatat,
    double? longCatat,
    bool? isSegel,
    String? usulanPerubahan,
    int? usulanNoUrut,
    String? notelpBaru,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final i = _rute.indexWhere((p) => p.id == pelanggan.id);
    if (i >= 0) _rute[i] = _rute[i].copyWith(sudahDicatat: true);
    return HasilCatat.terkirim;
  }

  @override
  Future<int> kirimTertunda() async => 0;

  @override
  Future<int> jumlahTertunda() async => 0;

  @override
  Future<List<CatatTertunda>> daftarTertunda() async => const [];

  @override
  Future<void> hapusTertunda(int idAntrean) async {}

  @override
  Future<List<LaporanSaya>> riwayatSaya() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final periode = periodeCatatSekarang();
    final status = ['DIVERIFIKASI', 'MENUNGGU'];
    var i = 0;
    return [
      for (final p in _rute.where((p) => p.sudahDicatat))
        LaporanSaya(
          id: 'demo-laporan-${p.nomorLangganan}',
          nomorLangganan: p.nomorLangganan,
          namaPelanggan: p.nama,
          periode: periode,
          standAwal: p.standLalu,
          standAkhir: (p.standLalu ?? 0) + (p.pemakaianLalu ?? 0),
          pemakaian: p.pemakaianLalu,
          kondisi: 'NORMAL',
          tanggalCatat: DateTime.now().subtract(Duration(hours: i * 3)),
          statusVerif: status[(i++) % status.length],
        ),
    ];
  }
}

/// Periode catat berjalan default untuk petugas: bulan kalender saat ini —
/// pencatatan lapangan memang merekam bulan berjalan (berbeda dari dashboard
/// yang memakai periode terakhir yang PUNYA data).
int periodeCatatSekarang() {
  final s = DateTime.now();
  return thblDariDate(DateTime(s.year, s.month));
}
