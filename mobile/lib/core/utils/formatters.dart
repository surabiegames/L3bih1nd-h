import 'package:intl/intl.dart';

/// ---- Periode (thbl) ----
/// `periode` punya DUA bentuk di API:
///  - di query & body request: SELALU integer thbl (Mei 2026 = 202605);
///  - di response: Tagihan/PembacaanMeter memakai ISO DateTime (tanggal 1 UTC),
///    LaporanHarian/LaporanMandiri tetap integer thbl.
/// Helper ini satu-satunya jalur konversi dua arah — jangan hitung manual.

int thblDariDate(DateTime d) => d.year * 100 + d.month;

DateTime dateDariThbl(int thbl) => DateTime.utc(thbl ~/ 100, thbl % 100, 1);

int thblDariIso(String iso) {
  final d = DateTime.parse(iso).toUtc();
  return thblDariDate(d);
}

/// "202605" / DateTime → "Mei 2026" (intl id_ID; inisialisasi di main()).
String labelPeriode(int thbl) =>
    DateFormat.yMMMM('id_ID').format(dateDariThbl(thbl));

/// ---- Uang ----

final NumberFormat _rupiah = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

String formatRupiah(num nilai) => _rupiah.format(nilai);

String formatRupiahBigInt(BigInt nilai) =>
    'Rp ${NumberFormat.decimalPattern('id_ID').format(nilai)}';

/// ---- Tanggal ----

/// Tanggal murni (jatuh tempo dll.) tersimpan tengah malam UTC — tampilkan
/// dengan komponen UTC, JANGAN digeser ke zona lokal (bisa mundur sehari
/// di WIB).
String formatTanggalUtc(DateTime d) =>
    DateFormat('d MMMM y', 'id_ID').format(d.toUtc());

/// Waktu kejadian (dibuat/diubah) — ini boleh dalam zona lokal pengguna.
String formatWaktuLokal(DateTime d) =>
    DateFormat('d MMM y HH.mm', 'id_ID').format(d.toLocal());

/// ---- Angka meter ----

String formatM3(num m3) =>
    '${NumberFormat.decimalPattern('id_ID').format(m3)} m³';

/// ---- Ukuran berkas ----

/// Ukuran byte ringkas (B/KB/MB) — dipakai indikator penyimpanan antrean
/// foto yang belum terunggah di beranda petugas.
String formatUkuranByte(int byte) {
  if (byte < 1024) return '$byte B';
  final kb = byte / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(kb < 10 ? 1 : 0)} KB';
  final mb = kb / 1024;
  return '${mb.toStringAsFixed(mb < 10 ? 1 : 0)} MB';
}
