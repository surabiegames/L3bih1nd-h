"use client"

// Grid /dashboard/organisasi — empat entitas struktur organisasi dalam satu
// halaman ber-tab: Divisi → Bagian → Sub-bagian, plus Pencatat (jembatan
// nama petugas lapangan di CSV ↔ akun User + penugasan Rute Baca Meter
// yang diunduh aplikasi mobile petugas).
import * as React from "react"
import type { ColDef } from "ag-grid-community"
import { DataGrid } from "../data-grid"
import { selBool, fmtLabel, KELAS_MONO } from "./sel"
import { LABEL_ROLE } from "../../lib/label"
import { PenugasanRuteDialog, type PencatatBaris } from "./penugasan-rute-dialog"

const TINGGI = "h-[480px]"

export function DivisiGrid() {
  const kolom: ColDef[] = [{ field: "nama", headerName: "Nama Divisi", minWidth: 240, flex: 2 }]
  return <DataGrid judul="Divisi" endpoint="/divisi" columnDefs={kolom} searchParam="q" tinggiClassName={TINGGI} />
}

export function BagianGrid() {
  const kolom: ColDef[] = [
    { field: "kode", headerName: "Kode", minWidth: 100, maxWidth: 130, cellClass: KELAS_MONO },
    { field: "nama", headerName: "Nama Bagian", minWidth: 220, flex: 2 },
    { field: "levelKepala", headerName: "Level Kepala", minWidth: 150, valueFormatter: fmtLabel(LABEL_ROLE) },
    { headerName: "Divisi", minWidth: 150, valueGetter: (p) => p.data?.divisi?.nama ?? "—" },
  ]
  return <DataGrid judul="Bagian" endpoint="/bagian" columnDefs={kolom} searchParam="q" tinggiClassName={TINGGI} />
}

export function SubBagianGrid() {
  const kolom: ColDef[] = [
    { field: "kode", headerName: "Kode", minWidth: 100, maxWidth: 130, cellClass: KELAS_MONO },
    { field: "nama", headerName: "Nama Sub-bagian", minWidth: 220, flex: 2 },
    { headerName: "Bagian", minWidth: 150, valueGetter: (p) => p.data?.bagian?.nama ?? "—" },
  ]
  return <DataGrid judul="Sub-bagian" endpoint="/sub-bagian" columnDefs={kolom} searchParam="q" tinggiClassName={TINGGI} />
}

export function PencatatGrid() {
  // Klik baris = buka modal penugasan Rute Baca Meter (kolom
  // Pencatat.ruteId) — rute inilah yang terunduh di aplikasi mobile
  // pencatat lewat GET /laporan-harian/rute-saya.
  const [terpilih, setTerpilih] = React.useState<PencatatBaris | null>(null)
  const [refreshKey, setRefreshKey] = React.useState(0)

  const kolom: ColDef[] = [
    { field: "namaLapangan", headerName: "Nama Lapangan", minWidth: 150 },
    { field: "namaLengkap", headerName: "Nama Lengkap", minWidth: 180, flex: 2 },
    { field: "nip", headerName: "NIP", minWidth: 130, cellClass: KELAS_MONO },
    { headerName: "Akun Tertaut", minWidth: 160, valueGetter: (p) => p.data?.user?.name ?? p.data?.user?.email ?? "—" },
    {
      headerName: "Rute RBM",
      minWidth: 120,
      cellClass: KELAS_MONO,
      valueGetter: (p) => p.data?.rute?.kode ?? "—",
    },
    { field: "isAktif", headerName: "Status", minWidth: 110, maxWidth: 130, cellRenderer: selBool("Aktif", "Non-aktif") },
  ]
  return (
    <>
      <DataGrid
        judul="Pencatat Lapangan — klik baris untuk menugaskan rute"
        endpoint="/pencatat"
        columnDefs={kolom}
        searchParam="q"
        tinggiClassName={TINGGI}
        onRowClicked={(data) => setTerpilih(data as unknown as PencatatBaris)}
        idTerpilih={terpilih?.id}
        refreshKey={refreshKey}
      />
      {terpilih && (
        <PenugasanRuteDialog
          pencatat={terpilih}
          onTutup={() => setTerpilih(null)}
          onSelesai={() => {
            setTerpilih(null)
            setRefreshKey((k) => k + 1)
          }}
        />
      )}
    </>
  )
}
