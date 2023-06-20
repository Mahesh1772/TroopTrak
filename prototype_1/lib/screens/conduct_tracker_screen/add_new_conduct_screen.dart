import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:recase/recase.dart';
import 'package:prototype_1/screens/conduct_tracker_screen/util/filters/participant_auto_selection.dart';

class AddNewConductScreen extends StatefulWidget {
  AddNewConductScreen({
    super.key,
    required this.selectedConductType,
    required this.conductName,
    required this.startDate,
    required this.startTime,
    required this.endTime,
  });
  late TextEditingController conductName;
  late String? selectedConductType;
  late String startDate;
  late String startTime;
  late String endTime;
  @override
  State<AddNewConductScreen> createState() => _AddNewConductScreenState();
}

// Store all the names in conduct
List<String> tempArray = [];
// List of all names
List<String> documentIDs = [];
// Name of soldiers not included
List<dynamic> soldierStatusArray = [];

class _AddNewConductScreenState extends State<AddNewConductScreen> {
  //This is what the stream builder is waiting for
  late Stream<QuerySnapshot> documentStream;
  // List to store all user data, whilst also mapping to name
  List<Map<String, dynamic>> userDetails = [];
  // To check if the type is changed inorder to change the tempArray
  bool type_changed = false;
  ParticipantAutoSelect parts = ParticipantAutoSelect(conductType: null);
  // Boolean value for checking if it is first time or not
  bool isFirstTIme = true;
  // To store text being searched
  String searchText = '';

  Future filter() async {
    //tempArray = [];
    if (isFirstTIme) {
      auto_filter();
      tempArray = documentIDs;
    }
  }

