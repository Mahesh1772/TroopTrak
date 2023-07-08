import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prototype_1/screens/detailed_screen/util/book_in_out_tile.dart.dart';

late Stream<QuerySnapshot> documentStream;
List<Map<String, dynamic>> userBookInStatus = [];

class AttendanceTab extends StatefulWidget {
  const AttendanceTab({
    super.key,
    required this.docID,
  });

  final String docID;

  @override
  State<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<AttendanceTab> {
  @override
  void initState() {
    documentStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.docID)
        .collection('Attendance')
        .snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.all(30.sp),
        child: StreamBuilder<QuerySnapshot>(
          stream: documentStream,
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
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.outbond,
                      color: Colors.white,
                      size: 30.sp,
                    ),
                    SizedBox(
                      width: 20.w,
                    ),
                    Text(
                      "Book In / Book Out",
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
                  height: 400.h,
                  child: ListView.builder(
                    itemCount: userBookInStatus.length,
                    padding: EdgeInsets.all(12.sp),
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      return BookInOutTile(
                        timeStamp: userBookInStatus[index]['date&time'],
                        isInsideCamp: userBookInStatus[index]['isInsideCamp'],
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