import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/picker_fields.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../attendance/domain/entities/attendance_record.dart';
import '../../../attendance/domain/usecases/attendance_usecases.dart';

/// Rebuild of `update_attendance_screen.dart`: changes date and time only;
/// the doc id and in/out flag stay, as in the source. The source started from
/// the doc id (the original booking time); this starts from the current value.
class EditAttendancePage extends StatefulWidget {
  const EditAttendancePage({super.key, required this.record});

  final AttendanceRecord record;

  @override
  State<EditAttendancePage> createState() => _EditAttendancePageState();
}

class _EditAttendancePageState extends State<EditAttendancePage> {
  late DateTime _date = widget.record.timestamp;
  late TimeOfDay _time = TimeOfDay.fromDateTime(widget.record.timestamp);
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    final at =
        DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    final result = await context
        .read<UpdateAttendance>()(widget.record.copyWith(timestamp: at));
    if (!mounted) return;
    setState(() => _saving = false);
    result.fold(
      (f) => AppSnackbar.error(context, f.message),
      (_) {
        AppSnackbar.success(context, 'Attendance updated');
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Edit Attendance',
                  style: text.displayLarge?.copyWith(fontSize: 30.sp)),
              Text('Fill in book in / book out time.',
                  style: text.bodySmall?.copyWith(fontWeight: FontWeight.w300)),
              SizedBox(height: 40.h),
              DatePickerField(
                key: const Key('attendanceDate'),
                hintText: 'Date',
                value: _date,
                icon: Icons.date_range_rounded,
                firstDate: DateTime(1960),
                lastDate: DateTime(2100),
                onChanged: (d) => setState(() => _date = d),
              ),
              SizedBox(height: 30.h),
              TimePickerField(
                key: const Key('attendanceTime'),
                hintText: 'Time',
                value: _time,
                icon: Icons.access_time_filled_rounded,
                onChanged: (t) => setState(() => _time = t),
              ),
              SizedBox(height: 40.h),
              PrimaryButton(
                key: const Key('saveAttendance'),
                label: 'EDIT ATTENDANCE',
                icon: Icons.edit_attributes_rounded,
                loading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
