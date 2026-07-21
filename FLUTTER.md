# Instruksi Membangun Aplikasi Flutter — PERUMDA Tirtawening

Dokumen ini adalah **spesifikasi lengkap untuk AI/developer yang membangun
aplikasi mobile Flutter** yang terkoneksi ke backend ini. Semua yang
dibutuhkan untuk terkoneksi ada di sini — tidak perlu membaca kode backend.
Backend sudah siap: autentikasi Bearer token, endpoint login mobile, dan
seluruh API bisnis sudah teruji dengan request nyata.

## 1. Gambaran sistem

Backend: Next.js + Hono REST API + PostgreSQL/PostGIS, untuk PERUMDA
Tirtawening (perusahaan air minum Kota Bandung). Domain: pelanggan air,
meter, pencatatan meter bulanan, tagihan, pembayaran, pengaduan, laporan
petugas lapangan. **Istilah domain memakai bahasa Indonesia** (pelanggan,
tagihan, pembacaan, pengaduan) — pertahankan istilah yang sama di aplikasi
Flutter agar konsisten dengan API dan pengguna.

Target pengguna aplikasi mobile:
- **Petugas lapangan (role STAFF/SUPERVISOR)**: catat meter, lihat daftar
  pelanggan per rute, laporan harian, verifikasi.
- **Pelanggan (role USER)**: lihat tagihan sendiri, kirim laporan meter
  mandiri berfoto, kirim pengaduan.

## 2. Base URL & environment

```
Dev  : http://<ip-mesin-dev>:3000        (next dev / next start)
Prod : https://<domain-produksi>
```

- Semua endpoint bisnis: `<base>/api/v1/*` — **wajib Bearer token**.
- Pintu masuk mobile: `<base>/api/mobile/auth/*` — tanpa token.
- Endpoint publik tanpa akun: `<base>/api/public/*` (cek tagihan, lapor
  meter, pengaduan — verifikasi identitas nomor langganan + nama).
- Aplikasi native TIDAK terpengaruh CORS. (Flutter Web perlu origin-nya
  didaftarkan di env `CORS_ORIGINS` backend.)
- Simpan base URL di konfigurasi build (mis. `--dart-define=API_BASE_URL=`),
  jangan hardcode.

## 3. Kontrak response (SEMUA endpoint)

Sukses tunggal:
```json
{ "success": true, "data": { ... } }
```
Sukses list (selalu berpaginasi):
```json
{ "success": true, "data": [ ... ],
  "meta": { "page": 1, "pageSize": 20, "total": 22520, "totalPages": 1126 } }
```
Gagal:
```json
{ "success": false, "error": { "code": "NOT_FOUND", "message": "…", "details": [ ... ] } }
```

| HTTP | code | Arti / penanganan di app |
|---|---|---|
| 400 | `BAD_REQUEST` | aturan bisnis dilanggar — tampilkan `message` apa adanya |
| 401 | `UNAUTHORIZED` | token tidak ada/kedaluwarsa → hapus token, arahkan ke login |
| 403 | `FORBIDDEN` | role tidak cukup — sembunyikan fitur ini untuk role tsb |
| 404 | `NOT_FOUND` | data tidak ada |
| 409 | `CONFLICT` | duplikat / sudah diproses (mis. verifikasi dua kali) |
| 422 | `VALIDATION_ERROR` | input salah; `details: [{path, message}]` per field |
| 429 | `RATE_LIMITED` | terlalu sering — tampilkan pesan tunggu |

`message` selalu bahasa Indonesia dan layak tampil langsung ke pengguna.

## 4. Autentikasi

### 4.1 Login username/password

```
POST /api/mobile/auth/login
Content-Type: application/json

{ "identifier": "<email ATAU username>", "password": "..." }
```

Respons sukses:
```json
{
  "success": true,
  "data": {
    "tokenType": "Bearer",
    "accessToken": "eyJhbGciOiJkaXIiLCJlbmMiOiJBMjU2Q0JDLUhTNTEyIiwia2lkIjoi…",
    "expiresInSeconds": 604800,
    "expiresAt": "2026-07-22T21:00:00.000Z",
    "user": {
      "id": "cmr…", "name": "Wiska Prayoga", "email": "…",
      "role": "SUPER_ADMIN", "divisiKode": null, "subBagianKode": null
    }
  }
}
```

Gagal (sebab apa pun — user tak ada / password salah / akun nonaktif):
`401` dengan pesan **selalu sama**: `"Kombinasi identitas dan kredensial
tidak dikenal"`. Jangan mencoba membedakan sebabnya di UI.

Rate limit: 10 percobaan / 15 menit / IP → 429.

### 4.2 Login Google (utama — sebagian besar akun Google-only)

Di Flutter pakai package `google_sign_in`, ambil `idToken`, lalu tukar:

```
POST /api/mobile/auth/google
{ "idToken": "<idToken dari google_sign_in>" }
```

Respons sukses/gagal sama persis dengan 4.1. Hanya email yang **sudah
terdaftar oleh admin** dan berstatus ACTIVE yang diterima — tidak ada
pendaftaran mandiri; jangan buat layar "Sign up".

Setup Google Cloud (lihat §11): client ID Android/iOS harus didaftarkan di
env backend `AUTH_GOOGLE_MOBILE_IDS`.

### 4.3 Memakai token

- Kirim di setiap request `/api/v1/*`:
  `Authorization: Bearer <accessToken>`.
