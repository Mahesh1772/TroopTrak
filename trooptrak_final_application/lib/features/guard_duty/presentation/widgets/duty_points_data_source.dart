import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../nominal_roll/domain/entities/user.dart';

class DutyPointsDataSource extends DataGridSource {
  DutyPointsDataSource(Map<String, double> pointsMap, List<User> users) {
    _pointsData = pointsMap.entries
        .map((entry) {
          final user = users.firstWhere(
            (u) => u.name == entry.key,
            orElse: () => User(
              id: '',
              name: entry.key,
              rank: 'Unknown',
              company: '',
              apppointment: '',
              bloodgroup: '',
              currentAttendance: '',
              dob: '',
              enlistment: '',
              ord: '',
              platoon: '',
              points: '0',
              rationType: '',
              section: '',
            ),
          );

          return {
            'name': user.name,
            'points': entry.value,
            'rank': user.rank,
          };
        })
        .toList();

    _pointsData.sort((a, b) => (b['points'] as double).compareTo(a['points'] as double));

    _dataGridRows = _pointsData
        .map<DataGridRow>((dataGridRow) => DataGridRow(cells: [
              DataGridCell<String>(
                columnName: 'rank',
                value: dataGridRow['rank'] as String,
              ),
              DataGridCell<String>(
                columnName: 'name',
                value: dataGridRow['name'].toString(),
              ),
              DataGridCell<double>(
                columnName: 'points',
                value: dataGridRow['points'] as double,
              ),
            ]))
        .toList();
  }

  List<Map<String, dynamic>> _pointsData = [];
  List<DataGridRow> _dataGridRows = [];

  @override
  List<DataGridRow> get rows => _dataGridRows;

  String getRankImage(String rank) {
    if (rank == 'Unknown') {
      return "lib/assets/army-ranks/men.png";
    }
    return "lib/assets/army-ranks/${rank.toLowerCase()}.png";
  }

  Color soldierColorGenerator(String rank) {
    if (['REC', 'PTE', 'LCP', 'CPL', 'CFC'].contains(rank)) {
      return Colors.brown.shade800;
    } else if (rank == 'SCT') {
      return Colors.brown.shade400;
    } else if (['3SG', '2SG', '1SG', 'SSG', 'MSG'].contains(rank)) {
      return Colors.indigo.shade700;
    } else if (['3WO', '2WO', '1WO', 'MWO', 'SWO', 'CWO'].contains(rank)) {
      return Colors.indigo.shade400;
    } else if (rank == 'OCT') {
      return Colors.teal.shade900;
    } else if (['2LT', 'LTA', 'CPT'].contains(rank)) {
      return Colors.teal.shade800;
    } else {
      return Colors.teal.shade400;
    }
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        if (dataGridCell.columnName == 'rank') {
          final rank = dataGridCell.value.toString();
          return Container(
            padding: EdgeInsets.all(8.sp),
            alignment: Alignment.center,
            child: Image.asset(
              getRankImage(rank),
              width: 35.w,
              color: _rankColorPicker(rank) ? Colors.amber : null,
            ),
          );
        }
        return Container(
          padding: EdgeInsets.all(8.sp),
          alignment: Alignment.center,
          child: Text(
            dataGridCell.columnName == 'points'
                ? dataGridCell.value.toStringAsFixed(1)
                : dataGridCell.value.toString(),
            style: TextStyle(fontSize: 14.sp),
          ),
        );
      }).toList(),
    );
  }

  bool _rankColorPicker(String rank) {
    return [
      'REC',
      'PTE',
      'LCP',
      'CPL',
      'CFC',
      '3SG',
      '2SG',
      '1SG',
      'SSG',
      'MSG',
      '3WO',
      '2WO',
      '1WO',
      'MWO',
      'SWO',
      'CWO'
    ].contains(rank);
  }
} 