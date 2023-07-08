import 'package:flutter/material.dart';

class AttendanceTab extends StatefulWidget {
  const AttendanceTab({
    super.key,
    required this.docID,
  });

  final String docID;

  @override
  State<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<AttendanceTab> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
