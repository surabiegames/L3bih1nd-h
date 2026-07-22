Cara aku menilai halaman ini

Tugas sebenarnya halaman verifikasi bukan "menampilkan tabel", tapi: memastikan satu periode itu benar dan lengkap, secepat mungkin, dengan jejak yang bisa dipercaya. Nah, halaman sekarang jago di bagian "menampilkan yang masuk", tapi lemah di "lengkap", "cepat", dan "sekali lihat langsung paham". Itu tiga celah utamanya.

---
🔴 Prioritas tinggi (paling terasa)

1. Kolom "Status" tunggal + penanda baris — bukan cuma 3 ceklis
Sekarang status baris harus disimpulkan pengguna dari tiga kolom centang terpisah. Untuk memindai ratusan baris, itu melelahkan. Yang kurang:
- Satu badge status yang eksplisit: Menunggu V1 / Menunggu V2 / ng (kamu sudah punya tahapLaporanHarian() di client — tinggaldirender jadi pill).
- Pewarnaan/aksen baris per tahap (netral → amber → biru → hijau). Kamu sudah pakai bahasa aksen-kiri di sidebar & baristerpilih; tinggal dipakai untuk status.
- Baris "terkunci" terlihat: laporan yang sudah pembacaanId/dipa — tandai supaya pengguna tidak mencoba lalu kena error.
- Baris yang stand-nya dikoreksi V1 (standAkhirRevisi != standAkhir) sebaiknya menonjol — itu justru yang perlu diperiksa ring atas.

Sebagian besar frontend saja — cepat, dampak besar.

2. Filter "giliran saya" + "hanya anomali" (quick filter chips)
Ini penghemat waktu terbesar. Seorang Supervisor cuma peduli barGGU_V2, Senior MENUNGGU_V3. Sekarang filter statusVerif masihkasar (MENUNGGU/DIVERIFIKASI/DITOLAK) dan tidak bisa memisah per-ring. Tambah:
- Chip "Menunggu giliran saya" (role-aware) → langsung ke antrea
- Chip "Hanya anomali" (|persentase| > ambang) — verifikasi paling bernilai ada di baris berisiko; sisanya bisa diproses massal.
- Default urutan anomali dulu saat mode verifikasi.

Butuh sedikit tambahan API (query param filter per-ring: verif1A).

3. Aksi massal + alur keyboard
Verifikasi itu berulang. Sekarang semua lewat klik-kanan satu-per-satu. Yang memanjakan:
- Multi-select + "Verifikasi V1 terpilih" / "Approve V3 semua yaaris sudah ada di server; tinggal endpoint batch.
- Keyboard-first: panah untuk pindah baris, Enter buka modal V1, tombol untuk approve/tolak, "lompat ke baris menunggu berikutnya". Untuk ratusan baris, ini beda siang-malam.

Butuh endpoint batch di server.

---
🔴 Yang kamu sebut: "melihat data yang belum dicatat"

Ini celah fungsional terbesar, dan aku setuju penting. Tabel sekarang hanya menampilkan LaporanHarianPetugas — yaitu yang sudah dikirim. Pelanggan yang
meterannya tidak terbaca sama sekali tidak muncul di mana pun dinutup periode, Supervisor justru butuh tahu siapa yang terlewat.

Kabar baiknya: datanya sudah bisa dihitung. Endpoint mobile /lapelakukan anti-join (Pelanggan × rute × periode vs laporan,menghasilkan sudahDicatat). Tinggal dibuat versi dashboard: tab/toggle "Belum dicatat" yang menampilkan pelanggan dalam cakupan (per rute/zona/pencatat) yang belum ada laporannya di periode itu. Ini yang mengubah halaman dadi "pastikan periode lengkap".

Butuh endpoint baru (pola-nya sudah ada).

---
🟡 Yang kamu sebut: toolbar & "filter per tanggal"

Betul, toolbar sekarang tipis (cuma periode, status kasar, pencatat, cari). API belum mendukung rentang tanggal tanggalCatat. Yang layak ditambah:
- Rentang tanggal tanggalCatat (dari–sampai) — verifikasi "kirim
- Filter rute / zona / wilayah / kondisi (DK, BMK) / golongan tarif.
- Filter punya foto vs tanpa foto, dan jarak GPS mencurigakan (jini sinyal anti-kecurangan yang sudah tersimpan tapi belum pernah dipakai di UI. Sayang.

API: tambah beberapa query param; sisanya frontend.

---
🟡 Soal "tidak ada pagination" — aku mau jujur soal trade-off

Perlu diluruskan: tabel ini sudah pakai infinite model (blok 50, secara UI sudah "tanpa pagination". Tapi kalau maksudnya muatsemua ke browser, itu berbahaya: LaporanHarianPetugas bisa puluhan ribu baris.

Rekomendasiku: jangan muat semua tanpa batas, tapi buat terasa tanpa pagination dengan membatasi ke himpunan kerja (satu periode + satu status). Set itu kecil
dan berhingga → bisa pindah ke client-side row model yang: sort/p, scroll mulus, plus progress "X dari Y". Itu "no pagination"yang aman. Kalau dipaksa unbounded di 22k baris, sort/scroll malah berat dan boros memori.

---
Sisanya yang memanjakan (🟡/nice-to-have)

- Thumbnail/preview foto stand di kolom (hover) — tak perlu buka
- Timeline audit di panel: siapa V1/V2/V3 dan kapan — bangun kepercayaan (sekarang cuma tooltip).
- State "periode bersih": saat menunggu = 0, tampilkan keadaan s
- Tombol "Verifikasi berikutnya" yang melompat ke baris menunggu berikutnya.