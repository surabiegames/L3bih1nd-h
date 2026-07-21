# Copilot Instructions untuk Project PERUMDA Tirtawening

## Ringkasan proyek
- Project ini adalah backend/dashboard PERUMDA Tirtawening berbasis Next.js 16, Hono API, Prisma 7 + PostGIS, dan Auth.js.
- Domain utama: pelanggan, meter, pembacaan meter, tagihan, laporan, pengaduan, organisasi, wilayah, dan user/admin.
- Nama domain dan field banyak memakai bahasa Indonesia. Jaga konsistensi nama tersebut.

## Arsitektur penting
- Semua kode API bisnis harus berada di folder server/, bukan di app/.
- Entry point API adalah [server/app.ts](../server/app.ts). File [app/api/[[...route]]/route.ts](../app/api/[[...route]]/route.ts) hanya meng-handle Hono app.
- Endpoint bisnis utama berada di prefix /api/v1/* dan wajib login.
- Endpoint publik berada di /api/public/* dan tidak boleh dipindahkan ke /api/v1.
- UI frontend harus mengikuti pola app/ + features/ sesuai panduan di [FRONTEND.md](../FRONTEND.md).

## Auth dan login
- Login utama untuk web/app menggunakan Auth.js.
- Endpoint login yang relevan untuk integrasi Flutter:
  - GET /api/auth/csrf
  - POST /api/auth/callback/credentials
- Setelah login, session disimpan sebagai cookie; request berikutnya ke endpoint protected harus menyertakan cookie tersebut.
- Auth dibagi menjadi dua bagian:
  - [auth.config.ts](../auth.config.ts): konfigurasi edge-safe, tidak boleh mengandung Prisma.
  - [auth.ts](../auth.ts): konfigurasi Node-only, menyertakan Prisma adapter, credentials login, dan callback JWT/session.
- Jangan mengubah pola split ini kecuali benar-benar perlu dan sudah dipahami.

## Aturan backend yang harus diikuti
- Jangan menulis API baru di app/api/**. Gunakan modul di server/modules/<domain>/ dan mount di [server/app.ts](../server/app.ts).
- Gunakan helper validasi dari [server/lib/validate.ts](../server/lib/validate.ts), bukan zValidator langsung.
- Gunakan error handler dari [server/lib/errors.ts](../server/lib/errors.ts) agar response konsisten.
- Jangan memakai Prisma.raw() / Prisma.join() di server/.
- Jangan memakai instanceof untuk mengenali error Prisma/Zod di server/.
- Untuk query geospasial/PostGIS, gunakan helper di [server/lib/spatial.ts](../server/lib/spatial.ts).

## Database dan Prisma
- Schema Prisma tersebar di folder prisma/ dan menggunakan multi-file schema.
- Selalu import Prisma client dari [lib/prisma.ts](../lib/prisma.ts) atau [app/generated/prisma](../app/generated/prisma), bukan membuat instance PrismaClient baru secara acak.
- Jika mengubah schema Prisma, jalankan generate/migrate sesuai instruksi repo.
- Jangan mengubah nama tabel/field yang sudah dipakai tanpa memikirkan migrasi dan dampak API.

## Konvensi coding
- Gunakan bahasa Indonesia untuk nama domain/model/endpoint bila sudah ada pola di repo.
- Jaga konsistensi response envelope:
  - sukses: { success: true, data: ... }
  - error: { success: false, error: { code, message, details } }
- Saat memodifikasi API, pikirkan RBAC dan akses per role.
- Untuk endpoint yang mengakses data sensitif, gunakan requireRole() sesuai aturan di [server/middleware/rbac.ts](../server/middleware/rbac.ts).

## Untuk integrasi Flutter / mobile
- Endpoint login mobile harus memakai cookie-based session.
- Base URL lokal biasanya:
  - http://localhost:3000
  - Android emulator: http://10.0.2.2:3000
- Jika request ke endpoint protected gagal, cek apakah cookie login dikirim dengan benar.
- Endpoint yang sering dipakai untuk uji session adalah /api/v1/me.

## Prioritas saat bekerja
1. Baca [server/README.md](../server/README.md) sebelum mengubah API/backend.
2. Baca [FRONTEND.md](../FRONTEND.md) sebelum menambah halaman atau UI.
3. Jika task menyangkut auth, jangan mengubah auth.config.ts dan auth.ts secara sembarangan.
4. Verifikasi perubahan dengan build/run sesuai instruksi repo, jangan hanya mengandalkan typecheck.
