import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/sticky_cta_page.dart';
import '../../domain/usecases/soldier_entry.dart';
import '../widgets/auth_header.dart';

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
  Widget build(BuildContext context) => StickyCtaPage(
        top: AppLayout.onboardingGap,
        cta: PrimaryButton(
          key: const Key('getStarted'),
          label: 'GET STARTED',
          loading: _loading,
          onPressed: _start,
        ),
        children: [
          Transform.translate(
            offset: Offset(-AppLayout.onboardingLogoShift.w, 0),
            child: const BrandLogo(width: AppLayout.onboardingLogo),
          ),
          SizedBox(height: AppLayout.onboardingGap.h),
          const AuthHeader(title: 'Welcome!', subtitle: 'Time to book in'),
        ],
      );
}
