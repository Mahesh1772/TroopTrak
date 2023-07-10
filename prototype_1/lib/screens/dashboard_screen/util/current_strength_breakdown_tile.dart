// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prototype_1/screens/dashboard_screen/util/dashboard_soldier_tile.dart';
import 'package:prototype_1/util/constants.dart';
import 'package:provider/provider.dart';

import '../../../user_models/user_details.dart';

class CurrentStrengthBreakdownTile extends StatelessWidget {
  CurrentStrengthBreakdownTile(
      {super.key,
      required this.title,
      required this.imgSrc,
      required this.currentNumOfSoldiers,
      required this.totalNumOfSoldiers,
      required this.imgColor,
      required this.userDetails});

  final String title, imgSrc;
  final int currentNumOfSoldiers, totalNumOfSoldiers;
  final Color imgColor;
  final List<Map<String, dynamic>> userDetails;

  List<Map<String, dynamic>> dummy = [];

  int insideCamp = 0;

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserData>(context);
    userModel.last_attendance();
    print(userModel.fullList);
    for (var user in userDetails) {
      if (userModel.fullList[user['name']]) {
        insideCamp += 1;
      }
    }
    return Container(
      margin: EdgeInsets.only(
        top: defaultPadding.h,
      ),
      padding: EdgeInsets.all(defaultPadding.sp),
      decoration: BoxDecoration(
        border: Border.all(width: 2.w, color: Colors.blue.withOpacity(0.15)),
        borderRadius: const BorderRadius.all(
          Radius.circular(defaultPadding),
        ),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            SizedBox(
              height: 20.h,
              width: 20.w,
              child: Image.asset(
                imgSrc,
                color: imgColor,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: defaultPadding.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "$insideCamp In Camp",
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Text(
              "$insideCamp / $totalNumOfSoldiers",
              style: GoogleFonts.poppins(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
          ],
        ),
        collapsedIconColor: Colors.white,
        children: [
          SizedBox(
            height: 220.h,
            child: ListView.builder(
              itemCount: userDetails.length,
              padding: EdgeInsets.all(12.sp),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return DashboardSoldierTile(
                  soldierName: userDetails[index]['name'],
                  soldierRank: userDetails[index]['rank'],
                  soldierAppointment: userDetails[index]['appointment'],
                  company: userDetails[index]['company'],
                  platoon: userDetails[index]['platoon'],
                  section: userDetails[index]['section'],
                  dateOfBirth: userDetails[index]['dob'],
                  rationType: userDetails[index]['rationType'],
                  bloodType: userDetails[index]['bloodgroup'],
                  enlistmentDate: userDetails[index]['enlistment'],
                  ordDate: userDetails[index]['ord'],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
