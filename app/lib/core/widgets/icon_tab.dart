import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_layout.dart';
import '../theme/app_spacing.dart';

/// A [Tab] with an icon beside its label; the tab bar theme colours both.
class IconTab extends StatelessWidget {
  const IconTab({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.inline.w,
        children: [
          Icon(icon, size: AppLayout.tabIconSize.r),
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
