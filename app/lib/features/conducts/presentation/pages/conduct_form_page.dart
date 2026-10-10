import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';

import '../../../../core/constants/conduct_types.dart';
import '../../../../core/services/clock.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/picker_fields.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../providers/conduct_form_provider.dart';

/// Rebuild of `add_new_conduct_screen.dart` and `update_conduct_screen.dart`.
/// The source update screen wrote the initial values back on Back; nothing
/// is written here until the button is pressed.
class ConductFormPage extends StatefulWidget {
  const ConductFormPage({super.key});

  @override
  State<ConductFormPage> createState() => _ConductFormPageState();
}

class _ConductFormPageState extends State<ConductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(
      text: context.read<ConductFormProvider>().initial?.name);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final provider = context.read<ConductFormProvider>();
    if (!_formKey.currentState!.validate()) {
      AppSnackbar.error(context, 'Details missing');
      return;
    }
    final error = await provider.submit(_name.text);
    if (!mounted) return;
    if (error != null) {
      AppSnackbar.error(context, error);
      return;
    }
    AppSnackbar.success(
        context,
        provider.isUpdate
            ? 'Conduct updated successfully!'
            : 'Conduct added successfully!');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConductFormProvider>();
    final text = context.textStyles;
    final today = context.read<Clock>().now();
    final gap = SizedBox(height: 30.h);
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
                        ? 'Edit conduct ✍️'
                        : 'Add a new conduct ✍️',
                    style: text.displayLarge?.copyWith(fontSize: 30.sp)),
                Text('Details of the conduct',
                    style:
                        text.bodySmall?.copyWith(fontWeight: FontWeight.w300)),
                SizedBox(height: 40.h),
                AppDropdownField<String>(
                  key: const Key('conductType'),
                  items: ConductTypes.all,
                  value: provider.type,
                  hintText: 'Select conduct...',
                  validator: (v) => v == null ? 'Bruh select!' : null,
                  onChanged: provider.setType,
                ),
                gap,
                TextFormField(
                  key: const Key('conductName'),
                  controller: _name,
                  validator: (v) => (v ?? '').trim().isEmpty
                      ? 'Oi can add conduct please?'
                      : null,
                  decoration:
                      const InputDecoration(labelText: 'Enter Conduct Name:'),
                ),
                gap,
                DatePickerField(
                  key: const Key('conductDate'),
                  hintText: 'Date:',
                  value: provider.date,
                  initialDate: today,
                  icon: Icons.date_range_rounded,
                  firstDate: DateTime(2022),
                  lastDate: DateTime(today.year + 1, today.month, today.day),
                  validator: (d) => d == null ? 'Select a date' : null,
                  onChanged: provider.setDate,
                ),
                gap,
                Row(
                  children: [
                    Expanded(
                      child: TimePickerField(
                        key: const Key('startTime'),
                        hintText: 'Start Time:',
                        value: provider.start,
                        icon: Icons.access_time_filled_rounded,
                        validator: (t) =>
                            t == null ? 'Select a start time' : null,
                        onChanged: provider.setStart,
                      ),
                    ),
                    SizedBox(width: AppSpacing.xl.w),
                    Expanded(
                      child: TimePickerField(
                        key: const Key('endTime'),
                        hintText: 'End Time:',
                        value: provider.end,
                        icon: Icons.access_time_filled_rounded,
                        validator: (t) =>
                            t == null ? 'Select an end time' : null,
                        onChanged: provider.setEnd,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),
                Text('Add Participants', style: text.displayMedium),
                if (provider.rosterError != null)
                  Text(provider.rosterError!,
                      style: text.bodySmall
                          ?.copyWith(color: context.palette.danger)),
                Padding(
                  padding: EdgeInsets.all(AppSpacing.xl.sp),
                  child: AppSearchField(
                    key: const Key('participantSearch'),
                    hintText: 'Search Name',
                    onChanged: provider.search,
                  ),
                ),
                StateView<List<Soldier>>(
                  state: provider.soldiers,
                  builder: (context, _) {
                    final soldiers = provider.visibleSoldiers;
                    if (soldiers.isEmpty && provider.query.isNotEmpty) {
                      return Center(
                        child: Text('No results Found!',
                            style: text.displayLarge
                                ?.copyWith(color: AppColors.authLink)),
                      );
                    }
                    return Column(
                      children: [
                        for (final s in soldiers)
                          _ParticipantRow(
                            soldier: s,
                            participating: provider.isParticipating(s.name),
                            reason: provider.reasonFor(s.name),
                            onToggle: () => provider.toggle(s.name),
                          ),
                      ],
                    );
                  },
                ),
                gap,
                PrimaryButton(
                  key: const Key('saveConduct'),
                  label: provider.isUpdate
                      ? 'EDIT CONDUCT DETAILS'
                      : 'ADD NEW CONDUCT',
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

class _ParticipantRow extends StatelessWidget {
  const _ParticipantRow({
    required this.soldier,
    required this.participating,
    required this.reason,
    required this.onToggle,
  });

  final Soldier soldier;
  final bool participating;
  final String? reason;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    return Card(
      key: Key('participant-${soldier.name}'),
      child: ListTile(
        title: Text(soldier.name.titleCase, style: text.titleMedium),
        subtitle: reason == null ? null : Text(reason!, style: text.labelSmall),
        leading: InkWell(
          key: Key('toggle-${soldier.name}'),
          onTap: onToggle,
          borderRadius: BorderRadius.circular(AppRadii.md.r),
          child: Container(
            height: 40.h,
            width: 100.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: participating ? AppColors.danger : AppColors.success,
              borderRadius: BorderRadius.circular(AppRadii.md.r),
            ),
            child: Text(participating ? 'REMOVE' : 'ADD',
                style: text.headlineLarge?.copyWith(color: AppColors.white)),
          ),
        ),
      ),
    );
  }
}
