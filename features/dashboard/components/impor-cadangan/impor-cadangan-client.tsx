"use client"

// Impor cadangan lapangan — admin mengunggah ZIP cadangan yang diekspor
// aplikasi petugas (bundel catatan.json + foto per pembacaan). Server mengurai
// & membuat LaporanHarianPetugas (idempoten: DUPLIKAT bila sudah ada).
import * as React from "react"
import { AlertTriangle, CheckCircle2, Loader2, Upload } from "lucide-react"
import { kirimForm, ApiError } from "../../lib/api-client"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"

interface HasilBaris {
  index: number
  nomorLangganan: string
  periode: number
  status: "TERSIMPAN" | "DUPLIKAT" | "GAGAL"
  pesan?: string
}
interface HasilImpor {
  total: number
  tersimpan: number
  duplikat: number
  gagal: number
  hasil: HasilBaris[]
}

export function ImporCadanganClient() {
  const [file, setFile] = React.useState<File | null>(null)
  const [mengirim, setMengirim] = React.useState(false)
  const [galat, setGalat] = React.useState<string | null>(null)
  const [hasil, setHasil] = React.useState<HasilImpor | null>(null)

  async function impor() {
    if (!file) return
    setMengirim(true)
    setGalat(null)
    setHasil(null)
    try {
      const form = new FormData()
      form.append("berkas", file)
      setHasil(await kirimForm<HasilImpor>("/laporan-harian/import-backup", form))
    } catch (e) {
      setGalat(e instanceof ApiError ? e.message : "Gagal mengimpor cadangan.")
    } finally {
      setMengirim(false)
    }
  }

  const bermasalah = hasil?.hasil.filter((h) => h.status === "GAGAL") ?? []

  return (
    <div className="max-w-2xl space-y-4">
      <div className="rounded-xl border bg-card p-5">
        <h3 className="text-base font-semibold">Unggah berkas cadangan (.zip)</h3>
        <p className="mt-1 text-sm text-muted-foreground">
          Petugas mengekspor cadangan dari menu <span className="font-medium">Cadangan Data</span> di aplikasi
          (tombol Ekspor ZIP), lalu kirim berkasnya ke Anda. Unggah di sini untuk mengubahnya menjadi laporan
          lapangan. Aman diimpor berulang — pembacaan yang sudah ada ditandai duplikat, bukan digandakan.
        </p>
        <div className="mt-4 flex flex-col gap-3 sm:flex-row sm:items-center">
          <Input
            type="file"
            accept=".zip,application/zip"
            onChange={(e) => setFile(e.target.files?.[0] ?? null)}
            className="cursor-pointer"
          />
          <Button onClick={impor} disabled={!file || mengirim} className="shrink-0">
            {mengirim ? <Loader2 className="size-4 animate-spin" /> : <Upload className="size-4" />}
            {mengirim ? "Mengimpor…" : "Impor"}
          </Button>
        </div>
        {galat && <p className="mt-3 text-sm text-destructive">{galat}</p>}
      </div>

      {hasil && (
        <div className="rounded-xl border bg-card p-5">
          <div className="flex items-center gap-2">
            {hasil.gagal === 0 ? (
              <CheckCircle2 className="size-5 text-emerald-600" />
            ) : (
              <AlertTriangle className="size-5 text-amber-600" />
            )}
            <h3 className="text-base font-semibold">Hasil impor</h3>
          </div>
          <div className="mt-3 flex flex-wrap gap-2">
            <Badge variant="secondary">Total {hasil.total}</Badge>
            <Badge className="bg-emerald-600 hover:bg-emerald-600">Tersimpan {hasil.tersimpan}</Badge>
            <Badge variant="outline">Duplikat {hasil.duplikat}</Badge>
            {hasil.gagal > 0 && <Badge variant="destructive">Gagal {hasil.gagal}</Badge>}
          </div>
          {bermasalah.length > 0 && (
            <div className="mt-4">
              <p className="mb-2 text-sm font-medium">Baris gagal:</p>
              <ul className="divide-y rounded-md border text-sm">
                {bermasalah.map((h) => (
                  <li key={h.index} className="flex items-center justify-between gap-3 px-3 py-2">
                    <span className="font-mono">{h.nomorLangganan || "?"}</span>
                    <span className="text-muted-foreground">{h.pesan ?? "Gagal."}</span>
                  </li>
                ))}
              </ul>
            </div>
          )}
        </div>
      )}
    </div>
  )
}
