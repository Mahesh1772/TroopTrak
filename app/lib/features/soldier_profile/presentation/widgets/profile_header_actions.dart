import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../core/widgets/header_buttons.dart';

/// Shows the theme a tap switches to, as the mockup's gallery button does.
class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<ThemeManager>();
    final toDark = !manager.isDark;
    return HeaderPillButton(
      key: const Key('themeToggle'),
      label: toDark ? 'Dark' : 'Light',
      icon: toDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
      iconColor: AppColors.warning,
      onPressed: () => manager.setDark(toDark),
    );
  }
}
