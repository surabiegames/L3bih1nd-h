import 'dart:io';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Kotak unggah + pratinjau SATU foto bukti — dipakai BERSAMA oleh layar
/// Lapor Pengaduan dan Lapor Meter supaya ukurannya IDENTIK (dulu tiap layar
/// punya kotak sendiri dengan radius/ikon/border beda — pelan-pelan
/// menyimpang). Label & deskripsi tetap dirender layar pemanggil (teksnya
/// beda: "Foto Bukti (opsional)" vs "Foto Meter *wajib"); yang disamakan
/// hanya KOTAK-nya.
class KotakFotoBukti extends StatelessWidget {
  const KotakFotoBukti({
    super.key,
    required this.path,
    required this.onTap,
    this.memproses = false,
  });

  /// Path berkas foto yang sudah diambil — null = belum ada foto.
  final String? path;
  final VoidCallback? onTap;

  /// Sedang mengompres/memproses foto (tampilkan spinner).
  final bool memproses;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final terisi = path != null;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 160,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: theme.colorScheme.muted,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: terisi ? theme.colorScheme.primary : theme.colorScheme.border,
          ),
        ),
        child: memproses
            ? const Center(child: CircularProgressIndicator())
            : terisi
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(path!), fit: BoxFit.cover),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      color: const Color(0xB3000000),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.checkmark,
                            size: 12,
                            color: Color(0xFFFFFFFF),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Ganti / hapus foto',
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.camera,
                    size: 28,
                    color: theme.colorScheme.mutedForeground,
                  ),
                  const SizedBox(height: 6),
                  Text('Ambil foto', style: theme.textTheme.muted),
                ],
              ),
      ),
    );
  }
}
