import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: const MyStatelessWidget(),
      ),
    );
  }
}

class MyStatelessWidget extends StatelessWidget {
  const MyStatelessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    /*return DataTable(
      columns: const <DataColumn>[
        DataColumn(
          label: Expanded(
            child: Text(
              'Name',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Text(
              'Age',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Text(
              'Role',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ),
      ],
      rows: const <DataRow>[
        DataRow(
          cells: <DataCell>[
            DataCell(Text('Sarah')),
            DataCell(Text('19')),
            DataCell(Text('Student')),
          ],
        ),
        DataRow(
          cells: <DataCell>[
            DataCell(Text('Janine')),
            DataCell(Text('43')),
            DataCell(Text('Professor')),
          ],
        ),
        DataRow(
          cells: <DataCell>[
            DataCell(Text('William')),
            DataCell(Text('27')),
            DataCell(Text('Associate Professor')),
          ],
        ),
      ],
    );
  }*/
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(columns: const [
        DataColumn(
            label: Text(
          'ID',
          style: TextStyle(
              fontSize: 40, fontWeight: FontWeight.w800, color: Colors.red),
        )),
        DataColumn(
            label: Text(
          'NAME',
          style: TextStyle(
              fontSize: 40, fontWeight: FontWeight.w800, color: Colors.red),
        )),
        DataColumn(
            label: Text(
          'AGE',
          style: TextStyle(
              fontSize: 40, fontWeight: FontWeight.w800, color: Colors.red),
        )),
      ], rows: const [
        DataRow(cells: [
          DataCell(Text('0001')),
          DataCell(Text('Zisan')),
          DataCell(Text('16')),
        ]),
        DataRow(cells: [
          DataCell(Text('0002')),
          DataCell(Text('Riyan')),
          DataCell(Text('21')),
        ]),
        DataRow(cells: [
          DataCell(Text('0003')),
          DataCell(Text('Safiq')),
          DataCell(Text('29')),
        ]),
        DataRow(cells: [
          DataCell(Text('0004')),
          DataCell(Text('Faruk')),
          DataCell(Text('36')),
        ]),
        DataRow(cells: [
          DataCell(Text('0001')),
          DataCell(Text('Zisan')),
          DataCell(Text('16')),
        ]),
        DataRow(cells: [
          DataCell(Text('0002')),
          DataCell(Text('Riyan')),
          DataCell(Text('21')),
        ]),
        DataRow(cells: [
          DataCell(Text('0003')),
          DataCell(Text('Safiq')),
          DataCell(Text('29')),
        ]),
        DataRow(cells: [
          DataCell(Text('0004')),
          DataCell(Text('Faruk')),
          DataCell(Text('36')),
        ]),
        DataRow(cells: [
          DataCell(Text('0001')),
          DataCell(Text('Zisan')),
          DataCell(Text('16')),
        ]),
        DataRow(cells: [
          DataCell(Text('0002')),
          DataCell(Text('Riyan')),
          DataCell(Text('21')),
        ]),
        DataRow(cells: [
          DataCell(Text('0003')),
          DataCell(Text('Safiq')),
          DataCell(Text('29')),
        ]),
        DataRow(cells: [
          DataCell(Text('0004')),
          DataCell(Text('Faruk')),
          DataCell(Text('36')),
        ]),
        DataRow(cells: [
          DataCell(Text('0001')),
          DataCell(Text('Zisan')),
          DataCell(Text('16')),
        ]),
        DataRow(cells: [
          DataCell(Text('0002')),
          DataCell(Text('Riyan')),
          DataCell(Text('21')),
        ]),
        DataRow(cells: [
          DataCell(Text('0003')),
          DataCell(Text('Safiq')),
          DataCell(Text('29')),
        ]),
        DataRow(cells: [
          DataCell(Text('0004')),
          DataCell(Text('Faruk')),
          DataCell(Text('36')),
        ]),
      ]),
    );
  }
}
