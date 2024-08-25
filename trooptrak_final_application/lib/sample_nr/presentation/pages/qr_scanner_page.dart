import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              color: Theme.of(context).colorScheme.primary,
            ),
            padding: EdgeInsets.all(12.sp),
            child: Column(
              children: [
                SizedBox(
                  height: 200.h,
                  child: ListView(
                    controller: controller,
                    children: [
                      Icon(
                        Icons.minimize_rounded,
                        color: Theme.of(context)
                            .colorScheme
                            .tertiary
                            .withOpacity(0.7),
                        size: 50.sp,
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "Scan QR Code",
                        style: Theme.of(context).textTheme.displayMedium,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "Please scan the QR code on the soldier's profile by placing it within the frame to add their details.",
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 400.h,
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
                      QRScannerOverlay(
                        overlayColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.54),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16.sp),
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
                                switch (state) {
                                  case TorchState.off:
                                    return const Icon(Icons.flash_off,
                                        color: Colors.grey);
                                  case TorchState.on:
                                    return const Icon(Icons.flash_on,
                                        color:
                                            Color.fromARGB(255, 72, 30, 229));
                                }
                              },
                            ),
                            iconSize: 30.0.sp,
                            onPressed: () => scannerController.toggleTorch(),
                          ),
                          IconButton(
                            icon: isStarted
                                ? const Icon(Icons.stop)
                                : const Icon(Icons.play_arrow),
                            iconSize: 30.0.sp,
                            onPressed: _startOrStop,
                          ),
                          IconButton(
                            icon: ValueListenableBuilder(
                              valueListenable:
                                  scannerController.cameraFacingState,
                              builder: (context, state, child) {
                                switch (state) {
                                  case CameraFacing.front:
                                    return const Icon(Icons.camera_front);
                                  case CameraFacing.back:
                                    return const Icon(Icons.camera_rear);
                                }
                              },
                            ),
                            iconSize: 30.0.sp,
                            onPressed: () => scannerController.switchCamera(),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Divider(
                              color: Theme.of(context).colorScheme.tertiary),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary),
                            child: Text(
                              "OR",
                              style: TextStyle(
                                  fontSize: 22.sp, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30.h),
                      GestureDetector(
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (image != null) {
                            final String? barcode = (await scannerController
                                .analyzeImage(image.path)) as String?;
                            if (barcode != null) {
                              provider.scanQRCode(barcode);
                            } else {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('No barcode found!'),
                                    backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                        child: Container(
                          height: 70.h,
                          padding: EdgeInsets.all(10.sp),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r),
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 72, 30, 229),
                                Color.fromARGB(255, 130, 60, 229),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image,
                                    color: Colors.white, size: 30.sp),
                                SizedBox(width: 20.w),
                                Text(
                                  'SELECT FROM GALLERY',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge!
                                      .copyWith(
                                        color: Colors.white,
                                      ),
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
