/// SATU peta label Indonesia untuk semua nilai enum API — jangan memformat
/// enum per layar (aturan FLUTTER.md §10). Kunci = string mentah dari API.
library;

const Map<String, String> labelStatusTagihan = {
  'BELUM_BAYAR': 'Belum Bayar',
  'SUDAH_BAYAR': 'Lunas',
  'JATUH_TEMPO': 'Jatuh Tempo',
  'DIHAPUSKAN': 'Dihapuskan',
};

const Map<String, String> labelStatusLaporan = {
  'MENUNGGU': 'Menunggu',
  'DIVERIFIKASI': 'Diverifikasi',
  'DITOLAK': 'Ditolak',
  'DIGUNAKAN': 'Digunakan',
};

const Map<String, String> labelJenisPengaduan = {
  'KEBOCORAN': 'Kebocoran',
  'AIR_MATI': 'Air Mati',
  'AIR_KERUH': 'Air Keruh',
  'METER_RUSAK': 'Akurasi / Meter Rusak',
  'TAGIHAN_TIDAK_SESUAI': 'Tagihan Tidak Sesuai',
  'KUALITAS_LAYANAN': 'Kualitas Layanan',
  'LAINNYA': 'Lainnya',
};

const Map<String, String> labelStatusPengaduan = {
  'BARU': 'Baru',
  'TERVERIFIKASI': 'Terverifikasi',
  'DITUGASKAN': 'Ditugaskan',
  'MENUJU_LOKASI': 'Menuju Lokasi',
  'DIPROSES': 'Diproses',
  'MENUNGGU_PELANGGAN': 'Menunggu Pelanggan',
  'SELESAI': 'Selesai',
  'DITUTUP': 'Ditutup',
  'DIBUKA_KEMBALI': 'Dibuka Kembali',
  'DITOLAK': 'Ditolak',
};

/// StatusPelanggan (prisma/pelanggan.prisma) — status sambungan pada kartu
/// langganan warga & pratinjau pelanggan.
const Map<String, String> labelStatusPelanggan = {
  'AKTIF': 'Aktif',
  'TUTUP_SEMENTARA': 'Tutup Sementara',
  'DISEGEL': 'Disegel',
  'TUTUP_SPT': 'Tutup SPT',
  'CABUT_PERMANEN': 'Cabut Permanen',
};

const Map<String, String> labelPrioritas = {
  'RENDAH': 'Rendah',
  'NORMAL': 'Normal',
  'TINGGI': 'Tinggi',
  'DARURAT': 'Darurat',
};

/// KondisiCatat — LENGKAP, seluruh 22 nilai enum (prisma/tagihan.prisma),
/// urut: keadaan normal dulu, lalu kelainan meter, lalu kendala kunjungan.
/// Label SELARAS dengan dashboard web (features/dashboard/lib/label.ts).
/// Singkatan warisan sistem lama (BMK/BMB, TTB, MTA, DK, MB) ditampilkan
/// sebagai singkatannya sendiri — kepanjangannya tidak terdokumentasi di
/// data sumber, TIDAK dikarang.
const Map<String, String> labelKondisiMeter = {
  'NORMAL': 'Normal',
  'TIDAK_DIPAKAI': 'Tidak Dipakai',
  'RUMAH_KOSONG': 'Rumah Kosong',
  'STAND_TEMPEL': 'Stand Tempel',
  'STAND_KONSUMEN': 'Stand Konsumen',
  'METER_RUSAK': 'Meter Rusak',
  'METER_MATI_ADA_AIR': 'Meter Mati, Ada Air',
  'METER_MUNDUR': 'Meter Mundur',
  'METER_TERBALIK': 'Meter Terbalik',
  'METER_DALAM_AIR': 'Meter Dalam Air',
  'LOS_METER': 'Los Meter',
  'MUDA_KEMBALI': 'Muda Kembali',
  'BMK_BMB': 'BMK/BMB',
  'TTB': 'TTB',
  'MTA': 'MTA',
  'DK': 'DK',
  'MB': 'MB',
  'TERHALANG': 'Terhalang',
  'TIDAK_ADA_AIR': 'Tidak Ada Air',
  'ADA_ANJING': 'Ada Anjing',
  'REV_PENCATAT': 'Revisi Pencatat',
  'DICABUT': 'Dicabut',
};

/// KategoriPembacaan — cara baca dilakukan (di lokasi / jarak jauh).
const Map<String, String> labelKategoriPembacaan = {
  'ONSITE': 'Di Lokasi (Onsite)',
  'OFFSITE': 'Jarak Jauh (Offsite)',
};

/// Kondisi yang MEMBOLEHKAN stand akhir < stand lalu (aturan bisnis backend;
/// selain ini, stand mundur ditolak 400).
const Set<String> kondisiSahMundur = {
  'METER_RUSAK',
  'METER_MUNDUR',
  'METER_TERBALIK',
  'METER_MATI_ADA_AIR',
  'MUDA_KEMBALI',
  'LOS_METER',
  'DICABUT',
};

String labelDari(Map<String, String> peta, String? kode) =>
    kode == null ? '-' : (peta[kode] ?? kode);
