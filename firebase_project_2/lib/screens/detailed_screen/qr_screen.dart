import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_project_2/screens/detailed_screen/util/custom_rect_tween.dart';
import 'package:firebase_project_2/util/text_styles/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

class GenerateQRScreen extends StatefulWidget {
  const GenerateQRScreen({super.key});

  @override
  State<GenerateQRScreen> createState() => _GenerateQRScreenState();
}

class _GenerateQRScreenState extends State<GenerateQRScreen> {
  String randomID = '';
  var firestore = FirebaseFirestore.instance.collection('Men');
  var fname = FirebaseAuth.instance.currentUser!.uid.toString();
  var uuid = Uuid();
  Timer? countdownTimer;
  Duration myDuration = const Duration(
    minutes: 2,
  );

  void startTimer() {
    countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        setState(() {
          final seconds = myDuration.inSeconds - 1;
          print(seconds);
          if (seconds < 0) {
            countdownTimer?.cancel();
            //_.cancel();
            firestore.doc(fname).set({
              'QRid': null,
            }, SetOptions(merge: true));
            Navigator.pop(context);
          } else {
            myDuration = Duration(seconds: seconds);
          }
        });
      },
    );
  }

  void generateRandomId() async {
    var v4 = uuid.v4(options: {'rng': UuidUtil.cryptoRNG});
    randomID = v4;
    await firestore.doc(fname).set({
      'QRid': randomID,
    }, SetOptions(merge: true));
  }

  @override
  void initState() {
    generateRandomId();
    startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.0.sp),
        child: Hero(
          tag: "QRCodeScreen",
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin!, end: end!);
          },
          child: Material(
            color: const Color.fromARGB(255, 39, 43, 58),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(vertical: 32.0.h, horizontal: 16.0.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          hoverColor: Colors.amber,
                          onTap: () async{
                            await firestore.doc(fname).set({
                              'QRid': null,
                            }, SetOptions(merge: true));
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 30.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    StyledText("ADD A NEW SOLDIER", 24.sp,
                        fontWeight: FontWeight.w600),
                    Divider(
                      color: Colors.white,
                      thickness: 0.2.h,
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0.sp),
                      child: Center(
                        child: QrImageView(
                          data: randomID, //data,
                          size: 300.sp,
                          backgroundColor: Colors.white,
                          version: QrVersions.auto,
                        ),
                      ),
                    ),
                    StyledText(
                      'Have a commander scan the above QR code to add your details on their end.',
                      18.sp,
                      fontWeight: FontWeight.w500,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 24.h,
                    ),
                    StyledText('QR will vanish in:', 20.sp,
                        fontWeight: FontWeight.w500),
                    SizedBox(
                      height: 10.0.h,
                    ),
                    Text(
                      '$minutes:$seconds',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.purpleAccent,
                        fontSize: 35.sp,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
