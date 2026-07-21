# Prompt untuk Claude Code — Halaman Verifikasi Foto Meter

Build halaman **Verifikasi Meter** untuk project Tirtawening. Ikuti konvensi project yang sudah ada (DataTable pattern via TanStack Table + shadcn/ui, Prisma untuk schema), dengan data fetching lewat REST API Hono agar endpoint yang sama bisa dipakai aplikasi mobile Flutter.

## Konteks project
- Stack: Next.js App Router (frontend) + **Hono** sebagai REST API layer (mounted via `hono/vercel` atau catch-all route) — desain endpoint sebagai REST murni (bukan tRPC) supaya bisa dikonsumsi juga oleh aplikasi Flutter mobile
- Database: **PostgreSQL + PostGIS** extension, Prisma v7 (`prisma.config.ts` untuk DB URL, `@prisma/adapter-pg` untuk adapter instantiation eksplisit). PostGIS dipakai untuk kolom lokasi geografis rumah pelanggan (titik koordinat)
- Data fetching di frontend: gunakan TanStack Query (`useQuery`/`useMutation`) yang memanggil REST endpoint Hono, bukan tRPC hook
- Domain: PembacaanMeter, LaporanHarianPetugas, pelanggan, periode (format YYYYMM integer)
- Kondisi meter enum yang sudah ada: METER_RUSAK, LOS_METER, BMK_BMB — tambahkan varian lain yang relevan (TIDAK_DIPAKAI, STAND_TEMPEL, REV_PENCATAT, DK, MTA, TTB) jika belum ada di schema
- Wilayah hierarchy: WilayahAdm → WilayahDist → WilayahSeksi → Zona → SeksiCater → Rute
- Gunakan warna semantik existing: header biru dengan CSS variable, sticky columns pattern yang sudah dipakai di tabel DRD

## Layout halaman

Dua kolom: panel detail (kiri, lebar tetap ~260-280px, `flex-shrink-0`) dan panel tabel (kanan, `flex-1 min-w-0`), dengan 4 kartu ringkasan statistik di atas keduanya.

### 1. Kartu ringkasan (atas, grid 4 kolom)
- Total laporan
- Terverifikasi (aksen hijau)
- Menunggu (aksen kuning)
- Progres selesai (%)

### 2. Panel kiri — detail & verifikasi pelanggan terpilih
Urutan blok dari atas ke bawah, dipisah divider tipis:
1. Nama + no. pelanggan + badge kondisi (warna sesuai severity)
2. Alamat singkat
3. Grid 3 kolom: stand awal / stand akhir / pakai (m3)
4. Deviasi dari periode lalu (%) dan nama pencatat
5. Mini bar-chart histori pemakaian 3 bulan terakhir (label bulan + nilai m3 di ujung bar)
6. **Peta lokasi rumah pelanggan** — komponen map kecil (tinggi ~140px, collapsible/expandable) yang menampilkan titik koordinat dari kolom PostGIS (`geography(Point, 4326)` pada tabel pelanggan):
   - Marker tunggal di lokasi rumah pelanggan, gunakan Leaflet atau MapLibre GL (ringan, tidak perlu API key berbayar)
   - Tampilkan jarak/rute singkat opsional jika ada titik pencatatan GPS saat foto diambil (bandingkan lokasi pencatatan vs lokasi rumah terdaftar — berguna untuk deteksi kecurangan input tanpa kunjungan lapangan)
   - Tombol kecil "Buka di peta penuh" untuk expand ke modal atau tab baru
7. **Lampiran temuan lapangan — disusun VERTIKAL (list baris), bukan grid sejajar**, agar panel tetap ramping. Mendukung foto DAN video dalam satu list:
   - Setiap baris: thumbnail kecil (40x40px) + label bulan + tipe lampiran (ikon foto atau ikon video) + status ("kosong" / "belum diunggah" / nama file)
   - Baris video ditandai ikon play di atas thumbnail; klik membuka video player (native `<video>` tag atau modal player), bukan image viewer
   - Lampiran periode berjalan diberi aksen warna beda (border/background accent) supaya kontras dari histori bulan lalu
   - Thumbnail foto bisa diklik untuk preview ukuran penuh (modal/lightbox); thumbnail video langsung memutar di modal yang sama
