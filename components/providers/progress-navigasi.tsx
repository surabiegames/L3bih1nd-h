"use client"

// components/providers/progress-navigasi.tsx — indikator "penghubung" antar
// halaman: bilah tipis di puncak viewport yang mengisi jeda antara klik dan
// halaman baru tampil (RSC di-fetch di server, halaman lama tetap terlihat
// tanpa isyarat apa pun — bilah inilah isyaratnya). Dipasang di root layout
// jadi berlaku di seluruh permukaan (publik, auth, dashboard).
//
// KENAPA TANPA LIBRARY: App Router (Next 16) tak punya router.events seperti
// Pages Router. Pola andal yang dipakai di sini menangkap DUA sumbu navigasi:
//   1. MULAI — tangkap klik <a> internal (Link sidebar/breadcrumb/footer) +
//      tambal window.history.pushState/replaceState (menangkap router.push
//      programatik, mis. klik baris di papan pengaduan) + popstate (back/
//      forward). Klik memberi start SEKETIKA sebelum fetch dimulai.
//   2. SELESAI — usePathname() berubah = route baru sudah commit → tuntaskan.
// Semua pemicu diberi pagar "pathname harus beda" supaya update URL yang cuma
// mengubah query/hash (mis. filter) tidak memunculkan bilah palsu.
import * as React from "react"
import { usePathname } from "next/navigation"

// Ambang trickle: bilah merayap menuju 90% selama menunggu, lalu melompat ke
// 100% saat route commit — memberi kesan "hampir selesai" tanpa pernah macet
// di 100% bila fetch lama.
const BATAS_TRICKLE = 90
const TICK_MS = 200
// Pagar keselamatan: navigasi yang dibatalkan/gagal tak pernah mengubah
// pathname → tanpa ini bilah merayap selamanya. Paksa tuntas setelah ini.
const TIMEOUT_AMAN_MS = 10_000

export function ProgressNavigasi() {
  const pathname = usePathname()
  const [progress, setProgress] = React.useState(0)
  const [aktif, setAktif] = React.useState(false)

  const tickRef = React.useRef<ReturnType<typeof setInterval> | null>(null)
  const tuntasRef = React.useRef<ReturnType<typeof setTimeout> | null>(null)
  const amanRef = React.useRef<ReturnType<typeof setTimeout> | null>(null)

  const mulai = React.useCallback(() => {
    // Batalkan fade-out yang mungkin sedang berjalan (navigasi cepat beruntun).
    if (tuntasRef.current) {
      clearTimeout(tuntasRef.current)
      tuntasRef.current = null
    }
    setAktif(true)
    // Kalau sudah merayap di tengah (start ganda dari klik + pushState),
    // jangan mundur ke 8 — pertahankan kemajuannya.
    setProgress((p) => (p > 0 && p < BATAS_TRICKLE ? p : 8))

    if (tickRef.current) clearInterval(tickRef.current)
    tickRef.current = setInterval(() => {
      setProgress((p) => {
        if (p >= BATAS_TRICKLE) return p
        // Lompatan mengecil saat mendekati 90% → gerak melambat, terasa halus.
        const sisa = BATAS_TRICKLE - p
        return Math.min(BATAS_TRICKLE, p + Math.max(0.4, sisa * 0.07))
      })
    }, TICK_MS)

    if (amanRef.current) clearTimeout(amanRef.current)
    amanRef.current = setTimeout(() => tuntas(), TIMEOUT_AMAN_MS)
    // tuntas stabil (useCallback) — aman tidak masuk deps.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  const tuntas = React.useCallback(() => {
    if (tickRef.current) {
      clearInterval(tickRef.current)
      tickRef.current = null
    }
    if (amanRef.current) {
      clearTimeout(amanRef.current)
      amanRef.current = null
    }
    setProgress(100)
    // Setelah transisi width ke 100% + fade selesai, sembunyikan & reset.
    tuntasRef.current = setTimeout(() => {
      setAktif(false)
      setProgress(0)
    }, 360)
  }, [])

  // MULAI: pasang penangkap klik + tambal history sekali saat mount.
  React.useEffect(() => {
    const bedaPath = (href: string | URL | null | undefined) => {
      if (!href) return false
      try {
        const u = new URL(String(href), location.href)
        return u.origin === location.origin && u.pathname !== location.pathname
      } catch {
        return false
      }
    }

    const onKlik = (e: MouseEvent) => {
      // Hormati klik non-navigasi: modifier (buka tab baru), tombol tengah,
      // atau default sudah dicegah oleh handler lain.
      if (
        e.defaultPrevented ||
        e.button !== 0 ||
        e.metaKey ||
        e.ctrlKey ||
        e.shiftKey ||
        e.altKey
      )
        return
      const anchor = (e.target as HTMLElement | null)?.closest("a")
      if (!anchor) return
      if (anchor.target && anchor.target !== "_self") return
      if (anchor.hasAttribute("download")) return
      if (bedaPath(anchor.getAttribute("href"))) mulai()
    }

    // router.push/replace di App Router berujung ke history API — menambalnya
    // menangkap navigasi programatik yang tak lewat <a> sama sekali.
    const bungkus = (asli: History["pushState"]): History["pushState"] =>
      function (this: History, ...args) {
        if (bedaPath(args[2])) mulai()
        return asli.apply(this, args)
      }

    const asliPush = window.history.pushState
    const asliReplace = window.history.replaceState
    window.history.pushState = bungkus(asliPush)
    window.history.replaceState = bungkus(asliReplace)

    const onPopstate = () => mulai()

    document.addEventListener("click", onKlik, { capture: true })
    window.addEventListener("popstate", onPopstate)

    return () => {
      document.removeEventListener("click", onKlik, { capture: true })
      window.removeEventListener("popstate", onPopstate)
      window.history.pushState = asliPush
      window.history.replaceState = asliReplace
    }
  }, [mulai])

  // SELESAI: pathname berubah = route baru commit. Lewati render pertama
  // (tak ada navigasi yang dimulai) supaya bilah tidak berkedip saat muat awal.
  const pertama = React.useRef(true)
  React.useEffect(() => {
    if (pertama.current) {
      pertama.current = false
      return
    }
    tuntas()
  }, [pathname, tuntas])

  // Bersihkan timer saat unmount.
  React.useEffect(
    () => () => {
      if (tickRef.current) clearInterval(tickRef.current)
      if (tuntasRef.current) clearTimeout(tuntasRef.current)
      if (amanRef.current) clearTimeout(amanRef.current)
    },
    [],
  )

  if (!aktif && progress === 0) return null

  return (
    <div
      aria-hidden
      className="pointer-events-none fixed inset-x-0 top-0 z-[9999]"
    >
      <div
        className="relative h-[3px] origin-left bg-primary transition-[width,opacity] duration-300 ease-out motion-reduce:transition-none"
        style={{
          width: `${progress}%`,
          opacity: aktif ? 1 : 0,
          // Cahaya tipis di sepanjang bilah — warna ikut token, jadi benar di
          // terang & gelap.
          boxShadow:
            "0 0 8px color-mix(in oklch, var(--primary) 70%, transparent), 0 0 3px var(--primary)",
        }}
      >
        {/* "Peg" — kepala bilah yang berpendar & miring, ciri khas indikator
            bergaya NProgress. Disembunyikan saat prefers-reduced-motion. */}
        <span className="absolute top-0 right-0 hidden h-full w-28 translate-y-[-1px] rotate-[2.5deg] rounded-full bg-primary opacity-90 blur-[3px] motion-safe:block" />
      </div>
    </div>
  )
}
