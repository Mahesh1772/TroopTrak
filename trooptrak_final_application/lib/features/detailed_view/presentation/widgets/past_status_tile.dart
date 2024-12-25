// lib/presentation/widgets/past_status_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../domain/entities/status.dart';
import '../pages/add_update_status_page.dart';
import '../providers/status_provider.dart';
import 'package:provider/provider.dart';

class PastStatusTile extends StatelessWidget {
  final Status status;
  final String userId;

  const PastStatusTile({super.key, required this.status, required this.userId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    IconData statusIcon;
    Color statusColor;
    String statusLabel;

    switch (status.statusType.toLowerCase()) {
      case 'excuse':
        statusIcon = Icons.personal_injury_rounded;
        statusColor = const Color.fromARGB(255, 255, 180, 50);
        statusLabel = 'EXCUSE';
        break;
      case 'leave':
        statusIcon = Icons.medical_services_rounded;
        statusColor = const Color.fromARGB(255, 255, 100, 100);
        statusLabel = 'LEAVE';
        break;
      case 'medical appointment':
        statusIcon = Icons.date_range_rounded;
        statusColor = const Color.fromARGB(255, 100, 150, 255);
        statusLabel = 'MEDICAL';
        break;
      default:
        statusIcon = Icons.help_outline;
        statusColor = const Color.fromARGB(255, 130, 130, 130);
        statusLabel = status.statusType.toUpperCase();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.45,
          children: [
            SlidableAction(
              onPressed: (context) {
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
              backgroundColor: const Color.fromARGB(255, 89, 73, 255),
              foregroundColor: Colors.white,
              icon: Icons.edit_rounded,
              spacing: 4.h,
              label: 'EDIT',
              borderRadius: BorderRadius.horizontal(left: Radius.circular(12.r)),
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              flex: 1,
            ),
            SlidableAction(
              onPressed: (context) {
                Provider.of<StatusProvider>(context, listen: false)
                    .deleteStatus(userId, status.id)
                    .listen(
                  (event) {},
                  onDone: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Status deleted',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.2,
                            fontSize: 14.sp,
                          ),
                        ),
                        backgroundColor: const Color.fromARGB(255, 255, 100, 100),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        margin: EdgeInsets.all(16),
                      ),
                    );
                  },
                  onError: (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error deleting status: $error',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.2,
                            fontSize: 14.sp,
                          ),
                        ),
                        backgroundColor: const Color.fromARGB(255, 255, 100, 100),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        margin: EdgeInsets.all(16),
                      ),
                    );
                  },
                );
              },
              backgroundColor: const Color.fromARGB(255, 255, 100, 100),
              foregroundColor: Colors.white,
              icon: Icons.delete_rounded,
              spacing: 4.h,
              label: 'DELETE',
              borderRadius: BorderRadius.horizontal(right: Radius.circular(12.r)),
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              flex: 1,
            ),
          ],
        ),
        child: Container(
          height: 72.h,
          decoration: BoxDecoration(
            color: isDarkMode ? Color.fromARGB(255, 45, 50, 65) : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.1),
                blurRadius: 8.r,
                offset: Offset(0, 4.h),
                spreadRadius: isDarkMode ? 1.r : 0.r,
              ),
            ],
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  statusIcon,
                  color: Colors.white,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 2,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              statusLabel,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                fontSize: 14.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            AutoSizeText(
                              status.statusName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                                fontSize: 12.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        flex: 1,
                        child: AutoSizeText(
                          "${status.startDate}\n${status.endDate}",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                            fontSize: 11.sp,
                          ),
                          textAlign: TextAlign.end,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
