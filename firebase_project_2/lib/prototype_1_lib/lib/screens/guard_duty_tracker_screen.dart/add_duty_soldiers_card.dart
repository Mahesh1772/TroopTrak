import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/guard_duty_tracker_screen.dart/add_new_duty_screen.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/guard_duty_tracker_screen.dart/util/custom_rect_tween.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/util/text_styles/text_style.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/conduct_tracker_screen/util/add_soldier_to_duty_tile.dart';
import 'package:provider/provider.dart';

import 'package:firebase_project_2/prototype_1_lib/lib/user_models/user_details.dart';

class AddDutySoldiersCard extends StatefulWidget {
  const AddDutySoldiersCard({
    super.key,
    required this.heroTag,
    required this.callbackFunction,
    required this.nonParticipants,
    required this.dutySoldiersAndRanks,
  });

  @override
  State<AddDutySoldiersCard> createState() => _AddDutySoldiersCardState();

  final String heroTag;
  final Function callbackFunction;
  final List nonParticipants;
  final Map<dynamic, dynamic> dutySoldiersAndRanks;
}

// List of all names
List<String> documentIDs = [];

//This is what the stream builder is waiting for
late Stream<QuerySnapshot> documentStream;

// List to store all user data, whilst also mapping to name
List<Map<String, dynamic>> userDetails = [];

// To store text being searched
String searchText = '';

class _AddDutySoldiersCardState extends State<AddDutySoldiersCard> {
  @override
  void initState() {
    documentStream = FirebaseFirestore.instance.collection('Users').snapshots();
    getDocIDs();

    super.initState();
  }

  void tileSelectionCallback(selection) {
    setState(() {
      dutySoldiersAndRanks = selection;
    });
  }

  Future getDocIDs() async {
    FirebaseFirestore.instance
        .collection('Users')
        .get()
        .then((value) => value.docs.forEach((element) {
              documentIDs.add(element['name']);
            }));
  }

  reverseMapAndRemoveExcess(Map<String, String> map) {
    Map<String, String> newmap = {};
    for (var _key in map.keys.toList()) {
      if (map[_key]!.contains("NA")) {
        continue;
      } else {
        newmap.addAll({_key: map[_key]!});
      }
    }
    print(newmap);
    return newmap;
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserData>(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.0.sp),
        child: Hero(
          tag: widget.heroTag,
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin!, end: end!);
          },
          child: Material(
            color: const Color.fromARGB(255, 39, 43, 58),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(vertical: 32.0.h, horizontal: 16.0.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StyledText("ADD A NEW SOLDIER", 24.sp,
                        fontWeight: FontWeight.w600),
                    Divider(
                      color: Colors.white,
                      thickness: 0.2.h,
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
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.white,
                          ),
                          focusColor: Colors.white,
                          prefixIcon: const Icon(
                            Icons.search_sharp,
                            color: Colors.white,
                          ),
                          prefixIconColor: Colors.white,
                          fillColor: const Color.fromARGB(255, 72, 30, 229),
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide: BorderSide.none),
                        ),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: userModel.data,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          documentIDs = [];
                          userDetails = [];
                          var users = snapshot.data?.docs.toList();
                          var docsmapshot = snapshot.data!;
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
                              userDetails.add(data as Map<String, dynamic>);
                            }
                            if (userDetails.isEmpty) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Text(
                                      'No results Found!',
                                      style: TextStyle(
                                        color: Colors.purpleAccent,
                                        fontSize: 45.sp,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              );
                            }
                          } else {
                            for (var i = 0; i < users!.length; i++) {
                              documentIDs.add(users[i]['name']);
                              var data = docsmapshot.docs[i].data()
                                  as Map<String, dynamic>;
                              userDetails.add(data);
                            }
                          }
                          print(userModel.non_participants);
                          userDetails = userDetails
                              .where((element) => !userModel.non_participants
                                  .contains(element['name']))
                              .toList();
                        }
                        return Flexible(
                          child: SizedBox(
                            height: 300.h,
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: userDetails.length,
                              padding: EdgeInsets.all(12.sp),
                              itemBuilder: (context, index) {
                                return AddSoldierToDutyTile(
                                    rank: userDetails[index]['rank'],
                                    name: userDetails[index]['name'],
                                    appointment: userDetails[index]
                                        ['appointment'],
                                    nonParticipants: widget.nonParticipants,
                                    selectedSoldiers: dutySoldiersAndRanks,
                                    tileSelectionCallback:
                                        tileSelectionCallback,
                                    isTileSelected: dutySoldiersAndRanks
                                        .containsKey(userDetails[index]['name']
                                            .toString()));
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    GestureDetector(
                      key: const Key("addSoldiersToDuty"),
                      onTap: () {
                        print(dutySoldiersAndRanks);
                        dutySoldiersAndRanks =
                            reverseMapAndRemoveExcess(dutySoldiersAndRanks);
                        widget.callbackFunction(dutySoldiersAndRanks);

                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(10.sp),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 72, 30, 229),
                              Color.fromARGB(255, 130, 60, 229),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_to_photos_rounded,
                                color: Colors.white,
                                size: 30.sp,
                              ),
                              SizedBox(
                                width: 20.w,
                              ),
                              AutoSizeText(
                                'ADD SOLDIER',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
