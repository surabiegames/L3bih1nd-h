import 'package:flutter_test/flutter_test.dart';
import 'package:wipel5/features/staff/baca_meter/tarif_repository.dart';

/// Uji hitung estimasi uang air progresif — logika `calculateTagihan`
/// Aurora: tiap blok konsumsi dikenai harganya sendiri.
void main() {
  // Struktur blok khas PDAM: 1-10 / 11-20 / 21-30 / 31+ m³.
  const tarif = TarifGolonganMobile(
    kodeAsli: '2A2',
    blok: [
      BlokTarifMobile(
        blok: 1,
        batasAwalM3: 1,
        batasAkhirM3: 10,
        hargaPerM3: 1000,
      ),
      BlokTarifMobile(
        blok: 2,
        batasAwalM3: 11,
        batasAkhirM3: 20,
        hargaPerM3: 2000,
      ),
      BlokTarifMobile(
        blok: 3,
        batasAwalM3: 21,
        batasAkhirM3: 30,
        hargaPerM3: 3000,
      ),
      BlokTarifMobile(
        blok: 4,
        batasAwalM3: 31,
        batasAkhirM3: null,
        hargaPerM3: 5000,
      ),
    ],
  );

  test('pemakaian di dalam blok pertama', () {
    expect(estimasiUangAir(tarif, 5), 5 * 1000);
  });

  test('tepat di batas blok pertama', () {
    expect(estimasiUangAir(tarif, 10), 10 * 1000);
  });

  test('melintasi dua blok: 15 m³ = 10×1000 + 5×2000', () {
    expect(estimasiUangAir(tarif, 15), 10 * 1000 + 5 * 2000);
  });

  test(
    'melintasi semua blok: 35 m³ = 10×1000 + 10×2000 + 10×3000 + 5×5000',
    () {
      expect(
        estimasiUangAir(tarif, 35),
        10 * 1000 + 10 * 2000 + 10 * 3000 + 5 * 5000,
      );
    },
  );

  test('blok terakhir tanpa batas atas menampung pemakaian besar', () {
    expect(
      estimasiUangAir(tarif, 100),
      10 * 1000 + 10 * 2000 + 10 * 3000 + 70 * 5000,
    );
  });

  test('pemakaian nol/negatif atau tarif tidak dikenal -> null', () {
    expect(estimasiUangAir(tarif, 0), isNull);
    expect(estimasiUangAir(tarif, -3), isNull);
    expect(estimasiUangAir(null, 10), isNull);
  });
}
