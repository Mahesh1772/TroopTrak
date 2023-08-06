import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/detailed_screen/tabs/statuses_screen/add_new_status_screen.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/detailed_screen/tabs/statuses_screen/update_status_screen.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/detailed_screen/util/current_status_detailed_screen_tile.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/detailed_screen/util/past_status_detailed_screen_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/user_models/user_details.dart';

List<Map<String, dynamic>> userCurrentStatus = [];

class StatusesTab extends StatefulWidget {
  const StatusesTab({super.key, required this.docID, required this.isToggled});

  final String docID;
  final bool isToggled;

  @override
  State<StatusesTab> createState() => _StatusesTabState();
}

class _StatusesTabState extends State<StatusesTab> {
  //This is what the stream builder is waiting forF

  @override
  Widget build(BuildContext context) {
    final Color textColor = widget.isToggled ? Colors.white : Colors.black;
    final statusModel = Provider.of<UserData>(context);
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
                      color: textColor,
                      size: 30.sp,
                    ),
                    SizedBox(
                      width: 20.w,
                    ),
                    Text(
                      "Active Statuses",
                      maxLines: 2,
                      style: GoogleFonts.poppins(
                        color: textColor,
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
                    shrinkWrap: true,
                    itemCount: userCurrentStatus.length,
                    padding: EdgeInsets.all(12.sp),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateStatusScreen(
                                statusID: userCurrentStatus[index]['ID'],
                                docID: widget.docID,
                                selectedStatusType: userCurrentStatus[index]
                                    ['statusType'],
                                statusName: TextEditingController(
                                    text: userCurrentStatus[index]['statusName']
                                        .toString()),
                                startDate: userCurrentStatus[index]
                                    ['startDate'],
                                endDate: userCurrentStatus[index]['endDate'],
                                isToggled: widget.isToggled,
                              ),
                            ),
                          );
                        },
                        child: SoldierStatusTile(
                          statusID: userCurrentStatus[index]['ID'],
                          docID: widget.docID,
                          statusType: userCurrentStatus[index]['statusType'],
                          statusName: userCurrentStatus[index]['statusName'],
                          startDate: userCurrentStatus[index]['startDate'],
                          endDate: userCurrentStatus[index]['endDate'],
                          start_date: userCurrentStatus[index]['start_id'],
                          end_date: userCurrentStatus[index]['end_id'],
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.av_timer_rounded,
                      color: textColor,
                      size: 30.sp,
                    ),
                    SizedBox(
                      width: 20.w,
                    ),
                    Text(
                      "Past Statuses",
                      maxLines: 2,
                      style: GoogleFonts.poppins(
                        color: textColor,
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
                        docID: widget.docID,
                        statusType: userPastStatus[index]['statusType'],
                        statusName: userPastStatus[index]['statusName'],
                        startDate: userPastStatus[index]['startDate'],
                        endDate: userPastStatus[index]['endDate'],
                        isToggled: widget.isToggled,
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddNewStatusScreen(
                            docID: widget.docID,
                            selectedStatusType: "Select status type...",
                            statusName: TextEditingController(),
                            startDate:
                                DateFormat('d MMM yyyy').format(DateTime.now()),
                            endDate:
                                DateFormat('d MMM yyyy').format(DateTime.now()),
                            isToggled: widget.isToggled,
                          ),
                        ),
                      );
                    },
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
                          borderRadius: BorderRadius.circular(50.0.r)),
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
                          Text(
                            "ADD NEW STATUS",
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
