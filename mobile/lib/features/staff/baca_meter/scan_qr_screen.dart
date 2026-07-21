import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/widgets.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/widgets/app_scaffold.dart';

/// Scan QR/barcode nomor langganan di rumah pelanggan — padanan
/// `ScanAndGetActivity` Aurora (ZXing/ZBar → ML Kit via mobile_scanner):
/// hasil scan dikembalikan ke pemanggil untuk dicocokkan dengan paket rute
/// LOKAL (pencarian offline, sama seperti `searchPelanggan` Aurora).
class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final _kontrol = MobileScannerController(
    formats: const [BarcodeFormat.qrCode, BarcodeFormat.code128],
  );
  bool _sudahKembali = false;

  @override
  void dispose() {
    _kontrol.dispose();
    super.dispose();
  }

  void _terdeteksi(BarcodeCapture tangkapan) {
    if (_sudahKembali) return;
    final nilai = tangkapan.barcodes
        .map((b) => b.rawValue)
        .whereType<String>()
        .map((v) => v.trim())
        .firstWhere((v) => v.isNotEmpty, orElse: () => '');
    if (nilai.isEmpty) return;
    _sudahKembali = true; // kamera menembak beruntun — pop sekali saja.
    Navigator.of(context).pop(nilai);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return AppScaffold(
      title: 'Scan Kode Pelanggan',
      subtitle: 'Arahkan kamera ke QR/barcode di rumah pelanggan',
      trailing: ShadIconButton.ghost(
        icon: const Icon(CupertinoIcons.bolt_fill),
        onPressed: () => _kontrol.toggleTorch(),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _kontrol,
            onDetect: _terdeteksi,
            errorBuilder: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Kamera tidak tersedia: ${error.errorCode.name}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.muted,
                ),
              ),
            ),
          ),
          // Bingkai target sederhana di tengah.
          Center(
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFFFFFFF), width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
