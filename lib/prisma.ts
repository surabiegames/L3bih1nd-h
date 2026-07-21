// lib/prisma.ts — singleton PrismaClient dipakai SELURUH aplikasi (auth.ts,
// server/**). Satu pool koneksi (@prisma/adapter-pg) per proses, di-cache
// lewat globalThis di dev supaya hot-reload Next.js tidak membuka pool baru
// setiap kali file berubah. Pola sama persis dengan prisma/seed/lib/db.ts.
//
// PENTING: import PrismaClient dari "@/app/generated/prisma" (root
// package), BUKAN dari "@/app/generated/prisma/client" — lihat catatan
// panjang di prisma/seed/lib/db.ts / CLAUDE.md soal kenapa subpath itu
// merusak inferensi tipe delegate model.
import { PrismaClient } from "@/app/generated/prisma"
import { PrismaPg } from "@prisma/adapter-pg"

if (!process.env.DATABASE_URL) {
  throw new Error("DATABASE_URL tidak ditemukan di environment — cek file .env di root project.")
}

const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL })

const globalForPrisma = globalThis as unknown as { prisma?: PrismaClient }

export const prisma = globalForPrisma.prisma ?? new PrismaClient({ adapter })

if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = prisma
