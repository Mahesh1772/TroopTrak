import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../domain/entities/attendance_record.dart';

class AttendanceTile extends StatelessWidget {
  final AttendanceRecord record;
  final Function(AttendanceRecord) onEdit;
  final Function(String) onDelete;

  const AttendanceTile({
    super.key,
    required this.record,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isInsideCamp = record.isInsideCamp;
    final Color tileColor = isInsideCamp ? Colors.green.shade600 : Colors.red;
    final IconData tileIcon = isInsideCamp ? Icons.work_history : Icons.home;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => onEdit(record),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
            ),
            SlidableAction(
              onPressed: (context) => onDelete(record.id),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  tileIcon,
                  color: Colors.white,
                  size: 25,
                ),
                const SizedBox(width: 15),
                SizedBox(
                  width: 80,
                  child: Text(
                    isInsideCamp ? "BOOK IN" : "BOOK OUT",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    record.dateTime,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
