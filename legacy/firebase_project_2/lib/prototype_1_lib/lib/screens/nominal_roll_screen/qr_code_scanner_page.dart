import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/nominal_roll_screen/add_new_soldier_screen.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/nominal_roll_screen/util/qr_scanner/qr_scanner_error_widget.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/nominal_roll_screen/util/qr_scanner/qr_scanner_overlay_shape.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/util/text_styles/text_style.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:firebase_project_2/prototype_1_lib/lib/user_models/user_details.dart';

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

  void _foundBarcode(BarcodeCapture capture) {
    final userModel = Provider.of<UserData>(context, listen: false);
    final List<Barcode> barcodes = capture.barcodes;
    Map<String, dynamic> menDetails = {};

    for (final barcode in barcodes) {
      print('Barcode found! ${barcode.rawValue}');
    }

    void checkIfFilled() {
      if (menDetails.isEmpty) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return Center(
                child: Container(
                  color: Colors.black54,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.remove_circle_rounded,
                        color: Colors.red,
                        size: 40.sp,
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      StyledText("Invalid QR / No such key found!", 18.sp,
                          fontWeight: FontWeight.bold),
                    ],
                  ),
                ),
              );
            });
      } else {
        pushToAddSoldier(menDetails);
      }
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StreamBuilder<QuerySnapshot>(
              stream: userModel.men_data,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var userDetails = [];
                  var users = snapshot.data?.docs.toList();

                  for (var user in users!) {
                    var data = user.data();
                    userDetails.add(data as Map<String, dynamic>);
                  }

                  for (var details in userDetails) {
                    if (barcodes[0].rawValue.toString() == details['QRid']) {
                      menDetails = details;
                      //Push to the update soldier screen
                      //pushToAddSoldier(details);
                    }
                  }
                }
                return Center(
                  child: Container(
                    color: Colors.black54,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 40.sp,
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        StyledText("QR Code Successfully Scanned!", 18.sp,
                            fontWeight: FontWeight.bold),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            checkIfFilled();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 50.h,
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
                                    color:
                                        const Color.fromARGB(255, 130, 60, 229)
                                            .withOpacity(0.6),
                                    spreadRadius: 1.r,
                                    blurRadius: 16.r,
                                    offset: Offset(8.w, 0.h),
                                  ),
                                  BoxShadow(
                                    color:
                                        const Color.fromARGB(255, 72, 30, 229)
                                            .withOpacity(0.2),
                                    spreadRadius: 8.r,
                                    blurRadius: 8.r,
                                    offset: Offset(-8.w, 0.h),
                                  ),
                                  BoxShadow(
                                    color:
                                        const Color.fromARGB(255, 130, 60, 229)
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
                                      Icons.edit_document,
                                      color: Colors.white,
                                      size: 30.sp,
                                    ),
                                    SizedBox(
                                      width: 20.w,
                                    ),
                                    AutoSizeText(
                                      'GO TO EDIT PAGE',
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
                        ),
                      ],
                    ),
                  ),
                );
              });
        });
  }

  void pushToAddSoldier(Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNewSoldierPage(
          name: TextEditingController(text: data['name']),
          company: TextEditingController(text: data['company']),
          platoon: TextEditingController(text: data['platoon']),
          section: TextEditingController(text: data['section']),
          appointment: TextEditingController(text: data['appointment']),
          dob: data['dob'],
          ord: data['ord'],
          enlistment: data['enlistment'],
          selectedItem: data['rationType'],
          selectedRank: data['rank'],
          selectedBloodType: data['bloodgroup'],
        ),
      ),
    );
  }

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
                        color: Theme.of(context)
                            .colorScheme
                            .tertiary
                            .withOpacity(0.7),
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
                      onDetect: _foundBarcode,
                    ),
                    QRScannerOverlay(
                      overlayColor: Theme.of(context).colorScheme.primary,
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
                    SizedBox(
                      height: 10.h,
                    ),
                    Stack(alignment: Alignment.center, children: [
                      Divider(color: Theme.of(context).colorScheme.tertiary),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary),
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
