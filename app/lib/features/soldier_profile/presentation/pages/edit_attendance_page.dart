import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/form_page_scaffold.dart';
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
  final _formKey = GlobalKey<FormState>();
  late DateTime _date = widget.record.timestamp;
  late TimeOfDay _time = TimeOfDay.fromDateTime(widget.record.timestamp);
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    final edited = widget.record
        .rescheduled(_date, hour: _time.hour, minute: _time.minute);
    final result = await context.read<UpdateAttendance>()(edited);
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
  Widget build(BuildContext context) => FormPageScaffold(
        formKey: _formKey,
        title: 'Edit Attendance',
        subtitle: 'Fill in book in / book out time.',
        cta: PrimaryButton(
          key: const Key('saveAttendance'),
          label: 'EDIT ATTENDANCE',
          icon: Icons.edit_rounded,
          loading: _saving,
          onPressed: _save,
        ),
        children: [
          DatePickerField(
            key: const Key('attendanceDate'),
            label: 'Date',
            hintText: 'Date',
            value: _date,
            firstDate: DateTime(1960),
            lastDate: DateTime(2100),
            onChanged: (d) => setState(() => _date = d),
          ),
          TimePickerField(
            key: const Key('attendanceTime'),
            label: 'Time',
            hintText: 'Time',
            value: _time,
            onChanged: (t) => setState(() => _time = t),
          ),
        ],
      );
}
