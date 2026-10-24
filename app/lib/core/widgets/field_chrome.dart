import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_layout.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_context.dart';
import 'inline_error.dart';

const _labelSize = 13.5;
const _valueSize = 17.0;

/// Puts [label] above [child], as every form field in the mockup does. Without
/// a label it is just [child].
class LabeledField extends StatelessWidget {
  const LabeledField({super.key, required this.child, this.label});

  final Widget child;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final label = this.label;
    if (label == null) return child;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: AppSpacing.xs.w,
            bottom: AppSpacing.inline.h,
          ),
          child: Text(
            label,
            style: AppTextStyles.barlow(
              _labelSize,
              FontWeight.w500,
              context.palette.secondaryText,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// The leading icon of a field, 14 px from the edge. Material adds 4 px after a
/// prefix icon, so the 6 px here makes the mockup's 10 px gap to the text.
/// Pair it with [fieldPrefixConstraints] on the decoration.
class FieldIcon extends StatelessWidget {
  const FieldIcon(this.icon, {super.key, this.size = AppLayout.fieldIconSize});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsetsDirectional.only(
          start: AppSpacing.control.w,
          end: AppSpacing.inline.w,
        ),
        child: Icon(icon, size: size.r),
      );
}

const fieldPrefixConstraints = BoxConstraints();

/// Material starts a field's error 18 px in from the edge (14 of padding and a
/// 4 px gap); the mockup starts it 4 px in, under the label.
const _errorInset = 18.0;

/// The error line of a field: an [InlineError] pulled back under the label.
class FieldError extends StatelessWidget {
  const FieldError(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) => Transform.translate(
        offset: Offset(-_errorInset.w, 0),
        child: InlineError(message),
      );
}

/// Tabular figures for a picked date or time. The line is as tall as the
/// 16 px body text it replaces, so the field stays 52 high.
TextStyle fieldValueStyle(BuildContext context) =>
    AppTextStyles.figure(_valueSize, FontWeight.w500, context.palette.onCard)
        .copyWith(height: AppLayout.fieldLineHeight / _valueSize);
