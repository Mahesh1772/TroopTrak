import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_project_2/user_models/user_details.dart';
import 'package:firebase_project_2/screens/detailed_screen/util/current_status_detailed_screen_tile.dart';
import 'package:firebase_project_2/screens/detailed_screen/util/past_status_detailed_screen_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

var fname = FirebaseAuth.instance.currentUser!.displayName.toString();
List<Map<String, dynamic>> userCurrentStatus = [];

class UserProfileStatusesTab extends StatefulWidget {
  const UserProfileStatusesTab({
    required this.docID,
    super.key,
  });
  final String docID;
  @override
  State<UserProfileStatusesTab> createState() => _UserProfileStatusesTabState();
}

class _UserProfileStatusesTabState extends State<UserProfileStatusesTab> {
  @override
  Widget build(BuildContext context) {
    final statusModel = Provider.of<MenUserData>(context);
    List<Map<String, dynamic>> userPastStatus = [];
    List<Map<String, dynamic>> toRemove = [];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.all(30.0.sp),
        child: StreamBuilder<QuerySnapshot>(
          stream: statusModel.status_data(widget.docID),
          builder: (context, snapshot) {
            var users = snapshot.data?.docs.toList();
            if (snapshot.hasData) {
              userCurrentStatus = [];
              userPastStatus = [];
              toRemove = [];
              for (var i = 0; i < users!.length; i++) {
                var data = users[i].data();
                userCurrentStatus.add(data as Map<String, dynamic>);
                userCurrentStatus[i]
                    .addEntries({'ID': users[i].reference.id}.entries);
              }
              for (var status in userCurrentStatus) {
                DateTime end =
                    DateFormat("d MMM yyyy").parse(status['endDate']);
                if (DateTime(end.year, end.month, end.day + 1)
                    .isBefore(DateTime.now())) {
                  userPastStatus.add(status);
                  toRemove.add(status);
                }
              }
              userCurrentStatus
                  .removeWhere((element) => toRemove.contains(element));
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.medical_information_rounded,
                      color: Colors.white,
                      size: 30.sp,
                    ),
                    SizedBox(
                      width: 20.w,
                    ),
                    Text(
                      "Active Statuses",
                      maxLines: 2,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 295.h,
                  child: ListView.builder(
                    itemCount: userCurrentStatus.length,
                    padding: EdgeInsets.all(12.sp),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return SoldierStatusTile(
                        statusID: userCurrentStatus[index]['ID'],
                        docID: fname,
                        statusType: userCurrentStatus[index]['statusType'],
                        statusName: userCurrentStatus[index]['statusName'],
                        startDate: userCurrentStatus[index]['startDate'],
                        endDate: userCurrentStatus[index]['endDate'],
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.av_timer_rounded,
                      color: Colors.white,
                      size: 30.sp,
                    ),
                    SizedBox(
                      width: 20.w,
                    ),
                    Text(
                      "Past Statuses",
                      maxLines: 2,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: userPastStatus.length,
                    itemBuilder: (context, index) {
                      return PastSoldierStatusTile(
                        statusID: userPastStatus[index]['ID'],
                        docID: fname,
                        statusType: userPastStatus[index]['statusType'],
                        statusName: userPastStatus[index]['statusName'],
                        startDate: userPastStatus[index]['startDate'],
                        endDate: userPastStatus[index]['endDate'],
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
