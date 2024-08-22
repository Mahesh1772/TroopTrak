import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_detail_provider.dart';

class BasicInfoTab extends StatelessWidget {
  final String userId;

  const BasicInfoTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDetailProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.user == null) {
          return const Center(child: Text('User data not available'));
        }

        final user = provider.user!;
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            ListTile(title: Text('Name: ${user.name}')),
            ListTile(title: Text('Rank: ${user.rank}')),
            ListTile(title: Text('Company: ${user.company}')),
            ListTile(title: Text('Appointment: ${user.apppointment}')),
            ListTile(title: Text('Blood Group: ${user.bloodgroup}')),
            ListTile(title: Text('Current Attendance: ${user.currentAttendance}')),
            ListTile(title: Text('Date of Birth: ${user.dob}')),
            ListTile(title: Text('Enlistment: ${user.enlistment}')),
            ListTile(title: Text('Platoon: ${user.platoon}')),
            ListTile(title: Text('Points: ${user.points.toString()}')),
            ListTile(title: Text('Ration Type: ${user.rationType}')),
            ListTile(title: Text('Section: ${user.section}')),
          ],
        );
      },
    );
  }
}