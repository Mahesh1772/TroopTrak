//import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserData extends ChangeNotifier {
  // The list of all document IDs,
  //which have access to each their own personal information
  List<String> documentIDs = [];

  // DocumentReference<Map<String, dynamic>>(Users/8bu245T440NIuQnJhm81)
  // This is the sample output, to get IDs we just do .id
  List<Map<String, dynamic>> userDetails = [];

  Stream<QuerySnapshot> soldiers = const Stream.empty();
  Stream<QuerySnapshot> conducts = const Stream.empty();
  Stream<QuerySnapshot> duty = const Stream.empty();
  Stream<QuerySnapshot> status = const Stream.empty();
  Stream<DocumentSnapshot<Map<String, dynamic>>> userData =
      const Stream.empty();

  Stream<QuerySnapshot> get data {
    soldiers = FirebaseFirestore.instance.collection('Users').snapshots();
    return soldiers;
  }

  Stream<QuerySnapshot> get men_data {
    soldiers = FirebaseFirestore.instance.collection('Men').snapshots();
    return soldiers;
  }

  Stream<QuerySnapshot> get conducts_data {
    conducts = FirebaseFirestore.instance.collection('Conducts').snapshots();
    return conducts;
  }

  Stream<QuerySnapshot> get duty_data {
    duty = FirebaseFirestore.instance.collection('Duties').snapshots();
    return duty;
  }

  Stream<QuerySnapshot> status_data(String docID) {
    status = FirebaseFirestore.instance
        .collection('Users')
        .doc(docID)
        .collection('Statuses')
        .snapshots();
    return status;
  }

  Stream<QuerySnapshot> attendance_data(String docID) {
    status = FirebaseFirestore.instance
        .collection('Users')
        .doc(docID)
        .collection('Attendance')
        .snapshots();
    return status;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> userData_data(String docID) {
    userData =
        FirebaseFirestore.instance.collection('Users').doc(docID).snapshots();
    return userData;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> updateStatus_data(
      String docID, String statusID) {
    userData = FirebaseFirestore.instance
        .collection('Users')
        .doc(docID)
        .collection('Statuses')
        .doc(statusID)
        .snapshots();
    return userData;
  }

  int i = 0;
  List<Map<String, dynamic>> attendance_list = [];
  Future inCamp() async {
    await FirebaseFirestore.instance
        .collection("Users")
        .get()
        .then((querySnapshot) async {
      for (var snapshot in querySnapshot.docs) {
        FirebaseFirestore.instance
            .collection("Users")
            .doc(snapshot.id)
            .collection("Attendance")
            .get()
            .then((querySnapshot) {
          //var lastData = querySnapshot.docs.last.data();
          fullList.addAll(
              {snapshot.id: querySnapshot.docs.last.data()['isInsideCamp']});
        });
      }
    });
    //return attendance_list;
  }

  List<Map<String, dynamic>> newList = [];
  Map<String, dynamic> fullList = {};

  List<String> non_participants = [];
  List<Map<String, dynamic>> statusList = [];
  List<String> guardDuty = ['Ex Uniform', 'Ex Boots'];
  Future autoFilter() async {
    if (statusList.isNotEmpty) {
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
  }

  Future<bool> getUserStatus(String ID) async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(ID)
        .collection("Statuses")
        .where('statusType', isEqualTo: 'Excuse')
        .where('statusName', whereIn: ['Ex Boots', 'Ex Uniform'])
        .get()
        .then((querySnapshot) {
          for (var result in querySnapshot.docs) {
            Map<String, dynamic> data = result.data();
            DateTime end = DateFormat("d MMM yyyy").parse(data['endDate']);
            if (DateTime(end.year, end.month, end.day + 1)
                .isAfter(DateTime.now())) {
              return true;
            }
          }
        });
    return false;
  }

  Future name() async {
    await FirebaseFirestore.instance
        .collection("Users")
        .get()
        .then((querySnapshot) async {
      for (var snapshot in querySnapshot.docs) {
        Map<String, dynamic> data = snapshot.data();
        documentIDs.add(data['name']);
      }
    });
    //return attendance_list;
  }

  Future<List<Map<String, dynamic>>> todayConducts() async {
    List<Map<String, dynamic>> conduct = [];
    await FirebaseFirestore.instance
        .collection("Conducts")
        .where('startDate',
            isEqualTo: DateFormat("d MMM yyyy").format(DateTime.now()))
        .get()
        .then((querySnapshot) async {
      for (var snapshot in querySnapshot.docs) {
        Map<String, dynamic> data = snapshot.data();
        conduct.add(data);
      }
    });
    return conduct;
  }

  Future<List<Map<String, dynamic>>> todayDuty() async {
    List<Map<String, dynamic>> conduct = [];
    await FirebaseFirestore.instance
        .collection("Duties")
        .where('dutyDate',
            isEqualTo: DateFormat("d MMM yyyy").format(DateTime.now()))
        .get()
        .then((querySnapshot) async {
      for (var snapshot in querySnapshot.docs) {
        Map<String, dynamic> data = snapshot.data();
        conduct.add(data);
      }
    });
    return conduct;
  }

  Map<String, String> categorySelected = {
    'Name': 'name',
    'Rank' : 'rank',
    'Company' : 'company',
    'Section' : 'section',
    'Platoon' : 'platoon',
    'Ration' : 'rationType',
    'Blood' : 'bloodgroup',
    'Appointment' : 'appointment',
  };
}


/*
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Users & Statuses')),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('Users').snapshots(),
          builder: (context, usersSnapshot) {
            if (usersSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (usersSnapshot.hasData) {
              // Your existing code...
              bool hasLoadedData = false;

              // Create a Completer to delay the execution until we have collected data from all 'Statuses' subcollections
              Completer<void> completer = Completer<void>();
              List<String> peopleWithCertainData = [];

              List? users = usersSnapshot.data?.docs.toList();
              var docsmapshot = usersSnapshot.data!;

              for (var i = 0; i < users!.length; i++) {
                final uid = users[i]['name'];
                var data = docsmapshot.docs[i].data() as Map<String, dynamic>;

                // Your existing code to process user data
                // ...

                // Query 'Statuses' subcollection for each user
                FirebaseFirestore.instance
                    .collection('Users')
                    .doc(uid)
                    .collection('Statuses')
                    .get()
                    .then((statusSnapshot) {
                  // Check if the user has any documents in 'Statuses' subcollection
                  if (statusSnapshot.docs.isNotEmpty) {
                    // Process the 'Statuses' subcollection data here
                    statusSnapshot.docs.forEach((statusDoc) {
                      String data = statusDoc['data']; // Replace 'data' with the field name you want to check
                      if (data == 'certainData') {
                        peopleWithCertainData.add(statusDoc['name']);
                      }
                    });
                  }

                  // Check if we have collected data for all users
                  if (i == users.length - 1) {
                    hasLoadedData = true;
                    completer.complete();
                  }
                });
              }

              return FutureBuilder<void>(
                future: completer.future,
                builder: (context, snapshot) {
                  // Check if the Future is still loading data
                  if (!hasLoadedData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  // Your existing code with LiquidPullToRefresh and FlipCard...
                  return LiquidPullToRefresh(
                    onRefresh: refreshPage,
                    child: FlipCard(
                      // ... (rest of your FlipCard code)
                    ),
                  );
                },
              );
            }

            return Center(
              child: Text('No Users found'),
            );
          },
        ),
      ),
    );
  }
}
*/