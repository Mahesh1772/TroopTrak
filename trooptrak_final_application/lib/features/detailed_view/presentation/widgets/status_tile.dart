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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    IconData statusIcon;
    Color statusColor;
    String statusLabel;

    switch (status.statusType.toLowerCase()) {
      case 'excuse':
        statusIcon = Icons.personal_injury_rounded;
        statusColor = isDarkMode ? const Color.fromARGB(255, 255, 180, 50) : Colors.amber[700]!;
        statusLabel = 'EXCUSE';
        break;
      case 'leave':
        statusIcon = Icons.medical_services_rounded;
        statusColor = isDarkMode ? const Color.fromARGB(255, 255, 100, 100) : Colors.red[600]!;
        statusLabel = 'LEAVE';
        break;
      case 'medical appointment':
        statusIcon = Icons.date_range_rounded;
        statusColor = isDarkMode ? const Color.fromARGB(255, 100, 150, 255) : Colors.blue[600]!;
        statusLabel = 'MEDICAL';
        break;
      default:
        statusIcon = Icons.help_outline;
        statusColor = isDarkMode ? const Color.fromARGB(255, 130, 130, 130) : Colors.grey[600]!;
        statusLabel = status.statusType.toUpperCase();
    }

    return Container(
      width: 260.w,
      height: 140.h,
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color.fromARGB(255, 45, 50, 65) : theme.colorScheme.surface,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      statusIcon,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      statusLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
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
                      icon: Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(
                        minWidth: 20.w,
                        minHeight: 20.h,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    IconButton(
                      onPressed: () {
                        Provider.of<StatusProvider>(context, listen: false)
                            .deleteStatus(userId, status.id)
                            .listen(
                          (event) {},
                          onDone: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Status deleted',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: theme.colorScheme.error,
                              ),
                            );
                          },
                          onError: (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error deleting status: $error',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: theme.colorScheme.error,
                              ),
                            );
                          },
                        );
                      },
                      icon: Icon(
                        Icons.delete_rounded,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(
                        minWidth: 20.w,
                        minHeight: 20.h,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AutoSizeText(
                    status.statusName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDarkMode ? Colors.white : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      fontSize: 14.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  AutoSizeText(
                    "${status.startDate} - ${status.endDate}",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDarkMode 
                          ? Colors.grey[300]
                          : theme.colorScheme.onSurface.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
