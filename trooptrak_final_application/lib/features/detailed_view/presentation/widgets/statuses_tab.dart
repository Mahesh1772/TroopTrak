// lib/presentation/pages/statuses_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/status.dart';
import '../providers/status_provider.dart';
import '../pages/add_update_status_page.dart';
import 'status_tile.dart';
import 'past_status_tile.dart';

class StatusesTab extends StatefulWidget {
  final String userId;

  const StatusesTab({super.key, required this.userId});

  @override
  State<StatusesTab> createState() => _StatusesTabState();
}

class _StatusesTabState extends State<StatusesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StatusProvider>(context, listen: false)
          .loadStatuses(widget.userId);
    });
  }

  bool isPastStatus(Status status) {
    final currentDate = DateTime.now();
    final endDate = DateTime.parse(status.endId);
    return currentDate.isAfter(endDate);
  }

  List<Status> sortStatuses(List<Status> statuses) {
    final activeStatuses =
        statuses.where((status) => !isPastStatus(status)).toList();
    final pastStatuses =
        statuses.where((status) => isPastStatus(status)).toList();

    activeStatuses.sort(
        (a, b) => DateTime.parse(b.endId).compareTo(DateTime.parse(a.endId)));

    pastStatuses.sort(
        (a, b) => DateTime.parse(b.endId).compareTo(DateTime.parse(a.endId)));

    return [...activeStatuses, ...pastStatuses];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Consumer<StatusProvider>(
      builder: (context, statusProvider, child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: StreamBuilder<List<Status>>(
            stream: statusProvider.statusesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.secondary,
                    strokeWidth: 3.w,
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.error,
                      letterSpacing: 1.2,
                      fontSize: 14.sp,
                    ),
                  ),
                );
              }

              final statuses = snapshot.data ?? [];
              final sortedStatuses = sortStatuses(statuses);
              final activeStatuses = sortedStatuses.where((s) => !isPastStatus(s)).toList();
              final pastStatuses = sortedStatuses.where((s) => isPastStatus(s)).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active Statuses Section
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: isDarkMode 
                              ? const Color.fromARGB(255, 45, 50, 65)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode 
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.1),
                              blurRadius: 4.r,
                              offset: Offset(0, 2.h),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.warning_rounded,
                          size: 20.sp,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "Active Statuses",
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.tertiary,
                          letterSpacing: 1.2,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  if (activeStatuses.isEmpty)
                    Container(
                      height: 160.h,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 32.sp,
                            color: theme.colorScheme.error,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'No active statuses',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.tertiary,
                              letterSpacing: 1.2,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    SizedBox(
                      height: 160.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: activeStatuses.length,
                        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                        itemBuilder: (context, index) {
                          return StatusTile(
                            status: activeStatuses[index],
                            userId: widget.userId,
                          );
                        },
                      ),
                    ),

                  SizedBox(height: 32.h),
                  
                  // Past Statuses Section
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: isDarkMode 
                              ? const Color.fromARGB(255, 45, 50, 65)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode 
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.1),
                              blurRadius: 4.r,
                              offset: Offset(0, 2.h),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.history_rounded,
                          size: 20.sp,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "Past Statuses",
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.tertiary,
                          letterSpacing: 1.2,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  
                  // Fixed height container for past statuses
                  SizedBox(
                    height: 180.h,
                    child: pastStatuses.isEmpty
                        ? Center(
                            child: Text(
                              'No past statuses',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.tertiary.withOpacity(0.7),
                                letterSpacing: 1.2,
                                fontSize: 14.sp,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                            itemCount: pastStatuses.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: PastStatusTile(
                                  status: pastStatuses[index],
                                  userId: widget.userId,
                                ),
                              );
                            },
                          ),
                  ),

                  SizedBox(height: 32.h),
                  // Add Status Button
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddUpdateStatusPage(
                              userId: widget.userId,
                            ),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.add_circle_outline_rounded,
                        size: 20.sp,
                        color: Colors.white,
                      ),
                      label: Text(
                        'ADD NEW STATUS',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          fontSize: 14.sp,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
