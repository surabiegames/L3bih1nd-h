# Audit Modul Pengaduan (Lapor & Lacak Tiket) — Tirtawening

> Dokumen ini adalah hasil review terhadap implementasi mobile (Flutter) modul
> pengaduan publik: `lapor_pengaduan_screen.dart`, `lacak_tiket_screen.dart`,
> `complaint_ticket_model.dart`, `lapor_pengaduan_repository.dart`.
> Tujuan: jadi checklist perbaikan yang bisa dieksekusi langsung, baik di
> backend (Hono) maupun mobile (Flutter), agar web dan mobile tetap sinkron.

## Ringkasan Eksekutif

Arsitektur yang sudah ada **secara prinsip sudah benar**: server sebagai
satu-satunya sumber kebenaran untuk state machine, SLA, dan hak akses aksi.
Client (baik web maupun mobile) hanya menampilkan apa yang dikirim server,
tidak menghitung ulang logika bisnis. Ini pola yang tepat dan sudah lebih
baik dari kebanyakan implementasi SI pengaduan PDAM yang ada di lapangan.

Yang perlu diperbaiki bukan arsitekturnya, tapi **hardening di titik-titik
tertentu** — terutama karena endpoint ini publik (tanpa login) dan pakai
"nomor tiket" sebagai bearer-token implisit.

---

## 🔎 Hasil Verifikasi terhadap Kode Backend + Web (2026-07-20)

> Audit di atas ditulis dari kode Flutter. Setelah diverifikasi ke **kode
> backend (Hono) & web (Next.js) yang sebenarnya** — termasuk `pnpm build`
> lolos + uji end-to-end ke database Neon asli — ternyata **mayoritas
> "celah" sudah tertutup di backend**. Ringkasnya:
>
> - **#1 Rate limiting** — SUDAH ADA di keempat endpoint publik (bukan hanya
>   create). Terbukti live: tepat 30 lookup/IP lalu `429`. Kunci utamanya
>   nomor tiket acak base32 (anti-enumerasi); rate limit lapis kedua.
> - **#2 Idempotency** — celah nyata, **kini SUDAH DIPERBAIKI**: kolom
>   `Pengaduan.clientRequestId` (UUID v4, unik) + short-circuit di
>   `publik.router.ts` + form web mengirim kunci stabil. Terbukti: 3 POST
>   kunci sama → 1 tiket.
> - **#3 Auto-close** — lazy-close saat tiket dibaca SUDAH ADA; kini
>   **cron eksternal di-wire** (`/api/cron/tutup-pengaduan`, dijaga
>   `CRON_SECRET`, `vercel.json`).
> - **#4 Upload** — magic-bytes + batas ukuran server SUDAH ADA. (Strip EXIF
>   masih opsional; Cloudinary membuang metadata pada transformasi.)
> - **#5 Format HP** — kini ada validasi lembut di form web (HP & telepon
>   rumah), dinormalisasi sebelum dikirim.
> - **#6 Draft persisten** — khusus mobile, tetap nice-to-have.

---

## ✅ Apa yang Sudah Benar (jangan diubah)

1. **Server-authoritative state machine.**
   Komentar di `complaint_ticket_model.dart` eksplisit: *"transisiTersedia
   datang dari GET /pengaduan/:id — JANGAN menyalin matriks transisi status
   ke Dart; server yang menegakkannya."* Ini persis prinsip yang saya
   rekomendasikan: satu state machine, bukan diduplikasi client & server.

2. **SLA dihitung server, bukan di Dart.**
   `SlaInfo` cuma menampung hasil (`sisaMenit`, `melanggar`,
   `responsTerlambat`, `terjeda`), tidak menghitung. Ini penting karena
   mencegah client punya jam yang berbeda (clock drift) dari server.

3. **Audit trail publik vs internal dipisah.**
   `riwayat` hanya berisi entri dengan `isPublik=true`. Catatan internal
   petugas tidak pernah keluar ke pelanggan. Ini best practice yang sering
   dilewatkan di implementasi lain.

4. **Pemisahan hak: yang menutup tiket adalah pelapor, bukan petugas.**
   Komentar: *"PATCH status ke DITUTUP dari sisi petugas ditolak
   eksplisit."* Ini selaras dengan pola ITIL/service-desk standar — closure
   confirmation adalah hak pelapor, bukan sepihak petugas. Konsisten di web
   (`aksi-pelapor.tsx`) dan mobile.

