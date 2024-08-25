import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
              print('Error in StatusesTab: ${snapshot.error}');
              print('Error stack trace: ${snapshot.stackTrace}');
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return const Center(child: Text('No data available'));
            }

            final statuses = snapshot.data!;
            print(statuses[0].toString());
            if (statuses.isEmpty) {
              return const Center(child: Text('No statuses found.'));
            }

            return ListView.builder(
              itemCount: statuses.length,
              itemBuilder: (context, index) {
                final status = statuses[index];
                return buildStatusTile(status);
              },
            );
          },
        );
      },
    );
  }

  Widget buildStatusTile(Status status) {
    IconData statusIcon = Icons.info;
    Color statusColor = Colors.blue;

    // Use a default value if statusType is null
    String statusTypeString = status.statusType.toLowerCase();

    switch (statusTypeString) {
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
                  const Icon(
                    Icons.delete_rounded,
                    color: Colors.white,
                    size: 30,
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
                (statusTypeString).toUpperCase(),
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
            ]
          ),
        ),
      ),
    );
  }
}
