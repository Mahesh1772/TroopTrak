import 'package:flutter/material.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

late Color? tileColor;
late IconData? tileIcon;
List soldierStatus = ["Excuse", "Ex FLEGs", "13 Jul 2021", "12 Jul 2022"];

class SoldierStatusTile extends StatefulWidget {
  const SoldierStatusTile({
    super.key,
    required this.statusType,
    required this.statusName,
    required this.startDate,
    required this.endDate,
  });

  final String statusType;
  final String startDate;
  final String endDate;
  final String statusName;

  @override
  State<SoldierStatusTile> createState() => _SoldierStatusTileState();
}

List<String> documentIDs = [];
const docIDs = 'Aakash Ramaswamy';

class _SoldierStatusTileState extends State<SoldierStatusTile> {
  Future getDocIDs() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(docIDs)
        .collection('Statuses')
        .get()
        .then((value) {
      value.docs.forEach((element) {
        //print(element.data());
        documentIDs.add(element.reference.id);
      });
    });
    //.orderBy('rank', descending: false)
    print(documentIDs);
    setState(() {});
  }

  @override
  void initState() {
    getDocIDs();
    super.initState();
    documentIDs = [];
  }

  Future deleteCurrentStatus() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(docIDs)
        .collection('Statuses')
        .doc('yKPlOfPtnQnRypRDvTZI')
        .delete();
  }

  final String statusType = "Excuse";
  final String startDate = "Ex FLEGs";
  final String endDate = "13 Jul 2021";
  final String statusName = "12 Jul 2022";

  @override
  Widget build(BuildContext context) {
    setTileIconAndColor(statusType);

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(boxShadow: const [
          BoxShadow(
              blurRadius: 2.0,
              spreadRadius: 2.0,
              offset: Offset(10, 10),
              color: Colors.black54)
        ], color: tileColor, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  tileIcon,
                  color: Colors.white,
                  size: 60,
                ),
                InkWell(
                  onTap: deleteCurrentStatus,
                  child: const Icon(
                    Icons.delete_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            StyledText(statusName, 20, fontWeight: FontWeight.bold),
            StyledText(statusType.toUpperCase(), 18,
                fontWeight: FontWeight.w500),
            StyledText("$startDate - $endDate", 16, fontWeight: FontWeight.bold)
          ],
        ),
      ),
    );
  }
}

setTileIconAndColor(String type) {
  if (type == "Excuse") {
    tileColor = Colors.amber[900];
    tileIcon = Icons.personal_injury_rounded;
  } else if (type == "Leave") {
    tileColor = Colors.red;
    tileIcon = Icons.medical_services_rounded;
  } else if (type == "Medical Appointment") {
    tileColor = Colors.blue[600];
    tileIcon = Icons.date_range_rounded;
  }
}
