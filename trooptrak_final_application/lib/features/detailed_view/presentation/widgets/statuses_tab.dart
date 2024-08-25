import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/status.dart';
import '../providers/status_provider.dart';
import '../pages/add_update_status_page.dart';

class StatusesTab extends StatelessWidget {
  final String userId;

  const StatusesTab({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<StatusProvider>(
      builder: (context, statusProvider, child) {
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: statusProvider.statuses.length,
                itemBuilder: (context, index) {
                  final status = statusProvider.statuses[index];
                  return ListTile(
                    title: Text(status.statusName),
                    subtitle: Text('${status.startDate} - ${status.endDate}'),
                    trailing: Text(status.statusType),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddUpdateStatusPage(
                            userId: userId,
                            status: status,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddUpdateStatusPage(userId: userId),
                  ),
                );
              },
              child: const Text('Add New Status'),
            ),
          ],
        );
      },
    );
  }
}