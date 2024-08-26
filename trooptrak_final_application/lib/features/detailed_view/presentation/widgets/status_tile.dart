// status_tile.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/status.dart';
import '../providers/status_provider.dart';
import '../pages/add_update_status_page.dart';

class StatusTile extends StatelessWidget {
  final Status status;
  final String userId;

  const StatusTile({Key? key, required this.status, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  Row(
                    children: [
                      GestureDetector(
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
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          Provider.of<StatusProvider>(context, listen: false)
                              .deleteStatus(userId, status.id)
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