import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/usecase/usecase.dart';
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
      backgroundColor: AppColors.darkSurface,
      body: Center(
        child: Image.asset(
          'lib/assets/phone_auth/troopTrak_logo.png',
          width: 220.w,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
