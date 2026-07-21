# Struktur & Pola Frontend

Dokumen ini adalah **rujukan pola** untuk membuat halaman baru. Padanan
backend-nya ada di `server/README.md`. Halaman `/login` sengaja dibangun
lengkap sebagai contoh hidup dari seluruh aturan di bawah — kalau ragu, tiru
`app/(auth)/login/` + `features/auth/`.

## Peta folder

```
app/                        HANYA urusan route
  layout.tsx                root: font, metadata template, provider
  (auth)/                   route group — TIDAK jadi segmen URL
    layout.tsx              kerangka bersama halaman auth
    login/page.tsx          /login
    forgot-password/page.tsx
    reset-password/page.tsx
  page.tsx                  /
components/
  ui/                       primitif shadcn — JANGAN diedit manual
  providers/                seluruh provider client-side
  app-logo.tsx              komponen bersama lintas fitur
  theme-toggle.tsx
features/                   logika + tampilan per domain
  auth/
    components/             komponen milik domain auth
    actions/                server action ("use server")
    lib/                    logika non-UI (schema, token, mailer, template)
lib/                        utilitas lintas domain (prisma, cn)
```

`features/<domain>/` adalah cermin dari `server/modules/<domain>/`. API
pelanggan di `server/modules/pelanggan/` → UI-nya di `features/pelanggan/`.

## Aturan

**1. Page tipis, fitur tebal.**
`app/**/page.tsx` hanya boleh mengurus: metadata, baca `params`/`searchParams`,
guard sesi + redirect, lalu merakit komponen dari `features/`. JSX panjang dan
aturan bisnis TIDAK ditulis di `page.tsx`. Contoh:
`app/(auth)/login/page.tsx` (17 baris efektif) → `features/auth/components/login-card.tsx`.

**2. Server component sampai terbukti butuh client.**
Jangan menaruh `"use client"` di `page.tsx` atau `layout.tsx`. Taruh sedekat
mungkin dengan interaktivitasnya — di daun. Di alur login, satu-satunya
komponen client adalah `google-sign-in-button.tsx` (butuh state pending);
kartu, layout, dan halaman tetap server component.

**3. Route group untuk mengelompokkan, bukan menambah URL.**
`(auth)` tidak muncul di URL — `/login` tetap `/login`. Dipakai agar halaman
sejenis berbagi layout. Dashboard nanti: `app/(dashboard)/layout.tsx` berisi
sidebar + header, halaman di dalamnya tetap `/pelanggan`, `/tagihan`, dst.

**4. Warna hanya lewat token semantik.**
Pakai `bg-background`, `text-muted-foreground`, `bg-card`, `border-border`.
JANGAN `bg-white`, `text-gray-500`, atau hex — token sudah punya padanan
gelap di `.dark` (`app/globals.css`), warna mentah tidak, dan dark mode akan
rusak diam-diam. Pengecualian sah: logo Google (brand guideline mewajibkan 4
warna aslinya).

**5. Metadata pakai template.**
`app/layout.tsx` menetapkan `title.template = "%s — PERUMDA Tirtawening"`.
Halaman cukup `export const metadata = { title: "Masuk" }`.

**6. Bahasa Indonesia untuk teks yang dilihat pengguna**, konsisten dengan
konvensi domain di skema Prisma.

**7. Form: dua pola, pilih sesuai tujuannya.**
- **Server action + `useActionState`** — default untuk form milik kita
  sendiri. Contoh: `forgot-password-form.tsx`, `reset-password-form.tsx`.
  Tetap jalan tanpa JS (progressive enhancement), pending dari React.
- **Handler client** — hanya bila submit-nya HARUS lewat endpoint pihak lain.
  Satu-satunya contoh: `credentials-form.tsx`, karena login wajib melalui
  `/api/auth/*` (Auth.js via Hono) dan `redirect: false` diperlukan agar
  pesan "password salah" muncul di tempat tanpa memuat ulang halaman.

