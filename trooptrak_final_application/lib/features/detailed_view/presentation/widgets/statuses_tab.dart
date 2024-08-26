import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/status.dart';
import '../providers/status_provider.dart';
import '../pages/add_update_status_page.dart';

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
                      return buildStatusTile(context, status);
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

  Widget buildStatusTile(BuildContext context, Status status) {
    IconData statusIcon = Icons.info;
    Color statusColor = Colors.blue;

    switch (status.statusType.toLowerCase()) {
      case 'excuse':
        statusIcon = Icons.personal_injury_rounded;
        statusColor = Colors.amber[900]!;
        break;
      case 'leave':
        statusIcon = Icons.medical_services_rounded;
        statusColor = Colors.red;
        break;
      case 'medical appointment':
        statusIcon = Icons.date_range_rounded;
        statusColor = Colors.blue[600]!;
        break;
      default:
        statusIcon = Icons.help_outline;
        statusColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: statusColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              blurRadius: 2.0,
              spreadRadius: 2.0,
              offset: Offset(10, 10),
              color: Colors.black54,
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    statusIcon,
                    color: Colors.white,
                    size: 60,
                  ),
                  GestureDetector(
                    onTap: () {
                      Provider.of<StatusProvider>(context, listen: false)
                          .deleteStatus(widget.userId, status.id)
                          .listen(
                            (event) {},
                            onDone: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Status deleted')),
                              );
                            },
                            onError: (error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error deleting status: $error')),
                              );
                            },
                          );
                    },
                    child: const Icon(
                      Icons.delete_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                status.statusName,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                status.statusType.toUpperCase(),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "${status.startDate} - ${status.endDate}",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
