import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/add_guard_duty_screen.dart';
import '../providers/guard_duty_provider.dart';
import 'package:trooptrak_final_application/features/guard_duty/domain/entities/guard_duty.dart';
import 'guard_duty_tile.dart';

class UpcomingDutiesTab extends StatelessWidget {
  const UpcomingDutiesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GuardDutyProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text(provider.error!));
        }

        final duties = provider.duties;
        if (duties.isEmpty) {
          return const Center(
            child: Text('No upcoming duties'),
          );
        }

        return ListView.builder(
          itemCount: duties.length,
          itemBuilder: (context, index) {
            final duty = duties[index];
            return GuardDutyTile(
              duty: duty,
              onEdit: () => _editDuty(context, duty),
              onDelete: () => _deleteDuty(context, duty),
            );
          },
        );
      },
    );
  }

  void _editDuty(BuildContext context, GuardDuty duty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddGuardDutyScreen(
          isEditing: true,
          dutyToEdit: duty,
        ),
      ),
    );
  }

  void _deleteDuty(BuildContext context, GuardDuty duty) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Duty'),
        content: const Text('Are you sure you want to delete this duty?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<GuardDutyProvider>().deleteDuty(duty);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 