**8. `"use server"` = permukaan publik.**
Setiap fungsi async yang di-**export** dari file `"use server"` menjadi
endpoint RPC yang bisa dipanggil siapa pun dari browser. Jadi: hanya server
action yang boleh di-export dari `features/*/actions/`. Helper internal
(mis. `hashPassword`) tinggal di `features/*/lib/` dan diberi
`import "server-only"` di baris pertama supaya salah-impor dari komponen
client gagal saat build, bukan diam-diam mengirim kode server ke browser.

**9. Validasi dua sisi, satu schema.**
Schema zod di `features/*/lib/schema.ts` dipakai client (UX) DAN server
(penegakan). Server TIDAK PERNAH mempercayai hasil validasi client —
selalu `safeParse` ulang di dalam action.

**10. Foto konten SELALU lewat `BingkaiFoto` (`components/bingkai-foto.tsx`)
— jangan `<img>` telanjang.**
Foto lapangan datang dari puluhan ponsel dengan dimensi berbeda-beda;
`<img>` telanjang membuat tinggi halaman ditentukan file, bukan desain.
`BingkaiFoto` mengunci frame lewat rasio aspek (`rasio="4/3"` default,
`16/9`, `1/1`, `3/4`; lebar diatur pemanggil via `className`), dengan dua
mode isian: `"isi"` (object-cover, tepi terpotong — foto suasana/bukti
umum) dan `"utuh"` (object-contain berbingkai — foto yang ANGKANYA harus
terbaca, mis. stand meter). Klik membuka dialog `FotoZoom` (wheel = zoom,
drag = geser) — cover yang memotong tepi selalu punya jalan dilihat utuh;
`tanpaDialog` untuk pratinjau `blob:` lokal di form. Semua `<img>` konten
lama sudah dimigrasikan (2026-07-19) — yang baru jangan mundur lagi.

## Dark mode — cara kerjanya

`app/globals.css` memakai `@custom-variant dark (&:is(.dark *))` dan menaruh
token di selektor `.dark {...}`. Artinya tema gelap aktif **hanya** saat ada
class `dark` di `<html>`. Konsekuensinya:

- `ThemeProvider` (`components/providers/theme-provider.tsx`) **wajib**
  `attribute="class"`. Diganti ke `data-theme` → seluruh token dark tidak
  pernah kepakai dan dark mode mati diam-diam.
- `<html>` **wajib** `suppressHydrationWarning` — next-themes menempelkan
  class `dark` sebelum React hydrate, jadi markup server & client memang
  selalu beda di titik itu.

**Jangan pakai pola `useState(mounted)` + `useEffect` untuk UI yang bergantung
tema.** Itu menyebabkan kedip setelah hydrate dan melanggar lint
`react-hooks/set-state-in-effect`. Karena class `dark` sudah menempel sebelum
hydrate, biarkan CSS yang memilih — lihat `components/theme-toggle.tsx`:

```tsx
<Sun className="hidden size-4 dark:block" />
<Moon className="size-4 dark:hidden" />
```

Baca `resolvedTheme` hanya di dalam event handler (saat diklik), tidak pernah
saat render.

## Alur auth — yang sudah ada & aturannya

| Halaman | Isi |
|---|---|
| `/login` | Google OAuth **dan** credentials (email **atau** username + password) |
| `/forgot-password` | kirim tautan reset ke email |
| `/reset-password?token=…&email=…` | buat password baru |

**Tidak ada halaman pendaftaran, dan itu disengaja.** Akun dibuat
administrator lewat `POST /api/v1/users`; `callbacks.signIn` di `auth.ts`
menolak email Google yang belum terdaftar. Admin pertama lewat
`pnpm db:bootstrap-admin`.

Aturan keamanan yang ditegakkan — jangan dilonggarkan tanpa alasan kuat:

- **Password di-hash dengan argon2id** (`lib/password.ts`, satu-satunya tempat).
  Auth.js TIDAK menyediakan hashing password sama sekali — sudah diperiksa:
  `@auth/core` & `next-auth` nol hasil untuk bcrypt/argon2/scrypt, dependensinya
  hanya `jose`/`oauth4webapi`/`hkdf`/`preact`. Jadi pilihan algoritma murni milik
  kita, tidak ada "standar Auth.js" yang perlu diikuti. Parameter default
  `@node-rs/argon2` (`m=19456,t=2,p=1`) sudah persis rekomendasi OWASP —
  jangan dioverride tanpa alasan. Parameter tersimpan di dalam string hash,
  jadi menaikkannya kelak tidak merusak password lama.
