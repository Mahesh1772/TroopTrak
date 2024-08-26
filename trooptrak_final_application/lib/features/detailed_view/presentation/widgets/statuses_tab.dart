// statuses_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/status.dart';
import '../providers/status_provider.dart';
import '../pages/add_update_status_page.dart';
import '../widgets/status_tile.dart';

class StatusesTab extends StatefulWidget {
  final String userId;

  const StatusesTab({Key? key, required this.userId}) : super(key: key);

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

                  return ListView.builder(
                    itemCount: statuses.length,
                    itemBuilder: (context, index) {
                      final status = statuses[index];
                      return StatusTile(status: status, userId: widget.userId);
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