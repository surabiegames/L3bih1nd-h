import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wipel5/core/db/database_lokal.dart';
import 'package:wipel5/features/staff/baca_meter/rbm_dao.dart';
import 'package:wipel5/features/staff/baca_meter/rbm_models.dart';

/// Uji DAO terhadap SQLite sungguhan (FFI di host) — perilaku yang dijaga:
/// urutan kunjungan RBM, penerapan status antrean ke paket, dan idempotensi
/// antrean (satu pelanggan satu baris per periode).
void main() {
  late Directory dirUji;
  late RbmDao dao;

  PelangganRute p(String nomor, String nama, {int? urutan}) => PelangganRute(
    id: 'id-$nomor',
    nomorLangganan: nomor,
    nama: nama,
    alamat: 'Jl. Uji',
    urutan: urutan,
  );

  RuteSaya paket(List<PelangganRute> rows) => RuteSaya(
    ruteKode: 'R-001',
    periode: 202607,
    target: rows.length,
    terbaca: 0,
    pelanggan: rows,
  );

  CatatTertunda antre(String nomor) => CatatTertunda(
    payload: {'nomorLangganan': nomor, 'periode': 202607, 'standAkhir': 10},
    fotoPaths: const {},
    dibuatPada: DateTime(2026, 7, 19),
  );

  setUp(() async {
    dirUji = await Directory.systemTemp.createTemp('rbm_dao_uji');
    DatabaseLokal.direktoriOverrideUntukUji = dirUji.path;
    dao = RbmDao();
  });

  tearDown(() async {
    await DatabaseLokal.instance.tutup();
    DatabaseLokal.direktoriOverrideUntukUji = null;
    await dirUji.delete(recursive: true);
  });

  test(
    'paket tersimpan dan terbaca kembali terurut noUrutRute, null di belakang',
    () async {
      await dao.simpanPaket(
        paket([
          p('00000000003', 'TANPA URUTAN'), // urutan null -> paling belakang
          p('00000000002', 'URUTAN DUA', urutan: 2),
          p('00000000001', 'URUTAN SATU', urutan: 1),
        ]),
      );

      final hasil = await dao.bacaPaket();
      expect(hasil, isNotNull);
      expect(hasil!.ruteKode, 'R-001');
      expect(hasil.periode, 202607);
      expect(
        [for (final x in hasil.pelanggan) x.nama],
        ['URUTAN SATU', 'URUTAN DUA', 'TANPA URUTAN'],
      );
    },
  );

  test(
    'unduhan baru mengganti seluruh paket lama (pola deleteAll Aurora)',
    () async {
      await dao.simpanPaket(paket([p('00000000001', 'LAMA')]));
      await dao.simpanPaket(paket([p('00000000009', 'BARU')]));

      final hasil = await dao.bacaPaket();
      expect(hasil!.pelanggan, hasLength(1));
      expect(hasil.pelanggan.single.nama, 'BARU');
    },
  );

  test('baris yang antre di outbox tampil sudahDicatat di paket', () async {
    await dao.simpanPaket(
      paket([
        p('00000000001', 'ANTRE', urutan: 1),
        p('00000000002', 'BELUM', urutan: 2),
      ]),
    );
    await dao.tambahAntrean(antre('00000000001'));

    final hasil = await dao.bacaPaket();
    expect(hasil!.pelanggan[0].sudahDicatat, isTrue);
    expect(hasil.pelanggan[1].sudahDicatat, isFalse);
    expect(hasil.terbaca, 1);
  });

  test(
    'antrean idempoten: catat ulang pelanggan yang sama menimpa, bukan menggandakan',
    () async {
      await dao.tambahAntrean(antre('00000000001'));
      await dao.tambahAntrean(antre('00000000001'));

      expect(await dao.jumlahAntrean(), 1);
    },
  );

  test(
    'tandaiGagal menyimpan pesan server dan menambah hitungan percobaan',
    () async {
      await dao.tambahAntrean(antre('00000000001'));
      final baris = (await dao.daftarAntrean()).single;

      await dao.tandaiGagal(
        baris.idAntrean!,
        'Referensi pelanggan tidak valid.',
      );
      final sesudah = (await dao.daftarAntrean()).single;

      expect(sesudah.percobaan, 1);
      expect(sesudah.pesanGagal, 'Referensi pelanggan tidak valid.');
    },
  );

  test('pencarian lokal menemukan lewat nama, nomor, dan alamat', () async {
    await dao.simpanPaket(
      paket([
        p('00000000001', 'ASEP SURYADI', urutan: 1),
        p('00000000002', 'RINA MARLINA', urutan: 2),
      ]),
    );

    expect(await dao.cari('asep'), hasLength(1));
    expect(await dao.cari('00000000002'), hasLength(1));
    expect(await dao.cari('Jl. Uji'), hasLength(2));
    expect(await dao.cari('tidak-ada'), isEmpty);
  });
}