- Token berumur **7 hari**, TIDAK ada endpoint refresh — saat menerima 401,
  hapus token tersimpan dan arahkan ke layar login. Simpan `expiresAt` dan
  login ulang proaktif bila sudah lewat.
- Simpan token di **`flutter_secure_storage`** (Keychain/Keystore), bukan
  SharedPreferences.
- Profil user saat ini: `GET /api/v1/me` → `{ id, name, email, role,
  divisiKode, subBagianKode }`. Panggil saat app start untuk validasi token
  sekaligus mengambil role.

## 5. Konvensi query list (berlaku di semua endpoint list)

| Param | Contoh | Keterangan |
|---|---|---|
| `page`, `pageSize` | `page=1&pageSize=20` | pageSize maks 1000 |
| `sortBy`, `sortDir` | `sortBy=periode&sortDir=desc` | kolom di-whitelist per endpoint; kolom tak dikenal → 422 |
| `q` | `q=asep` | pencarian teks (biasanya nomor langganan / nama) |
| `periode` | `periode=202605` | **integer thbl**: tahun×100+bulan (Mei 2026 = 202605) |

## 6. Tipe data yang tidak boleh salah tangani

1. **`periode` punya DUA bentuk**:
   - Di query & body request: SELALU integer thbl (`202605`).
   - Di response: `Tagihan.periode` & `PembacaanMeter.periode` berupa ISO
     DateTime (`"2026-05-01T00:00:00.000Z"` = tanggal 1 bulan itu, UTC),
     sedangkan `LaporanHarianPetugas.periode` & `LaporanMandiri.periode`
     tetap integer thbl. Buat helper konversi dua arah di Dart.
2. **`nominalTunggak` (Tagihan) adalah STRING**, bukan number — nilainya
   BigInt (bisa ratusan juta). Parse dengan `BigInt.parse`, jangan `int`.
3. Uang lain (`totalTagihan`, `jmlHargaAir`, dst.) integer rupiah biasa.
4. Koordinat pelanggan: `geoLat`/`geoLong` (double, nullable). Nilai
   ~46168.x adalah sampah data legacy — anggap null. Rentang valid
   Indonesia: lat -11…6, lng 95…141.
5. Tanggal murni (jatuh tempo dll.) = tengah malam UTC — tampilkan dengan
   komponen UTC, jangan digeser ke zona lokal (bisa mundur sehari di WIB).
6. `pemakaianM3`/nominal **dihitung server** — client tidak pernah mengirim
   hasil hitungan (jangan kirim `pemakaian`, `totalTagihan`, dsb.).

## 7. Role & akses (RBAC)

Role (menaik): `USER` (pelanggan) → `STAFF` → `SUPERVISOR` → `MANAGER` →
`SENIOR_MANAGER` → `DIREKSI` → `SUPER_ADMIN`. Grup kumulatif: STAFF_UP,
SUPERVISOR_UP, MANAGEMENT_UP, ADMIN.

Server selalu menegakkan sendiri (403). Di app, pakai `role` dari `/me`
hanya untuk **menyembunyikan menu** yang pasti ditolak:
- Hampir semua GET butuh STAFF_UP → pelanggan (USER) TIDAK bisa membaca
  data pelanggan lain; fitur pelanggan cukup: kirim laporan mandiri
  (`POST /laporan-mandiri`), kirim pengaduan (`POST /pengaduan`),
  ganti password sendiri (`PATCH /users/:id/password`), dan `/me`.
- Verifikasi laporan harian: SUPERVISOR_UP. Verifikasi laporan mandiri:
  STAFF_UP.

## 8. Katalog endpoint utama

Semua di bawah `/api/v1`, semua respons memakai envelope §3.

### 8.1 Untuk aplikasi petugas lapangan

**Pelanggan**
- `GET /pelanggan?q=&page=&pageSize=` — daftar/cari pelanggan
  (q: nomor langganan/nama). Baris berisi `nomorLangganan` (11 digit),
  `nama`, `alamat`, `status`, relasi wilayah, `geoLat/geoLong`.
- `GET /pelanggan/:id` — detail.
- `GET /pelanggan/near?lat=&lng=&radiusM=` — pelanggan terdekat dari titik
  GPS petugas (PostGIS).

**Meter**
- `GET /meter?pelangganId=&isAktif=true` — meter pelanggan; satu yang
  `isAktif` adalah meter terpasang sekarang, sisanya histori.

**Pembacaan meter resmi**
- `GET /pembacaan?meterId=&pelangganId=&periode=&pageSize=` — riwayat;
  urutan default periode desc → `pageSize=1` = pembacaan terakhir (dipakai
  untuk prefill stand lalu).
- `POST /pembacaan` — buat pembacaan resmi langsung (STAFF_UP):
  ```json
  { "meterId": "…", "periode": 202607, "standLalu": 120, "standAkhir": 135,
    "blokTarif": 1, "kondisi": "NORMAL", "kategori": "ONSITE",
    "tanggalCatat": "2026-07-15T09:00:00Z", "fotoBukti": "https://…" }
  ```
  Server menghitung `pemakaianM3`. `standAkhir < standLalu` ditolak 400
  kecuali `kondisi` termasuk yang sah mundur (METER_RUSAK, METER_MUNDUR,
  METER_TERBALIK, METER_MATI_ADA_AIR, MUDA_KEMBALI, LOS_METER, DICABUT).
  Satu meter satu baris per periode → kirim ganda = 409.

