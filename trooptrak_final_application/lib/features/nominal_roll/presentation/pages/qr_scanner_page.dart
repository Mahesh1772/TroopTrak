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
    final theme = Theme.of(context);
    return Consumer<QRScannerProvider>(
      builder: (context, provider, child) {
        if (provider.showSuccessMessage) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: theme.colorScheme.primary,
                title: Text(
                  'Success',
                  style: theme.textTheme.headlineMedium,
                ),
                content: Text(
                  'User added successfully!',
                  style: theme.textTheme.bodyLarge,
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      'Close',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    onPressed: () {
                      provider.hideSuccessMessage();
                      Navigator.of(context).pop(); // Close the dialog
                      Navigator.of(context).pop(); // Close the QR scanner
                    },
                  ),
                ],
              );
            },
          );
        }

        return DraggableScrollableSheet(
          initialChildSize: 0.95,
          minChildSize: 0.95,
          maxChildSize: 1,
          builder: (_, controller) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              color: theme.colorScheme.primary,
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              children: [
                // Header Section
                Container(
                  height: 160.h,
                  child: ListView(
                    controller: controller,
                    children: [
                      Icon(
                        Icons.minimize_rounded,
                        color: theme.colorScheme.tertiary.withOpacity(0.7),
                        size: 32.sp,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        "Scan QR Code",
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        "Please scan the QR code on the soldier's profile by placing it within the frame to add their details.",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 14.sp,
                          color: theme.colorScheme.tertiary.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                
                // Scanner Section
                Container(
                  height: 380.h,
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
                        overlayColor: theme.colorScheme.primary.withOpacity(0.54),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Controls Section
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            color: theme.colorScheme.tertiary,
                            icon: ValueListenableBuilder(
                              valueListenable: scannerController.torchState,
                              builder: (context, state, child) {
                                switch (state) {
                                  case TorchState.off:
                                    return Icon(
                                      Icons.flash_off,
                                      color: theme.colorScheme.tertiary.withOpacity(0.5),
                                      size: 24.sp,
                                    );
                                  case TorchState.on:
                                    return Icon(
                                      Icons.flash_on,
                                      color: theme.colorScheme.secondary,
                                      size: 24.sp,
                                    );
                                }
                              },
                            ),
                            onPressed: () => scannerController.toggleTorch(),
                          ),
                          IconButton(
                            color: theme.colorScheme.tertiary,
                            icon: isStarted
                                ? Icon(Icons.stop, size: 24.sp)
                                : Icon(Icons.play_arrow, size: 24.sp),
                            onPressed: _startOrStop,
                          ),
                          IconButton(
                            color: theme.colorScheme.tertiary,
                            icon: ValueListenableBuilder(
                              valueListenable: scannerController.cameraFacingState,
                              builder: (context, state, child) {
                                switch (state) {
                                  case CameraFacing.front:
                                    return Icon(Icons.camera_front, size: 24.sp);
                                  case CameraFacing.back:
                                    return Icon(Icons.camera_rear, size: 24.sp);
                                }
                              },
                            ),
                            onPressed: () => scannerController.switchCamera(),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Divider(
                            color: theme.colorScheme.tertiary.withOpacity(0.3),
                            thickness: 1.h,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            color: theme.colorScheme.primary,
                            child: Text(
                              "OR",
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.tertiary.withOpacity(0.7),
                                fontSize: 14.sp,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
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
                                SnackBar(
                                  content: Text(
                                    'No QR code found in the image',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  backgroundColor: theme.colorScheme.error,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  margin: EdgeInsets.all(16.w),
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          height: 56.h,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.secondary,
                                theme.colorScheme.secondary.withOpacity(0.8),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.secondary.withOpacity(0.3),
                                spreadRadius: 1.r,
                                blurRadius: 16.r,
                                offset: Offset(8.w, 0.h),
                              ),
                              BoxShadow(
                                color: theme.colorScheme.secondary.withOpacity(0.2),
                                spreadRadius: 8.r,
                                blurRadius: 8.r,
                                offset: Offset(-8.w, 0.h),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image,
                                color: Colors.white,
                                size: 24.sp,
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                'Upload QR Code',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp,
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
            ),
          ),
        );
      },
    );
  }
}
