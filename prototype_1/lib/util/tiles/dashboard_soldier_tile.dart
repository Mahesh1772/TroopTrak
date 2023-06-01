import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:prototype_1/screens/soldier_detailed_screen.dart';
import 'dart:math' as math;

class DashboardSoldierTile extends StatelessWidget {
  final String soldierName;
  final String soldierRank;
  final String company;
  final String platoon;
  final String section;
  final String soldierAppointment;
  final String dateOfBirth;
  final String rationType;
  final String bloodType;
  final String enlistmentDate;
  final String ordDate;

  const DashboardSoldierTile(
      {super.key,
      required this.soldierName,
      required this.soldierRank,
      required this.company,
      required this.platoon,
      required this.section,
      required this.soldierAppointment,
      required this.dateOfBirth,
      required this.rationType,
      required this.bloodType,
      required this.enlistmentDate,
      required this.ordDate});

  @override
  Widget build(BuildContext context) {
    List colors = [
      Colors.brown.shade800,
      Colors.indigo.shade800,
      Colors.indigo.shade400,
      Colors.teal.shade800,
      Colors.teal.shade400,
    ];

    int index = math.Random().nextInt(4);
    return Padding(
      padding: EdgeInsets.all(12.0.sp),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SoldierDetailedScreen(
                      soldierName: soldierName,
                      soldierRank: soldierRank,
                      company: company,
                      platoon: platoon,
                      section: section,
                      dateOfBirth: dateOfBirth,
                      enlistmentDate: enlistmentDate,
                      ordDate: ordDate,
                      soldierAppointment: soldierAppointment,
                      rationType: rationType,
                      bloodType: bloodType,
                    )),
          );
        },
        child: Container(
          width: 200.w,
          padding: EdgeInsets.all(12.sp),
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
                blurRadius: 2.0.r,
                spreadRadius: 2.0.r,
                offset: Offset(10.w, 10.h),
                color: Colors.black54)
          ], color: colors[index], borderRadius: BorderRadius.circular(12.r)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //soldier icon
                  Image.asset(
                    "lib/assets/army-ranks/soldier.png",
                    width: 60.w,
                  ),

                  //rank insignia
                  Image.asset(
                    soldierRank,
                    width: 30.w,
                  ),
                ],
              ),
              SizedBox(
                height: 10.h,
              ),
              StyledText(soldierName, 20.sp, fontWeight: FontWeight.bold)
            ],
          ),
        ),
      ),
    );
  }
}
