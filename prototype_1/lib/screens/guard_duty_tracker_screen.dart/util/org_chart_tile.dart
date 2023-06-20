import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:popup_card/popup_card.dart';
import 'package:prototype_1/screens/guard_duty_tracker_screen.dart/util/hero_dialog_route.dart';
import 'package:prototype_1/screens/guard_duty_tracker_screen.dart/add_duty_soldiers_card.dart';

class OrgChartTile extends StatelessWidget {
  const OrgChartTile({super.key, required this.rank, required this.name});

  final String rank;
  final String name;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          HeroDialogRoute(
            builder: (context) {
              return const AddDutySoldiersCard();
            },
          ),
        );
      },
      child: Container(
        width: 95.w,
        height: 95.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 38, 31, 60),
              Color.fromARGB(255, 54, 60, 81),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(8.0.sp),
              child: CircleAvatar(
                backgroundColor: Colors.black,
                child: Image.asset(
                  "lib/assets/army-ranks/${rank.toLowerCase().toString()}.png",
                  width: 20.w,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              width: 90.w,
              height: 20.h,
              child: AutoSizeText(
                name,
                maxLines: 2,
                minFontSize: 12,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
