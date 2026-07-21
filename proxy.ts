// proxy.ts — proteksi route di edge runtime (Next.js 16 "proxy", dulu
// "middleware"). Sengaja memakai authConfig EDGE-SAFE dari auth.config.ts
// (tanpa Prisma) — proxy hanya perlu cek "ada session valid atau tidak"
// lewat callbacks.authorized, tidak perlu query database.
//
// PENTING: JANGAN tulis `export const { auth: proxy } = NextAuth(authConfig)`.
// Next.js 16 melakukan pengecekan statis "apakah file ini meng-export
// function" sebelum module benar-benar dievaluasi, dan pengecekan itu
// gagal mengenali binding hasil destructuring-export meski nilainya
// memang function saat runtime (dikonfirmasi lewat instrumentasi manual:
// typeof proxy tetap "function", tapi Next.js tetap melempar
// ProxyMissingExportError). Assignment biasa dari member access aman.
import NextAuth from "next-auth"
import { authConfig } from "@/auth.config"

const nextAuth = NextAuth(authConfig)
export const proxy = nextAuth.auth

export const config = {
  matcher: ["/((?!api|_next/static|_next/image|favicon.ico).*)"],
}
