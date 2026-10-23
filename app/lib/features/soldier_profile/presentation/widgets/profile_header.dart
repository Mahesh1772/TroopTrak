import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/gradient_header.dart';
import '../../../../core/widgets/rank_plate.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import 'profile_header_actions.dart';

const _unitFontSize = 14.0;
const _unitIconSize = 18.0;
const _idGap = 16.0;

/// Gradient header of the soldier profile: who they are, their unit, the
/// viewer's [actions] and an optional [footer] (the month tally).
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.soldier,
    this.actions = const [],
    this.footer,
    this.showBack = true,
    this.topTrailing,
  });

  final Soldier soldier;

  /// Pills under the unit chips (SHOW QR CODE, SIGN OUT, the theme toggle).
  final List<Widget> actions;

  /// Shown under the actions.
  final Widget? footer;

  /// False when the page is a shell tab (the soldier's My Profile).
  final bool showBack;

  /// Top-right button (the soldier's sign-out icon).
  final Widget? topTrailing;

  @override
  Widget build(BuildContext context) {
    final inset = EdgeInsets.symmetric(horizontal: AppSpacing.xl.w);
    return GradientHeader(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: AppLayout.appBarHeight.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs.w),
              child: Row(
                children: [
                  if (showBack)
                    HeaderIconButton(
                      key: const Key('profileBack'),
                      icon: Icons.arrow_back_rounded,
                      tooltip: 'Back',
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  const Spacer(),
                  if (topTrailing != null) topTrailing!,
                ],
              ),
            ),
          ),
          Padding(
            padding: inset,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Identity(soldier: soldier),
                SizedBox(height: AppLayout.profileUnitTop.h),
                _UnitChips(soldier: soldier),
                if (actions.isNotEmpty) ...[
                  SizedBox(height: AppLayout.profileActionTop.h),
                  Wrap(
                    spacing: AppSpacing.sm.w,
                    runSpacing: AppSpacing.sm.h,
                    children: actions,
                  ),
                ],
                if (footer != null) ...[
                  SizedBox(height: AppLayout.profileMonthTop.h),
                  footer!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity({required this.soldier});

  final Soldier soldier;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: _idGap.w,
      children: [
        RankPlate(soldier.rank, size: RankPlate.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.xxs.h,
            children: [
              Text(
                soldier.name.toUpperCase(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.profileName(AppColors.white),
              ),
              Text(
                '${soldier.rank} · ${soldier.appointment}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.barlow(
                  15,
                  FontWeight.w400,
                  AppColors.onGradientSubtitle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UnitChips extends StatelessWidget {
  const _UnitChips({required this.soldier});

  final Soldier soldier;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm.w,
      runSpacing: AppSpacing.sm.h,
      children: [
        _UnitChip(
          label: '${soldier.company.toUpperCase()} COMPANY',
          icon: Icons.shield_outlined,
        ),
        _UnitChip(
          label: 'Platoon ${soldier.platoon}, Section ${soldier.section}',
        ),
      ],
    );
  }
}

class _UnitChip extends StatelessWidget {
  const _UnitChip({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.onGradientChip,
        borderRadius: BorderRadius.circular(AppRadii.xl.r),
      ),
      child: SizedBox(
        height: AppLayout.unitChipHeight.h,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.inline.w,
            children: [
              if (icon != null)
                Icon(icon, size: _unitIconSize.r, color: AppColors.white),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.barlow(
                    _unitFontSize,
                    FontWeight.w500,
                    AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
