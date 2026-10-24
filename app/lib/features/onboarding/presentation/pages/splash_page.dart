import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/linear_loader.dart';
import '../../domain/usecases/role_usecases.dart';
import '../providers/role_selection_provider.dart';

/// Resolves the stored role and replaces itself with the matching gate (R18).
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _route());
  }

  Future<void> _route() async {
    final result = await context.read<GetRole>()(const NoParams());
    if (!mounted || ModalRoute.of(context)?.isCurrent == false) return;
    final route = routeForRole(result.getOrElse(() => null));
    await Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandLogo(width: AppLayout.splashLogo),
            Transform.translate(
              offset: Offset(0, -AppSpacing.inline.h),
              child: Text(
                'Command centre in your pocket',
                textAlign: TextAlign.center,
                style: AppTextStyles.tagline(context.palette.secondaryText),
              ),
            ),
            SizedBox(height: AppLayout.splashLoaderTop.h),
            const LinearLoader(),
          ],
        ),
      ),
    );
  }
}
