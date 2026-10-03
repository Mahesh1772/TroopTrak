import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/clock.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/picker_fields.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/duty_form_provider.dart';
import '../widgets/duty_slots.dart';

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
    final text = context.textStyles;
    final today = context.read<Clock>().now();
    final gap = SizedBox(height: 30.h);
    final pricing = provider.pricing;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                    provider.isUpdate
                        ? 'Edit an existing duty.'
                        : 'Who is performing this duty?',
                    style: text.displayLarge?.copyWith(fontSize: 26.sp)),
                Text(
                    provider.isUpdate
                        ? 'Fill in the details of the guard duty.'
                        : 'Add details of the guard duty.',
                    style: text.bodyMedium),
                SizedBox(height: 40.h),
                const DutySlots(),
                SizedBox(height: 40.h),
                Container(
                  padding: EdgeInsets.all(AppSpacing.lg.sp),
                  decoration: BoxDecoration(
                    gradient:
                        LinearGradient(colors: context.palette.headerGradient),
                    borderRadius: BorderRadius.circular(AppRadii.lg.r),
                  ),
                  child: Column(
                    children: [
                      Text('EXPECTED POINTS PER PERSON',
                          style: text.headlineMedium
                              ?.copyWith(color: AppColors.white)),
                      Text('${pricing.points}',
                          key: const Key('expectedPoints'),
                          style: text.displayLarge
                              ?.copyWith(color: AppColors.white)),
                      Text(pricing.dayType,
                          key: const Key('dayType'),
                          style: text.titleMedium
                              ?.copyWith(color: AppColors.white)),
                    ],
                  ),
                ),
                gap,
                DatePickerField(
                  key: const Key('dutyDate'),
                  hintText: 'Date of Duty:',
                  value: provider.date,
                  initialDate: today,
                  icon: Icons.date_range_rounded,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(today.year + 1, 12, 31),
                  validator: (d) => d == null ? 'Select a duty date' : null,
                  onChanged: provider.setDate,
                ),
                gap,
                Row(
                  children: [
                    Expanded(
                      child: TimePickerField(
                        key: const Key('dutyStart'),
                        hintText: 'Start Time:',
                        value: provider.start,
                        initialTime: const TimeOfDay(hour: 8, minute: 0),
                        icon: Icons.access_time_filled_rounded,
                        validator: (t) =>
                            t == null ? 'Select a start time' : null,
                        onChanged: provider.setStart,
                      ),
                    ),
                    SizedBox(width: AppSpacing.xl.w),
                    Expanded(
                      child: TimePickerField(
                        key: const Key('dutyEnd'),
                        hintText: 'End Time:',
                        value: provider.end,
                        initialTime: const TimeOfDay(hour: 8, minute: 0),
                        icon: Icons.access_time_filled_rounded,
                        validator: (t) =>
                            t == null ? 'Select an end time' : null,
                        onChanged: provider.setEnd,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),
                PrimaryButton(
                  key: const Key('saveDuty'),
                  label: provider.isUpdate
                      ? 'UPDATE GUARD DUTY'
                      : 'ADD GUARD DUTY',
                  icon: Icons.add_to_photos_rounded,
                  loading: provider.saving,
                  onPressed: _submit,
                ),
                gap,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
