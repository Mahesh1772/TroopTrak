import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prototype_1/screens/guard_duty_tracker_screen.dart/util/guard_duty_main_page_tiles.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpcomingDuties extends StatefulWidget {
  const UpcomingDuties({super.key});

  @override
  State<UpcomingDuties> createState() => _UpcomingDutiesState();
}

//Stream we listen to
late Stream<QuerySnapshot> documentStream;

// List to store all user data, whilst also mapping to name
List<Map<String, dynamic>> dutyDetails = [];

//Loop variable
int i = 0;

class _UpcomingDutiesState extends State<UpcomingDuties> {
  @override
  void initState() {
    super.initState();
    documentStream =
        FirebaseFirestore.instance.collection('Duties').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(top: 50.h),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                child: StyledText("Upcoming Duties", 24.sp,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 15.h,
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: documentStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      dutyDetails = [];
                      var duties = snapshot.data?.docs.toList();
            
                      for (var i = 0; i < duties!.length; i++) {
                        var data = duties[i].data();
                        dutyDetails.add(data as Map<String, dynamic>);
                        dutyDetails[i]
                            .addEntries({'ID': duties[i].reference.id}.entries);
                      }
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: dutyDetails.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {},
                          child: GuardDutyTile(
                            docID: dutyDetails[index]['ID'],
                            participants: dutyDetails[index]['participants'],
                            dutyDate: dutyDetails[index]['dutyDate'],
                            startTime: dutyDetails[index]['startTime'],
                            endTime: dutyDetails[index]['endTime'],
                            dutyType: dutyDetails[index]['dayType'],
                            numberOfPoints: dutyDetails[index]['points'],
                          ),
                        );
                      },
                    );
                  }),
              SizedBox(
                height: 10.h,
              )
            ],
          ),
        ),
      ),
    );
  }
}
