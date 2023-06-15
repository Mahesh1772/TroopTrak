import 'package:prototype_1/screens/guard_duty_tracker_screen.dart/guard_duty_tracker_screen.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:flutter/material.dart';

class DutyPersonnelDataSource extends DataGridSource {
  DutyPersonnelDataSource({required List<DutyPersonnel> dutyPersonnel}) {
    _dutyPersonnel = dutyPersonnel
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'name', value: e.name),
              DataGridCell<String>(columnName: 'image', value: e.image),
              DataGridCell<String>(columnName: 'rank', value: e.rank),
              DataGridCell<int>(columnName: 'points', value: e.points),
            ]))
        .toList();
  }

  List<DataGridRow> _dutyPersonnel = [];

  @override
  List<DataGridRow> get rows => _dutyPersonnel;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
        alignment: (dataGridCell.columnName == 'name' ||
                dataGridCell.columnName == 'points')
            ? Alignment.centerRight
            : Alignment.centerLeft,
        padding: const EdgeInsets.all(16.0),
        child: StyledText(
          dataGridCell.value.toString(),
          20,
          fontWeight: FontWeight.w600,
        ),
      );
    }).toList());
  }
}
