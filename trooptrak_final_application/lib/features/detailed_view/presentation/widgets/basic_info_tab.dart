import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/features/nominal_roll/presentation/widgets/action_button.dart';
import '../../../nominal_roll/presentation/pages/edit_soldier_screen.dart';
import '../../../nominal_roll/presentation/pages/nominal_roll_screen.dart';
import '../../../nominal_roll/presentation/providers/user_detail_provider.dart';

class BasicInfoTab extends StatelessWidget {
  final String userId;

  const BasicInfoTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        height: 900.h,
        child: Consumer<UserDetailProvider>(
          builder: (context, provider, child) {
            final user = provider.user;
            if (user == null) {
              return const Center(child: Text('User data not available'));
            }
            return Column(
              children: [
                buildInfoTile(
                  context,
                  Icons.cake_rounded,
                  'Date of Birth',
                  user.dob,
                ),
                buildInfoTile(
                  context,
                  Icons.food_bank_rounded,
                  'Ration Type',
                  user.rationType,
                ),
                buildInfoTile(
                  context,
                  Icons.bloodtype_rounded,
                  'Blood Group',
                  user.bloodgroup,
                ),
                buildInfoTile(
                  context,
                  Icons.date_range_rounded,
                  'Enlistment',
                  user.enlistment,
                ),
                buildInfoTile(
                  context,
                  Icons.military_tech_rounded,
                  'ORD',
                  user.ord,
                ),
                buildInfoTile(
                  context,
                  Icons.attribution_outlined,
                  'Current Attendance',
                  user.currentAttendance,
                ),
                buildInfoTile(
                  context,
                  Icons.control_point_duplicate_rounded,
                  'Points',
                  user.points.toString(),
                ),
                SizedBox(
                  height: 30.h,
                ),
                ActionButton(
                    gradientColors: const [
                      Color.fromARGB(255, 72, 30, 229),
                      Color.fromARGB(255, 130, 60, 229),
                    ],
                    text: "EDIT SOLDIER DETAILS",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditSoldierScreen(userId: userId),
                        ),
                      );
                    },
                    icon: Icons.edit),
                SizedBox(
                  height: 10.h,
                ),
                ActionButton(
                  gradientColors: const [
                    Color.fromARGB(255, 229, 30, 30),
                    Color.fromARGB(255, 229, 60, 60),
                  ],
                  text: "DELETE SOLDIER",
                  onPressed: () => _showDeleteConfirmationDialog(context, provider),
                  icon: Icons.delete,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildInfoTile(
      BuildContext context, IconData? icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(left: 30.0.w, right: 30.0.w, top: 30.0.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 30.sp,
          ),
          SizedBox(
            width: 20.w,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 2,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                      fontSize: 18.sp,
                    ),
              ),
              Text(
                value,
                maxLines: 2,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 20.sp,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, UserDetailProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this soldier? This action cannot be undone."),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () async {
                Navigator.of(context).pop();
                final result = await provider.deleteUser(userId);
                result.fold(
                  (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $error')),
                    );
                  },
                  (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Soldier deleted successfully')),
                    );
                     Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const NominalRollPage()),
                      (Route<dynamic> route) => false,
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}