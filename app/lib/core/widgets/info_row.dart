import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/theme_context.dart';

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
  });

  final IconData icon;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    return Padding(
      padding: EdgeInsets.only(left: 30.w, right: 30.w, top: 30.h),
      child: Row(
        children: [
          Icon(icon, size: 30.sp, color: context.colors.tertiary),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  style: text.titleLarge?.copyWith(letterSpacing: 1.5),
                ),
                Text(
                  content,
                  maxLines: 2,
                  style: text.displaySmall?.copyWith(letterSpacing: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