**Rute Baca Meter (RBM) petugas — paket unduhan rute**
- `GET /laporan-harian/rute-saya?periode=` — rute yang ditugaskan ke akun
  token (alur: User → `Pencatat.userId` → **`PenugasanRute`**, dipetakan admin
  di dashboard web di halaman **Pemetaan Rute**). Satu pencatat bisa memegang
  **banyak rute** (berurut); `pelanggan` adalah daftar DATAR lintas semua rute,
  sudah terurut (urutan rute kerja → `noUrutRute` dalam rute). `periode`
  opsional, default bulan kalender berjalan. Respons:
  ```json
  { "pencatat": { "id": "…", "namaLapangan": "IWAN" },
    "rute": { "id": "…", "kode": "KC201",
              "seksiCater": { "kode": "SC-01", "nama": "Seksi Cater …" } },
    "rutes": [ { "id": "…", "kode": "KC201",
                 "seksiCater": { "kode": "SC-01", "nama": "…" },
                 "urutan": 0, "target": 42, "terbaca": 17 } ],
    "periode": 202607, "target": 42, "terbaca": 17, "dicatatSaya": 20,
    "pelanggan": [ {
      "pelangganId": "…", "nomorLangganan": "00408700794",
      "nama": "…", "alamat": "…", "rt": "006", "rw": "002",
      "status": "AKTIF", "notelp": null, "geoLat": null, "geoLong": null,
      "golonganTarif": "2A2", "ruteId": "…", "ruteKode": "KC201",
      "urutan": 1, "noUrutRute": 1,
      "meterId": "…", "nomorMeter": "042221",
      "standLalu": 10, "pemakaianLalu": 5,
      "beaBeban": 7000, "beaAdmin": 10000,
      "riwayat": [ { "periode": 202606, "standLalu": 5, "standAkhir": 10,
                     "pemakaianM3": 5 } ],
      "sudahDicatat": false, "laporan": null } ] }
  ```
  `rutes` = semua rute yang ditugaskan (urut kerja) dengan target/terbaca
  per rute; `rute` (tunggal, rute pertama) HANYA untuk kompatibilitas klien
  lama — klien baru pakai `rutes` + `pelanggan[].ruteKode` untuk mengelompokkan
  daftar per rute. `target` = TOTAL pelanggan lintas rute; daftar `pelanggan`
  TERURUT (urutan rute → `noUrutRute`; `urutan` = fallback posisi);
  `standLalu`/`pemakaianLalu` dari
  PembacaanMeter resmi terakhir (prefill form catat + dasar peringatan
  deviasi); `riwayat` = maks 3 pembacaan resmi terakhir, terbaru dulu —
  bahan menjawab pelanggan yang menanyakan riwayat pemakaiannya di tempat;
  `sudahDicatat`+`laporan` dari LaporanHarianPetugas periode tsb.
  `beaBeban`/`beaAdmin` = komponen tetap tagihan RESMI terakhir pelanggan
  (null bila belum pernah ditagih) — ditambahkan ke estimasi uang air
  progresif di layar catat untuk estimasi total (tetap ESTIMASI; angka resmi
  dihitung server saat closing).
  `rute.seksiCater` = konteks wilayah untuk header; `dicatatSaya` = jumlah
  laporan yang dicatat akun ini pada periode (lintas rute) — angka "hasil
  kerja saya" di beranda. `rute: null` = akun belum ditugaskan rute
  (tampilkan keadaan "menunggu penugasan admin", BUKAN pilih-rute
  self-service — rute dipetakan admin lewat `PATCH /pencatat/:id`).
  400 = akun belum tertaut ke Pencatat aktif.
  **Cache respons ini di perangkat** — inilah "paket unduhan rute" untuk
  kerja offline di lapangan.
- Akun petugas tidak tertaut? Admin membuat baris Pencatat (namaLapangan +
  userId + ruteId) via dashboard/`POST /api/v1/pencatat`.

**Upload berkas bukti petugas (foto & video)**
- `POST /laporan-harian/foto` — multipart/form-data (STAFF_UP):
  field `nomorLangganan` (11 digit), `periode` (thbl), `jenis`
  (`stand|segel|rumah|video`), berkas `foto` (nama field tetap `foto`
  juga untuk video). Foto: JPG/PNG/WEBP maks 5 MB; video: MP4/WebM maks
  50 MB — isi berkas selalu divalidasi magic bytes. Respons
  `{ jenis, url, publicId }` — panggil per berkas, lalu sertakan `url`-nya
  di `POST /laporan-harian` atau `/batch` (`fotoStandUrl`/`fotoSegelUrl`/
  `fotoRumahUrl`/`videoUrl`). Catatan: pada fallback disk lokal (dev tanpa
  Cloudinary) `url` berbentuk path relatif (`/api/public/berkas/…`) —
  gabungkan dengan base URL saat menampilkan.

**Laporan harian petugas** (laporan mentah pra-verifikasi)
- `GET /laporan-harian?periode=&statusVerif=MENUNGGU|DIVERIFIKASI|DITOLAK&q=&pencatatId=`
- `GET /laporan-harian/stats?periode=` →
  `{ total, menunggu, diverifikasi, ditolak, anomali, ambangAnomali, periodes:[202605,…] }`
  (`periodes` = daftar periode yang punya data, untuk dropdown filter).