  // All this was supposed to be in another file
  List<Map<String, dynamic>> statusList = [];
  List<String> Outfield = [
    'Ex Sunlight',
    'Ex grass',
    'Ex Outfield',
    'Ex Outfield',
    'Ex Uniform',
    'Ex Boots'
  ];
  List<String> Run = ['Ex RMJ', 'Ex Lower Limb', 'LD'];
  List<String> S_P = ['Ex Upper Limb', 'LD'];
  List<String> Imt = ['Ex FLEGS', 'Ex Uniform', 'Ex Boots', 'LD'];
  List<String> Atp = [
    'Ex FLEGS',
    'Ex Uniform',
    'Ex Boots',
    'LD',
    'Ex Lower Limb',
    'Ex RMJ'
  ];
  List<String> Ippt = [
    'Ex Upper Limb',
    'LD',
    'Ex Lower Limb',
    'Ex RMJ',
    'Ex Pushup',
    'Ex Situp'
  ];
  List<String> soc = [
    'Ex Upper Limb',
    'LD',
    'Ex Lower Limb',
    'Ex RMJ',
    'Ex Uniform',
    'Ex Boots',
    'Ex FLEGS'
  ];
  List MetabolicCircuit = [
    'Ex RMJ',
    'Ex Lower Limb',
    'LD',
  ];
  List CombatCircuit = [
    'Ex Uniform',
    'Ex Boots',
    'Ex RMJ',
    'Ex Heavy Loads',
    'Ex Lower Limb',
    'Ex FLEGs',
    'LD',
  ];
  List RouteMarch = [
    'Ex RMJ',
    'Ex Heavy Loads',
    'Ex Lower Limbs',
    'LD',
    'Ex Uniform',
    'Ex Boots',
    'Ex FLEGs',
  ];
  int i = 0;
  List<String> non_participants = [];
  Future getUserBooks() async {
    FirebaseFirestore.instance
        .collection("Users")
        .get()
        .then((querySnapshot) async {
      querySnapshot.docs.forEach((snapshot) {
        FirebaseFirestore.instance
            .collection("Users")
            .doc(snapshot.id)
            .collection("Statuses")
            .get()
            .then((querySnapshot) {
          querySnapshot.docs.forEach((result) {
            Map<String, dynamic> data = result.data();
            DateTime end = DateFormat("d MMM yyyy").parse(data['endDate']);
            if (DateTime(end.year, end.month, end.day + 1)
                .isAfter(DateTime.now())) {
              statusList.add(data);
              statusList[i].addEntries({'Name': snapshot.id}.entries);
              i++;
            }
          });
        });
      });
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

  void auto_filter() {
    non_participants = [];
    switch (widget.selectedConductType) {
      case 'Run':
        for (var status in statusList) {
          if (status['statusType'] == 'Excuse') {
            if (Run.contains(status['statusName'])) {
              non_participants.add(status['Name']);
            }
          } else if (status['statusType'] == 'Leave') {
            non_participants.add(status['Name']);
          }
        }
        break;
      case 'Route March':
        for (var status in statusList) {
          if (status['statusType'] == 'Excuse') {
            if (RouteMarch.contains(status['statusName'])) {
              non_participants.add(status['Name']);
            }
          } else if (status['statusType'] == 'Leave') {
            non_participants.add(status['Name']);
          }
        }
        break;
      case 'IPPT':
        for (var status in statusList) {
          if (status['statusType'] == 'Excuse') {
            if (Ippt.contains(status['statusName'])) {
              non_participants.add(status['Name']);
            }
          } else if (status['statusType'] == 'Leave') {
            non_participants.add(status['Name']);
          }
        }
        break;
      case 'Outfield':
        for (var status in statusList) {
          if (status['statusType'] == 'Excuse') {
            if (Outfield.contains(status['statusName'])) {
              non_participants.add(status['Name']);
            }
          } else if (status['statusType'] == 'Leave') {
            non_participants.add(status['Name']);
          }
        }
        break;
      case 'Metabolic Circuit':
        for (var status in statusList) {
          if (status['statusType'] == 'Excuse') {
            if (MetabolicCircuit.contains(status['statusName'])) {
              non_participants.add(status['Name']);
            }
          } else if (status['statusType'] == 'Leave') {
            non_participants.add(status['Name']);
          }
        }
        break;
      case 'Strength & Power':
        for (var status in statusList) {
          if (status['statusType'] == 'Excuse') {
            if (S_P.contains(status['statusName'])) {
              non_participants.add(status['Name']);
            }
          } else if (status['statusType'] == 'Leave') {
            non_participants.add(status['Name']);
          }
        }
        break;
      case 'Combat Circuit':
        for (var status in statusList) {
          if (status['statusType'] == 'Excuse') {
            if (CombatCircuit.contains(status['statusName'])) {
              non_participants.add(status['Name']);
            }
          } else if (status['statusType'] == 'Leave') {
            non_participants.add(status['Name']);
          }
        }
        break;
      case 'Live Firing':
        for (var status in statusList) {
          if (status['statusType'] == 'Excuse') {
            if (Atp.contains(status['statusName']) ||
                Imt.contains(status['statusName'])) {
              non_participants.add(status['Name']);
            }
          } else if (status['statusType'] == 'Leave') {
            non_participants.add(status['Name']);
          }
        }
        break;
      case 'SOC/VOC':
        for (var status in statusList) {
          if (status['statusType'] == 'Excuse') {
            if (soc.contains(status['statusName'])) {
              non_participants.add(status['Name']);
            }
          } else if (status['statusType'] == 'Leave') {
            non_participants.add(status['Name']);
          }
        }
        break;
      default:
        for (var status in statusList) {
          if (status['statusType'] == 'Leave') {
            non_participants.add(status['Name']);
          }
        }
    }
    documentIDs.removeWhere((element) => non_participants.contains(element));
  }

  @override
  void initState() {
    documentStream = FirebaseFirestore.instance.collection('Users').snapshots();
    getDocIDs();
    getUserBooks();
    super.initState();
  }

  final _conductTypes = [
    "Select conduct...",
    "Run",
    "Route March",
    "IPPT",
    "Outfield",
    "Strength & Power",
    "Metabolic Circuit",
    "Combat Circuit",
    "Live Firing",
    "SOC/VOC"
  ];
  void _showStartDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1960),
      lastDate: DateTime(2030),
    ).then((value) {
      setState(() {
        if (value != null) {
          widget.startDate = DateFormat('d MMM yyyy').format(value);
        }
      });
    });
  }

