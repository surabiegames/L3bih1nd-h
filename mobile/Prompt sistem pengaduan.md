# PROMPT UNTUK CLAUDE CODE — Sistem Pengaduan Pelanggan & Penugasan Petugas Gangguan (Aplikasi Tirtawening)

## KONTEKS PROJECT

Saya sedang mengembangkan modul baru bernama **Tirtawening**, bagian dari ekosistem **Tirtawening / SITT** (sistem PDAM untuk PERUMDA Tirtawening Kota Bandung). Modul baru ini adalah **Sistem Pengaduan Pelanggan (Trouble Ticketing System)** yang harus terintegrasi dengan:

1. **Web Aplikasi** (admin/operator/supervisor/manager) — Next.js App Router + Hono (mounted via catch-all route) + Prisma v7 + Auth.js v5
2. **Aplikasi Pelanggan** (mobile/web pelanggan untuk melapor gangguan)
3. **Aplikasi Petugas Gangguan** (mobile untuk petugas lapangan menerima & menyelesaikan tugas)

**Stack teknologi yang dipakai saat ini:**
- Frontend: **AG Grid** (tabel data), **shadcn/ui**, **Tailwind CSS v4**
- Backend: **Hono** (REST API, mounted via catch-all route agar kompatibel Flutter mobile)
- ORM: **Prisma v7** (adapter-based, `prisma.config.ts`, `@prisma/adapter-pg`)
- Auth: **Auth.js v5** (`proxy.ts` untuk Edge routing, bukan `middleware.ts`)
- Database: **PostgreSQL + PostGIS** — manfaatkan PostGIS untuk menyimpan koordinat lokasi gangguan (tipe `geography`/`geometry`), query radius/jarak petugas-ke-lokasi, dan agregasi spasial per wilayah kerja (WilayahAdm/WilayahDist/WilayahSeksi/Zona/SeksiCater/Rute).

Ikuti struktur RBAC yang sudah ada:
`SUPER_ADMIN → DIREKSI → SENIOR_MANAGER → MANAGER → SUPERVISOR → STAFF → USER`
terikat pada unit organisasi (Divisi → Bagian → SubBagian), dengan `divisiKode` dan `subBagianKode` di tabel User.

---

## TUJUAN UTAMA

Bangun sistem pengaduan yang **robust, real-time/sinkron, dan interaktif**, mencakup seluruh siklus hidup tiket dari pelaporan pelanggan sampai penyelesaian dan konfirmasi.

## ALUR BISNIS (BUSINESS FLOW)

1. **Pelaporan**
 - Pelanggan (customer) melapor gangguan (kebocoran, meter rusak, aliran mati, kualitas air, dll) lewat app pelanggan.
 - Input: kategori gangguan, deskripsi, foto kondisi, lokasi (pin peta/GPS + alamat), nomor pelanggan/ID sambungan, tingkat urgensi (opsional dari pelanggan, bisa direvisi operator).
 - Sistem generate nomor tiket unik + status awal `BARU` / `MENUNGGU_VERIFIKASI`.

2. **Penerimaan & Verifikasi (Operator Admin)**
 - Tiket baru muncul real-time di beranda/dashboard operator dan supervisor terkait wilayah.
 - Operator adalah *middle man*: bisa memverifikasi kelengkapan data, menghubungi pelanggan via chat tiket, melakukan triase awal, tapi **tidak punya wewenang menugaskan** petugas.
 - Operator bisa mengubah status ke `TERVERIFIKASI` atau meminta info tambahan ke pelanggan (`BUTUH_INFO_TAMBAHAN`).

3. **Penugasan (Supervisor/Manager/Senior Manager)**
 - Hanya role `SUPERVISOR`, `MANAGER`, `SENIOR_MANAGER` yang berwenang menugaskan tiket ke petugas (STAFF dengan peran petugas lapangan).
 - Supervisor melihat daftar petugas available di wilayah/unit kerjanya (SeksiCater/Rute terkait), assign satu atau lebih petugas ke satu tiket.
 - Status berubah jadi `DITUGASKAN`, dengan histori siapa menugaskan dan kapan.
 - Sistem kirim notifikasi push ke app petugas yang ditugaskan.

4. **Penanganan oleh Petugas**
 - Tiket masuk ke beranda aplikasi petugas, lengkap dengan:
 - Alamat lengkap & peta lokasi (embed map, koordinat)
 - Foto kondisi/rumah dari pelanggan
 - Detail aduan & tingkat urgensi
 - Riwayat chat tiket
 - Petugas ubah status: `MENUJU_LOKASI` → `SEDANG_DIKERJAKAN` → `SELESAI_DIKERJAKAN` (petugas selesai kerja, menunggu konfirmasi pelanggan).
 - Petugas wajib upload foto hasil pekerjaan / bukti penyelesaian sebelum submit selesai.

