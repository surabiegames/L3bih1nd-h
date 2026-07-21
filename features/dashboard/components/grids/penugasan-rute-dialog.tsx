"use client"

// features/dashboard/components/grids/penugasan-rute-dialog.tsx — modal
// penugasan Rute Baca Meter (RBM) ke seorang pencatat. Dibuka dari klik
// baris di tab Pencatat (/dashboard/organisasi).
//
// Inilah pengatur kolom `Pencatat.ruteId` yang dibaca aplikasi mobile
// petugas lewat GET /laporan-harian/rute-saya: rute yang dipilih di sini =
// rute (dan target pencatatan) yang terunduh di ponsel pencatat. Satu rute
// SENGAJA boleh dipegang lebih dari satu pencatat (pembagian beban /
// pengganti cuti) — memilih rute yang sudah dipegang orang lain bukan error.
//
// Modal hanya dirender saat baris diklik, jadi state isian selalu mulai
// bersih di tiap pembukaan.
import * as React from "react"
import { MapPinOff, Route, Search, Users } from "lucide-react"
import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { Spinner } from "@/components/ui/spinner"
import { cn } from "@/lib/utils"
import { ambilList, kirimJson, ApiError } from "../../lib/api-client"

export interface PencatatBaris {
  id: string
  namaLapangan: string
  namaLengkap?: string | null
  user?: { name?: string | null; email?: string | null } | null
  rute?: { id: string; kode: string } | null
}

interface RuteBaris {
  id: string
  kode: string
  seksiCater?: { nama?: string | null; kode?: string | null } | null
}

