import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/clock.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/form_page_scaffold.dart';
import '../../../../core/widgets/picker_fields.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/validators/duty_date_limits.dart';
import '../../domain/validators/duty_validators.dart';
import '../providers/duty_form_provider.dart';
import '../widgets/duty_points_card.dart';
import '../widgets/duty_slot_count.dart';
import '../widgets/duty_slots.dart';

const _defaultTime = TimeOfDay(hour: 8, minute: 0);

/// Rebuild of `add_new_duty_screen.dart` and `update_duty_screen.dart`.
class DutyFormPage extends StatefulWidget {
  const DutyFormPage({super.key});

  @override
  State<DutyFormPage> createState() => _DutyFormPageState();
}

class _DutyFormPageState extends State<DutyFormPage> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _submit() async {
    final provider = context.read<DutyFormProvider>();
    if (!_formKey.currentState!.validate()) {
      AppSnackbar.error(context, 'Details missing');
      return;
    }
    final error = await provider.submit();
    if (!mounted) return;
    if (error != null) {
      AppSnackbar.error(context, error);
      return;
    }
    AppSnackbar.success(
        context,
        provider.isUpdate
            ? 'Guard duty updated successfully!'
            : 'Guard duty added successfully!');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DutyFormProvider>();
    final today = context.read<Clock>().now();
    return FormPageScaffold(
      formKey: _formKey,
      title: provider.isUpdate
          ? 'Edit an existing duty.'
          : 'Who is performing this duty?',
      subtitle: provider.isUpdate
          ? 'Fill in the details of the guard duty.'
          : 'Add details of the guard duty.',
      cta: PrimaryButton(
        key: const Key('saveDuty'),
        label: provider.isUpdate ? 'UPDATE GUARD DUTY' : 'ADD GUARD DUTY',
        icon: provider.isUpdate ? Icons.edit_rounded : Icons.add_rounded,
        loading: provider.saving,
        onPressed: _submit,
      ),
      children: [
        const DutySlots(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs.w),
          child: DutySlotCount(
            label: 'Slots filled',
            filled: provider.participants.length,
          ),
        ),
        DutyPointsCard(
            points: provider.pricing.points, dayType: provider.dayLabel),
        DatePickerField(
          key: const Key('dutyDate'),
          label: 'Date of Duty:',
          hintText: 'Date of Duty:',
          value: provider.date,
          initialDate: today,
          icon: Icons.event_rounded,
          firstDate: DutyDateLimits.earliest,
          lastDate: DutyDateLimits.latest(today),
          validator: DutyValidators.date,
          onChanged: provider.setDate,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.md.w,
          children: [
            Expanded(
              child: TimePickerField(
                key: const Key('dutyStart'),
                label: 'Start Time:',
                hintText: 'Start Time:',
                value: provider.start,
                initialTime: _defaultTime,
                icon: Icons.schedule_rounded,
                validator: DutyValidators.startTime,
                onChanged: provider.setStart,
              ),
            ),
            Expanded(
              child: TimePickerField(
                key: const Key('dutyEnd'),
                label: 'End Time:',
                hintText: 'End Time:',
                value: provider.end,
                initialTime: _defaultTime,
                icon: Icons.schedule_rounded,
                note: provider.endsNextDay ? 'next day' : null,
                validator: DutyValidators.endTime,
                onChanged: provider.setEnd,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
