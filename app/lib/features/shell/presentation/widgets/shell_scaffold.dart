import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import 'shell_navigation_bar.dart';
import 'shell_tab.dart';

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
    final tabs = widget.tabs;
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: widget.showAppBar
            ? AppBar(
                toolbarHeight: AppLayout.appBarHeight.h,
                backgroundColor: context.colors.surface,
                scrolledUnderElevation: 0,
                titleSpacing: AppSpacing.xl.w,
                actionsPadding: EdgeInsets.only(right: AppSpacing.md.w),
                title: Text(
                  tabs[_index].title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.pageTitle(context.colors.onSurface),
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
        bottomNavigationBar: ShellNavigationBar(
          tabs: tabs,
          selectedIndex: _index,
          onSelected: _select,
        ),
      ),
    );
  }
}
