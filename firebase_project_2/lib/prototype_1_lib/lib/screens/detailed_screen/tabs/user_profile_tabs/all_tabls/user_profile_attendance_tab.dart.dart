import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/detailed_screen/util/book_in_out_tile.dart.dart';
import 'package:provider/provider.dart';

import 'package:firebase_project_2/prototype_1_lib/lib/user_models/user_details.dart';

var fname = FirebaseAuth.instance.currentUser!.displayName.toString();
var id = FirebaseAuth.instance.currentUser!;

late Stream<QuerySnapshot> documentStream;
List<Map<String, dynamic>> userBookInStatus = [];

class UserProfileAttendanceTab extends StatefulWidget {
  const UserProfileAttendanceTab({
    super.key,
    required this.isToggled,
  });

  final bool isToggled;

  @override
  State<UserProfileAttendanceTab> createState() =>
      _UserProfileAttendanceTabState();
}

class _UserProfileAttendanceTabState extends State<UserProfileAttendanceTab> {
  @override
  Widget build(BuildContext context) {
    final Color textColor = widget.isToggled ? Colors.white : Colors.black;
    final statusModel = Provider.of<UserData>(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.all(30.sp),
        child: StreamBuilder<QuerySnapshot>(
          stream: statusModel.attendance_data(fname),
          builder: (context, snapshot) {
            var users = snapshot.data?.docs.toList();

            if (snapshot.hasData) {
              userBookInStatus = [];

              for (var i = 0; i < users!.length; i++) {
                var data = users[i].data();
                userBookInStatus.add(data as Map<String, dynamic>);
                userBookInStatus[i]
                    .addEntries({'ID': users[i].reference.id}.entries);
              }
            }
            userBookInStatus.sort((m1, m2) {
              var r = DateFormat("E d MMM yyyy HH:mm:ss")
                  .parse(m1["date&time"])
                  .compareTo(DateFormat("E d MMM yyyy HH:mm:ss")
                      .parse(m2["date&time"]));
              if (r != 0) return r;
              return DateFormat("E d MMM yyyy HH:mm:ss")
                  .parse(m1["date&time"])
                  .compareTo(DateFormat("E d MMM yyyy HH:mm:ss")
                      .parse(m2["date&time"]));
            });
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.outbond,
                      color: textColor,
                      size: 30.sp,
                    ),
                    SizedBox(
                      width: 20.w,
                    ),
                    Text(
                      "Book In / Book Out",
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
                  height: 400.h,
                  child: ListView.builder(
                    itemCount: userBookInStatus.length,
                    padding: EdgeInsets.all(12.sp),
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      return BookInOutTile(
                        docID: fname,
                        attendanceID: userBookInStatus[index]['ID'],
                        timeStamp: userBookInStatus[index]['date&time'],
                        isInsideCamp: userBookInStatus[index]['isInsideCamp'],
                        isToggled: widget.isToggled,
                      );
                    },
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
