import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/models/bill_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/labels.dart';
import '../../../core/widgets/status_badge.dart';

/// Tampilan hasil cek tagihan (kartu pelanggan + ringkasan tunggakan +
/// riwayat tagihan per periode). Dipakai bersama oleh layar publik
/// (Cek Tagihan) dan layar petugas (Info Tagihan) supaya rincian biaya
/// tampil identik di kedua aplikasi.
class HasilCekTagihanView extends StatelessWidget {
  const HasilCekTagihanView({super.key, required this.hasil});

  final CekTagihanResult hasil;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _KartuPelanggan(pelanggan: hasil.pelanggan),
        const SizedBox(height: 16),
        _KartuTunggakan(total: hasil.totalTunggakan),
        const SizedBox(height: 16),
        Text('Riwayat Tagihan', style: theme.textTheme.large),
        const SizedBox(height: 8),
        if (hasil.tagihan.isEmpty)
          Text(
            'Belum ada tagihan tercatat untuk pelanggan ini.',
            style: theme.textTheme.muted,
          )
        else
          for (final t in hasil.tagihan) ...[
            _KartuTagihan(tagihan: t),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _KartuPelanggan extends StatelessWidget {
  const _KartuPelanggan({required this.pelanggan});

  final CustomerInfo pelanggan;

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      title: Text(pelanggan.nama),
      description: Text('No. Langganan ${pelanggan.nomorLangganan}'),
      trailing: pelanggan.status == null
          ? null
          : ShadBadge.outline(child: Text(pelanggan.status!)),
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          children: [
            _BarisRincian(label: 'Alamat', nilai: pelanggan.alamat ?? '-'),
            _BarisRincian(
              label: 'RT / RW',
              nilai: '${pelanggan.rt ?? '-'} / ${pelanggan.rw ?? '-'}',
            ),
            _BarisRincian(
              label: 'Golongan Tarif',
              nilai: pelanggan.tarifGolongan ?? '-',
            ),
          ],
        ),
      ),
    );
  }
}

class _KartuTunggakan extends StatelessWidget {
  const _KartuTunggakan({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final lunas = total == 0;
    return ShadCard(
      leading: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Icon(
          lunas
              ? CupertinoIcons.checkmark_circle
              : CupertinoIcons.exclamationmark_triangle_fill,
          size: 28,
          color: lunas
              ? const Color(AppStatusColors.successLight)
              : theme.colorScheme.destructive,
        ),
      ),
      title: Text(lunas ? 'Tidak Ada Tunggakan' : 'Total Tunggakan'),
      description: Text(
        lunas
            ? 'Semua tagihan sudah dibayar.'
            : 'Segera lakukan pembayaran untuk menghindari denda '
                  'atau pemutusan sambungan.',
      ),
      trailing: lunas
          ? null
          : Text(
              formatRupiah(total),
              style: theme.textTheme.large.copyWith(
                color: theme.colorScheme.destructive,
              ),
            ),
    );
  }
}

/// Kartu satu periode tagihan dengan toggle rincian biaya.
class _KartuTagihan extends StatefulWidget {
  const _KartuTagihan({required this.tagihan});

  final BillModel tagihan;

  @override
  State<_KartuTagihan> createState() => _KartuTagihanState();
}

class _KartuTagihanState extends State<_KartuTagihan> {
  bool _terbuka = false;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final t = widget.tagihan;

    return ShadCard(
      title: Text(t.labelPeriodeTagihan),
      description: Text(
        t.pemakaianM3 == null
            ? 'Pemakaian -'
            : 'Pemakaian ${formatM3(t.pemakaianM3!)}',
      ),
      trailing: StatusBadge(
        label: labelDari(labelStatusTagihan, t.status),
        tone: toneStatusTagihan(t.status),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Tagihan', style: theme.textTheme.muted),
                Flexible(
                  child: Text(
                    formatRupiah(t.totalTagihan),
                    textAlign: TextAlign.end,
                    style: theme.textTheme.large,
                  ),
                ),
              ],
            ),
            if (_terbuka) ...[
              const SizedBox(height: 8),
              Container(height: 1, color: theme.colorScheme.border),
              const SizedBox(height: 8),
              if (t.standLalu != null || t.standAkhir != null)
                _BarisRincian(
                  label: 'Stand Meter',
                  nilai: '${t.standLalu ?? '-'} → ${t.standAkhir ?? '-'}',
                ),
              if (t.jmlHargaAir != null)
                _BarisRincian(
                  label: 'Harga Air',
                  nilai: formatRupiah(t.jmlHargaAir!),
                ),
              if (t.beaBeban != null)
                _BarisRincian(
                  label: 'Bea Beban',
                  nilai: formatRupiah(t.beaBeban!),
                ),
              if (t.beaAdmin != null)
                _BarisRincian(
                  label: 'Bea Admin',
                  nilai: formatRupiah(t.beaAdmin!),
                ),
              if (t.airKotor != null)
                _BarisRincian(
                  label: 'Air Kotor',
                  nilai: formatRupiah(t.airKotor!),
                ),
              if (t.lainLain != null && t.lainLain != 0)
                _BarisRincian(
                  label: 'Lain-lain',
                  nilai: formatRupiah(t.lainLain!),
                ),
              if (t.denda != null && t.denda != 0)
                _BarisRincian(label: 'Denda', nilai: formatRupiah(t.denda!)),
              if (t.tanggalJatuhTempo != null)
                _BarisRincian(
                  label: 'Jatuh Tempo',
                  nilai: formatTanggalUtc(t.tanggalJatuhTempo!),
                ),
              if (t.tanggalBayar != null)
                _BarisRincian(
                  label: 'Tanggal Bayar',
                  nilai: formatTanggalUtc(t.tanggalBayar!),
                ),
            ],
            const SizedBox(height: 4),
            ShadButton.ghost(
              onPressed: () => setState(() => _terbuka = !_terbuka),
              trailing: Icon(
                _terbuka
                    ? CupertinoIcons.chevron_up
                    : CupertinoIcons.chevron_down,
              ),
              child: Text(_terbuka ? 'Tutup Rincian' : 'Lihat Rincian'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarisRincian extends StatelessWidget {
  const _BarisRincian({required this.label, required this.nilai});

  final String label;
  final String nilai;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: theme.textTheme.muted)),
          Expanded(flex: 2, child: Text(nilai, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
