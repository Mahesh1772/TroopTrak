import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/status_types.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_segmented_control.dart';
import '../../../../core/widgets/field_chrome.dart';
import '../../../../core/widgets/inline_error.dart';
import '../../../statuses/domain/validators/status_validators.dart';

const _segments = [
  AppSegment<String?>(value: StatusTypes.excuse, label: 'Excuse'),
  AppSegment<String?>(value: StatusTypes.leave, label: 'Leave'),
  AppSegment<String?>(value: StatusTypes.medicalAppointment, label: 'MA'),
];

/// The Excuse / Leave / MA switch. Nothing is selected until [initialValue]
/// or a tap, and saving without a choice shows the type validator's message.
class StatusTypeField extends StatelessWidget {
  const StatusTypeField({
    super.key,
    required this.onChanged,
    this.initialValue,
  });

  final String? initialValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: initialValue,
      validator: StatusValidators.type,
      builder: (state) {
        final error = state.errorText;
        return LabeledField(
          label: 'Status type',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.inline.h,
            children: [
              AppSegmentedControl<String?>(
                segments: _segments,
                selected: state.value,
                onChanged: (type) {
                  state.didChange(type);
                  onChanged(type);
                },
              ),
              if (error != null) InlineError(error),
            ],
          ),
        );
      },
    );
  }
}
