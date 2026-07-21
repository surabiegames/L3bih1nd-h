// app/(dashboard)/dashboard/organisasi/page.tsx — /dashboard/organisasi
//
// Empat entitas struktur organisasi dalam satu halaman ber-tab — masing-
// masing kecil, memecahnya jadi empat halaman hanya menambah klik.
import type { Metadata } from "next"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { HalamanDasbor } from "@/features/dashboard/components/halaman-dasbor"
import { DivisiGrid, BagianGrid, SubBagianGrid, PencatatGrid } from "@/features/dashboard/components/grids/organisasi-grids"

export const metadata: Metadata = { title: "Organisasi & petugas" }

export default function OrganisasiPage() {
  return (
    <HalamanDasbor
      eyebrow="Data Induk"
      judul="Organisasi & petugas"
      deskripsi="Hierarki Divisi → Bagian → Sub-bagian, serta pemetaan nama petugas lapangan ke akun sistem."
    >
      <Tabs defaultValue="divisi">
        <TabsList>
          <TabsTrigger value="divisi">Divisi</TabsTrigger>
          <TabsTrigger value="bagian">Bagian</TabsTrigger>
          <TabsTrigger value="sub-bagian">Sub-bagian</TabsTrigger>
          <TabsTrigger value="pencatat">Pencatat</TabsTrigger>
        </TabsList>
        <TabsContent value="divisi" className="mt-4">
          <DivisiGrid />
        </TabsContent>
        <TabsContent value="bagian" className="mt-4">
          <BagianGrid />
        </TabsContent>
        <TabsContent value="sub-bagian" className="mt-4">
          <SubBagianGrid />
        </TabsContent>
        <TabsContent value="pencatat" className="mt-4">
          <PencatatGrid />
        </TabsContent>
      </Tabs>
    </HalamanDasbor>
  )
}
