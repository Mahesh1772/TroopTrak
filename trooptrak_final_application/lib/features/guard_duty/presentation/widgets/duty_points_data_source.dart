import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DutyPointsDataSource extends DataGridSource {
  DutyPointsDataSource(Map<String, double> pointsMap) {
    _pointsData = pointsMap.entries
        .map((entry) => {
              'name': entry.key,
              'points': entry.value,
            })
        .toList();

    _pointsData.sort((a, b) => (b['points'] as double).compareTo(a['points'] as double));

    _dataGridRows = _pointsData
        .map<DataGridRow>((dataGridRow) => DataGridRow(cells: [
              DataGridCell<String>(
                columnName: 'rank',
                value: _getRankFromPoints(dataGridRow['points'] as double),
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

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        if (dataGridCell.columnName == 'rank') {
          return Container(
            padding: EdgeInsets.all(8.sp),
            alignment: Alignment.center,
            child: Text(
              dataGridCell.value.toString(),
              style: TextStyle(fontSize: 14.sp),
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

  String _getRankFromPoints(double points) {
    if (points >= 50) return '1st';
    if (points >= 30) return '2nd';
    if (points >= 20) return '3rd';
    return '${(_pointsData.indexOf(_pointsData.firstWhere((element) => element['points'] == points)) + 1)}th';
  }
} 