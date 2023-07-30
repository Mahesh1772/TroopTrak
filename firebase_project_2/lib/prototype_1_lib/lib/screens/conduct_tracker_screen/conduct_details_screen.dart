import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/conduct_tracker_screen/update_conduct_screen.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/util/text_styles/text_style.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';

import 'package:firebase_project_2/prototype_1_lib/lib/user_models/user_details.dart';

class ConductDetailsScreen extends StatefulWidget {
  const ConductDetailsScreen({
    super.key,
    required this.conductName,
    required this.conductType,
    required this.startDate,
    required this.startTime,
    required this.endTime,
    required this.participants,
    required this.conductID,
  });

  final String conductName;
  final String conductType;
  final String startDate;
  final String startTime;
  final String endTime;
  final List participants;
  final String conductID;
  @override
  State<ConductDetailsScreen> createState() => _ConductDetailsScreenState();
}

//Map that contains conduct Details
Map<String, dynamic> conductData = {};

String excuseText = "Removed from conduct";

Map<String, dynamic> soldierReason = {};

class _ConductDetailsScreenState extends State<ConductDetailsScreen> {
  //This is what the stream builder is waiting for
  late Stream<QuerySnapshot> documentStream;

  //This is what the stream builder is waiting for
  late Stream<QuerySnapshot> conductStream;

  // The list of all document IDs,
  //which have access to each their own personal information
  List<String> documentIDs = [];

  // List to store all user data, whilst also mapping to name
  List<Map<String, dynamic>> userDetails = [];
  List<Map<String, dynamic>> toRemove = [];
  List listOfParticipants = [];
  List<Map<String, dynamic>> nonParticipants = [];

  // To store text being searched
  String searchText = '';

  Future deleteConductDetails() async {
    await FirebaseFirestore.instance
        .collection('Conducts')
        .doc(widget.conductID)
        .delete();
  }

  deleteConduct() async {
    await deleteConductDetails();
    Navigator.pop(context);
  }

