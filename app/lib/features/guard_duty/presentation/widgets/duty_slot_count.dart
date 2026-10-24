import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../domain/entities/duty.dart';

const _countSize = 15.0;

/// A [label] on the left and "filled / 10" on the right.
class DutySlotCount extends StatelessWidget {
  const DutySlotCount({super.key, required this.label, required this.filled});

  final String label;
  final int filled;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        Expanded(
          child:
              Text(label, style: AppTextStyles.caption(palette.secondaryText)),
        ),
        Text.rich(
          TextSpan(
            text: '$filled',
            children: [
              TextSpan(
                text: ' / ${Duty.maxSlots}',
                style: AppTextStyles.figure(
                  _countSize,
                  FontWeight.w500,
                  palette.secondaryText,
                ),
              ),
            ],
          ),
          style: AppTextStyles.figure(
            _countSize,
            FontWeight.w600,
            palette.onCard,
          ),
        ),
      ],
    );
  }
}
