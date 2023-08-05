// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/dashboard_screen/util/dashboard_soldier_tile.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/util/constants.dart';

class CurrentStrengthBreakdownTile extends StatelessWidget {
  CurrentStrengthBreakdownTile({
    super.key,
    required this.title,
    required this.imgSrc,
    required this.currentNumOfSoldiers,
    required this.totalNumOfSoldiers,
    required this.imgColor,
    required this.userDetails,
    required this.fullList,
  });

  final String title, imgSrc;
  final int currentNumOfSoldiers, totalNumOfSoldiers;
  final Color imgColor;
  final List<Map<String, dynamic>> userDetails;

  Map<String, dynamic> fullList;

  List<Map<String, dynamic>> dummy = [];

  @override
  Widget build(BuildContext context) {
    //userDetails.removeWhere((element) => fullList[element['name']] == true);
    return Container(
      margin: EdgeInsets.only(
        top: defaultPadding.h,
      ),
      padding: EdgeInsets.all(defaultPadding.sp),
      decoration: BoxDecoration(
        border: Border.all(width: 2.w, color: Colors.blue.withOpacity(0.25)),
        borderRadius: const BorderRadius.all(
          Radius.circular(defaultPadding),
        ),
      ),
      child: ExpansionTile(
        textColor: Theme.of(context).colorScheme.tertiary,
        iconColor: Theme.of(context).colorScheme.tertiary,
        collapsedIconColor: Colors.blue,
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
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "$currentNumOfSoldiers In Camp",
                      style: GoogleFonts.poppins(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.45),
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
              "$currentNumOfSoldiers / $totalNumOfSoldiers",
              style: GoogleFonts.poppins(
                fontSize: 24.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        children: [
          SizedBox(
            height: 220.h,
            child: ListView.builder(
              itemCount: userDetails.length,
              padding: EdgeInsets.all(12.sp),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return DashboardSoldierTile(
                  docID: userDetails[index]['name'],
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
