import 'dart:async';
import 'package:flutter/material.dart';
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
          if (seconds < 0) {
            _.cancel();
            Navigator.pop(context);
          } else {
            myDuration = Duration(seconds: seconds);
          }
        });
      },
    );
  }

  void generateRandomId() {
    var v4 = uuid.v4(options: {'rng': UuidUtil.cryptoRNG});
    randomID = v4;
  }

  @override
  void initState() {
    // TODO: implement initState
    generateRandomId();
    startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));
    return Scaffold(
      backgroundColor: Colors.black12,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              child: Icon(Icons.arrow_back),
              hoverColor: Colors.amber,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(
              height: 50,
            ),
            Center(
              child: QrImageView(
                data: randomID, //data,
                size: 300,
                backgroundColor: Colors.white,
                version: QrVersions.auto,
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            Text(
              'QR will vanish in:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.pink,
                fontSize: 20,
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Text(
              '$minutes:$seconds',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.purpleAccent,
                fontSize: 30,
              ),
            )
          ],
        ),
      ),
    );
  }
}
