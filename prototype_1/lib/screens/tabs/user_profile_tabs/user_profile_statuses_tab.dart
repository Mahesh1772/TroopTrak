import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:prototype_1/util/tiles/current_status_detailed_screen_tile.dart';
import 'package:prototype_1/util/tiles/past_status_detailed_screen_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

var fname = FirebaseAuth.instance.currentUser!.displayName.toString();
var soldierStatuses = [
  //soldierStatuses - [statusType, statusName, startDate, endDate]
  ["Excuse", "Ex FLEGs", "13 Jul 2021", "12 Jul 2022"],
  ["Leave", "MC", "10 Jun 2021", "12 Jul 2021"],
  ["Medical Appointment", "National Skin Centre", "5 Apr 2021", "5 Apr 2021"],
];

var pastStatuses = [
  //soldierStatuses - [statusType, statusName, startDate, endDate]
  ["Excuse", "Ex FLEGs", "13 Jul 2021", "12 Jul 2022"],
  ["Leave", "MC", "10 Jun 2021", "12 Jul 2021"],
  ["Medical Appointment", "National Skin Centre", "5 Apr 2021", "5 Apr 2021"],
  ["Excuse", "Ex FLEGs", "13 Jul 2021", "12 Jul 2022"],
  ["Leave", "MC", "10 Jun 2021", "12 Jul 2021"],
  ["Medical Appointment", "National Skin Centre", "5 Apr 2021", "5 Apr 2021"],
];

class UserProfileStatusesTab extends StatefulWidget {
  const UserProfileStatusesTab({
    super.key,
    required this.docID,
  });

  final String docID;

  @override
  State<UserProfileStatusesTab> createState() => _UserProfileStatusesTabState();
}

class _UserProfileStatusesTabState extends State<UserProfileStatusesTab> {
  late Stream<QuerySnapshot> documentStream;
  @override
  void initState() {
    documentStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.docID)
        .collection('Statuses')
        .snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> userCurrentStatus = [];
    List<Map<String, dynamic>> userPastStatus = [];
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.all(30.0.sp),
        child: StreamBuilder<QuerySnapshot>(
            stream: documentStream,
            builder: (context, snapshot) {
              var users = snapshot.data?.docs.toList();
              if (snapshot.hasData) {
                userCurrentStatus = [];
                for (var i = 0; i < users!.length; i++) {
                  var data = users[i].data();
                  userCurrentStatus.add(data as Map<String, dynamic>);
                  userCurrentStatus[i]
                      .addEntries({'ID': users[i].reference.id}.entries);
                }
                for (var status in userCurrentStatus) {
                  if (DateFormat("d MMM yyyy")
                      .parse(status['endDate'])
                      .isBefore(DateTime.now())) {
                    userPastStatus.add(status);
                    userCurrentStatus.remove(status);
                  }
                }
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
                    height: 250.h,
                    child: ListView.builder(
                      itemCount: soldierStatuses.length,
                      padding: EdgeInsets.all(12.sp),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return SoldierStatusTile(
                          statusID: userCurrentStatus[index]['ID'],
                          docID: widget.docID,
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
                      itemCount: pastStatuses.length,
                      itemBuilder: (context, index) {
                        return PastSoldierStatusTile(
                            statusID: '',
                            docID: widget.docID,
                            statusType: pastStatuses[index][0],
                            statusName: pastStatuses[index][1],
                            startDate: pastStatuses[index][2],
                            endDate: pastStatuses[index][3]);
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 40.0.w, vertical: 16.0.h),
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 72, 30, 229),
                                Color.fromARGB(255, 130, 60, 229),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(50.0)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.note_add,
                              color: Colors.white,
                              size: 30.sp,
                            ),
                            SizedBox(
                              width: 20.w,
                            ),
                            StyledText("ADD NEW STATUS", 18.sp,
                                fontWeight: FontWeight.bold),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }
}
