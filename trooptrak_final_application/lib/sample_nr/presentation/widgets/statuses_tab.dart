import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_detail_provider.dart';
import '../../domain/entities/status.dart';

class StatusesTab extends StatelessWidget {
  final String userId;

  const StatusesTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDetailProvider>(
      builder: (context, provider, child) {
        return StreamBuilder<List<Status>>(
          stream: provider.getUserStatuses(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final statuses = snapshot.data ?? [];

            if (statuses.isEmpty) {
              return const Center(child: Text('No statuses found.'));
            }

            return ListView.builder(
              itemCount: statuses.length,
              itemBuilder: (context, index) {
                final status = statuses[index];
                return Card(
                  child: ListTile(
                    title: Text(status.statusName),
                    subtitle: Text('${status.startDate} - ${status.endDate}'),
                    trailing: Text(status.statusType),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}