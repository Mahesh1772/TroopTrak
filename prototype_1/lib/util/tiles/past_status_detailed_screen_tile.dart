import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

late IconData? tileIcon;

class PastSoldierStatusTile extends StatelessWidget {
  final String statusType;
  final String startDate;
  final String endDate;
  final String statusName;

  const PastSoldierStatusTile({
    super.key,
    required this.statusType,
    required this.statusName,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    setTileIcon(statusType);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {},
              icon: Icons.info_rounded,
              backgroundColor: Colors.blue,
            ),
            SlidableAction(
              onPressed: (context) {},
              icon: Icons.delete_forever_rounded,
              backgroundColor: Colors.red,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
          ],
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(104, 158, 158, 158),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  tileIcon,
                  color: Colors.white,
                  size: 30,
                ),
                SizedBox(
                  width: 100,
                  child: AutoSizeText(
                    statusName,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: AutoSizeText(
                    "$startDate - $endDate",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white),
                    maxLines: 1,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

setTileIcon(String type) {
  if (type == "Excuse") {
    tileIcon = Icons.personal_injury_rounded;
  } else if (type == "Leave") {
    tileIcon = Icons.medical_services_rounded;
  } else if (type == "Medical Appointment") {
    tileIcon = Icons.date_range_rounded;
  }
}
