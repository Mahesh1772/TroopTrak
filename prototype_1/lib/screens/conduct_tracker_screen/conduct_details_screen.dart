import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:recase/recase.dart';

class ConductDetailsScreen extends StatefulWidget {
  const ConductDetailsScreen(
      {super.key,
      required this.conductName,
      required this.conductType,
      required this.startDate,
      required this.endDate});

  final String conductName;
  final String conductType;
  final String startDate;
  final String endDate;
  @override
  State<ConductDetailsScreen> createState() => _ConductDetailsScreenState();
}

class _ConductDetailsScreenState extends State<ConductDetailsScreen> {
  //This is what the stream builder is waiting for
  late Stream<QuerySnapshot> documentStream;

  // The list of all document IDs,
  //which have access to each their own personal information
  List<String> documentIDs = [];

  // List to store all user data, whilst also mapping to name
  List<Map<String, dynamic>> userDetails = [];

  // To store text being searched
  String searchText = '';

  @override
  void initState() {
    documentStream = FirebaseFirestore.instance.collection('Users').snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          SizedBox(
                            height: 20.h,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 20.0.w, right: 20.0.w, top: 20.0.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.conductType.toUpperCase(),
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
                                        widget.conductName,
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
                              widget.startDate == widget.endDate
                                  ? widget.startDate.toUpperCase()
                                  : "${widget.startDate.toUpperCase()} - ${widget.endDate.toUpperCase()}",
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
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  StreamBuilder(
                    stream: documentStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        documentIDs = [];
                        userDetails = [];
                        var users = snapshot.data?.docs.toList();
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
                            userDetails.add(data as Map<String, dynamic>);
                          }
                        }
                      }

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StyledText("Non-Participants", 24.sp,
                              fontWeight: FontWeight.w500),
                          SizedBox(
                            height: 250,
                            child: ListView.builder(
                                itemCount: userDetails.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    padding: EdgeInsets.all(16.0.sp),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(20.0.sp),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.transparent,
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
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              StyledText(
                                                  userDetails[index]['name']
                                                      .toString()
                                                      .titleCase,
                                                  18,
                                                  fontWeight: FontWeight.w600),
                                              const StyledText(
                                                  "Reason: Ex RMJ", 14,
                                                  fontWeight: FontWeight.w400),
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
                          StyledText("Participants", 24.sp,
                              fontWeight: FontWeight.w500),
                          SizedBox(
                            height: 250,
                            child: ListView.builder(
                                itemCount: userDetails.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    padding: EdgeInsets.all(16.0.sp),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(20.0.sp),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.transparent,
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
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              StyledText(
                                                  userDetails[index]['name']
                                                      .toString()
                                                      .titleCase,
                                                  18,
                                                  fontWeight: FontWeight.w600),
                                              const StyledText(
                                                  "Reason: Ex RMJ", 14,
                                                  fontWeight: FontWeight.w400),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                }),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
