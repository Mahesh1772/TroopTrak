import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/qr_scanner_provider.dart';
import '../widgets/qr_scanner_overlay.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatelessWidget {
  const QRScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Consumer<QRScannerProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              MobileScanner(
                onDetect: (capture) {
                  provider.scanQRCode();
                },
              ),
              QRScannerOverlay(overlayColour: Colors.black.withOpacity(0.5)),
              if (provider.scannedSoldier != null)
                Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Soldier Found: ${provider.scannedSoldier!.name}'),
                          Text('Rank: ${provider.scannedSoldier!.rank}'),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, provider.scannedSoldier);
                            },
                            child: const Text('Add Soldier'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (provider.error != null)
                Center(
                  child: Text(provider.error!, style: const TextStyle(color: Colors.red)),
                ),
            ],
          );
        },
      ),
    );
  }
}