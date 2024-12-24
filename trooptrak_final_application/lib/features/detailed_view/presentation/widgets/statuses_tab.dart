// lib/presentation/pages/statuses_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/status.dart';
import '../providers/status_provider.dart';
import '../pages/add_update_status_page.dart';

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
    return Consumer<StatusProvider>(
      builder: (context, statusProvider, child) {
        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(30.0.sp),
                child: StreamBuilder<List<Status>>(
                  stream: statusProvider.statusesStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.secondary,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      );
                    }

                    final statuses = snapshot.data ?? [];
                    final sortedStatuses = sortStatuses(statuses);

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.medical_information_rounded,
                              size: 30.sp,
                              color: theme.colorScheme.tertiary,
                            ),
                            SizedBox(width: 20.w),
                            Text(
                              "Active Statuses",
                              maxLines: 2,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.tertiary,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 295.h,
                          child: statuses.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error_outline_rounded,
                                        size: 50.sp,
                                        color: theme.colorScheme.error,
                                      ),
                                      SizedBox(height: 10.h),
                                      Text(
                                        'No statuses found!',
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          color: theme.colorScheme.tertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.all(12.sp),
                                  itemCount: sortedStatuses.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    final status = sortedStatuses[index];
                                    if (!isPastStatus(status)) {
                                      return _buildStatusCard(context, status);
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.av_timer_rounded,
                              size: 30.sp,
                              color: theme.colorScheme.tertiary,
                            ),
                            SizedBox(width: 20.w),
                            Text(
                              "Past Statuses",
                              maxLines: 2,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.tertiary,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.all(12.sp),
                            itemCount: sortedStatuses.length,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              final status = sortedStatuses[index];
                              if (isPastStatus(status)) {
                                return _buildPastStatusCard(context, status);
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 50.h,
                          margin: EdgeInsets.symmetric(horizontal: 20.w),
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
                              Icons.add,
                              color: theme.colorScheme.tertiary,
                            ),
                            label: Text(
                              'ADD STATUS',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.tertiary,
                                letterSpacing: 1.5,
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
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusCard(BuildContext context, Status status) {
    final theme = Theme.of(context);
    return Container(
      width: 250.w,
      margin: EdgeInsets.only(right: 15.w),
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            status.statusType,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.tertiary,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            status.statusName,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.tertiary,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start Date',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.tertiary.withOpacity(0.5),
                    ),
                  ),
                  Text(
                    status.startDate,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'End Date',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.tertiary.withOpacity(0.5),
                    ),
                  ),
                  Text(
                    status.endDate,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPastStatusCard(BuildContext context, Status status) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.statusType,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.tertiary.withOpacity(0.7),
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  status.statusName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.tertiary,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Start: ${status.startDate}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.tertiary.withOpacity(0.5),
                ),
              ),
              Text(
                'End: ${status.endDate}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.tertiary.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
