import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddSoldierToDutyTile extends StatelessWidget {
  final String rank;
  final String name;
  final String appointment;
  final bool isSelected;
  final Function(bool) onSelected;

  const AddSoldierToDutyTile({
    super.key,
    required this.rank,
    required this.name,
    required this.appointment,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Text(
          rank,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 12.sp,
          ),
        ),
      ),
      title: Text(
        name,
        style: TextStyle(fontSize: 14.sp),
      ),
      subtitle: Text(
        appointment,
        style: TextStyle(fontSize: 12.sp),
      ),
      trailing: Checkbox(
        value: isSelected,
        onChanged: (value) => onSelected(value ?? false),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.r),
        ),
      ),
    );
  }
} 