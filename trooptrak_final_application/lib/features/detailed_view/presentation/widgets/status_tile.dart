// status_tile.dart
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/status.dart';
import '../providers/status_provider.dart';
import '../pages/add_update_status_page.dart';

class StatusTile extends StatelessWidget {
  final Status status;
  final String userId;

  const StatusTile({super.key, required this.status, required this.userId});

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
      padding: EdgeInsets.all(15.0.sp),
      child: Container(
        width: 230.w,
        height: 300.h,
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: statusColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              blurRadius: 2.0.r,
              spreadRadius: 2.0.r,
              offset: Offset(10.w, 10.h),
              color: Colors.black54,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  statusIcon,
                  color: Colors.white,
                  size: 60.sp,
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
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 30.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
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
                              SnackBar(
                                  content:
                                      Text('Error deleting status: $error')),
                            );
                          },
                        );
                      },
                      child: Icon(
                        Icons.delete_rounded,
                        color: Colors.white,
                        size: 30.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10.h),
            AutoSizeText(
              status.statusName,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 5.h),
            AutoSizeText(status.statusType.toUpperCase(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                    )),
            SizedBox(height: 5.h),
            AutoSizeText("${status.startDate} - ${status.endDate}",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    )),
          ],
        ),
      ),
    );
  }
}
