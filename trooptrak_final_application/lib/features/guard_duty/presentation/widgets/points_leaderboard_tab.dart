import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../../../nominal_roll/domain/entities/user.dart';
import '../../../nominal_roll/presentation/providers/user_provider.dart';
import '../providers/guard_duty_provider.dart';
import 'duty_points_data_source.dart';

class PointsLeaderboardTab extends StatelessWidget {
  const PointsLeaderboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    
    return StreamBuilder<List<User>>(
      stream: userProvider.users,
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return Consumer<GuardDutyProvider>(
          builder: (context, dutyProvider, child) {
            if (dutyProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (dutyProvider.error != null) {
              return Center(child: Text(dutyProvider.error!));
            }

            final duties = dutyProvider.duties;
            // Calculate points for each person
            final Map<String, double> pointsMap = {};
            for (final duty in duties) {
              for (final participant in duty.participants.keys) {
                pointsMap[participant] = (pointsMap[participant] ?? 0) + duty.points;
              }
            }

            return SfDataGrid(
              source: DutyPointsDataSource(pointsMap, userSnapshot.data!),
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
      },
    );
  }
} 