- `POST /laporan-harian` — kirim hasil catat lapangan (STAFF_UP):
  `{ nomorLangganan, pelangganId?, periode, standAwal, standAkhir,
     kondisi?, kategori?, nomorMeter?, pemakaianLalu?, tanggalCatat?,
     fotoStandUrl?, fotoSegelUrl?, fotoRumahUrl?, videoUrl?,
     latCatat?, longCatat?, isSegel?, usulanPerubahan?, usulanNoUrut?,
     notelpBaru? }`
  — tiga foto bukti (stand meter, segel, rumah/persil) + video opsional;
  dashboard menampilkannya sebagai tab, dan foto stand ikut ke
  PembacaanMeter resmi saat V3.
  `latCatat`/`longCatat` = posisi GPS saat menyimpan — server menghitung
  `jarakMeter` (jarak ke titik pelanggan, bukti kehadiran; JANGAN dihitung
  client). `isSegel` = kondisi segel yang ditemukan; `usulanPerubahan` =
  teks bebas usulan koreksi data pelanggan; `usulanNoUrut` = usulan nomor
  urut kunjungan baru (admin menerapkannya ke `Pelanggan.noUrutRute` saat
  closing). `notelpBaru` = pembaruan No. HP pelanggan dari lapangan (pola
  `bill_nohp` Aurora) — server menerapkannya langsung ke `Pelanggan.notelp`
  bila laporan tertaut pelanggan; kosong/null diabaikan.
  `pencatatId` TIDAK perlu dikirim — server mengisinya dari akun token
  (jembatan Pencatat.userId); snapshot `namaPelanggan`/`alamatPelanggan`
  juga diisi server dari `pelangganId` bila tidak dikirim. Duplikat
  (nomorLangganan+periode sama) = 409 — jangan kirim ulang, muat ulang
  rute.
- `POST /laporan-harian/batch` — sinkronisasi borongan hasil kerja offline
  (STAFF_UP): `{ "laporan": [ <badan sama seperti POST tunggal>, … ] }`
  (1–300 baris). Respons per-record, BUKAN semua-atau-gagal:
  ```json
  { "total": 42, "tersimpan": 40, "duplikat": 1, "gagal": 1,
    "hasil": [ { "index": 0, "nomorLangganan": "…", "periode": 202607,
                 "status": "TERSIMPAN", "id": "…" },
               { "index": 1, "…": "…", "status": "DUPLIKAT",
                 "pesan": "Laporan periode ini sudah pernah terunggah." } ] }
  ```
  Perlakukan `TERSIMPAN` **dan** `DUPLIKAT` sebagai sukses (tandai baris
  lokal "sudah terunggah") — DUPLIKAT muncul saat unggah ulang setelah
  sinyal putus. Hanya `GAGAL` yang perlu dicoba lagi/dilaporkan.
- Verifikasi BERJENJANG V1→V2→V3 (menggantikan `/verify` lama — endpoint
  itu sudah DIHAPUS). Urutan wajib; pembacaan resmi baru terbentuk di V3:
  - `PATCH /laporan-harian/:id/verif1` (SUPERVISOR_UP):
    `{ "meterId": "…", "blokTarif": 1, "standAkhirRevisi": 120?,
       "kondisi": "DK"?, "catatanVerif": "…"? }` — pemeriksaan awal +
    koreksi stand (revisi TIDAK menimpa `standAkhir` catat) + koreksi
    keterangan/kondisi catat + pilih meter tujuan.
  - `PATCH /laporan-harian/:id/verif2` (MANAGER ke atas):
    `{ "catatanVerif": "…"? }` — validasi tingkat menengah.
  - `PATCH /laporan-harian/:id/verif3` (SENIOR_MANAGER ke atas):
    `{ "catatanVerif": "…"? }` — approve final, laporan naik jadi
    PembacaanMeter resmi (stand = `standAkhirRevisi` bila ada, selain itu
    `standAkhir`).
- `PATCH /laporan-harian/:id/reject` (SUPERVISOR_UP):
  `{ "catatanVerif": "alasan (wajib)" }` — cek ulang; semua ring direset.
- `PATCH /laporan-harian/:id/unverify` — membatalkan SATU tahap terakhir
  (V3→V2→V1→kosong; baris DITOLAK kembali MENUNGGU). Role minimal
  mengikuti ring yang dibatalkan; 409 bila pembacaan sudah dipakai tagihan.
- Field penting per baris: `standAwal`, `standAkhir`, `standAkhirRevisi`,
  `pemakaian`, `persentase` (deviasi % dari bulan lalu; |nilai| >
  `ambangAnomali` = anomali, tandai merah), `kondisi`, `isVerified`,
  `verifiedAt`, `verif1At`/`verif2At`/`verif3At` (+ relasi
  `verif1By`/`verif2By`/`verif3By`), relasi `pelanggan` & `pencatat`.

**Laporan mandiri pelanggan** (foto meter kiriman pelanggan)
- `GET /laporan-mandiri?status=MENUNGGU&periode=&q=`
- `GET /laporan-mandiri/stats?periode=`
- `GET /laporan-mandiri/:id` — termasuk `fotoUrl` (tampilkan gambar),
  `pelanggan`, `pembacaan`.
- `PATCH /laporan-mandiri/:id/verify` (STAFF_UP):
  `{ "meterId": "…", "standLalu": 120, "blokTarif": 1 }`
- `PATCH /laporan-mandiri/:id/reject`:
  `{ "alasanDitolak": "foto buram" }`
