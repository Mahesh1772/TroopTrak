import 'package:firebase_project_2/src/constants/colors.dart';
import 'package:firebase_project_2/src/constants/image_names.dart';
import 'package:firebase_project_2/src/constants/text_names.dart';
import 'package:flutter/material.dart';
import 'package:firebase_project_2/src/constants/sizes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  bool animate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              top: animate ? 0 : -30,
              left: 0,
              child: Image(
                image: AssetImage(SplashTopIcon),
              ),
            ),
            Positioned(
              top: 0,
              left: DefaultSize,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    AppTagLine,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ],
              ),
            ),
            const Positioned(
              bottom: 100,
              child: Image(
                image: AssetImage(SplashImage),
              ),
            ),
            Positioned(
              bottom: 40,
              right: DefaultSize,
              child: Container(
                width: SplashContainerSizer,
                height: SplashContainerSizer,
                color: PrimaryColor,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
