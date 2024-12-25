import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/guard_duty.dart';
import 'duty_participant_tile.dart';

class GuardDutyTile extends StatefulWidget {
  final GuardDuty duty;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const GuardDutyTile({
    super.key,
    required this.duty,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<GuardDutyTile> createState() => _GuardDutyTileState();
}

class _GuardDutyTileState extends State<GuardDutyTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: [
          ListTile(
            title: Text(
              'Guard Duty - ${widget.duty.dutyDate}',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${widget.duty.startTime} - ${widget.duty.endTime}\n'
              '${widget.duty.dutyType} (${widget.duty.points} points)',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: widget.onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: widget.onDelete,
                ),
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  onPressed: () {
                    setState(() => _isExpanded = !_isExpanded);
                  },
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            const Divider(),
            Padding(
              padding: EdgeInsets.all(16.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Participants',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 8.w,
                      mainAxisSpacing: 8.h,
                    ),
                    itemCount: widget.duty.participants.length,
                    itemBuilder: (context, index) {
                      final entry = widget.duty.participants.entries.elementAt(index);
                      return DutyParticipantTile(
                        name: entry.key,
                        rank: entry.value,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
} 