8. Dua tombol aksi ditumpuk vertikal: "Valid" (hijau, submit verifikasi) dan "Cek ulang" (netral, flag untuk petugas lapangan)

### 3. Panel kanan — tabel laporan pencatatan
- Search bar (no. meter / nama petugas) + badge counter "X anomali" (merah, hitung baris dengan deviasi > threshold, misal >50%) + tombol Filter
- Kolom tabel: No. pelanggan, Pencatat, Tgl catat, St. awal, St. akhir, Pakai (m3), Δ% (delta dari bulan lalu), Kondisi (badge, bisa lebih dari satu), Lampiran (ikon foto/video + jumlah), Lokasi (ikon pin, hijau jika titik GPS pencatatan cocok dengan lokasi rumah terdaftar, merah jika selisih jauh — indikasi potensi kecurangan), Status
- Baris dengan anomali (Δ% ekstrem, stand turun, atau stand tidak berubah dengan histori naik) diberi ikon warning kecil di sebelah no. pelanggan
- Baris yang sedang aktif dipilih (sinkron dengan panel kiri) disorot background aksen
- Kolom Δ%: warna merah jika anomali, hijau jika turun wajar, netral jika normal
- Pagination server-side (dataset besar, ribuan baris — lihat contoh 7.518 total)
- Kolom Status: badge "Menunggu" (kuning) / "Terverifikasi" (hijau) / "Perlu cek ulang" (merah)

## Interaksi & state
- Klik baris tabel → load detail pelanggan tsb ke panel kiri (tanpa reload halaman, gunakan client state / query param)
- Tombol "Valid" dan "Cek ulang" di panel kiri memanggil `PATCH /api/pembacaan-meter/:id/verifikasi` (Hono route) untuk update `statusVerifikasi` pada record `PembacaanMeter`, lalu invalidate TanStack Query cache supaya baris tabel ter-update otomatis
- Endpoint yang dibutuhkan minimal:
  - `GET /api/pembacaan-meter?periode=&page=&search=` — list untuk tabel, dengan pagination server-side
  - `GET /api/pembacaan-meter/:id` — detail untuk panel kiri, termasuk lokasi PostGIS (dikonversi ke GeoJSON/lat-lng di response) dan daftar lampiran (foto+video)
  - `PATCH /api/pembacaan-meter/:id/verifikasi` — update status verifikasi
  - Endpoint yang sama harus reusable dari Flutter (auth via Bearer token, bukan session cookie, jika belum ada middleware auth REST-friendly, tambahkan)
- Filter periode (dropdown bulan/tahun) di header halaman, default ke periode berjalan

## Komponen yang perlu dibuat/reuse
- Reuse `DataTable` generic pattern (TanStack Table) yang sudah distandarkan di project untuk tabel kanan
- Komponen baru: `MeterVerificationPanel` (panel kiri), `AttachmentList` (list foto+video vertikal dengan tipe berbeda), `MiniUsageHistoryChart` (bar chart mini 3 bulan), `CustomerLocationMap` (peta kecil PostGIS)
- Gunakan shadcn/ui: Card, Badge, Button, Input, Table (base), Dialog (untuk preview foto/video/peta penuh)
- Library map: Leaflet (`react-leaflet`) atau MapLibre GL — pilih yang lebih ringan untuk embed kecil di panel

## Catatan desain
- Ikuti sentence case, tidak ada gradient/shadow berlebih, konsisten dengan styling table DRD yang sudah ada (header biru CSS variable, sticky column jika perlu)
- Skeleton loading state untuk tabel saat fetching
- Empty state jika foto belum diunggah: ikon placeholder + teks status, bukan kotak kosong tanpa keterangan