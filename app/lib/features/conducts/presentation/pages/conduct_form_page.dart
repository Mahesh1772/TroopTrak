import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/conduct_types.dart';
import '../../../../core/services/clock.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/form_page_scaffold.dart';
import '../../../../core/widgets/picker_fields.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/validators/conduct_date_limits.dart';
import '../../domain/validators/conduct_validators.dart';
import '../providers/conduct_form_provider.dart';
import '../widgets/conduct_participants_section.dart';

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
    final today = context.read<Clock>().now();
    return FormPageScaffold(
      formKey: _formKey,
      title: provider.isUpdate ? 'Edit conduct' : 'Add a new conduct',
      subtitle: 'Details of the conduct',
      cta: PrimaryButton(
        key: const Key('saveConduct'),
        label: provider.isUpdate ? 'EDIT CONDUCT DETAILS' : 'ADD NEW CONDUCT',
        icon: provider.isUpdate ? Icons.edit_rounded : Icons.add_task_rounded,
        loading: provider.saving,
        onPressed: _submit,
      ),
      children: [
        AppDropdownField<String>(
          key: const Key('conductType'),
          label: 'Conduct type',
          items: ConductTypes.all,
          value: provider.type,
          hintText: 'Select conduct...',
          validator: ConductValidators.type,
          onChanged: provider.setType,
        ),
        AppTextField(
          key: const Key('conductName'),
          controller: _name,
          label: 'Enter Conduct Name:',
          validator: ConductValidators.name,
        ),
        DatePickerField(
          key: const Key('conductDate'),
          label: 'Date:',
          hintText: 'Date:',
          value: provider.date,
          initialDate: today,
          icon: Icons.event_rounded,
          firstDate: ConductDateLimits.earliest,
          lastDate: ConductDateLimits.latest(today),
          validator: ConductValidators.date,
          onChanged: provider.setDate,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.md.w,
          children: [
            Expanded(
              child: TimePickerField(
                key: const Key('startTime'),
                label: 'Start Time:',
                hintText: 'Start Time:',
                value: provider.start,
                icon: Icons.schedule_rounded,
                validator: ConductValidators.startTime,
                onChanged: provider.setStart,
              ),
            ),
            Expanded(
              child: TimePickerField(
                key: const Key('endTime'),
                label: 'End Time:',
                hintText: 'End Time:',
                value: provider.end,
                icon: Icons.schedule_rounded,
                validator: ConductValidators.endTime,
                onChanged: provider.setEnd,
              ),
            ),
          ],
        ),
        const ConductParticipantsSection(),
      ],
    );
  }
}
