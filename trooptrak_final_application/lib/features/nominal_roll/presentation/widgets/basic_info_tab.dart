import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/user_detail_provider.dart';

class BasicInfoTab extends StatelessWidget {
  final String userId;

  const BasicInfoTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDetailProvider>(
      builder: (context, provider, child) {
        final user = provider.user;
        if (user == null) {
          return const Center(child: Text('User data not available'));
        }

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            buildInfoTile('Name', user.name),
            buildInfoTile('Rank', user.rank),
            buildInfoTile('Company', user.company),
            buildInfoTile('Appointment', user.apppointment),
            buildInfoTile('Blood Group', user.bloodgroup),
            buildInfoTile('Current Attendance', user.currentAttendance),
            buildInfoTile('Date of Birth', user.dob),
            buildInfoTile('Enlistment', user.enlistment),
            buildInfoTile('ORD', user.ord),
            buildInfoTile('Platoon', user.platoon),
            buildInfoTile('Points', user.points.toString()),
            buildInfoTile('Ration Type', user.rationType),
            buildInfoTile('Section', user.section),
          ],
        );
      },
    );
  }

  Widget buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 32, 36, 51),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
