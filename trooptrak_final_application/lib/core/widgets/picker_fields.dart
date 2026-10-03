import 'package:flutter/material.dart';

import '../utils/date_formats.dart';

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

class DatePickerField extends StatelessWidget {
  const DatePickerField({
    super.key,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    required this.hintText,
    this.value,
    this.initialDate,
    this.icon = Icons.calendar_month_rounded,
    this.errorText,
    this.validator,
  });

  final ValueChanged<DateTime> onChanged;
  final DateTime firstDate;
  final DateTime lastDate;
  final String hintText;
  final DateTime? value;
  final DateTime? initialDate;
  final IconData icon;
  final String? errorText;
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
          hintText: hintText,
          label: value == null ? null : formatDay(value!),
          errorText: error,
          onTap: () => _pick(context, report),
        ),
      );
}

class TimePickerField extends StatelessWidget {
  const TimePickerField({
    super.key,
    required this.onChanged,
    required this.hintText,
    this.value,
    this.initialTime = const TimeOfDay(hour: 9, minute: 0),
    this.icon = Icons.access_time_rounded,
    this.errorText,
    this.validator,
  });

  final ValueChanged<TimeOfDay> onChanged;
  final String hintText;
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
        hintText: hintText,
        label: time == null
            ? null
            : formatTime(DateTime(2000, 1, 1, time.hour, time.minute)),
        errorText: error,
        onTap: () => _pick(context, report),
      ),
    );
  }
}

class _PickerShell extends StatelessWidget {
  const _PickerShell({
    required this.icon,
    required this.hintText,
    required this.label,
    required this.errorText,
    required this.onTap,
  });

  final IconData icon;
  final String hintText;
  final String? label;
  final String? errorText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        isEmpty: label == null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hintText,
          errorText: errorText,
        ),
        child: label == null
            ? null
            : Text(label!, style: theme.textTheme.bodyMedium),
      ),
    );
  }
}
