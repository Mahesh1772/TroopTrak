import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:prototype_1/screens/nominal_roll_screen/util/qr_scanner/qr_scanner_error_widget.dart';
import 'package:prototype_1/screens/nominal_roll_screen/util/qr_scanner/qr_scanner_overlay_shape.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:image_picker/image_picker.dart';

class QrCodeScannerPage extends StatefulWidget {
  const QrCodeScannerPage({super.key});

  @override
  State<QrCodeScannerPage> createState() => _QrCodeScannerPageState();
}

class _QrCodeScannerPageState extends State<QrCodeScannerPage>
    with SingleTickerProviderStateMixin {
  final MobileScannerController scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  BarcodeCapture? barcode;

  bool isStarted = true;

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
    Widget makeDismissible({required Widget child}) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(),
          child: GestureDetector(
            onTap: () {},
            child: child,
          ),
        );

    return makeDismissible(
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.9,
        maxChildSize: 1,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20.r),
            ),
            color: const Color.fromARGB(255, 21, 25, 34),
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
                      color: Colors.white70,
                      size: 50.sp,
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    StyledText(
                      "Scan QR Code",
                      24.sp,
                      fontWeight: FontWeight.bold,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Text(
                      "Please scan the QR code on the soldier's profile by placing it within the frame to add their details.",
                      style: GoogleFonts.poppins(
                        color: Colors.white60,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 400.h,
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: scannerController,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, child) {
                        return ScannerErrorWidget(error: error);
                      },
                      onDetect: (barcode) {
                        setState(() {
                          this.barcode = barcode;
                        });
                      },
                    ),
                    QRScannerOverlay(
                      overlayColor: const Color.fromARGB(255, 21, 25, 34),
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
                                  return const Icon(
                                    Icons.flash_off,
                                    color: Colors.grey,
                                  );
                                case TorchState.on:
                                  return const Icon(
                                    Icons.flash_on,
                                    color: Color.fromARGB(255, 72, 30, 229),
                                  );
                              }
                            },
                          ),
                          iconSize: 30.0.sp,
                          onPressed: () => scannerController.toggleTorch(),
                        ),
                        IconButton(
                          color: Colors.white,
                          icon: isStarted
                              ? const Icon(Icons.stop)
                              : const Icon(Icons.play_arrow),
                          iconSize: 30.0.sp,
                          onPressed: _startOrStop,
                        ),
                        IconButton(
                          color: Colors.white,
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
                    SizedBox(
                      height: 10.h,
                    ),
                    Stack(alignment: Alignment.center, children: [
                      const Divider(
                        color: Colors.white,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 21, 25, 34),
                        ),
                        child: StyledText(
                          "OR",
                          22.sp,
                          fontWeight: FontWeight.w500,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ]),
                    SizedBox(
                      height: 30.h,
                    ),
                    GestureDetector(
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          if (await scannerController
                              .analyzeImage(image.path)) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Barcode found!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No barcode found!'),
                                backgroundColor: Colors.red,
                              ),
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
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 130, 60, 229)
                                  .withOpacity(0.6),
                              spreadRadius: 1.r,
                              blurRadius: 16.r,
                              offset: Offset(8.w, 0.h),
                            ),
                            BoxShadow(
                              color: const Color.fromARGB(255, 72, 30, 229)
                                  .withOpacity(0.2),
                              spreadRadius: 8.r,
                              blurRadius: 8.r,
                              offset: Offset(-8.w, 0.h),
                            ),
                            BoxShadow(
                              color: const Color.fromARGB(255, 130, 60, 229)
                                  .withOpacity(0.2),
                              spreadRadius: 8.r,
                              blurRadius: 8.r,
                              offset: Offset(8.w, 0.h),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image,
                                color: Colors.white,
                                size: 30.sp,
                              ),
                              SizedBox(
                                width: 20.w,
                              ),
                              AutoSizeText(
                                'SELECT FROM GALLERY',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22.sp,
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
      ),
    );
  }
}
