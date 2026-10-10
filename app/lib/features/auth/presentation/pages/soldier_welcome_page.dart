import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/dark_section.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/usecases/soldier_entry.dart';

String routeForSoldierEntry(SoldierEntry entry) => switch (entry) {
      SoldierEntry.home => AppRoutes.soldierHome,
      SoldierEntry.profileCapture => AppRoutes.profileCapture,
      SoldierEntry.phoneEntry => AppRoutes.phoneEntry,
    };

/// Soldier gate (source Wrapper): GET STARTED resolves the entry route (R19).
class SoldierWelcomePage extends StatefulWidget {
  const SoldierWelcomePage({super.key});

  @override
  State<SoldierWelcomePage> createState() => _SoldierWelcomePageState();
}

class _SoldierWelcomePageState extends State<SoldierWelcomePage> {
  bool _loading = false;

  Future<void> _start() async {
    setState(() => _loading = true);
    final result = await context.read<ResolveSoldierEntry>()(const NoParams());
    if (!mounted) return;
    setState(() => _loading = false);
    await result.fold(
      (f) async => AppSnackbar.error(context, f.message),
      (entry) => Navigator.of(context)
          .pushReplacementNamed(routeForSoldierEntry(entry)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    return DarkSection(
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 35.w, vertical: 25.h),
              child: Column(
                children: [
                  Image.asset(
                    'lib/assets/phone_auth/troopTrak_mascot.png',
                    height: 300.h,
                    color: AppColors.authIcon,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                  Text('TroopTrak',
                      style: text.displayLarge?.copyWith(fontSize: 46.sp)),
                  SizedBox(height: 70.h),
                  Text('Welcome!',
                      style: text.displayLarge?.copyWith(
                          fontSize: 32.sp, color: AppColors.authLink)),
                  SizedBox(height: AppSpacing.xxxl.h),
                  Text('Time to book in 😄',
                      style: text.displayMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.authHint)),
                  SizedBox(height: 50.h),
                  PrimaryButton(
                    key: const Key('getStarted'),
                    label: 'GET STARTED',
                    loading: _loading,
                    onPressed: _start,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