  void _showStartTimePicker() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then(
      ((value) {
        setState(
          () {
            if (value != null) {
              widget.startTime = value.format(context).toString();
            }
          },
        );
      }),
    );
  }

  void _showEndTimePicker() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then(
      ((value) {
        setState(
          () {
            if (value != null) {
              widget.endTime = value.format(context).toString();
            }
          },
        );
      }),
    );
  }

  Future addConductDetails() async {
    await FirebaseFirestore.instance.collection('Conducts').add({
      //User map formatting
      'conductName': widget.conductName.text.trim(),
      'conductType': widget.selectedConductType,
      'startDate': widget.startDate,
      'startTime': widget.startTime,
      'endTime': widget.endTime,
      'participants': tempArray,
    });
  }

  addConduct() {
    addConductDetails();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    widget.conductName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _formKey1 = GlobalKey<FormState>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 21, 25, 34),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                StyledText(
                  "Add a new conduct ✍️",
                  30.sp,
                  fontWeight: FontWeight.bold,
                ),
                StyledText(
                  "Details of the conduct",
                  14.sp,
                  fontWeight: FontWeight.w300,
                ),
                SizedBox(
                  height: 40.h,
                ),
                //Status type drop down menu
                Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Container(
                    height: 70.h,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: DropdownButtonFormField<String>(
                        validator: (value) {
                          if (value == "Select conduct...") {
                            return 'Bruh select!';
                          }
                          return null;
                        },
                        alignment: Alignment.center,
                        dropdownColor: Colors.black54,
                        value: widget.selectedConductType,
                        icon: const Icon(
                          Icons.arrow_downward_sharp,
                          color: Colors.white,
                        ),
                        style: const TextStyle(color: Colors.black54),
                        items: _conductTypes
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item,
                                child: AutoSizeText(
                                  item,
                                  maxLines: 1,
                                  style: GoogleFonts.poppins(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (String? item) async => setState(() {
                          widget.selectedConductType = item;
                          isFirstTIme = true;
                        }),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30.h,
                ),
                //Name of status textfield
                Form(
                  key: _formKey1,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 20.w),
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Oi can add conduct please?";
                          }
                          return null;
                        },
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        controller: widget.conductName,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Enter Conduct Name:',
                          labelStyle: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30.h,
                ),
                InkWell(
                  onTap: () {
                    _showStartDatePicker();
                  },
                  child: Container(
                    height: 70.h,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.w, vertical: 15.h),
                          child: AutoSizeText(
                            widget.startDate,
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 16.sp),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0.sp),
                          child: const Icon(
                            Icons.date_range_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 30.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        _showStartTimePicker();
                      },
                      child: Container(
                        height: 70.h,
                        width: 200.w,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15.w, vertical: 15.h),
                              child: AutoSizeText(
                                widget.startTime,
                                style: GoogleFonts.poppins(
                                    color: Colors.white, fontSize: 16.sp),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0.sp),
                              child: const Icon(
                                Icons.access_time_filled_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20.w,
                    ),
                    InkWell(
                      onTap: () {
                        _showEndTimePicker();
                      },
                      child: Container(
                        height: 70.h,
                        width: 200.w,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15.w, vertical: 15.h),
                              child: AutoSizeText(
                                widget.endTime,
                                style: GoogleFonts.poppins(
                                    color: Colors.white, fontSize: 16.sp),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0.sp),
                              child: const Icon(
                                Icons.access_time_filled_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40.h,
                ),
                const StyledText("Add Participants", 24,
                    fontWeight: FontWeight.bold),
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
                        filter();
                      }
                    }
                    return Flexible(
                      child: SizedBox(
                        height: 300,
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: userDetails.length,
                          padding: EdgeInsets.all(12.sp),
                          itemBuilder: (context, index) {
                            return Card(
                              color: Colors.black54,
                              child: ListTile(
                                title: StyledText(
                                    userDetails[index]['name']
                                        .toString()
                                        .titleCase,
                                    16.sp,
                                    fontWeight: FontWeight.w500),
                                leading: InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (tempArray.contains(userDetails[index]
                                              ['name']
                                          .toString())) {
                                        tempArray.remove(userDetails[index]
                                                ['name']
                                            .toString());
                                      } else {
                                        tempArray.add(userDetails[index]['name']
                                            .toString());
                                      }
                                      isFirstTIme = false;
                                    });
                                  },
                                  child: Container(
                                    height: 40.h,
                                    width: 100.w,
                                    decoration: BoxDecoration(
                                      color: tempArray.contains(
                                              userDetails[index]['name']
                                                  .toString())
                                          ? Colors.red
                                          : Colors.green,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: StyledText(
                                          tempArray.contains(userDetails[index]
                                                      ['name']
                                                  .toString())
                                              ? "REMOVE"
                                              : "ADD",
                                          18.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
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
                    if (_formKey.currentState!.validate() &&
                        _formKey1.currentState!.validate() &&
                        widget.endTime != "End Time:" &&
                        widget.startTime != "Start Time:" &&
                        widget.startTime != "Date:") {
                      IconSnackBar.show(
                          duration: const Duration(seconds: 1),
                          direction: DismissDirection.horizontal,
                          context: context,
                          snackBarType: SnackBarType.save,
                          label: 'Conduct added successfully!',
                          snackBarStyle: const SnackBarStyle() // this one
                          );
                      addConduct();
                    } else {
                      IconSnackBar.show(
                          direction: DismissDirection.horizontal,
                          context: context,
                          snackBarType: SnackBarType.alert,
                          label: 'Details missing',
                          snackBarStyle: const SnackBarStyle() // this one
                          );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(10.sp),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.shade400,
                          Colors.deepPurple.shade700,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
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
                            'ADD NEW CONDUCT',
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
    );
  }
}
