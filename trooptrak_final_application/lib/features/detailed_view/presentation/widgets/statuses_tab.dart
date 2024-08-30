// lib/presentation/pages/statuses_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/features/nominal_roll/presentation/widgets/action_button.dart';
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

    // Sort active statuses by endDate in descending order (latest end date first)
    activeStatuses.sort(
        (a, b) => DateTime.parse(b.endId).compareTo(DateTime.parse(a.endId)));

    // Sort past statuses by endDate in descending order (latest end date first)
    pastStatuses.sort(
        (a, b) => DateTime.parse(b.endId).compareTo(DateTime.parse(a.endId)));

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
              child: Padding(
                padding: EdgeInsets.all(30.0.sp),
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
                            ),
                            SizedBox(
                              width: 20.w,
                            ),
                            Text(
                              "Active Statuses",
                              maxLines: 2,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    fontSize: 20.sp,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error_outline_rounded,
                                        size: 50.sp,
                                        color: Colors.red,
                                      ),
                                      SizedBox(height: 10.h),
                                      Text(
                                        'No statuses found!',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium,
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

                                    return StatusTile(
                                        status: status, userId: widget.userId);
                                  },
                                ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.av_timer_rounded,
                              size: 30.sp,
                            ),
                            SizedBox(
                              width: 20.w,
                            ),
                            Text(
                              "Past Statuses",
                              maxLines: 2,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    fontSize: 20.sp,
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
                                return PastStatusTile(
                                    status: status, userId: widget.userId);
                              } else {
                                return Center(
                                  child: Text(
                                    'No past statuses found',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        ActionButton(
                          gradientColors: const [
                            Color.fromARGB(255, 72, 30, 229),
                            Color.fromARGB(255, 130, 60, 229),
                          ],
                          text: "ADD STATUS",
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => AddUpdateStatusPage(
                                userId: widget.userId,
                              ),
                            ));
                          },
                          icon: Icons.add,
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
}
