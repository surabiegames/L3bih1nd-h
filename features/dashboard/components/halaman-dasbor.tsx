// features/dashboard/components/halaman-dasbor.tsx — kepala halaman seragam
// untuk semua halaman dashboard: eyebrow hijau + judul editorial + deskripsi
// (+ slot aksi/chip di kanan). Grammar yang sama dengan halaman Ringkasan
// dan permukaan publik.
export function HalamanDasbor({
  eyebrow,
  judul,
  deskripsi,
  aksi,
  children,
}: {
  eyebrow: string
  judul: string
  deskripsi?: string
  /** Slot kanan-atas: chip periode, tombol aksi, dsb. */
  aksi?: React.ReactNode
  children: React.ReactNode
}) {
  return (
    <div className="flex flex-col gap-6">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <p className="text-[11px] font-semibold tracking-[0.2em] text-primary uppercase">{eyebrow}</p>
          <h1 className="mt-2 text-2xl font-semibold tracking-tight text-foreground">{judul}</h1>
          {deskripsi && <p className="mt-1.5 max-w-2xl text-sm text-muted-foreground">{deskripsi}</p>}
        </div>
        {aksi}
      </div>
      {children}
    </div>
  )
}
