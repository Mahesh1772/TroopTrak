import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/fraction_bar.dart';

/// "QR will vanish in:" beside the `mm:ss` left (keyed `qrCountdown`), over a
/// bar that drains with [fraction] (1 down to 0), keyed `qrDrain`.
class QrCountdownCard extends StatelessWidget {
  const QrCountdownCard({
    super.key,
    required this.countdown,
    required this.fraction,
  });

  final String countdown;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AppCard(
      color: palette.cardElevated,
      radius: AppRadii.lg,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg.w,
        AppSpacing.md.h,
        AppSpacing.lg.w,
        AppSpacing.control.h,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  'QR will vanish in:',
                  style: AppTextStyles.subtitle(palette.secondaryText),
                ),
              ),
              Text(
                countdown,
                key: const Key('qrCountdown'),
                style: AppTextStyles.figure(
                  AppLayout.qrCountdownFigure,
                  FontWeight.w700,
                  palette.accentText,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.tight.h),
          FractionBar(
            fillKey: const Key('qrDrain'),
            fraction: fraction,
            height: AppLayout.qrDrainBar,
            duration: AppMotion.second,
          ),
        ],
      ),
    );
  }
}
