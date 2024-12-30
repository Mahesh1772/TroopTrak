import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../pages/add_conduct_screen.dart';

class AddConductButton extends StatelessWidget {
  const AddConductButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      height: 56.h,
      width: 56.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.secondary,
            theme.colorScheme.secondary.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.secondary.withOpacity(isDarkMode ? 0.2 : 0.3),
            blurRadius: 16.r,
            offset: Offset(0, 6.h),
            spreadRadius: 2.r,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddConductScreen(),
              ),
            );
          },
          child: Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 28.sp,
          ),
        ),
      ),
    );
  }
} 