- `PATCH /laporan-mandiri/:id/unverify` (STAFF_UP) — batalkan hasil proses:
  kembali `MENUNGGU`; pembacaan resmi yang terbentuk ikut dihapus, 409 bila
  sudah dipakai tagihan.
- Status: `MENUNGGU | DIVERIFIKASI | DITOLAK | DIGUNAKAN`.

**Pengaduan**
- `GET /pengaduan?status=&jenis=&prioritas=&ditugaskanKeId=&milikSaya=true&melanggarSla=true`
  (kelola: SUPERVISOR_UP; create terbuka semua role login). `milikSaya=true`
  = tiket yang ditugaskan ke user token ini — pakai ini untuk layar "Tugas
  saya" petugas lapangan, jangan menyalin id user sendiri ke `ditugaskanKeId`.
  Tiap baris membawa `sla` (lihat di bawah).
- `POST /pengaduan` — `{ jenis, judul, deskripsi, pelapor, kontakPelapor?,
  alamatKejadian?, koordinat?: { lat, lng }, prioritas?, nomorLangganan? }`.
  Jenis: KEBOCORAN, AIR_MATI, AIR_KERUH, METER_RUSAK, TAGIHAN_TIDAK_SESUAI,
  KUALITAS_LAYANAN, LAINNYA. KEBOCORAN **wajib** `koordinat` (422 kalau tidak).
  Prioritas & target SLA diisi server bila tidak dikirim.
- `GET /pengaduan/:id` — detail + `riwayat` (linimasa PENUH, termasuk catatan
  internal) + `transisiTersedia`.
- `GET /pengaduan/near?lat=&lng=` — aduan terdekat (dispatch petugas).
- `GET /pengaduan/statistik` — angka antrean (belum ditugaskan, lewat SLA,
  rata-rata kepuasan).
- `GET /pengaduan/petugas` (SUPERVISOR_UP) — `[{ id, name, role }]` akun aktif,
  bahan dropdown "tugaskan". **Pakai ini, bukan `GET /users`** — `/users`
  dibatasi MANAGEMENT_UP, jadi seorang SUPERVISOR (yang berhak menugaskan)
  akan dapat 403 dan daftar kosong.
- `GET /pengaduan/saya` — tiket yang DIBUAT akun token ini (lewat
  `POST /pengaduan` login ATAU `POST /api/public/pengaduan` saat kebetulan
  login — lihat §8.2). **Terbuka untuk SIAPA PUN yang login, termasuk role
  `USER`** — beda dari `GET /pengaduan` biasa yang SUPERVISOR_UP. Ini yang
  dipakai layar "Laporan Saya" akun warga; jangan disamakan dengan
  `milikSaya=true` di atas (itu "ditugaskan ke saya", untuk petugas).
- `PATCH /pengaduan/:id/tugaskan` — `{ ditugaskanKeId, catatan? }`. Ini
  satu-satunya jalan ke status `DITUGASKAN` — jangan memakai `/status` untuk
  itu, karena tiket akan pindah status tanpa petugas (keadaan separuh jadi).
- `PATCH /pengaduan/:id/status` — `{ status, catatan?, catatanPenyelesaian?,
  fotoPenyelesaianUrl?, fotoPenyelesaianPublicId?, isPublik? }`. **Terbuka
  STAFF_UP** (2026-07-19; dulu SUPERVISOR_UP yang membuat petugas 403):
  role STAFF hanya boleh (a) memverifikasi `BARU → TERVERIFIKASI` (peran
  operator), atau (b) menggerakkan tiket yang DITUGASKAN KEPADANYA lewat
  `MENUJU_LOKASI | DIPROSES | MENUNGGU_PELANGGAN | SELESAI`. **`SELESAI`
  WAJIB `catatanPenyelesaian` + `fotoPenyelesaianUrl`** (unggah dulu via
  `POST /pengaduan/foto`) — berlaku semua role; server juga mengisi
  `konfirmasiBatasAt` (auto-close, lihat bawah). **Menolak `DITUTUP` &
  `DIBUKA_KEMBALI`** (hak pelapor, lewat `/api/public/*`).
- `POST /pengaduan/foto` — multipart `{ nomorTiket, foto }` → `{ url,
  publicId }`. Foto bukti penyelesaian; pola sama `laporan-harian/foto`.
- `POST /pengaduan/:id/chat` — `{ pesan, fotoUrl? }` (STAFF_UP). Pesan CHAT
  dua arah ke pelapor — SELALU publik, tampil sebagai percakapan di halaman
  pelacakan warga (entri riwayat `aksi: "CHAT"`). Ditolak bila tiket
  `DITUTUP`. Sisi pelapor: `POST /api/public/pengaduan/:nomorTiket/chat`.
- `POST /pengaduan/tutup-otomatis` — (SUPERVISOR_UP) sweep tiket `SELESAI`
  yang `konfirmasiBatasAt`-nya lewat → `{ jumlahDitutup }`. Idempoten;
  untuk penjadwal eksternal (cron). Jalur malasnya berjalan otomatis saat
  tiket dibaca lewat endpoint publik.
- Filter list tambahan: `kelurahanId=` / `kecamatanId=` — wilayah kejadian
  hasil auto-tag PostGIS `ST_Contains` dari koordinat saat tiket dibuat
  (null bila polygon kelurahan belum di-seed / titik di luar cakupan).
- `POST /pengaduan/:id/catatan` — `{ catatan, isPublik?, fotoUrl? }` (STAFF_UP).
  Tindak lanjut tanpa mengubah status. **`isPublik` default `false`** —
  kirim `true` secara sadar kalau catatan itu memang untuk dibaca warga.