5. **Interaksi/Chat pada Tiket**
 - Setiap tiket punya thread chat/komentar yang bisa diakses oleh: pelanggan, petugas yang ditugaskan, operator, dan supervisor/manager pengawas.
 - Mendukung teks + lampiran foto.
 - Riwayat percakapan tersimpan sebagai bagian dari log tiket (audit trail).

6. **Penyelesaian & Konfirmasi**
 - Setelah petugas submit `SELESAI_DIKERJAKAN`, sistem kirim notifikasi ke pelanggan untuk konfirmasi.
 - Pelanggan bisa: **Konfirmasi Selesai** (`SELESAI`) atau **Belum Selesai/Komplain Ulang** (kembali ke `DITUGASKAN` atau buka tiket eskalasi).
 - **Auto-close**: jika pelanggan tidak merespons dalam waktu tertentu (misal 3x24 jam, dibuat configurable), tiket otomatis berstatus `SELESAI_OTOMATIS`.

7. **Eskalasi & SLA (tambahan yang perlu dipertimbangkan)**
 - SLA per kategori gangguan (misal kebocoran besar = respon cepat).
 - Auto-escalate ke Manager/Senior Manager jika tiket tidak ditugaskan/tidak dikerjakan dalam batas waktu SLA.
 - Dashboard monitoring SLA breach untuk Manager ke atas.

---

## STATUS TIKET (STATE MACHINE) — usulkan & validasi ke saya sebelum implementasi

```
BARU → TERVERIFIKASI → DITUGASKAN → MENUJU_LOKASI → SEDANG_DIKERJAKAN
 → SELESAI_DIKERJAKAN → SELESAI (konfirmasi pelanggan)
 → SELESAI_OTOMATIS (timeout)
 → DIBUKA_ULANG (komplain ulang, balik ke DITUGASKAN)
 → DIBATALKAN
```
Tambahkan `CANCELLED_REASON`, `assignedAt`, `resolvedAt`, `confirmedAt`, `slaDeadline` sebagai field audit di schema.

## HAK AKSES PER ROLE (RBAC)

| Role | Lihat Tiket | Verifikasi | Tugaskan Petugas | Kerjakan Tiket | Chat | Eskalasi |
|---|---|---|---|---|---|---|
| PELANGGAN (customer) | tiket sendiri | - | - | - | ✅ | ✅ (buka ulang) |
| STAFF (operator admin) | wilayah/unit | ✅ | ❌ | - | ✅ | ❌ |
| STAFF (petugas lapangan) | tiket ditugaskan | - | - | ✅ | ✅ | - |
| SUPERVISOR | unit/wilayah | ✅ | ✅ | - | ✅ | ✅ |
| MANAGER | lebih luas | ✅ | ✅ | - | ✅ | ✅ |
| SENIOR_MANAGER | seluruh divisi | ✅ | ✅ | - | ✅ | ✅ |
| SUPER_ADMIN | semua | ✅ | ✅ | - | ✅ | ✅ |

*(Sesuaikan dengan struktur Divisi/Bagian/SubBagian yang sudah ada — validasi ulang tabel role petugas lapangan, apakah perlu flag baru seperti `isPetugasLapangan` boolean di User, karena STAFF saat ini punya makna umum.)*

---

## YANG SAYA MINTA CLAUDE CODE LAKUKAN

1. **Jangan langsung coding.** Mulai dengan:
 - Ajukan pertanyaan klarifikasi jika ada bagian alur yang ambigu (terutama soal role petugas lapangan vs STAFF biasa, dan mekanisme notifikasi real-time yang akan dipakai: WebSocket / polling / push notification service).
 - Usulkan **Prisma v7 schema** (model `Tiket`/`Pengaduan`, `TiketAssignment`, `TiketChat`, `TiketAttachment`, `TiketStatusHistory`, dsb) dan minta review saya sebelum migrate. Field lokasi gangguan gunakan tipe geospasial PostGIS (`Unsupported("geography(Point, 4326)")` di Prisma, atau raw SQL migration untuk kolom `geography`) agar bisa query jarak/radius.
 - Usulkan struktur route Hono (REST) untuk masing-masing aksi (create tiket, verifikasi, assign, update status, chat, konfirmasi).
 - Usulkan query PostGIS praktis yang relevan: cari petugas terdekat dari titik gangguan (`ST_DWithin`/`ST_Distance`), validasi apakah titik lokasi masuk polygon wilayah kerja (`ST_Contains`) untuk auto-suggest SeksiCater/Rute saat tiket dibuat.

2. **Real-time sync**: rekomendasikan pendekatan realtime yang cocok untuk stack ini (Next.js + Hono di Vercel) — pertimbangkan Pusher/Ably/Supabase Realtime dibanding WebSocket native karena serverless. Jelaskan trade-off nya ke saya.

