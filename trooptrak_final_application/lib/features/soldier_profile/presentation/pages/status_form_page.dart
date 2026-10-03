import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/status_names.dart';
import '../../../../core/constants/status_types.dart';
import '../../../../core/services/clock.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/picker_fields.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../statuses/domain/entities/status.dart';
import '../../../statuses/domain/usecases/status_usecases.dart';
import '../widgets/suggestion_field.dart';

/// Rebuild of `add_new_status_screen.dart` and `update_status_screen.dart`.
/// The source update screen saved on every change and reverted on back; here
/// nothing is written until UPDATE STATUS.
class StatusFormPage extends StatefulWidget {
  const StatusFormPage({super.key, required this.soldierId, this.status});

  final String soldierId;

  /// The status being edited; null to add a new one.
  final Status? status;

  @override
  State<StatusFormPage> createState() => _StatusFormPageState();
}

class _StatusFormPageState extends State<StatusFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.status?.name);
  late String? _type = widget.status?.type;
  late final DateTime _today = context.read<Clock>().now();
  late DateTime _start = widget.status?.start ?? _today;
  late DateTime _end = widget.status?.end ?? _today;
  bool _saving = false;

  bool get _isUpdate => widget.status != null;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      AppSnackbar.error(context, 'Details missing');
      return;
    }
    final draft = Status(
      id: widget.status?.id ?? '',
      soldierId: widget.soldierId,
      type: _type!,
      name: _name.text,
      start: _start,
      end: _end,
      startAttendanceId: widget.status?.startAttendanceId,
      endAttendanceId: widget.status?.endAttendanceId,
    );
    setState(() => _saving = true);
    final result = await (_isUpdate
        ? context.read<UpdateStatus>()(
            UpdateStatusParams(previous: widget.status!, updated: draft))
        : context.read<AddStatus>()(draft));
    if (!mounted) return;
    setState(() => _saving = false);
    result.fold(
      (f) => AppSnackbar.error(context, f.message),
      (_) {
        AppSnackbar.success(
            context,
            _isUpdate
                ? 'Status updated successfully!'
                : 'Status added successfully!');
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    final gap = SizedBox(height: 30.h);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isUpdate
                      ? 'Edit the status for this soldier ✍️'
                      : "Let's add a new status for this soldier ✍️",
                  style: text.displayLarge?.copyWith(fontSize: 30.sp),
                ),
                Text('Fill in the details of the status',
                    style:
                        text.bodySmall?.copyWith(fontWeight: FontWeight.w300)),
                SizedBox(height: 40.h),
                AppDropdownField<String>(
                  key: const Key('statusType'),
                  items: StatusTypes.all,
                  value: _type,
                  hintText: 'Select status type...',
                  validator: (v) => v == null ? 'Bruh select Dei!' : null,
                  onChanged: (v) => setState(() => _type = v),
                ),
                gap,
                SuggestionField(
                  key: const Key('statusName'),
                  controller: _name,
                  suggestions: StatusNames.suggestions,
                  labelText: 'Enter Status Name:',
                  validator: (v) => (v ?? '').trim().isEmpty
                      ? 'Oi can enter the status type please?'
                      : null,
                ),
                gap,
                Row(
                  children: [
                    Expanded(
                      child: DatePickerField(
                        key: const Key('statusStart'),
                        hintText: 'Start date',
                        value: _start,
                        firstDate: DateTime(1960),
                        lastDate: DateTime(2100),
                        onChanged: (d) => setState(() => _start = d),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md.w),
                    Expanded(
                      child: DatePickerField(
                        key: const Key('statusEnd'),
                        hintText: 'End date',
                        value: _end,
                        firstDate: DateTime(1960),
                        lastDate: DateTime(2100),
                        onChanged: (d) => setState(() => _end = d),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),
                PrimaryButton(
                  key: const Key('saveStatus'),
                  label: _isUpdate ? 'UPDATE STATUS' : 'ADD STATUS',
                  icon: _isUpdate
                      ? Icons.edit_document
                      : Icons.add_to_photos_rounded,
                  loading: _saving,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
