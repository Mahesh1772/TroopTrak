import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';

class ShellTab {
  const ShellTab({
    required this.key,
    required this.label,
    required this.title,
    required this.icon,
    required this.builder,
  });

  final String key;
  final String label;
  final String title;
  final IconData icon;
  final WidgetBuilder builder;
}

/// Bottom-nav shell shared by both roles. Tabs are built on first visit and
/// then kept alive in an [IndexedStack]; back is disabled as in the source.
class ShellScaffold extends StatefulWidget {
  const ShellScaffold({
    super.key,
    required this.tabs,
    this.actions,
    this.showAppBar = true,
  });

  final List<ShellTab> tabs;
  final List<Widget>? actions;

  /// The soldier shell has no app bar, as in the source.
  final bool showAppBar;

  @override
  State<ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends State<ShellScaffold> {
  int _index = 0;
  final _visited = <int>{0};

  void _select(int index) => setState(() {
        _index = index;
        _visited.add(index);
      });

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    final background = context.colors.surface;
    final tabs = widget.tabs;
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: widget.showAppBar
            ? AppBar(
                toolbarHeight: 60.h,
                title: AutoSizeText(
                  tabs[_index].title,
                  maxLines: 1,
                  style: text.titleLarge?.copyWith(fontSize: 26.sp),
                ),
                actions: widget.actions,
              )
            : null,
        body: IndexedStack(
          index: _index,
          children: [
            for (var i = 0; i < tabs.length; i++)
              _visited.contains(i)
                  ? tabs[i].builder(context)
                  : const SizedBox.shrink(),
          ],
        ),
        bottomNavigationBar: ColoredBox(
          color: background,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm.w, vertical: 15.h),
              child: GNav(
                selectedIndex: _index,
                onTabChange: _select,
                gap: 7.w,
                backgroundColor: background,
                color: AppColors.navInactive,
                activeColor: AppColors.white,
                tabBackgroundGradient: const LinearGradient(
                  colors: [AppColors.brandIndigo, AppColors.navActiveEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                padding: EdgeInsets.all(AppSpacing.lg.sp),
                tabs: [
                  for (final tab in tabs)
                    GButton(
                      key: Key(tab.key),
                      icon: tab.icon,
                      text: tab.label,
                      textStyle: text.labelMedium?.copyWith(
                          color: AppColors.white, fontWeight: FontWeight.bold),
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
