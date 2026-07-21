import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/network/api_exception.dart';
import '../langganan_warga_repository.dart';

/// Kartu pratinjau "ini pelanggan Anda?" di bawah input nomor langganan —
/// dipakai form daftar akun dan form tambah langganan. Mengambil identitas
/// lewat endpoint publik GET /api/public/pelanggan/:nomor BEGITU nomor
/// genap 11 digit (debounce 500 ms; endpoint itu di-rate-limit 20/5 menit
/// per IP, jadi jangan fetch per ketukan).
///
/// Beri `nomor` mentah dari input; widget ini sendiri yang memutuskan
/// kapan layak fetch. Belum 11 digit = tidak menampilkan apa-apa.
class PratinjauPelanggan extends StatefulWidget {
  const PratinjauPelanggan({super.key, required this.nomor});

  final String nomor;

  @override
  State<PratinjauPelanggan> createState() => _PratinjauPelangganState();
}

class _PratinjauPelangganState extends State<PratinjauPelanggan> {
  final _repo = LanggananWargaRepository.create();
  Timer? _debounce;

  bool _memuat = false;
  PelangganRingkas? _hasil;
  String? _galat;

  /// Nomor yang sedang/terakhir di-fetch — respons yang datang terlambat
  /// untuk nomor lama tidak boleh menimpa hasil nomor baru.
  String? _nomorDiproses;

  bool get _lengkap =>
      widget.nomor.length == 11 && int.tryParse(widget.nomor) != null;

  @override
  void initState() {
    super.initState();
    if (_lengkap) _jadwalkan();
  }

  @override
  void didUpdateWidget(covariant PratinjauPelanggan lama) {
    super.didUpdateWidget(lama);
    if (widget.nomor == lama.nomor) return;
    _debounce?.cancel();
    if (_lengkap) {
      _jadwalkan();
    } else {
      setState(() {
        _memuat = false;
        _hasil = null;
        _galat = null;
        _nomorDiproses = null;
      });
    }
  }

  void _jadwalkan() {
    setState(() {
      _memuat = true;
      _hasil = null;
      _galat = null;
    });
    _debounce = Timer(const Duration(milliseconds: 500), _cari);
  }

  Future<void> _cari() async {
    final nomor = widget.nomor;
    _nomorDiproses = nomor;
    try {
      final hasil = await _repo.pratinjau(nomor);
      if (!mounted || _nomorDiproses != nomor) return;
      setState(() {
        _memuat = false;
        _hasil = hasil;
      });
    } on ApiException catch (e) {
      if (!mounted || _nomorDiproses != nomor) return;
      setState(() {
        _memuat = false;
        _galat = e.message;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    if (!_lengkap && !_memuat && _hasil == null && _galat == null) {
      return const SizedBox.shrink();
    }

    if (_memuat) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            const SizedBox.square(
              dimension: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text('Memeriksa nomor langganan…', style: theme.textTheme.muted),
          ],
        ),
      );
    }

    if (_galat != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_circle,
              size: 16,
              color: theme.colorScheme.destructive,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _galat!,
                style: theme.textTheme.muted.copyWith(
                  color: theme.colorScheme.destructive,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final hasil = _hasil;
    if (hasil == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ShadCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.checkmark_seal_fill,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasil.nama,
                    style: theme.textTheme.small.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    hasil.alamat,
                    style: theme.textTheme.muted.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