5. **Nomor tiket tidak sekuensial.**
   Format `TW-YYMM-XXXXXX` dengan 6 karakter acak dari alfabet 32 karakter
   (`ABCDEFGHJKMNPQRSTUVWXYZ23456789` — sengaja buang huruf/angka yang
   ambigu: I, L, O, 0, 1). Ini mencegah enumerasi tiket orang lain
   (`TW-2607-000001`, `000002`, dst — pola yang sering saya lihat di
   skripsi-skripsi PDAM dan gampang di-scrape).

6. **Anti-harvesting nomor langganan.**
   Nomor langganan sengaja *tidak diverifikasi* di endpoint pengaduan
   supaya endpoint ini tidak bisa dipakai untuk mengecek validitas nomor
   pelanggan orang lain secara masal.

7. **Idempotent UI state untuk foto & retry.**
   Kompresi foto dilakukan manual (bukan andalkan `image_picker`), dengan
   alasan terdokumentasi: sebagian device Android mengabaikan
   `maxWidth`/`imageQuality`. Ini detail kecil tapi menunjukkan sudah
   pernah kena kasus nyata di lapangan, bukan asumsi.

8. **Login opsional, tapi tiket tetap ditautkan ke akun bila sedang login.**
   Pola yang benar: satu endpoint publik untuk semua, server yang
   menentukan penautan (`getSessionUserOpsional()`), bukan dua jalur
   terpisah (guest vs logged-in) yang gampang divergen.

---

## ⚠️ Celah yang Perlu Diperbaiki

### 1. Nomor tiket = bearer token tanpa rate limiting (PRIORITAS TINGGI)

`nomorTiket` dipakai sebagai satu-satunya kunci akses untuk:
- `GET /api/public/pengaduan/:nomorTiket` (lihat status + riwayat)
- `POST .../konfirmasi` (tutup tiket + rating)
- `POST .../buka-kembali`
- `POST .../chat` (baca & tulis percakapan)

6 karakter dari alfabet 32 = ~1 miliar kombinasi per bulan-tahun. Itu besar,
**tapi** tanpa rate limiting di endpoint publik, seseorang bisa
brute-force nomor tiket orang lain dan:
- Membaca alamat kejadian, foto bukti, dan percakapan pelapor lain
- Mengonfirmasi/menutup tiket orang lain
- Mengirim chat mengatas-namakan pelapor

**Rekomendasi backend (Hono):**
```ts
// Terapkan rate limit per-IP DAN per-nomorTiket di keempat endpoint ini,
// bukan cuma di endpoint create.
// Contoh kasar: 10 request/menit per IP untuk GET lookup,
// 5 request/menit per nomorTiket untuk aksi (konfirmasi/buka-kembali/chat).
```
Tambahkan juga logging percobaan lookup yang gagal (nomor tidak ditemukan)
per IP — kalau ada IP yang mencoba ratusan nomor acak dalam waktu singkat,
itu sinyal brute-force yang layak diblokir.

### 2. Tidak ada idempotency key saat submit pengaduan

`kirim()` di repository langsung POST tanpa client-generated ID. Kalau
request timeout di jaringan lemah (skenario realistis untuk warga/petugas
di lapangan) dan Flutter retry otomatis atau user tap ulang tombol, bisa
tercipta 2 tiket duplikat untuk laporan yang sama.

**Rekomendasi:**
```dart
// ComplaintDraft — tambahkan
final String clientRequestId; // uuid v4, dibuat sekali saat form dibuka

// toJson() / toMultipartMap() — sertakan
'clientRequestId': clientRequestId,
```
```ts
// Backend: unique constraint di kolom clientRequestId.
// Kalau request kedua datang dengan clientRequestId yang sama,
// kembalikan tiket yang sudah ada (bukan error, bukan duplikat).
```

### 3. Auto-close via `konfirmasiBatasAt` — pastikan benar-benar dieksekusi

UI sudah menampilkan pesan *"lewat itu tiket ditutup otomatis"*, tapi ini
janji UI. Perlu dipastikan ada **cron job / scheduled function** di
backend yang benar-benar menutup tiket setelah `konfirmasiBatasAt`
terlewati — kalau tidak, tiket akan menggantung selamanya di status
`SELESAI` dan pelapor yang tidak pernah membuka app akan membuat data kotor.