- **Token reset disimpan sebagai hash SHA-256**, bukan teks asli
  (`features/auth/lib/password-reset.ts`). Yang dikirim ke email adalah token
  asli; database hanya menyimpan sidik jarinya. Sekali pakai, berlaku 1 jam,
  dan token lama dihapus tiap kali ada permintaan baru.
- **Tidak membocorkan keberadaan akun.** `/forgot-password` selalu menjawab
  pesan sukses yang sama, terdaftar atau tidak. Login selalu menjawab
  "email/username atau password salah" untuk semua sebab. `authorize()`
  menjalankan `bcrypt.compare` terhadap hash tiruan saat user tidak ada,
  supaya waktu responsnya tidak membocorkan email mana yang terdaftar.
- **Akun non-`ACTIVE` ditolak di KEDUA jalur** (credentials & Google). Kalau
  hanya salah satu yang dicek, menonaktifkan user tidak menutup pintu yang
  lain.
- **Sesi memakai JWT dan TIDAK bisa dicabut dari server.** Konsekuensinya:
  reset password TIDAK mengusir sesi yang sudah aktif di perangkat lain
  sampai JWT-nya kedaluwarsa. Untuk mengubah ini, strategi sesi harus pindah
  ke database — keputusan besar, jangan diselipkan diam-diam.

**Email belum terkonfigurasi.** `features/auth/lib/mailer.ts` mengirim lewat
Resend bila `RESEND_API_KEY` diisi; bila tidak, isi email **dicetak ke konsol
server** dan tidak terkirim ke siapa pun. Di produksi kondisi tanpa API key
sengaja dibuat **error**, karena "mengaku sudah mengirim tautan reset padahal
tidak" jauh lebih berbahaya daripada gagal terang-terangan. Ganti penyedia?
Cukup ubah isi `kirimEmail()`.

## Dashboard internal

`app/(dashboard)/` (sidebar shadcn + header) — URL tetap `/dashboard/*`.
Digerbangi dua lapis: `proxy.ts` di edge, **dan** `auth()` di
`app/(dashboard)/layout.tsx`. Lapis kedua bukan mubazir: middleware hanya
memeriksa keberadaan cookie di edge (tanpa Prisma), dan kalau matcher
`proxy.ts` kelak diubah, halaman tidak boleh ikut terbuka diam-diam.

**Server component ambil data LANGSUNG lewat `features/dashboard/lib/queries.ts`,
bukan `fetch` ke `/api/v1/dashboard`.** Halaman dirender di server yang sama
dengan API-nya — memanggil API sendiri lewat HTTP berarti satu perjalanan
jaringan sia-sia, harus meneruskan cookie manual, dan butuh URL absolut yang
beda antara dev/produksi. Endpoint `/api/v1/dashboard/*` tetap ada untuk
pemanggil LUAR (mobile, widget client). Bandingkan dengan `features/publik`
yang justru WAJIB lewat fetch — rate limit-nya berbasis IP pemakai.

Aturan angka di dashboard:
- **Agregasi di database** (`count`/`aggregate`/`groupBy`), tidak pernah
  `findMany` lalu hitung di JS — tabel pelanggan & tagihan >22.000 baris.
- **Periode acuan = periode terakhir yang ADA DATANYA**, bukan bulan berjalan.
  Data berasal dari closing bulanan yang bisa tertinggal; memakai bulan
  berjalan membuat dashboard terlihat kosong/rusak padahal datanya belum masuk.
- **Uang di kartu statistik pakai `formatRupiahRingkas()`** ("Rp 3,01 M").
  Sudah terbukti: nilai penuh (Rp 3.012.396.720) terpotong jadi "Rp 3.012.3…"
  dan angkanya jadi tak terbaca sama sekali. Nilai penuh tetap tersedia lewat
  `title` dan di tabel/rincian.
