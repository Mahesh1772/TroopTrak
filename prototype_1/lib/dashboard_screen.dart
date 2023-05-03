import 'package:flutter/material.dart';
import 'package:prototype_1/text_style.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 21, 25, 34),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: StyledText('Dashboard', 20),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(
                    'lib/assets/user.png',
                    width: 50,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: StyledText('Welcome,\nAakash 👋', 32),
            ),
          ],
        ),
      ),
    );
  }
}
