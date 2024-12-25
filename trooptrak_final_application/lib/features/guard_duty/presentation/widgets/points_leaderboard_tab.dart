import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../providers/guard_duty_provider.dart';
import 'duty_points_data_source.dart';

class PointsLeaderboardTab extends StatelessWidget {
  const PointsLeaderboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GuardDutyProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text(provider.error!));
        }

        final duties = provider.duties;
        // Calculate points for each person
        final Map<String, double> pointsMap = {};
        for (final duty in duties) {
          for (final participant in duty.participants.keys) {
            pointsMap[participant] = (pointsMap[participant] ?? 0) + duty.points;
          }
        }

        return SfDataGrid(
          source: DutyPointsDataSource(pointsMap),
          columns: <GridColumn>[
            GridColumn(
              columnName: 'rank',
              label: Container(
                padding: EdgeInsets.all(8.0.sp),
                alignment: Alignment.center,
                child: const Text('Rank'),
              ),
            ),
            GridColumn(
              columnName: 'name',
              label: Container(
                padding: EdgeInsets.all(8.0.sp),
                alignment: Alignment.center,
                child: const Text('Name'),
              ),
            ),
            GridColumn(
              columnName: 'points',
              label: Container(
                padding: EdgeInsets.all(8.0.sp),
                alignment: Alignment.center,
                child: const Text('Points'),
              ),
            ),
          ],
        );
      },
    );
  }
} 