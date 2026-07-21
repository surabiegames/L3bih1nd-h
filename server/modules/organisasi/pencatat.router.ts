// server/modules/organisasi/pencatat.router.ts — jembatan nama petugas
// lapangan (kd_petugas di CSV legacy) <-> akun User sistem.
import { z } from "zod"
import { prisma } from "@/lib/prisma"
import { createCrudRouter } from "../../lib/crud-factory"
import { ROLE_GROUPS } from "../../middleware/rbac"

const createSchema = z.object({
  namaLapangan: z.string().trim().min(1).max(100),
  namaLengkap: z.string().trim().min(1).max(150).optional(),
  nip: z.string().trim().min(1).max(30).optional(),
  aliasLain: z.string().max(1000).optional(),
  userId: z.string().min(1).optional(),
  /// Penugasan Rute Baca Meter — null = tarik penugasan. Dibaca aplikasi
  /// mobile petugas lewat GET /laporan-harian/rute-saya.
  ruteId: z.string().min(1).nullable().optional(),
  isAktif: z.boolean().optional(),
})

const updateSchema = createSchema.partial()

export const pencatatRouter = createCrudRouter({
  entitas: "Pencatat",
  delegate: prisma.pencatat,
  createSchema,
  updateSchema,
  searchFields: ["namaLapangan", "namaLengkap", "nip"],
  orderBy: { namaLapangan: "asc" },
  include: {
    user: { select: { id: true, name: true, email: true, role: true } },
    rute: { select: { id: true, kode: true } },
  },
  read: ROLE_GROUPS.STAFF_UP,
  write: ROLE_GROUPS.SUPERVISOR_UP,
})
