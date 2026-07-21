/// Model modul Baca Meter (RBM) — dipakai repository, DAO SQLite, dan layar.
/// Dipisah dari `rute_repository.dart` supaya `rbm_dao.dart` bisa
/// mengimpornya tanpa impor melingkar.
library;

/// Satu pembacaan resmi masa lalu (unsur `riwayat` di paket rute) — padanan
/// period1..period3 Aurora: bahan menjawab pelanggan yang menanyakan
/// riwayat pemakaiannya di tempat.
class RiwayatBacaan {
  const RiwayatBacaan({
    required this.periode,
    this.standLalu,
    this.standAkhir,
    this.pemakaianM3,
  });

  final int periode;
  final int? standLalu;
  final int? standAkhir;
  final int? pemakaianM3;

  factory RiwayatBacaan.fromJson(Map<String, dynamic> json) => RiwayatBacaan(
    periode: (json['periode'] as num?)?.toInt() ?? 0,
    standLalu: (json['standLalu'] as num?)?.toInt(),
    standAkhir: (json['standAkhir'] as num?)?.toInt(),
    pemakaianM3: (json['pemakaianM3'] as num?)?.toInt(),
  );

  Map<String, Object?> toJson() => {
    'periode': periode,
    'standLalu': standLalu,
    'standAkhir': standAkhir,
    'pemakaianM3': pemakaianM3,
  };
}

/// Satu pelanggan pada rute baca meter petugas (RBM — Rute Baca Meter).
/// Bentuknya mengikuti baris `GET /laporan-harian/rute-saya` dan bisa
/// di-serialisasi (cache unduhan rute untuk kerja offline).
class PelangganRute {
  const PelangganRute({
    required this.id,
    required this.nomorLangganan,
    required this.nama,
    this.alamat,
    this.nomorMeter,
    this.meterId,
    this.ruteKode,
    this.urutan,
    this.noUrutRute,
    this.standLalu,
    this.pemakaianLalu,
    this.status,
    this.notelp,
    this.golonganTarif,
    this.geoLat,
    this.geoLong,
    this.beaBeban,
    this.beaAdmin,
    this.riwayat = const [],
    this.sudahDicatat = false,
    this.laporan,
  });

  /// pelangganId di backend.
  final String id;
  final String nomorLangganan;
  final String nama;
  final String? alamat;
  final String? nomorMeter;

  /// Meter aktif terpasang — dipakai riwayat pembacaan.
  final String? meterId;
  final String? ruteKode;

  /// Nomor urut tampil (server sudah memberi fallback posisi bila
  /// noUrutRute kosong).
  final int? urutan;

  /// Urutan kunjungan RBM resmi (Pelanggan.noUrutRute; null = belum diatur).
  final int? noUrutRute;

  /// Stand resmi bulan lalu — prefill & dasar hitung pemakaian.
  final int? standLalu;

  /// Pemakaian bulan lalu (m³) — dasar peringatan deviasi di layar catat.
  final int? pemakaianLalu;

  /// StatusPelanggan (AKTIF/DISEGEL/…) — ditampilkan, tidak difilter client.
  final String? status;

  /// Telepon pelanggan — Aurora membiarkan petugas memperbaruinya di tempat.
  final String? notelp;

  /// Kode golongan tarif (kodeAsli), mis. "2A2".
  final String? golonganTarif;

  /// Titik pelanggan — untuk jarak GPS live di layar catat.
  final double? geoLat;
  final double? geoLong;

  /// Komponen tetap tagihan terakhir (Rupiah): beban & administrasi. null =
  /// pelanggan belum pernah ditagih → estimasi jatuh ke uang air saja.
  /// Ditambahkan ke estimasi uang air progresif di layar catat.
  final int? beaBeban;
  final int? beaAdmin;

  /// Maks. 3 pembacaan resmi terakhir, terbaru dulu.
  final List<RiwayatBacaan> riwayat;

  /// Sudah dicatat pada periode berjalan (laporan sudah dikirim/antre).
  final bool sudahDicatat;

  /// Laporan periode berjalan bila sudah tercatat (id, standAkhir, kondisi,
  /// tanggalCatat dari server) — bahan layar Riwayat saat offline.
  final Map<String, dynamic>? laporan;