  Future getDocIDs() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .get()
        .then((value) => value.docs.forEach((element) {
              documentIDs.add(element['name']);
            }));
  }

  @override
  void initState() {
    documentStream = FirebaseFirestore.instance.collection('Users').snapshots();
    conductStream =
        FirebaseFirestore.instance.collection('Conducts').snapshots();
    getDocIDs();
    super.initState();
  }

  callback(listofusers, nonparts) {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => super.widget));
    documentStream = FirebaseFirestore.instance.collection('Users').snapshots();
    conductStream =
        FirebaseFirestore.instance.collection('Conducts').snapshots();
    listofusers = userDetails;
    nonparts = nonParticipants;
    WidgetsBinding.instance.addPostFrameCallback((_) => build);
  }

  List<String> nonparticipantlist() {
    documentIDs.removeWhere(
        (element) => conductData['participants'].contains(element));
    return documentIDs;
  }

  @override
  Widget build(BuildContext context) {
    final conductModel = Provider.of<UserData>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 21, 25, 34),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12.0.r)),
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 72, 30, 229),
                    Color.fromARGB(255, 130, 60, 229),
                  ],
                ),
              ),
              child: SafeArea(
                child: StreamBuilder2<DocumentSnapshot<Map<String, dynamic>>,
                        QuerySnapshot>(
                    streams: StreamTuple2(
                        conductModel.conduct_data(widget.conductID),
                        conductModel.data),
                    builder: (context, snapshots) {
                      if (snapshots.snapshot1.hasData) {
                        conductData = snapshots.snapshot1.data!.data()
                            as Map<String, dynamic>;
                        conductData
                            .addEntries({'ID': widget.conductID}.entries);

                        documentIDs.removeWhere((element) =>
                            conductData['participants'].contains(element));
                      }
                      if (snapshots.snapshot2.hasData) {
                        List? users = snapshots.snapshot2.data?.docs.toList();
                        documentIDs = [];
                        userDetails = [];
                        nonParticipants = [];

                        if (searchText.isNotEmpty) {
                          users = users!.where((element) {
                            return element
                                .get('name')
                                .toString()
                                .toLowerCase()
                                .contains(searchText.toLowerCase());
                          }).toList();
                          for (var user in users) {
                            var data = user.data();
                            if (conductData['participants']
                                .contains(user['name'])) {
                              userDetails.add(data as Map<String, dynamic>);
                            } else {
                              nonParticipants.add(data as Map<String, dynamic>);
                            }
                          }

                          if (userDetails.isEmpty && nonParticipants.isEmpty) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: Text(
                                    'Nothing to see here...yet.',
                                    style: GoogleFonts.poppins(
                                      color: Colors.lightBlue,
                                      fontSize: 24.sp,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            );
                          }
                        } else {
                          for (var user in users!) {
                            var data = user.data();
                            if (conductData['participants']
                                .contains(user['name'])) {
                              userDetails.add(data as Map<String, dynamic>);
                            } else {
                              nonParticipants.add(data as Map<String, dynamic>);
                            }
                          }
                        }
                        userDetails.removeWhere(
                            (element) => toRemove.contains(element));
                        nonParticipants.removeWhere(
                            (element) => toRemove.contains(element));
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 20.h),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Icon(
                                          Icons.arrow_back_sharp,
                                          color: Colors.white,
                                          size: 25.sp,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      UpdateConductScreen(
                                                    conductID:
                                                        conductData['ID'],
                                                    selectedConductType:
                                                        conductData[
                                                            'conductType'],
                                                    nonParticipants:
                                                        nonparticipantlist(),
                                                    conductName:
                                                        TextEditingController(
                                                      text: conductData[
                                                          'conductName'],
                                                    ),
                                                    startDate: conductData[
                                                        'startDate'],
                                                    startTime: conductData[
                                                        'startTime'],
                                                    endTime:
                                                        conductData['endTime'],
                                                    callbackFunction: callback,
                                                    participants: conductData['participants'],
                                                  ),
                                                ),
                                              ).then(
                                                (value) => setState(
                                                  () {
                                                    documentStream =
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('Users')
                                                            .snapshots();
                                                    conductStream =
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'Conducts')
                                                            .snapshots();
                                                    Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (BuildContext
                                                                    context) =>
                                                                super.widget));
                                                    WidgetsBinding.instance
                                                        .addPostFrameCallback(
                                                            (_) => build);
                                                  },
                                                ),
                                              );
                                            },
                                            child: Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 25.sp,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 40.w,
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              await deleteConduct();
                                            },
                                            child: Icon(
                                              Icons.delete_forever,
                                              color: Colors.white,
                                              size: 25.sp,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20.h,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 20.0.w,
                                        right: 20.0.w,
                                        top: 20.0.h),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                conductData['conductType']
                                                    .toUpperCase(),
                                                maxLines: 2,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 24.sp,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 1.5,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5.h,
                                              ),
                                              Text(
                                                conductData['conductName'],
                                                maxLines: 3,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 35.sp,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20.h,
                                  ),
                                  Center(
                                    child: Text(
                                      conductData['startDate'].toUpperCase(),
                                      maxLines: 2,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20.h,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Padding(
                              padding: EdgeInsets.all(20.0.sp),
                              child: TextField(
                                onChanged: (value) {
                                  setState(() {
                                    searchText = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search Name',
                                  prefixIcon: const Icon(Icons.search_sharp),
                                  prefixIconColor: Colors.indigo.shade900,
                                  fillColor: Colors.amber,
                                  filled: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                      borderSide: BorderSide.none),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      StyledText("Participants", 24.sp,
                                          fontWeight: FontWeight.w500),
                                      SizedBox(
                                        height: 250,
                                        child: ListView.builder(
                                            itemCount: userDetails.length,
                                            itemBuilder: (context, index) {
                                              return Container(
                                                padding:
                                                    EdgeInsets.all(16.0.sp),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.all(
                                                          20.0.sp),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color:
                                                            Colors.transparent,
                                                        border: Border.all(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Image.asset(
                                                          "lib/assets/army-ranks/${userDetails[index]['rank'].toString().toLowerCase()}.png",
                                                          width: 20,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          StyledText(
                                                              userDetails[index]
                                                                      ['name']
                                                                  .toString()
                                                                  .titleCase,
                                                              18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              );
                                            }),
                                      ),
                                      SizedBox(
                                        height: 20.h,
                                      ),
                                      StyledText("Non-Participants", 24.sp,
                                          fontWeight: FontWeight.w500),
                                      SizedBox(
                                        height: 250,
                                        child: ListView.builder(
                                            itemCount: nonParticipants.length,
                                            itemBuilder: (context, index) {
                                              return Container(
                                                padding:
                                                    EdgeInsets.all(16.0.sp),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.all(
                                                          20.0.sp),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color:
                                                            Colors.transparent,
                                                        border: Border.all(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Image.asset(
                                                          "lib/assets/army-ranks/${nonParticipants[index]['rank'].toString().toLowerCase()}.png",
                                                          width: 20,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          StyledText(
                                                              nonParticipants[
                                                                          index]
                                                                      ['name']
                                                                  .toString()
                                                                  .titleCase,
                                                              18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                          StyledText(
                                                              soldierReason[nonParticipants[
                                                                          index]
                                                                      [
                                                                      'name']] ??
                                                                  excuseText,
                                                              14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              );
                                            }),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                      return Center(child: CircularProgressIndicator(),);
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
