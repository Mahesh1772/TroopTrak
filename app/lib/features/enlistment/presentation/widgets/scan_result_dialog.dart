import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/soldier_row.dart';
import '../../../../core/widgets/state_tone.dart';
import '../../../soldiers/domain/entities/soldier.dart';

/// What a scan found: the soldier's card with the keyed `goToEditPage` action
/// that pops `true`, or the invalid-code message when [profile] is null.
class ScanResultDialog extends StatelessWidget {
  const ScanResultDialog({super.key, this.profile});

  final Soldier? profile;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final found = profile;
    final tone = found == null ? StateTone.leave : StateTone.inCamp;
    return Dialog(
      backgroundColor: palette.sheet,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.sheet.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.lg.h,
          children: [
            Center(
              child: SizedBox.square(
                dimension: AppLayout.scanResultBadge.r,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tone.tint(palette),
                  ),
                  child: Icon(
                    found == null
                        ? Icons.remove_circle_rounded
                        : Icons.check_circle_rounded,
                    size: AppLayout.scanResultIcon.r,
                    color: tone.text(palette),
                  ),
                ),
              ),
            ),
            Text(
              found == null
                  ? 'Invalid QR / No such key found!'
                  : 'QR Code Successfully Scanned!',
              textAlign: TextAlign.center,
              style: AppTextStyles.compactTitle(palette.onCard),
            ),
            if (found != null) ...[
              AppCard(
                key: const Key('scanResultSoldier'),
                color: palette.cardElevated,
                radius: AppRadii.lg,
                child: SoldierRow(soldier: found, note: found.appointment),
              ),
              PrimaryButton(
                key: const Key('goToEditPage'),
                label: 'GO TO EDIT PAGE',
                icon: Icons.edit_document,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