- `PATCH /pengaduan/:id/eskalasi` — `{ eskalasiKeId, alasan, prioritasBaru? }`.

Status: `BARU | TERVERIFIKASI | DITUGASKAN | MENUJU_LOKASI | DIPROSES |
MENUNGGU_PELANGGAN | SELESAI | DITUTUP | DIBUKA_KEMBALI | DITOLAK`.
**Jangan menyalin matriks transisi ke Dart** — pakai `transisiTersedia` dari
`GET /pengaduan/:id` (sudah DISARING per role pemanggil: STAFF hanya melihat
transisi yang benar-benar boleh ia eksekusi); server yang menegakkannya
(`server/modules/pengaduan/alur.ts`) dan salinan di client pasti menyimpang.

Objek `sla` (dihitung server, jangan dihitung ulang di Dart):
`{ targetResponsAt, targetSelesaiAt, sisaMenit, melanggar, responsTerlambat,
terjeda }`. `sisaMenit` negatif = lewat tenggat; `terjeda: true` = jam SLA
berhenti karena menunggu pelapor.

Nomor tiket berformat `TW-YYMM-XXXXXX` (mis. `TW-2607-4F2A9K`) — 6 karakter
terakhir ACAK, bukan urut. Tampilkan apa adanya; jangan coba menebak/menyusun
sendiri.

**Langganan warga (`/langganan-saya`)** — nomor langganan tertaut akun yang
sedang login. Terbuka untuk role `USER` (tanpa requireRole, semua query
terikat userId token); sumber kartu biodata beranda app publik:
- `GET /langganan-saya` — `[{ id, isUtama, nomorLangganan, nama, alamat
  (disamarkan), rt, rw, status, tarifGolongan, jumlahTagihanBelumBayar,
  totalTunggakan, createdAt }]`, urutan utama dulu.
- `POST /langganan-saya` — `{ nomorLangganan }`; tautkan nomor tambahan
  (maks. 5 per akun, rate-limit per akun; 409 bila sudah tertaut, 404 pesan
  seragam bila nomor tidak ada). Tautan pertama otomatis utama.
- `PATCH /langganan-saya/:id/utama` — jadikan utama.
- `DELETE /langganan-saya/:id` — lepas tautan; tautan TERAKHIR tidak bisa
  dihapus (akun warga selalu punya ≥1 langganan); bila yang dihapus utama,
  tautan tertua tersisa otomatis naik jadi utama.

**Tagihan & DRD**
- `GET /tagihan?pelangganId=&status=&periode=` — tagihan air per pelanggan.
- `GET /tagihan/drd?periode=202605&q=&status=&page=` — Daftar Rekening
  Ditagih lengkap (baris tagihan + `pelanggan.{nomorLangganan,nama,alamat,
  tarifGolongan.kodeAsli,rute.kode}`).
- `GET /tagihan/drd/rekap?periode=202605` →
  ```json
  { "totalRekening": 22520, "totalPemakaianM3": 341111,
    "totalHargaAir": 2374256720, "totalDenda": 0,
    "totalTagihan": 3012396720,
    "perStatus": [ { "status": "BELUM_BAYAR", "jumlah": 16431, "nominal": 2240802230 } ],
    "periodes": [202605] }
  ```
- Status tagihan: `BELUM_BAYAR | SUDAH_BAYAR | JATUH_TEMPO | DIHAPUSKAN`.

**Master tarif (estimasi offline)**
- `GET /tarif?pageSize=100&hanyaAktif=true` — golongan tarif + `blokTarif`
  (`{ blok, batasAwalM3, batasAkhirM3, hargaPerM3 }`) untuk estimasi uang air
  progresif di layar catat. **`hanyaAktif=true` WAJIB dari mobile**: tanpa itu
  respons memuat blok generasi lama (nomor blok ganda saat tarif pernah naik)
  dan estimasi salah hitung. Cache lokal; angka resmi tetap dihitung server.

**Notifikasi & perangkat push (petugas)**
- `POST /api/v1/perangkat/token` — `{ token, platform: "android"|"ios"|"web" }`
  (STAFF_UP). Daftarkan token FCM perangkat; upsert by token (satu baris per
  perangkat). Dipanggil aplikasi setelah login & pemulihan sesi.
- `DELETE /api/v1/perangkat/token` — `{ token }`. Lepas token milik sendiri
  (dipanggil saat logout, SEBELUM Bearer dibuang).
- `GET /api/v1/notifikasi?belumDibaca=&page=&pageSize=` — inbox in-app; meta
  memuat `belumDibaca`. Terikat akun token (tanpa requireRole). Item:
  `{ id, judul, isi, tipe, data, dibacaAt, createdAt }` (`data` = JSON string
  tautan dalam-app, mis. `{ "tipe":"pengaduan","id":"…" }`).
- `PATCH /api/v1/notifikasi/:id/baca` — tandai satu dibaca (milik sendiri).
- `POST /api/v1/notifikasi/baca-semua` — tandai semua dibaca.
- Server menulis notifikasi otomatis saat admin menugaskan rute
  (`PATCH /pencatat/:id`), menugaskan/mengeskalasi tiket pengaduan. Inbox
  BERFUNGSI walau FCM belum aktif (server memakai adapter NotifierLog →
  NotifierFcm; lihat `server/modules/notifikasi/`). Push nyata butuh
  `google-services.json` (mobile) + env `FCM_SERVICE_ACCOUNT` (server).