**Checklist verifikasi (bukan kode baru, tapi harus dicek ada):**
- [ ] Ada scheduled job (Vercel Cron / worker) yang jalan berkala
- [ ] Job ini menulis entri `PengaduanTimeline` (aktor: SYSTEM) saat auto-close
- [ ] Job ini idempotent (aman dijalankan 2x kalau overlap)

### 4. Validasi upload foto — verifikasi sisi server, bukan cuma ekstensi

Mobile sudah kompres ke 1280px & cek ukuran client-side, bagus. Tapi itu
**bukan proteksi**, hanya UX. Yang wajib ada di server:
- [ ] Validasi magic bytes (bukan hanya `Content-Type` header, yang bisa
      dipalsukan)
- [ ] Batas ukuran ditegakkan server (bukan cuma diasumsikan dari client)
- [ ] Strip EXIF metadata sebelum simpan (foto dari warga bisa mengandung
      GPS location tersembunyi yang tidak diinginkan pelapor)

### 5. Kontak pelapor tidak divalidasi format

`kontakPelapor` cuma dicek `length >= 5`, bukan format nomor HP Indonesia.
Ini bukan soal keamanan tapi kualitas data — kalau field ini dipakai
petugas untuk menghubungi balik pelapor, nomor asal-asalan bikin proses
lapangan macet.

**Rekomendasi ringan:**
```dart
validator: (v) {
  final bersih = v.trim().replaceAll(RegExp(r'[\s-]'), '');
  final validHp = RegExp(r'^(08|\+628)\d{8,11}$').hasMatch(bersih);
  if (!validHp) return 'Format nomor HP tidak valid (contoh: 081234567890).';
  return null;
},
```

### 6. Draft form tidak persisten — risiko kehilangan input

Kalau app di-kill mid-form (biasa terjadi di Android low-RAM saat user
switch app untuk ambil foto dari galeri, misalnya), seluruh isian form
hilang. Untuk warga yang baru sekali lapor pipa bocor, ini pengalaman
buruk.

**Rekomendasi (nice-to-have, bukan blocker):**
Simpan draft ke local storage (Hive/SharedPreferences) setiap kali field
berubah (debounced), hapus draft setelah submit sukses.

---

## Yang TIDAK Perlu Diubah (validasi keputusan desain)

- **Login opsional untuk melapor** — ini pilihan desain yang tepat untuk
  layanan publik air minum (bukan semua pelapor adalah pelanggan
  terdaftar), jangan dipaksa jadi mandatory auth.
- **Chat tanpa autentikasi tambahan selain nomor tiket** — ini konsisten
  dengan model "tanda terima kertas" (siapa yang pegang nomor tiket boleh
  berinteraksi). Ini valid selama poin #1 (rate limiting) sudah ditutup.

---

## Ringkasan Prioritas untuk Claude Code

| # | Item | Lokasi | Prioritas | Status Backend/Web (2026-07-20) |
|---|------|--------|-----------|----------------------------------|
| 1 | Rate limiting di 4 endpoint publik by IP | Backend (Hono) | 🔴 Tinggi | ✅ Sudah ada & terbukti (`429` di limit 30) |
| 2 | Idempotency key saat submit pengaduan | Backend + form web (+ mobile) | 🔴 Tinggi | ✅ Ditambahkan (`clientRequestId` unik) |
| 3 | Cron auto-close benar berjalan | Backend | 🟠 Sedang | ✅ Lazy-close + cron `/api/cron/tutup-pengaduan` |
| 4 | Magic bytes (+ strip EXIF) pada upload | Backend | 🟠 Sedang | ✅ Magic bytes + batas server; ⬜ EXIF opsional |
| 5 | Validasi format nomor HP | Form web (+ mobile) | 🟢 Rendah | ✅ Validasi lembut di form web |
| 6 | Draft form persisten lokal | `lapor_pengaduan_screen.dart` | 🟢 Rendah | ⬜ Khusus mobile (nice-to-have) |

**Sisa untuk mobile (Flutter):** kirim `clientRequestId` (UUID v4, dibuat
sekali saat form dibuka) pada `POST /api/public/pengaduan` — backend sudah
menerimanya; validasi format HP; draft persisten. Strip EXIF di server
opsional.

**Verdict:** halaman pengaduan **web sudah production-ready** — build lolos,
alur end-to-end (lapor → lacak → proses → selesai → konfirmasi/rating) +
kontrol keamanan (anti-enumerasi, rate limit, RBAC, magic-bytes, idempotensi)
terverifikasi terhadap database asli.