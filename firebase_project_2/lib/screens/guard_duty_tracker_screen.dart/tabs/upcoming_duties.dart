import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_project_2/screens/guard_duty_tracker_screen.dart/util/guard_duty_main_page_tiles.dart';
import 'package:firebase_project_2/util/text_styles/text_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../../user_models/user_details.dart';

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

String fname = FirebaseAuth.instance.currentUser!.displayName.toString();

class _UpcomingDutiesState extends State<UpcomingDuties> {
  bool isPartcipant(Map<String, dynamic> todayConducts, String name) {
    if (todayConducts.containsKey(name)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final statusModel = Provider.of<UserData>(context);
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
                  stream: statusModel.duty_data,
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
                      print(dutyDetails.last['participants']);
                    }
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      physics: const PageScrollPhysics(),
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
                            isUserParticipating: isPartcipant(
                                dutyDetails[index]['participants'], fname),
                          ),
                        );
                      },
                    );
                  }),
              SizedBox(
                height: 50.h,
              )
            ],
          ),
        ),
      ),
    );
  }
}