**Wilayah / geo**
- `GET /wilayah/lookup?lat=&lng=` — reverse lookup titik GPS → wilayah.
- Hierarki referensi: `/wilayah-adm`, `/wilayah-dist`, `/wilayah-seksi`,
  `/zona`, `/seksi-cater`, `/rute`, `/kecamatan`, `/kelurahan`, `/dma`.

**Dashboard ringkasan**: `GET /dashboard/*` (stat agregat siap pakai).

### 8.2 Endpoint publik tanpa login WAJIB (akun warga opsional)

- `POST /api/public/cek-tagihan` — `{ nomorLangganan }` → tagihan (nama tidak
  lagi diminta — keputusan produk 2026-07-15, lihat verifikasi.ts); pesan
  gagal seragam.
- `POST /api/public/lapor-meter` — multipart (foto + data); laporan selalu
  masuk berstatus MENUNGGU, periode ditentukan server.
- `POST /api/public/pengaduan` — menerima JSON **atau** multipart (kirim
  multipart bila melampirkan `foto`; koordinat sebagai field skalar `lat`/`lng`
  di multipart, atau `koordinat: { lat, lng }` di JSON). Balasan:
  `{ nomorTiket, targetSelesaiAt, pesan }`. **Login TETAP opsional** — tapi
  kalau request ini kebetulan membawa `Authorization: Bearer <token>` yang
  valid (atau cookie sesi web), tiket OTOMATIS tertaut ke akun itu dan akan
  muncul di `GET /pengaduan/saya` (§8.1). Tidak mengirim token = tiket
  anonim seperti biasa, hanya bisa dilacak lewat nomor tiket.
- `GET /api/public/pengaduan/:nomorTiket` — status + linimasa PUBLIK + nama
  petugas + `sla` + `bisaDinilai`/`bisaDibukaKembali`/`bisaChat` +
  `konfirmasiBatasAt` + `fotoPenyelesaianUrl` (bukti hasil pekerjaan).
  Tanpa verifikasi identitas: nomor tiket berperan sebagai kunci pembawa,
  aman karena 6 karakter terakhirnya acak. **Auto-close malas**: tiket
  `SELESAI` yang `konfirmasiBatasAt`-nya lewat langsung ditutup di sini
  (status jadi `DITUTUP`, entri riwayat `DITUTUP_OTOMATIS`) — batasnya dari
  konfigurasi `pengaduan.batasKonfirmasiJam`, default 72 jam.
- `POST /api/public/pengaduan/:nomorTiket/chat` — `{ pesan }`. Chat pelapor
  ke petugas; balasannya terbaca sebagai entri riwayat `aksi: "CHAT"` di GET
  di atas (render sebagai bubble percakapan, pisahkan dari linimasa status).
  Ditolak bila tiket sudah `DITUTUP`. Bila request membawa Bearer/cookie
  sesi, nama pengirim memakai nama akun (pola sama dengan POST /pengaduan).
- `POST /api/public/pengaduan/:nomorTiket/konfirmasi` — `{ rating: 1..5,
  komentar? }`. Hanya saat status `SELESAI`; menutup tiket.
- `POST /api/public/pengaduan/:nomorTiket/buka-kembali` — `{ alasan }` (min. 10
  karakter). Hanya saat status `SELESAI`.
- `POST /api/public/auth/register` — `{ nama, email, password (min. 8),
  nomorLangganan (11 digit, WAJIB) }` → `{ id, name, email, pesan }`.
  Pendaftaran akun warga MANDIRI, role selalu `USER`, status langsung
  `ACTIVE` (belum ada verifikasi email — lihat catatan mailer.ts di web).
  `nomorLangganan` diverifikasi ADA (404 pesan seragam bila tidak) dan
  otomatis jadi langganan UTAMA akun (lihat `/langganan-saya` di §8.1);
  pratinjau "ini pelanggan Anda?" sebelum submit bisa memakai
  `GET /api/public/pelanggan/:nomorLangganan`. **Tidak menukar token
  sendiri** — panggil
  `POST /api/mobile/auth/login` (§8.1 mobile) langsung sesudahnya dengan
  kredensial yang sama untuk langsung masuk, sama seperti alur di
  `SesiWarga.daftar()` (`mobile/lib/core/auth/sesi_warga.dart`). Ini SATU-
  SATUNYA jalur signup mandiri di seluruh sistem — akun STAFF ke atas tetap
  admin-provisioned lewat `POST /users` (dashboard web), endpoint ini tidak
  pernah menerima role/status/field organisasi apa pun dari body.
- Semua di-rate-limit per IP — tangani 429.

## 9. Alur fitur yang disarankan

**App petugas lapangan:**
1. Login (Google utama, password cadangan) → simpan token → `GET /me`.
2. Beranda: `laporan-harian/stats` + `laporan-mandiri/stats` periode
   berjalan (kartu: total, menunggu, anomali).
3. Catat meter: cari pelanggan (`/pelanggan?q=` atau `/pelanggan/near`
   dari GPS) → tampilkan meter aktif + pembacaan terakhir → form stand
   akhir + kondisi + foto → `POST /laporan-harian` (atau `POST /pembacaan`
   bila alur langsung resmi).
4. Verifikasi (supervisor): daftar `statusVerif=MENUNGGU`, detail dengan
   foto + histori `GET /pembacaan?pelangganId=&pageSize=3`, aksi
   verify/reject.
