// server/modules/wilayah/rute.router.ts — rute pencatatan meter. Tidak
// punya field `nama` (beda dari model wilayah lain) -> orderBy/searchFields
// dioverride ke `kode`.
import { z } from "zod"
import { GEO } from "../../lib/spatial"
import { createGeoCrudRouter, geoJsonSchema } from "../../lib/geo-crud-factory"
import { ROLE_GROUPS } from "../../middleware/rbac"

const createSchema = z.object({
  kode: z.string().trim().min(1).max(50),
  noUrut: z.coerce.number().int().min(0).nullable().optional(),
  seksiCaterId: z.string().min(1),
  area: geoJsonSchema.nullable().optional(),
})

const updateSchema = createSchema.partial()

export const ruteRouter = createGeoCrudRouter({
  entitas: "Rute",
  model: "rute",
  geo: GEO.rute,
  createSchema,
  updateSchema,
  searchFields: ["kode"],
  orderBy: { kode: "asc" },
  include: { seksiCater: true },
  read: ROLE_GROUPS.STAFF_UP,
  write: ROLE_GROUPS.ADMIN,
})
