import 'package:geolocator/geolocator.dart';

/// Pembungkus GPS untuk alur catat meter — padanan `GPSTracker` Aurora.
///
/// Dipakai layar catat untuk (1) menyimpan posisi petugas saat menyimpan
/// (`latCatat`/`longCatat` di payload laporan) dan (2) menampilkan jarak
/// live ke titik pelanggan (`tv_range_location` di Aurora). Jarak yang
/// MENGIKAT tetap dihitung server (`jarakMeter` via PostGIS) — angka di
/// layar hanya umpan balik untuk petugas.
class LokasiService {
  const LokasiService();

  /// Posisi saat ini. null = layanan lokasi mati atau izin ditolak — biarkan
  /// layar yang memutuskan cara menagihnya ke pengguna (Aurora memaksa lewat
  /// dialog "aktifkan GPS" sebelum boleh mencatat).
  Future<Position?> posisiSekarang({
    Duration batasWaktu = const Duration(seconds: 15),
  }) async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;

    var izin = await Geolocator.checkPermission();
    if (izin == LocationPermission.denied) {
      izin = await Geolocator.requestPermission();
    }
    if (izin == LocationPermission.denied ||
        izin == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: batasWaktu,
        ),
      );
    } on Object {
      // Timeout/gangguan sensor: pakai posisi terakhir yang diketahui —
      // lebih baik posisi 1 menit lalu daripada tidak ada bukti kehadiran.
      return Geolocator.getLastKnownPosition();
    }
  }

  /// Jarak meter antara dua koordinat (haversine, dari geolocator).
  static double jarakMeter(
    double lat1,
    double long1,
    double lat2,
    double long2,
  ) => Geolocator.distanceBetween(lat1, long1, lat2, long2);

  /// Aliran posisi untuk tampilan jarak live di layar catat
  /// (`tv_range_location` Aurora) — update tiap perpindahan ±5 m.
  Stream<Position> aliranPosisi() => Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    ),
  );

  /// Layanan lokasi perangkat menyala? Untuk guard ala Aurora: tanpa GPS
  /// aktif, tombol simpan catat tidak boleh jalan.
  Future<bool> layananAktif() => Geolocator.isLocationServiceEnabled();
}
