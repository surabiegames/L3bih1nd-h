import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Catatan prosedural tenang di kaki beranda — MENGGANTIKAN InfoBanner
/// bergradien (Emerald/Sky) yang dulu dipakai untuk isi yang sama.
///
/// KENAPA TENANG: isi catatan ini statis, tidak pernah berubah, dan tidak
/// menuntut tindakan. Warna jenuh pada permukaan sebesar itu membuatnya
/// terbaca sebagai iklan dan menyaingi hal yang benar-benar penting
/// (tunggakan, status tiket). Aturan yang dipegang beranda ini: warna
/// pekat hanya untuk hal yang BERUBAH dan perlu perhatian; informasi
/// tetap cukup dengan token `muted` milik tema.
///
/// Konsekuensi lain yang disengaja: karena memakai token tema (bukan
/// warna literal), blok ini otomatis benar di mode gelap — beda dari
/// InfoBanner yang latar Emerald-50-nya menyala di tema gelap.
class CatatanLayanan extends StatelessWidget {
  const CatatanLayanan({super.key, required this.butir});

  final List<CatatanButir> butir;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < butir.length; i++) ...[
            // Container, bukan Divider: Divider milik Material, sementara
            // app ini berdiri di atas WidgetsApp (ShadApp) tanpa Material.
            if (i > 0) Container(height: 1, color: theme.colorScheme.border),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Icon(
                      butir[i].ikon,
                      size: 15,
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${butir[i].judul} — ',
                            style: theme.textTheme.small.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: butir[i].isi,
                            style: theme.textTheme.muted.copyWith(
                              fontSize: 12,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Satu butir catatan — data murni, supaya blok di atas bisa dipakai ulang
/// tanpa menyalin markup.
class CatatanButir {
  const CatatanButir({
    required this.ikon,
    required this.judul,
    required this.isi,
  });

  final IconData ikon;
  final String judul;
  final String isi;
}
