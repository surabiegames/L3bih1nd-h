#!/usr/bin/env python3
"""generate_launcher_icons.py — bangun source PNG ikon launcher dari logo
resmi perusahaan (public/images/logo.png, di root repo Next.js — SATU-
SATUNYA sumber warna/bentuk brand, bukan diciptakan ulang di sini).

Menghasilkan 4 file di assets/icons/ (dipakai flutter_launcher_icons-
publik.yaml & flutter_launcher_icons-petugas.yaml):
  publik.png / publik_fg.png   — latar PUTIH (app pelanggan)
  petugas.png / petugas_fg.png — latar BIRU asli logo (app staf)

Gaya flat ala macOS/iOS modern: TANPA gradien, TANPA drop-shadow —
logo ditempatkan dengan padding aman di kanvas persegi polos, OS yang
mengurus pembulatan sudut/masking adaptive icon. Dua skala berbeda:
  - *_fg.png  (foreground adaptive icon Android): skala lebih kecil
    (~62%) supaya mark tidak terpotong mask lingkaran/squircle launcher.
  - polos (ikon iOS + fallback Android lama): skala lebih besar (~80%),
    karena OS hanya membulatkan sudut tipis, tidak memotong lingkaran.

Jalankan dari root repo:
    python3 mobile/scripts/generate_launcher_icons.py
Lalu regenerate ikon platform:
    cd mobile
    dart run flutter_launcher_icons -f flutter_launcher_icons-publik.yaml
    dart run flutter_launcher_icons -f flutter_launcher_icons-petugas.yaml
"""

from pathlib import Path

from PIL import Image

REPO_ROOT = Path(__file__).resolve().parents[2]
LOGO_PATH = REPO_ROOT / "public" / "images" / "logo.png"
ICONS_DIR = REPO_ROOT / "mobile" / "assets" / "icons"

CANVAS = 1024
WHITE = (255, 255, 255, 255)
# #0F75BC — biru asli logo (disampel langsung dari piksel logo.png),
# bukan warna karangan baru.
BRAND_BLUE = (15, 117, 188, 255)

FLAT_SCALE = 0.80
ADAPTIVE_FG_SCALE = 0.62


def make_icon(logo: Image.Image, bg_color, scale: float, out_path: Path, *, transparent: bool) -> None:
    canvas = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0) if transparent else bg_color)
    mark_size = int(CANVAS * scale)
    mark = logo.resize((mark_size, mark_size), Image.LANCZOS)
    offset = ((CANVAS - mark_size) // 2, (CANVAS - mark_size) // 2)
    canvas.paste(mark, offset, mark)
    canvas.save(out_path)
    print(f"wrote {out_path.relative_to(REPO_ROOT)} ({canvas.size[0]}x{canvas.size[1]})")


def main() -> None:
    logo = Image.open(LOGO_PATH).convert("RGBA")
    ICONS_DIR.mkdir(parents=True, exist_ok=True)

    make_icon(logo, WHITE, FLAT_SCALE, ICONS_DIR / "publik.png", transparent=False)
    make_icon(logo, WHITE, ADAPTIVE_FG_SCALE, ICONS_DIR / "publik_fg.png", transparent=True)

    make_icon(logo, BRAND_BLUE, FLAT_SCALE, ICONS_DIR / "petugas.png", transparent=False)
    make_icon(logo, BRAND_BLUE, ADAPTIVE_FG_SCALE, ICONS_DIR / "petugas_fg.png", transparent=True)


if __name__ == "__main__":
    main()
