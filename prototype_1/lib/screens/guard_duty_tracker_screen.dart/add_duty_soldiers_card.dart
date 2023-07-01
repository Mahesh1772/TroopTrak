import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prototype_1/screens/guard_duty_tracker_screen.dart/add_new_duty_screen.dart';
import 'package:prototype_1/screens/guard_duty_tracker_screen.dart/util/custom_rect_tween.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:prototype_1/screens/guard_duty_tracker_screen.dart/util/add_soldier_to_duty_tile.dart';

class AddDutySoldiersCard extends StatefulWidget {
  const AddDutySoldiersCard(
      {super.key, required this.heroTag, required this.callbackFunction});

  @override
  State<AddDutySoldiersCard> createState() => _AddDutySoldiersCardState();

  final String heroTag;
  final Function callbackFunction;
}

// Store all the names in conduct
Map<String, String> tempArray = {};

// List of all names
List<String> documentIDs = [];

List<String> docIDs = [];

// Name of soldiers not included
List<dynamic> soldierStatusArray = [];

//This is what the stream builder is waiting for
late Stream<QuerySnapshot> documentStream;

// List to store all user data, whilst also mapping to name
List<Map<String, dynamic>> userDetails = [];

// To store text being searched
String searchText = '';

List<String> non_participants = [];

// Boolean value for checking if it is first time or not
bool isFirstTIme = true;

List<String> guardDuty = ['Ex Uniform', 'Ex Boots'];

class _AddDutySoldiersCardState extends State<AddDutySoldiersCard> {
  List<Map<String, dynamic>> statusList = [];

  @override
  void initState() {
    documentStream = FirebaseFirestore.instance.collection('Users').snapshots();
    //getDocIDs();
    getUserBooks();
    //non_participants = [];
    //print(docIDs);
    autoFilter();
    tempArray = {};
    super.initState();
  }

  int i = 0;

  Future getUserBooks() async {
    FirebaseFirestore.instance
        .collection("Users")
        .get()
        .then((querySnapshot) async {
      for (var snapshot in querySnapshot.docs) {
        FirebaseFirestore.instance
            .collection("Users")
            .doc(snapshot.id)
            .collection("Statuses")
            .get()
            .then((querySnapshot) {
          for (var result in querySnapshot.docs) {
            Map<String, dynamic> data = result.data();
            DateTime end = DateFormat("d MMM yyyy").parse(data['endDate']);
            if (DateTime(end.year, end.month, end.day + 1)
                .isAfter(DateTime.now())) {
              statusList.add(data);
              statusList[i].addEntries({'Name': snapshot.id}.entries);
              i++;
              print(statusList);
            }
          }
        });
      }
    });
  }

  Future getDocIDs() async {
    FirebaseFirestore.instance
        .collection('Users')
        .get()
        .then((value) => value.docs.forEach((element) {
              docIDs.add(element['name']);
            }));
    print(docIDs);
  }

  void populateDutySoldiersAndRanksArray() {
    var length = dutySoldiersAndRanks.length;

    for (var i = length; i < 10; i++) {
      dutySoldiersAndRanks.addEntries({'NA$i': 'NA'}.entries);
    }

    //print(dutySoldiersAndRanks);
  }

  void autoFilter() {
    //non_participants = [];
    for (var status in statusList) {
      if (status['statusType'] == 'Excuse') {
        if (guardDuty.contains(status['statusName'])) {
          non_participants.add(status['Name']);
        }
      } else if (status['statusType'] == 'Leave') {
        non_participants.add(status['Name']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    getUserBooks();
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
                      stream: documentStream,
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
                            //autoFilter();
                          }
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
                                );
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
                      onTap: () {
                        dutySoldiersAndRanks = {};

                        for (var i = 0; i < tempArray.length; i++) {
                          dutySoldiersAndRanks.addAll(tempArray);
                        }

                        populateDutySoldiersAndRanksArray();

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
