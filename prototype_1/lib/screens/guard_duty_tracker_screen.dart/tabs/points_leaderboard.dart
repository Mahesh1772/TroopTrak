import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prototype_1/screens/guard_duty_tracker_screen.dart/util/duty_personnel_data_source.dart';
import 'package:prototype_1/util/constants.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class PointsLeaderBoard extends StatefulWidget {
  const PointsLeaderBoard({super.key});

  @override
  State<PointsLeaderBoard> createState() => _PointsLeaderBoardState();
}

class DutyPersonnel {
  DutyPersonnel(this.name, this.image, this.rank, this.points);
  final String name;
  final String image;
  final String rank;
  final int points;
}

//This is what the stream builder is waiting for
late Stream<QuerySnapshot> documentStream;

// The list of all document IDs,
//which have access to each their own personal information
List<String> documentIDs = [];

// List to store all user data, whilst also mapping to name
List<Map<String, dynamic>> userDetails = [];

//Information for column of data
List<DutyPersonnel> dutyPersonnel = <DutyPersonnel>[];

//bool value,
bool isFirstTIme = true;

late DutyPersonnelDataSource dutyPersonnelDataSource;

//All information on Duties
List<Map<dynamic, dynamic>> dutyInfo = [];

//To have a points table
Map<dynamic, double> pointsTable = {};

List<DutyPersonnel> getDutyPersonnel() {
  List<DutyPersonnel> array = [];
  if (userDetails.isNotEmpty) {
    for (int i = 0; i < userDetails.length; i += 1) {
      array.add(DutyPersonnel(
          userDetails[i]['name'],
          "lib/assets/army-ranks/solider.png",
          userDetails[i]['rank'],
          pointsTable[userDetails[i]['name']]!.toInt()));
      print(pointsTable[userDetails[i]['name']]);
    }
    print(userDetails.length);
  }
  return array;
}

class _PointsLeaderBoardState extends State<PointsLeaderBoard> {
  Future getDutyInfo() async {
    if (isFirstTIme) {
      FirebaseFirestore.instance
          .collection("Duties")
          .get()
          .then((querySnapshot) async {
        for (var snapshot in querySnapshot.docs) {
          Map<String, dynamic> data = snapshot.data();
          dutyInfo.add(data);
        }
      });
    }
  }

  Future getDocIDs() async {
    FirebaseFirestore.instance
        .collection('Users')
        .get()
        .then((value) => value.docs.forEach((element) {
              Map<String, dynamic> data = element.data();
              documentIDs.add(element['name']);
              if (isFirstTIme) {
                pointsTable.addEntries({data['name']: 0.0}.entries);
              }
            }));
  }

  void getDutyPoints() {
    for (var info in dutyInfo) {
      for (var person in info['participants']) {
        if (isFirstTIme) {
          pointsTable[person] = (pointsTable[person]! + info['points']);
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    documentStream = FirebaseFirestore.instance.collection('Users').snapshots();
    getDutyInfo();
    getDocIDs();
    //getDutyPoints();
    //print(pointsTable);
    dutyPersonnel = getDutyPersonnel();
    dutyPersonnelDataSource =
        DutyPersonnelDataSource(dutyPersonnel: dutyPersonnel);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20.0.h),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: EdgeInsets.all(defaultPadding.sp),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black54,
                          offset: Offset(10.0.w, 10.0.h),
                          blurRadius: 2.0.r,
                          spreadRadius: 2.0.r),
                    ],
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 72, 30, 229),
                        Color.fromARGB(255, 130, 60, 229),
                      ],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.r)),
                  ),
                  child: const Icon(Icons.leaderboard_rounded,
                      color: Colors.white),
                ),
                SizedBox(
                  width: 20.w,
                ),
                StyledText("Points Leaderboard", 24.sp,
                    fontWeight: FontWeight.bold),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 30.0.h),
              child: StreamBuilder<QuerySnapshot>(
                stream: documentStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    getDutyPoints();
                    isFirstTIme = false;
                    documentIDs = [];
                    userDetails = [];
                    var users = snapshot.data?.docs.toList();
                    for (var user in users!) {
                      var data = user.data();
                      userDetails.add(data as Map<String, dynamic>);
                    }
                    dutyPersonnel = getDutyPersonnel();
                    dutyPersonnelDataSource =
                        DutyPersonnelDataSource(dutyPersonnel: dutyPersonnel);
                  }
                  return Padding(
                    padding: EdgeInsets.all(8.0.sp),
                    child: SizedBox(
                      width: double.maxFinite,
                      height: 630.h,
                      child: SfDataGridTheme(
                        data: SfDataGridThemeData(
                            sortIconColor: Colors.white,
                            filterIconColor: Colors.white,
                            headerColor: Colors.deepPurple.shade700),
                        child: SfDataGrid(
                          rowHeight: 100.h,
                          allowSorting: true,
                          allowFiltering: true,
                          source: dutyPersonnelDataSource,
                          columnWidthMode: ColumnWidthMode.fill,
                          columns: <GridColumn>[
                            GridColumn(
                              columnName: 'rank',
                              label: Container(
                                padding: EdgeInsets.all(16.0.sp),
                                alignment: Alignment.center,
                                child: StyledText("Rank", 20.sp,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            GridColumn(
                              columnName: 'name',
                              label: Container(
                                padding: EdgeInsets.all(16.0.sp),
                                alignment: Alignment.center,
                                child: StyledText("Name", 20.sp,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            GridColumn(
                              columnName: 'points',
                              label: Container(
                                padding: EdgeInsets.all(16.0.sp),
                                alignment: Alignment.center,
                                child: StyledText("Points", 20.sp,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
