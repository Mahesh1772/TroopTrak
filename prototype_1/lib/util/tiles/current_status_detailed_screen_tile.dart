import 'package:flutter/material.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:recase/recase.dart';

late Color? tileColor;
late IconData? tileIcon;

class SoldierStatusTile extends StatelessWidget {
  final String statusType;
  final String startDate;
  final String endDate;
  final String statusName;

  const SoldierStatusTile({
    super.key,
    required this.statusType,
    required this.statusName,
    required this.startDate,
    required this.endDate,
  });

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
            Icon(
              tileIcon,
              color: Colors.white,
              size: 60,
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