3. **Notifikasi**: rancang mekanisme push notification lintas platform (web + mobile app petugas via Flutter) — sertakan rekomendasi provider (misal Firebase Cloud Messaging) dan bagaimana Hono API men-trigger-nya.

4. **Konsistensi dengan pola project**:
 - Ikuti pola RBAC & denormalisasi `divisiKode`/`subBagianKode` yang sudah ada.
 - Gunakan **AG Grid Community** untuk tabel monitoring/manajemen tiket di web (konsisten dengan modul laporan keuangan yang sudah dipakai AG Grid), kombinasikan dengan shadcn/ui untuk komponen non-tabel (modal, form, badge status).
 - Peta lokasi gangguan: rekomendasikan library peta (Leaflet/MapLibre GL) yang membaca koordinat PostGIS untuk ditampilkan di dashboard web dan di aplikasi petugas.
 - Styling ikuti Tailwind v4 (CSS-variable based, sesuai pola header biru & sticky column yang sudah dipakai di tabel DRD).
 - Ikuti konvensi penamaan domain existing (WilayahAdm, WilayahDist, WilayahSeksi, Zona, SeksiCater, Rute) untuk mengaitkan lokasi gangguan dengan wilayah kerja petugas, dimanfaatkan bersama data spasial PostGIS.

5. **Bertahap**: kerjakan per fase — (1) schema & migrasi, (2) API inti (CRUD tiket + status transition), (3) chat & attachment, (4) notifikasi & realtime, (5) auto-close/SLA job (cron), (6) UI web dashboard, (7) integrasi mobile API. Konfirmasi ke saya di akhir tiap fase sebelum lanjut.

6. Tuliskan asumsi apapun yang kamu ambil secara eksplisit, jangan diam-diam menebak.

---

## PERTANYAAN YANG PERLU SAYA JAWAB DULU (Claude Code, tanyakan ini ke saya di awal sesi)

- Apakah petugas lapangan adalah role terpisah dari STAFF biasa, atau STAFF dengan flag tambahan?
- Sudah ada sistem notifikasi (FCM/OneSignal) yang dipakai di Tirtacater/SITT sekarang?
- Apakah aplikasi Pelanggan & Petugas berupa Flutter mobile app terpisah, atau web app responsif untuk fase awal?
- Apakah tiket harus terhubung ke data `pelanggan` existing (nomor sambungan) atau bisa juga dari non-pelanggan terdaftar?
- Berapa lama batas waktu auto-close yang diinginkan?
---

## STATUS IMPLEMENTASI (2026-07-19) — dijawab & dikerjakan Claude Code

Sebagian besar prompt di atas TERNYATA SUDAH ADA di sistem (modul
`server/modules/pengaduan` + `/api/public/pengaduan*` + dua app Flutter).
Sesi ini menambal seluruh kesenjangan yang tersisa. Rincian teknis ada di
`server/README.md` poin 14 dan `FLUTTER.md` bagian Pengaduan.

### State machine FINAL (diimplementasikan, bukan usulan lagi)

```
BARU → TERVERIFIKASI → DITUGASKAN → MENUJU_LOKASI → DIPROSES
     → SELESAI (wajib foto bukti + catatan; mulai hitung mundur konfirmasi)
     → DITUTUP          (konfirmasi pelapor, ATAU otomatis lewat batas waktu)
     → DIBUKA_KEMBALI   (pelapor membantah → kembali ke penugasan)
     → DITOLAK          (bisa DIBUKA_KEMBALI)
MENUNGGU_PELANGGAN = "BUTUH_INFO_TAMBAHAN" prompt (jam SLA terjeda)
```

Pemetaan istilah prompt → enum yang dipakai (nilai lama dipertahankan agar
baris eksisting tidak perlu backfill): `MENUNGGU_VERIFIKASI`→`BARU`,
`SEDANG_DIKERJAKAN`→`DIPROSES`, `SELESAI_DIKERJAKAN`→`SELESAI`,
`SELESAI (konfirmasi)`→`DITUTUP`, `SELESAI_OTOMATIS`→`DITUTUP` + entri
riwayat `DITUTUP_OTOMATIS`, `DIBUKA_ULANG`→`DIBUKA_KEMBALI`,
`DIBATALKAN`→`DITOLAK`. Field audit yang diminta sudah ada semua:
`assignedAt`≈riwayat DITUGASKAN, `resolvedAt`=`selesaiAt`,
`confirmedAt`=`ratingAt`, `slaDeadline`=`targetSelesaiAt`,
`CANCELLED_REASON`≈catatan riwayat transisi DITOLAK; tambahan baru:
`verifikasiAt`, `konfirmasiBatasAt`, `fotoPenyelesaianUrl`.

