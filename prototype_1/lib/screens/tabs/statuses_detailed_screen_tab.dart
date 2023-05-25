import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prototype_1/screens/add_new_status_screen.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:prototype_1/util/tiles/current_status_detailed_screen_tile.dart';
import 'package:prototype_1/util/tiles/past_status_detailed_screen_tile.dart';

var soldierStatuses = [
  //soldierStatuses - [statusType, statusName, startDate, endDate]
  ["Excuse", "Ex FLEGs", "13 Jul 2021", "12 Jul 2022"],
  ["Leave", "MC", "10 Jun 2021", "12 Jul 2021"],
  ["Medical Appointment", "National Skin Centre", "5 Apr 2021", "5 Apr 2021"],
];

var pastStatuses = [
  //soldierStatuses - [statusType, statusName, startDate, endDate]
  ["Excuse", "Ex FLEGs", "13 Jul 2021", "12 Jul 2022"],
  ["Leave", "MC", "10 Jun 2021", "12 Jul 2021"],
  ["Medical Appointment", "National Skin Centre", "5 Apr 2021", "5 Apr 2021"],
  ["Excuse", "Ex FLEGs", "13 Jul 2021", "12 Jul 2022"],
  ["Leave", "MC", "10 Jun 2021", "12 Jul 2021"],
  ["Medical Appointment", "National Skin Centre", "5 Apr 2021", "5 Apr 2021"],
];

class StatusesTab extends StatefulWidget {
  const StatusesTab({
    super.key,
  });

  @override
  State<StatusesTab> createState() => _StatusesTabState();
}

class _StatusesTabState extends State<StatusesTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.medical_information_rounded,
                  color: Colors.white,
                  size: 30,
                ),
                const SizedBox(
                  width: 20,
                ),
                Text(
                  "Active Statuses",
                  maxLines: 2,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 250,
              child: ListView.builder(
                itemCount: soldierStatuses.length,
                padding: const EdgeInsets.all(12),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return SoldierStatusTile(
                      statusType: soldierStatuses[index][0],
                      statusName: soldierStatuses[index][1],
                      startDate: soldierStatuses[index][2],
                      endDate: soldierStatuses[index][3]);
                },
              ),
            ),
            Row(
              children: [
                const Icon(
                  Icons.av_timer_rounded,
                  color: Colors.white,
                  size: 30,
                ),
                const SizedBox(
                  width: 20,
                ),
                Text(
                  "Past Statuses",
                  maxLines: 2,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: pastStatuses.length,
                itemBuilder: (context, index) {
                  return PastSoldierStatusTile(
                      statusType: pastStatuses[index][0],
                      statusName: pastStatuses[index][1],
                      startDate: pastStatuses[index][2],
                      endDate: pastStatuses[index][3]);
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddNewStatusScreen(
                          selectedStatusType: "Select status type...",
                          statusName: TextEditingController(),
                          startDate: "Start Date:",
                          endDate: "End Date:"),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40.0, vertical: 16.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 72, 30, 229),
                          Color.fromARGB(255, 130, 60, 229),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(50.0)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.note_add,
                        color: Colors.white,
                        size: 30,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      StyledText("ADD NEW STATUS", 18,
                          fontWeight: FontWeight.bold),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
