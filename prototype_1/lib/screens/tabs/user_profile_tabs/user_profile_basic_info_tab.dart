import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prototype_1/screens/update_soldier_details_screen.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:prototype_1/util/text_styles/soldier_detailed_screen_info_template.dart';

class UserProfileBasicInfoTab extends StatelessWidget {
  final String dateOfBirth;
  final String rationType;
  final String bloodType;
  final String enlistmentDate;
  final String ordDate;

  const UserProfileBasicInfoTab(
      {super.key,
      required this.dateOfBirth,
      required this.rationType,
      required this.bloodType,
      required this.enlistmentDate,
      required this.ordDate});

  @override
  Widget build(BuildContext context) {
    const docIDs = 'Lee Kuan Yew';

    return SizedBox(
      height: 600,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(docIDs)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            //We are trying to map the key and values pairs
            //to a variable called "data" of Type Map
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;

            return Column(
              children: [
                SoldierDetailedInfoTemplate(
                  title: "Date Of Birth",
                  content: dateOfBirth.toUpperCase(),
                  icon: Icons.cake_rounded,
                ),
                SoldierDetailedInfoTemplate(
                  title: "Ration Type:",
                  content: rationType.toUpperCase(),
                  icon: Icons.food_bank_rounded,
                ),
                SoldierDetailedInfoTemplate(
                  title: "Blood Type:",
                  content: bloodType.toUpperCase(),
                  icon: Icons.bloodtype_rounded,
                ),
                SoldierDetailedInfoTemplate(
                  title: "Enlistment Date:",
                  content: enlistmentDate.toUpperCase(),
                  icon: Icons.date_range_rounded,
                ),
                SoldierDetailedInfoTemplate(
                  title: "ORD:",
                  content: ordDate.toUpperCase(),
                  icon: Icons.military_tech_rounded,
                ),
                const SizedBox(
                  height: 30,
                ),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          // Populating the controllers with pre-existing values
                          builder: (context) => UpdateSoldierDetailsPage(
                              name: TextEditingController(text: docIDs),
                              company:
                                  TextEditingController(text: data['company']),
                              platoon:
                                  TextEditingController(text: data['platoon']),
                              section:
                                  TextEditingController(text: data['section']),
                              appointment: TextEditingController(
                                  text: data['appointment']),
                              dob: data['dob'],
                              ord: data['ord'],
                              enlistment: data['enlistment'],
                              selectedItem: data['rationType'],
                              selectedRank: data['rank'],
                              selectedBloodType: data['bloodgroup']),
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
                      child: const StyledText("EDIT SOLDIER DETAILS", 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 16.0),
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          gradient: const LinearGradient(
                            colors: [
                              Colors.red,
                              Color.fromARGB(255, 237, 131, 124)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(50.0)),
                      child: const StyledText("DELETE SOLDIER DETAILS", 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            );
          }

          return const Text('Loading......');
        },
      ),
    );
  }
}