export function PenugasanRuteDialog({
  pencatat,
  onTutup,
  onSelesai,
}: {
  pencatat: PencatatBaris
  onTutup: () => void
  /** Dipanggil setelah PATCH sukses — parent menutup modal + refresh grid. */
  onSelesai: () => void
}) {
  const [cari, setCari] = React.useState("")
  const [hasil, setHasil] = React.useState<RuteBaris[]>([])
  const [memuat, setMemuat] = React.useState(true)
  const [pilihan, setPilihan] = React.useState<RuteBaris | null>(
    pencatat.rute ? { id: pencatat.rute.id, kode: pencatat.rute.kode } : null
  )
  // Target pencatatan (jumlah pelanggan) rute yang PERNAH dihitung, ber-kunci
  // id rute — nilai tampil diturunkan dari sini, jadi ganti pilihan tidak
  // butuh reset state sinkron di effect (aturan react-hooks/set-state-in-effect).
  const [targetRute, setTargetRute] = React.useState<{ id: string; total: number } | null>(null)
  const [mengirim, setMengirim] = React.useState(false)
  const [galat, setGalat] = React.useState<string | null>(null)
  const target = pilihan && targetRute?.id === pilihan.id ? targetRute.total : null

  // Cari rute (debounce) — tanpa kata kunci pun 20 rute pertama tampil,
  // supaya modal tidak kosong sebelum mengetik. Semua setState berada di
  // callback timeout (asinkron), bukan badan effect.
  React.useEffect(() => {
    let batal = false
    const t = setTimeout(async () => {
      setMemuat(true)
      try {
        const { rows } = await ambilList<RuteBaris>("/rute", {
          q: cari.trim() || undefined,
          pageSize: 20,
        })
        if (!batal) setHasil(rows)
      } catch (err) {
        if (!batal) setGalat(err instanceof ApiError ? err.message : "Gagal memuat daftar rute.")
      } finally {
        if (!batal) setMemuat(false)
      }
    }, 300)
    return () => {
      batal = true
      clearTimeout(t)
    }
  }, [cari])

  // Hitung target pelanggan rute terpilih. Pratinjau saja — gagal hitung
  // tidak menghalangi penugasan.
  React.useEffect(() => {
    if (!pilihan) return
    const id = pilihan.id
    let batal = false
    ambilList("/pelanggan", { ruteId: id, pageSize: 1 })
      .then(({ total }) => {
        if (!batal) setTargetRute({ id, total })
      })
      .catch(() => {})
    return () => {
      batal = true
    }
  }, [pilihan])

  async function simpan(ruteId: string | null) {
    setMengirim(true)
    setGalat(null)
    try {
      await kirimJson(`/pencatat/${pencatat.id}`, "PATCH", { ruteId })
      onSelesai()
    } catch (err) {
      setGalat(err instanceof ApiError ? err.message : "Gagal menyimpan penugasan.")
      setMengirim(false)
    }
  }

  const akun = pencatat.user?.name ?? pencatat.user?.email
  const tanpaAkun = !akun

  return (
    <Dialog open onOpenChange={(v) => !v && onTutup()}>
      <DialogContent className="max-h-[92dvh] max-w-[calc(100vw-2rem)] gap-0 overflow-y-auto p-0 sm:max-w-lg">
        <DialogHeader className="border-b border-border/70 px-4 py-3 text-left">
          <DialogTitle className="text-sm">Penugasan Rute Baca Meter</DialogTitle>
          <DialogDescription className="text-xs">
            {pencatat.namaLapangan}
            {pencatat.namaLengkap ? ` — ${pencatat.namaLengkap}` : ""}
            {akun ? ` · akun ${akun}` : ""}
          </DialogDescription>
        </DialogHeader>

        <div className="flex flex-col gap-3 p-4">
          {tanpaAkun && (
            <p className="border border-border bg-muted/40 px-3 py-2 text-xs text-muted-foreground">
              Pencatat ini belum tertaut ke akun sistem — rute tetap bisa
              ditugaskan, tapi aplikasi mobile baru bisa mengunduhnya setelah
              kolom “Akun Tertaut” diisi.
            </p>
          )}

          {/* Penugasan saat ini + target pratinjau */}
          <div className="flex items-center gap-2 border border-border bg-muted/20 px-3 py-2">
            {pilihan ? (
              <Route className="size-4 shrink-0 text-muted-foreground" />
            ) : (
              <MapPinOff className="size-4 shrink-0 text-muted-foreground" />
            )}
            <div className="min-w-0 flex-1">
              <p className="text-xs font-semibold">
                {pilihan ? (
                  <>
                    Rute <span className="font-mono">{pilihan.kode}</span>
                    {pilihan.id === pencatat.rute?.id ? " (penugasan saat ini)" : " (pilihan baru)"}
                  </>
                ) : (
                  "Belum ada rute yang dipilih"
                )}
              </p>
              {pilihan && (
                <p className="flex items-center gap-1 text-[11px] text-muted-foreground">
                  <Users className="size-3" />
                  {target === null ? "menghitung target…" : `${target.toLocaleString("id-ID")} pelanggan = target pencatatan per periode`}
                </p>
              )}
            </div>
          </div>

          {/* Pencarian rute */}
          <div className="relative">
            <Search className="pointer-events-none absolute top-1/2 left-2.5 size-3.5 -translate-y-1/2 text-muted-foreground" />
            <Input
              value={cari}
              onChange={(e) => setCari(e.target.value)}
              placeholder="Cari kode rute…"
              className="h-8 pl-8 text-xs"
              aria-label="Cari rute"
              autoFocus
            />
          </div>

          <div className="max-h-56 overflow-y-auto border border-border/70">
            {memuat ? (
              <div className="flex items-center justify-center gap-2 px-3 py-6 text-xs text-muted-foreground">
                <Spinner className="size-3.5" /> Memuat rute…
              </div>
            ) : hasil.length === 0 ? (
              <p className="px-3 py-6 text-center text-xs text-muted-foreground">
                Tidak ada rute yang cocok dengan “{cari}”.
              </p>
            ) : (
              hasil.map((r) => (
                <button
                  key={r.id}
                  type="button"
                  onClick={() => setPilihan(r)}
                  className={cn(
                    "flex w-full items-center gap-2 border-b border-border/50 px-3 py-2 text-left text-xs last:border-b-0 hover:bg-accent/60",
                    pilihan?.id === r.id && "bg-primary/10 shadow-[inset_2px_0_0_0_var(--primary)]"
                  )}
                >
                  <span className="font-mono font-semibold">{r.kode}</span>
                  <span className="min-w-0 flex-1 truncate text-muted-foreground">
                    {r.seksiCater?.nama ?? r.seksiCater?.kode ?? ""}
                  </span>
                  {pencatat.rute?.id === r.id && (
                    <span className="shrink-0 border border-border bg-muted/40 px-1.5 py-0.5 text-[10px] font-semibold tracking-wide text-muted-foreground uppercase">
                      saat ini
                    </span>
                  )}
                </button>
              ))
            )}
          </div>

          {galat && <p className="bg-destructive/10 px-3 py-2 text-xs text-destructive">{galat}</p>}
        </div>

        <DialogFooter className="flex-row justify-end gap-2 border-t border-border/70 px-4 py-3">
          {pencatat.rute && (
            <Button
              variant="outline"
              size="sm"
              className="mr-auto h-8 text-xs text-destructive hover:text-destructive"
              disabled={mengirim}
              onClick={() => simpan(null)}
            >
              Tarik Penugasan
            </Button>
          )}
          <Button variant="outline" size="sm" className="h-8 text-xs" disabled={mengirim} onClick={onTutup}>
            Batal
          </Button>
          <Button
            size="sm"
            className="h-8 text-xs"
            disabled={mengirim || !pilihan || pilihan.id === pencatat.rute?.id}
            onClick={() => pilihan && simpan(pilihan.id)}
          >
            {mengirim ? <Spinner className="size-3.5" /> : null}
            {mengirim ? "Menyimpan…" : "Simpan Penugasan"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
