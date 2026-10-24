import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_context.dart';
import '../utils/date_formats.dart';
import 'field_chrome.dart';

/// Wraps a picker shell in a [FormField] when a validator is given, so the
/// pick takes part in `Form.validate()`.
Widget _validated<T>({
  required T? value,
  required FormFieldValidator<T>? validator,
  required String? errorText,
  required Widget Function(String? errorText, ValueChanged<T> report) shell,
  required ValueChanged<T> onChanged,
}) {
  if (validator == null) return shell(errorText, onChanged);
  return FormField<T>(
    validator: (picked) => validator(picked ?? value),
    builder: (state) => shell(state.errorText ?? errorText, (v) {
      state.didChange(v);
      onChanged(v);
    }),
  );
}

/// A tappable field that opens the date picker. [label] sits above the field;
/// [hintText] shows inside it until a [value] is picked. [invalid] draws the
/// error border with no message, for fields that share a message elsewhere.
class DatePickerField extends StatelessWidget {
  const DatePickerField({
    super.key,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    required this.hintText,
    this.label,
    this.value,
    this.initialDate,
    this.icon = Icons.calendar_month_rounded,
    this.errorText,
    this.invalid = false,
    this.validator,
  });

  final ValueChanged<DateTime> onChanged;
  final DateTime firstDate;
  final DateTime lastDate;
  final String hintText;
  final String? label;
  final DateTime? value;
  final DateTime? initialDate;
  final IconData icon;
  final String? errorText;
  final bool invalid;
  final FormFieldValidator<DateTime>? validator;

  DateTime get _initial {
    final candidate = value ?? initialDate ?? lastDate;
    if (candidate.isBefore(firstDate)) return firstDate;
    if (candidate.isAfter(lastDate)) return lastDate;
    return candidate;
  }

  Future<void> _pick(
      BuildContext context, ValueChanged<DateTime> report) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _initial,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) report(picked);
  }

  @override
  Widget build(BuildContext context) => _validated<DateTime>(
        value: value,
        validator: validator,
        errorText: errorText,
        onChanged: onChanged,
        shell: (error, report) => _PickerShell(
          icon: icon,
          label: label,
          hintText: hintText,
          text: value == null ? null : formatDay(value!),
          errorText: error,
          invalid: invalid,
          onTap: () => _pick(context, report),
        ),
      );
}

/// A tappable field that opens the time picker, laid out like
/// [DatePickerField]. A [note] sits after the picked time.
class TimePickerField extends StatelessWidget {
  const TimePickerField({
    super.key,
    required this.onChanged,
    required this.hintText,
    this.label,
    this.value,
    this.initialTime = const TimeOfDay(hour: 9, minute: 0),
    this.icon = Icons.access_time_rounded,
    this.errorText,
    this.validator,
    this.note,
  });

  final ValueChanged<TimeOfDay> onChanged;
  final String hintText;
  final String? label;
  final String? note;
  final TimeOfDay? value;
  final TimeOfDay initialTime;
  final IconData icon;
  final String? errorText;
  final FormFieldValidator<TimeOfDay>? validator;

  Future<void> _pick(
      BuildContext context, ValueChanged<TimeOfDay> report) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: value ?? initialTime,
    );
    if (picked != null) report(picked);
  }

  @override
  Widget build(BuildContext context) {
    final time = value;
    return _validated<TimeOfDay>(
      value: value,
      validator: validator,
      errorText: errorText,
      onChanged: onChanged,
      shell: (error, report) => _PickerShell(
        icon: icon,
        label: label,
        hintText: hintText,
        text: time == null
            ? null
            : formatTime(DateTime(2000, 1, 1, time.hour, time.minute)),
        note: time == null ? null : note,
        errorText: error,
        onTap: () => _pick(context, report),
      ),
    );
  }
}

class _PickerShell extends StatelessWidget {
  const _PickerShell({
    required this.icon,
    required this.label,
    required this.hintText,
    required this.text,
    required this.errorText,
    required this.onTap,
    this.invalid = false,
    this.note,
  });

  final IconData icon;
  final String? label;
  final String hintText;
  final String? text;
  final String? errorText;
  final bool invalid;
  final String? note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = this.text;
    final note = this.note;
    return LabeledField(
      label: label,
      child: InkWell(
        onTap: onTap,
        customBorder: context.theme.inputDecorationTheme.border,
        child: InputDecorator(
          isEmpty: text == null,
          decoration: InputDecoration(
            prefixIcon: FieldIcon(icon),
            prefixIconConstraints: fieldPrefixConstraints,
            hintText: hintText,
            errorText: errorText,
            error:
                invalid && errorText == null ? const SizedBox.shrink() : null,
          ),
          child: text == null
              ? null
              : note == null
                  ? Text(text, maxLines: 1, style: fieldValueStyle(context))
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      spacing: AppSpacing.inline.w,
                      children: [
                        Text(text,
                            maxLines: 1, style: fieldValueStyle(context)),
                        Flexible(
                          child: Text(
                            note,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption(
                                context.palette.secondaryText),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