  PelangganRute copyWith({bool? sudahDicatat, int? standLalu}) => PelangganRute(
    id: id,
    nomorLangganan: nomorLangganan,
    nama: nama,
    alamat: alamat,
    nomorMeter: nomorMeter,
    meterId: meterId,
    ruteKode: ruteKode,
    urutan: urutan,
    noUrutRute: noUrutRute,
    standLalu: standLalu ?? this.standLalu,
    pemakaianLalu: pemakaianLalu,
    status: status,
    notelp: notelp,
    golonganTarif: golonganTarif,
    geoLat: geoLat,
    geoLong: geoLong,
    beaBeban: beaBeban,
    beaAdmin: beaAdmin,
    riwayat: riwayat,
    sudahDicatat: sudahDicatat ?? this.sudahDicatat,
    laporan: laporan,
  );

  factory PelangganRute.fromJson(
    Map<String, dynamic> json, {
    String? ruteKode,
  }) => PelangganRute(
    id: json['pelangganId'] as String? ?? json['id'] as String? ?? '',
    nomorLangganan: json['nomorLangganan'] as String? ?? '',
    nama: json['nama'] as String? ?? '',
    alamat: json['alamat'] as String?,
    nomorMeter: json['nomorMeter'] as String?,
    meterId: json['meterId'] as String?,
    // Per-baris `ruteKode` (rute-saya multi-rute) menang; fallback ke param
    // untuk kompatibilitas paket lama satu-rute.
    ruteKode: json['ruteKode'] as String? ?? ruteKode,
    urutan: (json['urutan'] as num?)?.toInt(),
    noUrutRute: (json['noUrutRute'] as num?)?.toInt(),
    standLalu: (json['standLalu'] as num?)?.toInt(),
    pemakaianLalu: (json['pemakaianLalu'] as num?)?.toInt(),
    status: json['status'] as String?,
    notelp: json['notelp'] as String?,
    golonganTarif: json['golonganTarif'] as String?,
    geoLat: (json['geoLat'] as num?)?.toDouble(),
    geoLong: (json['geoLong'] as num?)?.toDouble(),
    beaBeban: (json['beaBeban'] as num?)?.toInt(),
    beaAdmin: (json['beaAdmin'] as num?)?.toInt(),
    riwayat: (json['riwayat'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(RiwayatBacaan.fromJson)
        .toList(),
    sudahDicatat: json['sudahDicatat'] == true,
    laporan: json['laporan'] is Map
        ? (json['laporan'] as Map).cast<String, dynamic>()
        : null,
  );

  Map<String, Object?> toJson() => {
    'pelangganId': id,
    'nomorLangganan': nomorLangganan,
    'nama': nama,
    'alamat': alamat,
    'nomorMeter': nomorMeter,
    'meterId': meterId,
    'ruteKode': ruteKode,
    'urutan': urutan,
    'noUrutRute': noUrutRute,
    'standLalu': standLalu,
    'pemakaianLalu': pemakaianLalu,
    'status': status,
    'notelp': notelp,
    'golonganTarif': golonganTarif,
    'geoLat': geoLat,
    'geoLong': geoLong,
    'beaBeban': beaBeban,
    'beaAdmin': beaAdmin,
    'riwayat': [for (final r in riwayat) r.toJson()],
    'sudahDicatat': sudahDicatat,
    'laporan': laporan,
  };
}

/// Ringkasan satu rute dalam beban kerja pencatat (rute-saya multi-rute).
class RuteRingkas {
  const RuteRingkas({
    required this.id,
    required this.kode,
    this.seksiCater,
    this.urutan = 0,
    this.target = 0,
    this.terbaca = 0,
  });

  final String id;
  final String kode;
  final String? seksiCater;
  final int urutan;
  final int target;
  final int terbaca;

  factory RuteRingkas.fromJson(Map<String, dynamic> json) {
    final seksi = json['seksiCater'];
    return RuteRingkas(
      id: json['id'] as String? ?? '',
      kode: json['kode'] as String? ?? '',
      seksiCater: seksi is Map ? seksi['nama'] as String? : null,
      urutan: (json['urutan'] as num?)?.toInt() ?? 0,
      target: (json['target'] as num?)?.toInt() ?? 0,
      terbaca: (json['terbaca'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'kode': kode,
    if (seksiCater != null) 'seksiCater': {'nama': seksiCater},
    'urutan': urutan,
    'target': target,
    'terbaca': terbaca,
  };
}

/// Paket rute petugas: identitas rute + target periode + daftar pelanggan.
/// Ini yang diunduh dari server dan di-cache di perangkat.
///
/// Sejak pemetaan rute many-to-many, satu pencatat bisa memegang BANYAK rute
/// ([rutes], urut kerja). [pelanggan] adalah daftar DATAR lintas semua rute,
/// sudah terurut (urutan rute, lalu noUrutRute). [ruteKode]/[seksiCater]
/// tunggal dipertahankan (rute pertama) untuk kompatibilitas.
class RuteSaya {
  const RuteSaya({
    required this.ruteKode,
    required this.periode,
    required this.target,
    required this.terbaca,
    required this.pelanggan,
    this.rutes = const [],
    this.seksiCater,
    this.dicatatSaya = 0,
    this.namaPencatat,
    this.pencatatId,
    this.diunduhPada,
    this.dariCache = false,
  });

  /// null = akun belum ditugaskan rute (bukan error).
  final String? ruteKode;

  /// Semua rute yang ditugaskan (urut kerja). Kosong = belum ditugaskan.
  final List<RuteRingkas> rutes;

  /// Nama seksi cater rute PERTAMA (dari server) — konteks wilayah di header.
  final String? seksiCater;
  final int periode;

  /// Target pencatatan = jumlah pelanggan rute pada periode ini.
  final int target;
  final int terbaca;
  final List<PelangganRute> pelanggan;

  /// Jumlah laporan yang DICATAT PENCATAT INI pada periode berjalan —
  /// lintas rute (pindah rute tidak menghilangkan hasil kerja).
  final int dicatatSaya;
  final String? namaPencatat;

  /// Id baris Pencatat akun ini — kunci filter `pencatatId` di
  /// GET /laporan-harian (layar Riwayat hasil catat).
  final String? pencatatId;

  /// Kapan paket ini diunduh dari server (waktu perangkat).
  final DateTime? diunduhPada;

  /// true = dibaca dari cache lokal (server tidak terjangkau).
  final bool dariCache;

  factory RuteSaya.fromJson(
    Map<String, dynamic> json, {
    DateTime? diunduhPada,
    bool dariCache = false,
    int? periodeFallback,
  }) {
    // Daftar rute (multi). Fallback ke `rute` tunggal (paket lama) supaya
    // cache/lama tetap terbaca.
    final rutes = (json['rutes'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(RuteRingkas.fromJson)
        .toList();
    final ruteTunggal = json['rute'];
    final kode = rutes.isNotEmpty
        ? rutes.first.kode
        : (ruteTunggal is Map ? ruteTunggal['kode'] as String? : null);
    final seksi = rutes.isNotEmpty
        ? rutes.first.seksiCater
        : (ruteTunggal is Map && ruteTunggal['seksiCater'] is Map
              ? (ruteTunggal['seksiCater'] as Map)['nama'] as String?
              : null);
    final pencatat = json['pencatat'];
    // Per-baris ruteKode dari server menang; param cuma fallback paket lama.
    final rows = (json['pelanggan'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((row) => PelangganRute.fromJson(row, ruteKode: kode))
        .toList();
    return RuteSaya(
      ruteKode: kode,
      rutes: rutes,
      seksiCater: seksi,
      periode: (json['periode'] as num?)?.toInt() ?? periodeFallback ?? 0,
      target: (json['target'] as num?)?.toInt() ?? rows.length,
      terbaca:
          (json['terbaca'] as num?)?.toInt() ??
          rows.where((p) => p.sudahDicatat).length,
      pelanggan: rows,
      dicatatSaya: (json['dicatatSaya'] as num?)?.toInt() ?? 0,
      namaPencatat: pencatat is Map
          ? pencatat['namaLapangan'] as String?
          : null,
      pencatatId: pencatat is Map ? pencatat['id'] as String? : null,
      diunduhPada: diunduhPada,
      dariCache: dariCache,
    );
  }

  Map<String, Object?> toJson() => {
    'rute': ruteKode == null
        ? null
        : {
            'kode': ruteKode,
            if (seksiCater != null) 'seksiCater': {'nama': seksiCater},
          },
    'rutes': [for (final r in rutes) r.toJson()],
    'pencatat': namaPencatat == null && pencatatId == null
        ? null
        : {'namaLapangan': namaPencatat, 'id': pencatatId},
    'periode': periode,
    'target': target,
    'terbaca': terbaca,
    'dicatatSaya': dicatatSaya,
    'pelanggan': [for (final p in pelanggan) p.toJson()],
  };

  RuteSaya salinDenganPelanggan(List<PelangganRute> rows) => RuteSaya(
    ruteKode: ruteKode,
    rutes: rutes,
    seksiCater: seksiCater,
    periode: periode,
    target: target,
    terbaca: rows.where((p) => p.sudahDicatat).length,
    pelanggan: rows,
    dicatatSaya: dicatatSaya,
    namaPencatat: namaPencatat,
    pencatatId: pencatatId,
    diunduhPada: diunduhPada,
    dariCache: dariCache,
  );
}

/// Satu baris riwayat hasil catat AKUN INI (layar Riwayat — padanan
/// `tv_today_reading` + daftar read Aurora, ditambah status verifikasi
/// berjenjang yang tidak dimiliki Aurora).
class LaporanSaya {
  const LaporanSaya({
    this.id,
    required this.nomorLangganan,
    this.namaPelanggan,
    required this.periode,
    this.standAwal,
    this.standAkhir,
    this.pemakaian,
    this.kondisi,
    this.tanggalCatat,
    required this.statusVerif,
    this.catatanVerif,
    this.pesanGagal,
  });

  final String? id;
  final String nomorLangganan;
  final String? namaPelanggan;
  final int periode;
  final int? standAwal;
  final int? standAkhir;
  final int? pemakaian;
  final String? kondisi;
  final DateTime? tanggalCatat;

  /// ANTRE (lokal, belum terkirim) / MENUNGGU / DIVERIFIKASI / DITOLAK.
  final String statusVerif;
  final String? catatanVerif;

  /// Pesan server saat baris antrean ditolak (hanya statusVerif ANTRE).
  final String? pesanGagal;

  bool get hariIni {
    final t = tanggalCatat;
    if (t == null) return false;
    final kini = DateTime.now();
    final lokal = t.toLocal();
    return lokal.year == kini.year &&
        lokal.month == kini.month &&
        lokal.day == kini.day;
  }

  /// Dari baris GET /laporan-harian. Status verifikasi TURUNAN, aturan yang
  /// sama dengan server: MENUNGGU = verifiedAt null; DIVERIFIKASI =
  /// isVerified; DITOLAK = verifiedAt terisi tanpa isVerified.
  factory LaporanSaya.fromJson(Map<String, dynamic> json) {
    final isVerified = json['isVerified'] == true;
    final verifiedAt = json['verifiedAt'];
    return LaporanSaya(
      id: json['id'] as String?,
      nomorLangganan: json['nomorLangganan'] as String? ?? '',
      namaPelanggan: json['namaPelanggan'] as String?,
      periode: (json['periode'] as num?)?.toInt() ?? 0,
      standAwal: (json['standAwal'] as num?)?.toInt(),
      standAkhir: (json['standAkhir'] as num?)?.toInt(),
      pemakaian: (json['pemakaian'] as num?)?.toInt(),
      kondisi: json['kondisi'] as String?,
      tanggalCatat: DateTime.tryParse(json['tanggalCatat'] as String? ?? ''),
      statusVerif: isVerified
          ? 'DIVERIFIKASI'
          : verifiedAt == null
          ? 'MENUNGGU'
          : 'DITOLAK',
      catatanVerif: json['catatanVerif'] as String?,
    );
  }
}

/// Hasil kirim catat: langsung sampai server, atau tersimpan di antrean
/// offline (dikirim otomatis saat sinyal kembali).
enum HasilCatat { terkirim, tersimpanOffline }

/// Satu entri antrean offline: payload laporan + path foto lokal yang
/// belum terunggah.
class CatatTertunda {
  const CatatTertunda({
    required this.payload,
    required this.fotoPaths,
    required this.dibuatPada,
    this.idAntrean,
    this.percobaan = 0,
    this.pesanGagal,
  });

  final Map<String, Object?> payload;

  /// jenis (stand/segel/rumah/video) -> path berkas lokal.
  final Map<String, String> fotoPaths;
  final DateTime dibuatPada;

  /// id baris antrean di SQLite (null sebelum tersimpan).
  final int? idAntrean;

  /// Berapa kali sudah dicoba kirim + pesan gagal terakhir dari server —
  /// bahan layar "antrean" supaya baris bermasalah kelihatan, bukan
  /// menghilang diam-diam.
  final int percobaan;
  final String? pesanGagal;

  String get nomorLangganan => payload['nomorLangganan'] as String? ?? '';
  int get periode => (payload['periode'] as num?)?.toInt() ?? 0;

  factory CatatTertunda.fromJson(Map<String, dynamic> json) => CatatTertunda(
    payload: (json['payload'] as Map?)?.cast<String, Object?>() ?? {},
    fotoPaths: (json['fotoPaths'] as Map?)?.cast<String, String>() ?? {},
    dibuatPada:
        DateTime.tryParse(json['dibuatPada'] as String? ?? '') ??
        DateTime.now(),
  );

  Map<String, Object?> toJson() => {
    'payload': payload,
    'fotoPaths': fotoPaths,
    'dibuatPada': dibuatPada.toIso8601String(),
  };
}