5. Pengaduan: daftar + `near` + ubah status.

**App pelanggan:** cek tagihan, kirim laporan meter berfoto, kirim & lacak
pengaduan — cukup via `/api/public/*` (tanpa akun) atau `/api/v1` dengan
akun role USER. Akun OPSIONAL (layanan tetap bisa dipakai anonim), tapi
mendaftar WAJIB menyertakan `nomorLangganan` (jadi langganan utama akun;
kartu biodatanya tampil di beranda): `POST /api/public/auth/register` → langsung
`POST /api/mobile/auth/login` → simpan Bearer token (`SesiWarga`) → tiket
yang dikirim sesudahnya via `POST /api/public/pengaduan` otomatis tertaut,
terlihat di `GET /pengaduan/saya` (layar "Laporan Saya", padanan `/akun` di
web).

## 10. Kerangka teknis Flutter yang disarankan

Paket: `dio` (HTTP), `flutter_secure_storage` (token), `google_sign_in`,
state management bebas (Riverpod/Bloc), `geolocator` (fitur near),
`image_picker` (foto meter).

Klien API terpusat — terjemahkan envelope SEKALI:

```dart
class ApiException implements Exception {
  final int status; final String code; final String message;
  ApiException(this.status, this.code, this.message);
}

class ApiClient {
  ApiClient(this._storage)
      : dio = Dio(BaseOptions(
          baseUrl: const String.fromEnvironment('API_BASE_URL'),
          headers: {'Content-Type': 'application/json'},
        )) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (o, h) async {
        final token = await _storage.read(key: 'accessToken');
        if (token != null) o.headers['Authorization'] = 'Bearer $token';
        h.next(o);
      },
      onError: (e, h) async {
        if (e.response?.statusCode == 401) {
          await _storage.delete(key: 'accessToken');
          // arahkan ke login (lewat auth state / navigator global)
        }
        h.next(e);
      },
    ));
  }
  final Dio dio; final FlutterSecureStorage _storage;

  /// Bongkar envelope { success, data, meta?, error? }.
  T unwrap<T>(Response r, T Function(dynamic data) parse) {
    final body = r.data as Map<String, dynamic>;
    if (body['success'] == true) return parse(body['data']);
    final err = body['error'] as Map<String, dynamic>? ?? {};
    throw ApiException(r.statusCode ?? 0,
        err['code'] as String? ?? 'UNKNOWN',
        err['message'] as String? ?? 'Terjadi kesalahan.');
  }
}
```

Helper periode (wajib ada):

```dart
int thblDariDate(DateTime d) => d.year * 100 + d.month;          // 202605
DateTime dateDariThbl(int thbl) =>
    DateTime.utc(thbl ~/ 100, thbl % 100, 1);
int thblDariIso(String iso) => thblDariDate(DateTime.parse(iso).toUtc());
String labelPeriode(int thbl) { /* "Mei 2026" — pakai intl id_ID */ }
```

Aturan model Dart:
- Semua field relasi nullable (`pelanggan?`, `pencatat?`) — data legacy
  punya baris orphan; tampilkan snapshot `namaPelanggan`/`nomorLangganan`
  bila relasi null.
- `nominalTunggak` → `BigInt?`.
- Jangan memformat enum sendiri per layar — buat satu peta label Indonesia
  (mis. `BELUM_BAYAR` → "Belum dibayar", `MENUNGGU` → "Menunggu") di satu
  file.

## 11. Checklist konfigurasi Google Sign-In

1. Di Google Cloud Console project yang sama dengan web client
   (`AUTH_GOOGLE_ID` backend), buat OAuth Client ID **Android** (package
   name + SHA-1) dan/atau **iOS** (bundle id).
2. Tambahkan client ID tersebut ke env backend:
   `AUTH_GOOGLE_MOBILE_IDS=<android-id>,<ios-id>` (dipisah koma), lalu
   restart backend. Tanpa ini `POST /api/mobile/auth/google` menolak token
   (aud tidak dikenal).
3. Di Flutter, minta `idToken` (bukan hanya accessToken):
   `GoogleSignIn(serverClientId: '<web-client-id>')` di Android agar
   `idToken` ber-`aud` yang konsisten, lalu kirim ke `/api/mobile/auth/google`.
4. Akun Google yang dipakai HARUS sudah didaftarkan admin di sistem
   (dibuat via dashboard/POST /users) — kalau belum, respons 401 seragam.

## 12. Larangan (jangan dilanggar — server akan menolak / merusak data)

1. **Jangan hitung nilai uang/pemakaian di client** lalu mengirimnya —
   server menghitung sendiri dan menolak field itu.
2. **Jangan tampilkan/mem-parse pesan gagal login untuk menebak sebabnya**
   — sengaja seragam (anti user-enumeration). Jangan buat retry otomatis
   agresif; ada rate limit.
3. **Jangan simpan token di penyimpanan biasa** — secure storage saja.
4. **Jangan pakai endpoint `/api/public/*` dari app yang sudah login** —
   itu untuk pengunjung anonim dan ber-rate-limit ketat per IP.
5. **Jangan asumsikan periode berjalan = bulan kalender sekarang** — pakai
   `periodes[0]` dari endpoint `stats`/`rekap` sebagai default (closing
   bulanan bisa tertinggal).
6. **Jangan kirim ulang aksi verify/reject setelah 409** — 409 berarti
   sudah diproses; muat ulang detail.
