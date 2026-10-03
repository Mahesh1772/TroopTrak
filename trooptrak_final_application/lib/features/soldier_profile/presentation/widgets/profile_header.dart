import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/rank_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/rank_avatar.dart';
import '../../../soldiers/domain/entities/soldier.dart';

/// Gradient header of the source detail and profile screens.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.soldier,
    this.actions = const [],
  });

  final Soldier soldier;

  /// Sign out, theme toggle or QR buttons for the viewer's own profile.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    TextStyle? white(TextStyle? style, double size) => style?.copyWith(
        color: AppColors.white, fontSize: size.sp, letterSpacing: 1.5);
    final inset = EdgeInsets.symmetric(horizontal: 30.w);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg.r),
        gradient: LinearGradient(colors: context.palette.headerGradient),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(
              top: AppSpacing.sm.h,
              bottom: (actions.isEmpty ? 50 : AppSpacing.xxxl).h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                key: const Key('profileBack'),
                onPressed: () => Navigator.of(context).maybePop(),
                icon: Icon(Icons.arrow_back_sharp,
                    color: AppColors.white, size: 25.sp),
              ),
              SizedBox(height: AppSpacing.xl.h),
              Padding(
                padding: inset,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(soldier.name.toUpperCase(),
                              maxLines: 3, style: white(text.displayLarge, 25)),
                          SizedBox(height: AppSpacing.xs.h),
                          Text(soldier.appointment,
                              maxLines: 2, style: white(text.titleMedium, 16)),
                        ],
                      ),
                    ),
                    RankAvatar.insignia(
                      soldier.rank,
                      size: 60.w,
                      tint: false,
                      color: RankAssets.tintInsignia(soldier.rank)
                          ? AppColors.white
                          : null,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.xl.h),
              Padding(
                padding: inset,
                child: Text('${soldier.company.toUpperCase()} COMPANY',
                    maxLines: 2, style: white(text.headlineLarge, 18)),
              ),
              Padding(
                padding: inset,
                child: Text(
                    'Platoon ${soldier.platoon}, Section ${soldier.section}',
                    maxLines: 2,
                    style: white(text.titleMedium, 16)),
              ),
              for (final action in actions) ...[
                SizedBox(height: AppSpacing.xl.h),
                Center(child: action),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
