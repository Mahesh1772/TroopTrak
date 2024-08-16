import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/qr_scanner_provider.dart';
import '../widgets/qr_scanner_overlay.dart';
import '../widgets/qr_scanner_error_widget.dart';
import 'package:image_picker/image_picker.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  late MobileScannerController scannerController;
  bool isStarted = true;

  @override
  void initState() {
    super.initState();
    scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  void _startOrStop() {
    try {
      if (isStarted) {
        scannerController.stop();
      } else {
        scannerController.start();
      }
      setState(() {
        isStarted = !isStarted;
      });
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong! $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QRScannerProvider>(
      builder: (context, provider, child) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.9,
          maxChildSize: 1,
          builder: (_, controller) => Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              color: Theme.of(context).colorScheme.primary,
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: ListView(
                    controller: controller,
                    children: [
                      Icon(
                        Icons.minimize_rounded,
                        color: Theme.of(context).colorScheme.tertiary.withOpacity(0.7),
                        size: 50,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Scan QR Code",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Please scan the QR code on the soldier's profile by placing it within the frame to add their details.",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary.withOpacity(0.7),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 400,
                  child: Stack(
                    children: [
                      MobileScanner(
                        controller: scannerController,
                        onDetect: (capture) {
                          final List<Barcode> barcodes = capture.barcodes;
                          for (final barcode in barcodes) {
                            provider.scanQRCode(barcode.rawValue ?? '');
                          }
                        },
                        errorBuilder: (context, error, child) {
                          return QRScannerErrorWidget(error: error);
                        },
                      ),
                      const QRScannerOverlay(overlayColor: Colors.black54),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            color: Colors.white,
                            icon: ValueListenableBuilder(
                              valueListenable: scannerController.torchState,
                              builder: (context, state, child) {
                                switch (state as TorchState) {
                                  case TorchState.off:
                                    return const Icon(Icons.flash_off, color: Colors.grey);
                                  case TorchState.on:
                                    return const Icon(Icons.flash_on, color: Color.fromARGB(255, 72, 30, 229));
                                  case TorchState.auto:
                                    // TODO: Handle this case.
                                  case TorchState.unavailable:
                                    // TODO: Handle this case.
                                }
                              },
                            ),
                            iconSize: 30.0,
                            onPressed: () => scannerController.toggleTorch(),
                          ),
                          IconButton(
                            icon: isStarted ? const Icon(Icons.stop) : const Icon(Icons.play_arrow),
                            iconSize: 30.0,
                            onPressed: _startOrStop,
                          ),
                          IconButton(
                            icon: ValueListenableBuilder(
                              valueListenable: scannerController.cameraFacingState,
                              builder: (context, state, child) {
                                switch (state as CameraFacing) {
                                  case CameraFacing.front:
                                    return const Icon(Icons.camera_front);
                                  case CameraFacing.back:
                                    return const Icon(Icons.camera_rear);
                                }
                              },
                            ),
                            iconSize: 30.0,
                            onPressed: () => scannerController.switchCamera(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Divider(color: Theme.of(context).colorScheme.tertiary),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
                            child: const Text(
                              "OR",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      GestureDetector(
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            final String? barcode = (await scannerController.analyzeImage(image.path)) as String?;
                            if (barcode != null) {
                              provider.scanQRCode(barcode);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('No barcode found!'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                        child: Container(
                          height: 70,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 72, 30, 229),
                                Color.fromARGB(255, 130, 60, 229),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image, color: Colors.white, size: 30),
                                SizedBox(width: 20),
                                Text(
                                  'SELECT FROM GALLERY',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}