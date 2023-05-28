// ignore_for_file: must_be_immutable
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prototype_1/screens/soldier_detailed_screen.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:prototype_1/util/constants.dart';
import 'package:prototype_1/util/charts/current_strength_chart.dart';
import 'package:intl/intl.dart';
import 'package:prototype_1/util/tiles/dashboard_soldier_tile.dart';

List unitSoldiers = [
  //[ soldierName, soldierRank, tileColour, soldierAttendance, soldierIcon, soldierAppointment, companyName, platoonName, sectionNumber, dateOfBirth, rationType, bloodType, enlistmentDate, ordDate]

  [
    "Wei John Koh",
    "lib/assets/army-ranks/3sg.png",
    Colors.brown.shade800,
    "IN CAMP",
    "lib/assets/army-ranks/soldier.png",
    "section commander",
    "Alpha",
    "4",
    "3",
    "04 May 2001",
    "VC",
    "AB+",
    "11 Aug 2020",
    "10 Aug 2022",
  ],
  [
    "Sivagnanam Maheshwaran",
    "lib/assets/army-ranks/3sg.png",
    Colors.indigo.shade800,
    "IN CAMP",
    "lib/assets/army-ranks/soldier.png",
    "LOGISTICS SPECIALIST",
    "Bravo",
    "1",
    "2",
    "05 Apr 2001",
    "VI",
    "AB+",
    "11 Aug 2019",
    "10 Aug 2021",
  ],
  [
    "Aakash Ramaswamy",
    "lib/assets/army-ranks/3sg.png",
    Colors.indigo.shade400,
    "NOT IN CAMP",
    "lib/assets/army-ranks/soldier.png",
    "MARKSMAN TEAM COMMANDER",
    "Charlie",
    "HQ",
    "MM",
    "02 Apr 2002",
    "VI",
    "O+",
    "11 Aug 2020",
    "10 Aug 2022",
  ],
  [
    "Nikhil Babu",
    "lib/assets/army-ranks/cfc.png",
    Colors.teal.shade800,
    "IN CAMP",
    "lib/assets/army-ranks/men.png",
    "section 2IC",
    "Bn HQ",
    "2",
    "4",
    "03 Sept 2000",
    "M",
    "B+",
    "10 Aug 2020",
    "09 Aug 2022",
  ],
  [
    "John Doe",
    "lib/assets/army-ranks/lcp.png",
    Colors.teal.shade400,
    "NOT IN CAMP",
    "lib/assets/army-ranks/men.png",
    "1st MATADOR / LAW GUNNER",
    "Support",
    "3",
    "3",
    "04 Jul 2003",
    "NM",
    "A+",
    "11 Jul 2021",
    "10 Jul 2023",
  ],
];

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  String fname = FirebaseAuth.instance.currentUser!.displayName.toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: StyledText(
                      'Dashboard',
                      20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 100.0),
                    child: InkWell(
                      onTap: () {
                        FirebaseAuth.instance.signOut();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black54,
                                offset: Offset(10.0, 10.0),
                                blurRadius: 2.0,
                                spreadRadius: 2.0),
                          ],
                          color: Colors.deepPurple.shade400,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(defaultPadding),
                          child: Icon(
                            Icons.exit_to_app_rounded,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SoldierDetailedScreen(
                                    soldierName: unitSoldiers[1][0],
                                    soldierRank: unitSoldiers[1][1],
                                    tileColor: unitSoldiers[1][2],
                                    soldierAttendance: unitSoldiers[1][3],
                                    soldierIcon: unitSoldiers[1][4],
                                    soldierAppointment: unitSoldiers[1][5],
                                    company: unitSoldiers[1][6],
                                    platoon: unitSoldiers[1][7],
                                    section: unitSoldiers[1][8],
                                    dateOfBirth: unitSoldiers[1][9],
                                    rationType: unitSoldiers[1][10],
                                    bloodType: unitSoldiers[1][11],
                                    enlistmentDate: unitSoldiers[1][12],
                                    ordDate: unitSoldiers[1][13],
                                  )));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Image.asset(
                        'lib/assets/user.png',
                        width: 50,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: StyledText(
                  'Welcome,\n$fname! 👋',
                  32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Container(
                  padding: const EdgeInsets.all(defaultPadding),
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black54,
                          offset: Offset(10.0, 10.0),
                          blurRadius: 2.0,
                          spreadRadius: 2.0),
                    ],
                    color: accentColor,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Strength In-Camp",
                            style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                          const InkWell(
                            child: Icon(
                              Icons.more_vert_sharp,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                      Text(
                        "As of ${DateFormat('yMMMMd').add_Hm().format(DateTime.now())}",
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.45)),
                      ),
                      const SizedBox(
                        height: defaultPadding + 2,
                      ),
                      CurrentStrengthChart(),
                      const SizedBox(
                        height: defaultPadding,
                      ),
                      const CurrentStrengthBreakdownTile(
                        title: "Total Officers",
                        imgSrc: "lib/assets/icons8-medals-64.png",
                        currentNumOfSoldiers: 6,
                        totalNumOfSoldiers: 9,
                        imgColor: Colors.red,
                      ),
                      const CurrentStrengthBreakdownTile(
                        title: "Total WOSEs",
                        imgSrc: "lib/assets/icons8-soldier-man-64.png",
                        currentNumOfSoldiers: 74,
                        totalNumOfSoldiers: 117,
                        imgColor: Colors.blue,
                      ),
                      const CurrentStrengthBreakdownTile(
                        title: "On Status",
                        imgSrc: "lib/assets/icons8-error-64.png",
                        currentNumOfSoldiers: 25,
                        totalNumOfSoldiers: 126,
                        imgColor: Colors.yellow,
                      ),
                      const CurrentStrengthBreakdownTile(
                        title: "On MA",
                        imgSrc: "lib/assets/icons8-doctors-folder-64.png",
                        currentNumOfSoldiers: 1,
                        totalNumOfSoldiers: 126,
                        imgColor: Colors.lightBlueAccent,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CurrentStrengthBreakdownTile extends StatelessWidget {
  const CurrentStrengthBreakdownTile({
    super.key,
    required this.title,
    required this.imgSrc,
    required this.currentNumOfSoldiers,
    required this.totalNumOfSoldiers,
    required this.imgColor,
  });

  final String title, imgSrc;
  final int currentNumOfSoldiers, totalNumOfSoldiers;
  final Color imgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: defaultPadding,
      ),
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: Colors.blue.withOpacity(0.15)),
        borderRadius: const BorderRadius.all(
          Radius.circular(defaultPadding),
        ),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: Image.asset(
                imgSrc,
                color: imgColor,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "$currentNumOfSoldiers In Camp",
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Text(
              "$currentNumOfSoldiers / $totalNumOfSoldiers",
              style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
          ],
        ),
        collapsedIconColor: Colors.white,
        children: [
          SizedBox(
            height: 220,
            child: ListView.builder(
              itemCount: unitSoldiers.length,
              padding: const EdgeInsets.all(12),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return DashboardSoldierTile(
                  soldierName: unitSoldiers[index][0],
                  soldierRank: unitSoldiers[index][1],
                  tileColor: unitSoldiers[index][2],
                  soldierAttendance: unitSoldiers[index][3],
                  soldierIcon: unitSoldiers[index][4],
                  soldierAppointment: unitSoldiers[index][5],
                  company: unitSoldiers[index][6],
                  platoon: unitSoldiers[index][7],
                  section: unitSoldiers[index][8],
                  dateOfBirth: unitSoldiers[index][9],
                  rationType: unitSoldiers[index][10],
                  bloodType: unitSoldiers[index][11],
                  enlistmentDate: unitSoldiers[index][12],
                  ordDate: unitSoldiers[index][13],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