- **Grafik butuh ≥2 titik.** Dengan 1 titik Recharts merender kotak kosong
  yang terlihat seperti komponen rusak — dan itu kondisi nyata sekarang (impor
  CSV baru berisi satu periode). `TrenTagihan` menanganinya dengan menampilkan
  angkanya langsung + alasan kenapa grafik belum ada.

## Halaman publik (tanpa login)

| Halaman | Endpoint |
|---|---|
| `/cek-tagihan` | `POST /api/public/cek-tagihan` |
| `/lapor-meter` | `POST /api/public/lapor-meter` (multipart) |
| `/pengaduan` | `POST /api/public/pengaduan` (multipart), `GET /api/public/pengaduan/:nomorTiket`, `POST …/:nomorTiket/konfirmasi`, `POST …/:nomorTiket/buka-kembali` |

Kode: `app/(public)/` + `features/publik/`. Klien API terpusat di
`features/publik/lib/api.ts` — jangan `fetch` ke `/api/public` langsung dari
komponen; bentuk envelope respons didefinisikan backend dan di file itulah ia
diterjemahkan sekali.

**Dipanggil dari komponen client (fetch), BUKAN server action.** Rate limit di
backend berbasis IP pemakai; lewat server action semua request akan tampak
berasal dari IP server, sehingga satu orang bisa menghabiskan kuota semua
orang dan pembatasnya jadi tak berguna.

### Kenapa cek tagihan meminta NAMA, bukan nomor langganan saja

Diperiksa di data produksi (2026-07-15) — bukan asumsi:
- `nomorLangganan` **berurutan** (`00000100119`, `00000200509`, `00000200510`),
  jadi bukan rahasia dan bisa ditebak dengan loop.
- Ada **22.534** pelanggan aktif. Kalau nomor saja sudah membuka data,
  seluruh basis pelanggan bisa disedot habis.
- **Nomor HP tidak bisa dipakai** sebagai verifikasi: hanya **16,3%** pelanggan
  punya `notelp`, sebagian sampah (`"0000"`) — akan mengunci ~84% pelanggan.
- **Nama layak dipakai**: hanya **1 dari 22.534** baris tidak berguna.
  Pelanggan tahu namanya (tercetak di rekening); penyerang yang mengiterasi
  nomor tidak.

Ini **bukan autentikasi** — pemegang rekening orang lain tetap bisa lewat.
Tujuannya menaikkan biaya dari "loop sepele" jadi "harus tahu pasangan
nomor+nama per orang", yang mematikan pemanenan massal. Jaminan lebih kuat
butuh OTP ke HP terdaftar (perlu gateway SMS + data HP jauh lebih lengkap).

### Aturan yang tidak boleh dilonggarkan

- **`/api/public/*` router terpisah, JANGAN pindah ke `/api/v1`.**
  `verifyAuth()` blanket di `/api/v1` adalah jaring pengaman: selama utuh,
  endpoint internal yang lupa `requireRole()` tetap tertutup. Melubanginya
  per-route menghapus jaring itu diam-diam.
- **Pesan kegagalan verifikasi harus SAMA** untuk semua sebab (nomor tidak
  ada / nama salah). Membedakannya = alat pengecek nomor langganan valid.
- **Pengaduan TIDAK memverifikasi `nomorLangganan`** dan menyimpannya sebagai
  teks saja — kalau diverifikasi, endpoint pengaduan berubah jadi alat
  enumerasi. Petugas mencocokkannya lewat dashboard.
- **Lacak tiket aman tanpa verifikasi** karena `nomorTiket` (`TW-YYMM-XXXXXX`)
  punya 6 karakter ACAK di belakang — bukan nomor urut. Itu satu-satunya yang
  menjaganya: nomor tiket adalah kunci pembawa, dan pemegangnya juga boleh
  menutup/membuka kembali tiket. **Kalau format itu suatu saat dibuat
  berurutan, pasang faktor kedua LEBIH DULU** (mis. nomor HP pelapor, pesan
  gagal seragam) — kalau tidak, halaman pelacakan jadi alat memanen aduan
  seluruh warga. Lihat `server/modules/pengaduan/tiket.ts`.
