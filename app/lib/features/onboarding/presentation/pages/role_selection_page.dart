import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/app_role.dart';
import '../providers/role_selection_provider.dart';
import '../widgets/role_card.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  Future<void> _confirm(BuildContext context) async {
    final provider = context.read<RoleSelectionProvider>();
    final route = await provider.confirm();
    if (!context.mounted) return;
    if (route != null) {
      await Navigator.of(context).pushReplacementNamed(route);
    } else if (provider.error != null) {
      AppSnackbar.error(context, provider.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoleSelectionProvider>();
    final text = context.textStyles;
    final white = text.titleMedium?.copyWith(color: AppColors.white);
    return Scaffold(
      backgroundColor: AppColors.darkSurface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg.r),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RoleCard(
                    key: const Key('role-soldier'),
                    icon: 'lib/assets/icons8-soldiers-64.png',
                    title: 'Men',
                    subtitle: 'CFC and below',
                    pressed: provider.selected == AppRole.soldier,
                    onTap: () => provider.toggle(AppRole.soldier),
                  ),
                  RoleCard(
                    key: const Key('role-commander'),
                    icon: 'lib/assets/icons8-soldier-man-64.png',
                    title: 'Commanders',
                    subtitle: '3SG or higher',
                    pressed: provider.selected == AppRole.commander,
                    onTap: () => provider.toggle(AppRole.commander),
                  ),
                ],
              ),
              const Spacer(),
              Text('Please pick your role.',
                  textAlign: TextAlign.center,
                  style: text.displayLarge?.copyWith(
                      color: AppColors.white,
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w500)),
              SizedBox(height: AppSpacing.lg.h),
              Text('If you are rank 3SG or higher, select commanders.',
                  textAlign: TextAlign.center, style: white),
              Text('If your rank is CFC or lower, select men.',
                  textAlign: TextAlign.center, style: white),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox.square(
                  dimension: 60.r,
                  child: ElevatedButton(
                    key: const Key('role-confirm'),
                    onPressed: provider.saving ? null : () => _confirm(context),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                      backgroundColor: AppColors.deepPurple,
                    ),
                    child:
                        const Icon(Icons.arrow_forward, color: AppColors.white),
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
