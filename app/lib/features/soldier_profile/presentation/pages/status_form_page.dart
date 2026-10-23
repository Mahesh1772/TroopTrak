import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/clock.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/form_page_scaffold.dart';
import '../../../../core/widgets/inline_error.dart';
import '../../../../core/widgets/picker_fields.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../../statuses/domain/entities/status.dart';
import '../../../statuses/domain/services/book_out_note.dart';
import '../../../statuses/domain/usecases/status_usecases.dart';
import '../../../statuses/domain/validators/status_validators.dart';
import '../widgets/book_out_note_card.dart';
import '../widgets/soldier_summary_card.dart';
import '../widgets/status_type_field.dart';
import '../widgets/suggestion_chips.dart';

/// Rebuild of `add_new_status_screen.dart` and `update_status_screen.dart`.
/// The source update screen saved on every change and reverted on back; here
/// nothing is written until UPDATE STATUS.
class StatusFormPage extends StatefulWidget {
  const StatusFormPage({super.key, required this.soldier, this.status});

  final Soldier soldier;

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

  Status get _draft => Status(
        id: widget.status?.id ?? '',
        soldierId: widget.soldier.id,
        type: _type ?? '',
        name: _name.text,
        start: _start,
        end: _end,
        startAttendanceId: widget.status?.startAttendanceId,
        endAttendanceId: widget.status?.endAttendanceId,
      );

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
    final draft = _draft;
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
    final periodError = StatusValidators.period(_start, _end);
    final note = bookOutNote(_draft, widget.soldier);
    return FormPageScaffold(
      formKey: _formKey,
      title:
          _isUpdate ? 'Edit the status for this soldier' : 'Add a new status',
      subtitle: 'Fill in the details of the status',
      cta: PrimaryButton(
        key: const Key('saveStatus'),
        label: _isUpdate ? 'UPDATE STATUS' : 'ADD STATUS',
        icon: _isUpdate ? Icons.edit_rounded : Icons.add_rounded,
        loading: _saving,
        onPressed: _submit,
      ),
      children: [
        SoldierSummaryCard(soldier: widget.soldier),
        StatusTypeField(
          key: const Key('statusType'),
          initialValue: _type,
          onChanged: (type) => setState(() => _type = type),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              key: const Key('statusName'),
              controller: _name,
              label: 'Enter Status Name:',
              validator: StatusValidators.name,
            ),
            SuggestionChips(controller: _name, type: _type),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.inline.h,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.md.w,
              children: [
                Expanded(
                  child: DatePickerField(
                    key: const Key('statusStart'),
                    label: 'Start date',
                    hintText: 'Start date',
                    value: _start,
                    firstDate: DateTime(1960),
                    lastDate: DateTime(2100),
                    onChanged: (d) => setState(() => _start = d),
                  ),
                ),
                Expanded(
                  child: DatePickerField(
                    key: const Key('statusEnd'),
                    label: 'End date',
                    hintText: 'End date',
                    value: _end,
                    firstDate: DateTime(1960),
                    lastDate: DateTime(2100),
                    invalid: periodError != null,
                    onChanged: (d) => setState(() => _end = d),
                  ),
                ),
              ],
            ),
            if (periodError != null)
              InlineError(periodError, key: const Key('periodError')),
          ],
        ),
        if (note != null) BookOutNoteCard(note, key: const Key('bookOutNote')),
      ],
    );
  }
}