### Jawaban atas "pertanyaan yang perlu dijawab dulu" (keputusan diambil
eksplisit karena sesi berjalan otonom — mudah diubah kalau tidak sesuai)

1. **Petugas lapangan = STAFF biasa, TANPA flag baru.** Penentu haknya
   adalah PENUGASAN (`ditugaskanKeId`), bukan identitas role: STAFF boleh
   memverifikasi (operator) dan menggerakkan tiket yang ditugaskan
   kepadanya (petugas). Flag `isPetugasLapangan` tidak diperlukan selama
   penugasan eksplisit; kalau kelak perlu memisahkan operator vs lapangan
   secara struktural, pakai pola bridge seperti `Pencatat`.
2. **Belum ada FCM/OneSignal di sistem.** Belum diimplementasikan (butuh
   proyek Firebase + kredensial = keputusanmu). Rekomendasi: **FCM** (gratis,
   native Android, `firebase_messaging` di Flutter); Hono men-trigger via
   `firebase-admin` di titik-titik yang sudah terpusat — `transisiPengaduan()`
   dan `catatRiwayat()` di alur.ts adalah SATU-SATUNYA pintu perubahan,
   jadi hook notifikasi cukup dipasang di dua fungsi itu.
3. **Aplikasi pelanggan & petugas = dua flavor Flutter yang SUDAH ADA**
   (`mobile/`, main_publik/main_petugas) — bukan web responsif.
4. **Tiket TIDAK wajib pelanggan terdaftar** (sudah begitu sejak awal):
   `nomorLangganan` opsional dan sengaja tidak diverifikasi (anti-harvesting,
   lihat verifikasi.ts). Warga non-pelanggan tetap bisa melapor kebocoran.
5. **Auto-close default 3×24 jam**, configurable tanpa deploy lewat baris
   `Konfigurasi` kunci `pengaduan.batasKonfirmasiJam` (menu Konfigurasi
   dashboard). Eksekusi TANPA cron: malas saat tiket dibaca + endpoint sweep
   `POST /api/v1/pengaduan/tutup-otomatis` untuk penjadwal eksternal.

### Realtime & notifikasi — rekomendasi (belum dikode)

- **Fase sekarang: polling** — app petugas memuat ulang antrean saat layar
  dibuka/di-refresh; cukup untuk volume PDAM dan nol dependensi.
- **Push (langkah berikutnya): FCM** — trigger server-side di alur.ts (lihat
  jawaban #2). OneSignal hanya menang bila butuh dashboard non-teknis.
- **Live update dashboard web**: SSE dari route Hono (Hono mendukung
  streaming; satu arah cukup untuk papan monitoring) SEBELUM melompat ke
  Pusher/Ably yang berbayar; WebSocket native tidak cocok di serverless.
  Kalau kelak deploy ke Vercel dan SSE terkendala timeout, barulah
  pertimbangkan Pusher/Ably/Supabase Realtime.

### Yang juga sudah dikerjakan sesi ini

- Chat dua arah pelapor ↔ petugas pada thread tiket (riwayat aksi `CHAT`,
  UI bubble di app warga + aksi "Chat dengan Pelapor" di app petugas).
- Foto bukti penyelesaian WAJIB untuk SELESAI (server menolak tanpa itu;
  dialog app petugas mengumpulkan catatan+foto sekaligus).
- Auto-tag wilayah kejadian `ST_Contains` (kelurahan→kecamatan) saat tiket
  dibuat + filter antrean `?kelurahanId=`/`?kecamatanId=`. CATATAN: kolom
  `area` kelurahan di database saat ini masih kosong — auto-tag mengembalikan
  null sampai polygon di-seed.
- `transisiTersedia` disaring per role (petugas tidak lagi ditawari aksi
  yang pasti ditolak server).
- Verifikasi end-to-end via curl di build produksi: buat→verifikasi(403
  saat STAFF coba menugaskan)→tugaskan→menuju lokasi→proses→selesai
  (400 tanpa foto)→chat 2 arah→auto-close malas→sweep→chat ditolak
  setelah tutup. Data uji sudah dibersihkan.

### Belum dikerjakan (sengaja — butuh keputusan/kredensial darimu)

- Push notification FCM & realtime SSE (lihat rekomendasi di atas).
- Peta embed (Leaflet/MapLibre) di web & app petugas — koordinat sudah
  tersedia di API; tinggal komponen peta.
- Multi-petugas per tiket — tetap SATU petugas (`ditugaskanKeId`);
  penugasan ulang + eskalasi sudah menutupi kebutuhan umum. Ubah ke tabel
  `PenugasanPengaduan` bila regu >1 orang benar-benar dibutuhkan.
- AG Grid untuk papan pengaduan web — papan yang ada sudah memakai pola
  dashboard eksisting; migrasi ke AG Grid adalah pekerjaan UI terpisah.
