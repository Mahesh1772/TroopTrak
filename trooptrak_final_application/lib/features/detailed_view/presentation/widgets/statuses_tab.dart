// lib/presentation/pages/statuses_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/status.dart';
import '../providers/status_provider.dart';
import '../pages/add_update_status_page.dart';
import '../widgets/status_tile.dart';
import '../widgets/past_status_tile.dart';

class StatusesTab extends StatefulWidget {
  final String userId;

  const StatusesTab({super.key, required this.userId});

  @override
  _StatusesTabState createState() => _StatusesTabState();
}

class _StatusesTabState extends State<StatusesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StatusProvider>(context, listen: false).loadStatuses(widget.userId);
    });
  }

  bool isPastStatus(Status status) {
    final currentDate = DateTime.now();
    final endDate = DateTime.parse(status.endId);
    return currentDate.isAfter(endDate);
  }

  List<Status> sortStatuses(List<Status> statuses) {
    final activeStatuses = statuses.where((status) => !isPastStatus(status)).toList();
    final pastStatuses = statuses.where((status) => isPastStatus(status)).toList();

    // Sort active statuses by endDate in descending order (latest end date first)
    activeStatuses.sort((a, b) => DateTime.parse(b.endId).compareTo(DateTime.parse(a.endId)));

    // Sort past statuses by endDate in descending order (latest end date first)
    pastStatuses.sort((a, b) => DateTime.parse(b.endId).compareTo(DateTime.parse(a.endId)));

    // Combine the sorted lists with active statuses at the top
    return [...activeStatuses, ...pastStatuses];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StatusProvider>(
      builder: (context, statusProvider, child) {
        return Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Status>>(
                stream: statusProvider.statusesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    print('Error in StatusesTab: ${snapshot.error}');
                    print('Error stack trace: ${snapshot.stackTrace}');
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final statuses = snapshot.data ?? [];
                  print('Received ${statuses.length} statuses');

                  if (statuses.isEmpty) {
                    return const Center(child: Text('No statuses found.'));
                  }

                  final sortedStatuses = sortStatuses(statuses);

                  return ListView.builder(
                    itemCount: sortedStatuses.length,
                    itemBuilder: (context, index) {
                      final status = sortedStatuses[index];
                      if (isPastStatus(status)) {
                        return PastStatusTile(status: status, userId: widget.userId);
                      } else {
                        return StatusTile(status: status, userId: widget.userId);
                      }
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
                    builder: (context) => AddUpdateStatusPage(userId: widget.userId),
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
