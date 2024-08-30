import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActionButton extends StatelessWidget {
  const ActionButton(
      {super.key,
      required this.gradientColors,
      required this.text,
      required this.onPressed,
      required this.icon});

  final List<Color> gradientColors;
  final String text;
  final Function onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          onPressed;
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40.0.w, vertical: 16.0.h),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              gradient: LinearGradient(
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(50.0.r)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 30.sp,
                color: Colors.white,
              ),
              SizedBox(
                width: 20.w,
              ),
              Text(
                text,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 18.sp,
                      color: Colors.white,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
