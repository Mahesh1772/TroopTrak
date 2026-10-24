import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/theme_context.dart';
import 'shell_tab.dart';

/// The themed [NavigationBar] with the gradient pill behind the active icon.
class ShellNavigationBar extends StatelessWidget {
  const ShellNavigationBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<ShellTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.palette.line)),
      ),
      child: NavigationBar(
        height: AppLayout.shellNavBarHeight,
        elevation: 0,
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelected,
        destinations: [
          for (final tab in tabs)
            NavigationDestination(
              key: Key(tab.key),
              label: tab.label,
              icon: _NavPill(
                key: ValueKey('navPill-${tab.key}'),
                icon: tab.icon,
                active: false,
              ),
              selectedIcon: _NavPill(
                key: ValueKey('navPill-${tab.key}'),
                icon: tab.selectedIcon ?? tab.icon,
                active: true,
              ),
            ),
        ],
      ),
    );
  }
}

// Same type and key for the idle and active icon, so the pill fades in place.
class _NavPill extends StatelessWidget {
  const _NavPill({super.key, required this.icon, required this.active});

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.quick,
      curve: AppMotion.ease,
      width: AppLayout.navPill.width,
      height: AppLayout.navPill.height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppLayout.navPill.height / 2),
        gradient: active
            ? const LinearGradient(
                colors: AppColors.navPillGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      child: Icon(icon),
    );
  }
}