- **Respons pelacakan hanya membawa yang perlu**: nama petugas (bukan
  kontak/email/id-nya), dan HANYA entri `RiwayatPengaduan` ber-`isPublik: true`
  — difilter di query, bukan disaring di komponen. Pelapor/kontak/koordinat
  tetap tidak ikut.
- **Tiket ditutup pelapor, bukan petugas** — `PATCH /api/v1/pengaduan/:id/status`
  menolak `DITUTUP`/`DIBUKA_KEMBALI`. Petugas menandai `SELESAI`; warga yang
  mengonfirmasi (+ menilai) atau membantah lewat halaman pelacakan.
- **Lapor meter selalu `status: MENUNGGU`** — laporan publik tidak pernah
  langsung jadi angka resmi; petugas memverifikasi lewat
  `PATCH /api/v1/laporan-mandiri/:id/verify`. Periodenya ditentukan server
  (bulan berjalan), tidak diterima dari client.
- **Foto divalidasi lewat magic bytes**, bukan `file.type` (bisa dipalsukan:
  `curl -F "foto=@x.txt;type=image/jpeg"`). Nama & ekstensi ditentukan server.

**Rate limit di memori proses** (`server/lib/rate-limit.ts`): hilang saat
restart, tidak berlaku lintas instance. Deploy >1 instance → pindahkan ke
Redis. Ia juga bergantung `x-forwarded-for` yang **dikirim klien** — pastikan
reverse proxy produksi menimpanya, kalau tidak semua pembatas bisa dilewati.

**Storage — Cloudinary** (`server/lib/storage.ts`): dipakai bila `CLOUDINARY_*`
diisi; kalau tidak, simpan ke `./.uploads` dan **error di produksi** (disk lokal
hilang saat redeploy). Memakai **signed upload**, bukan unsigned preset —
unsigned berarti siapa pun yang membaca JS di browser bisa memakai kuota
Cloudinary kita. `fotoPublicId` di skema = `public_id` Cloudinary.

**Kredensial Cloudinary saat ini DITOLAK (401).** Sudah didiagnosis sampai
tuntas: Cloudinary melaporkan `String to sign` yang **identik** dengan yang
kode kita bangun, dan `sha1(string + secret kita)` **persis** yang terkirim —
jadi algoritmanya benar dan satu-satunya variabel tersisa adalah
`CLOUDINARY_API_SECRET` yang tidak cocok dengan akun tersebut (secret dari
cloud lain / sudah di-rotate / `api_key` bukan pasangan `cloud_name`-nya).
Perbaiki di Cloudinary Console → Settings → API Keys.

## Komponen shadcn

Style `radix-nova`, base color `mist` (primary = teal — cocok untuk
perusahaan air). Konfigurasi di `components.json`.

- Tambah komponen: `npx shadcn@latest add <nama>` — jangan salin manual.
- **Jangan edit `components/ui/**` untuk kebutuhan satu halaman.** Sesuaikan
  lewat `className` di tempat pemakaian. `components/ui/**` juga tidak ikut
  standar lint proyek (kode generated) — karena itu `pnpm lint` di folder itu
  ramai; lint kode Anda sendiri, bukan folder itu.
- Ukuran tombol shadcn di style ini kecil (`default` = h-8). Untuk CTA utama
  naikkan eksplisit, mis. `className="h-10 w-full"`.

## Verifikasi halaman baru

`tsc` dan `lint` **tidak cukup** — keduanya lolos sementara dark mode mati
atau tombol tak berfungsi. Minimal:

1. `pnpm build` — memastikan batas server/client tidak dilanggar.
2. Buka halaman di tema terang **dan** gelap.
3. Jalankan alur aksinya sungguhan (klik tombol, submit form), jangan hanya
   melihat tampilannya.

Screenshot headless tanpa browser (dipakai saat membangun halaman ini):

```bash
chrome --headless --disable-gpu --hide-scrollbars --disable-lcd-text \
  --screenshot=out.png --window-size=900,640 http://localhost:3000/login
# tema gelap: tambahkan --force-dark-mode --enable-features=WebContentsForceDark
```

Catatan: teks kecil bisa tampak kecoklatan di screenshot headless karena
subpixel antialiasing — itu artefak, bukan bug CSS. `--disable-lcd-text`
menghilangkannya.
