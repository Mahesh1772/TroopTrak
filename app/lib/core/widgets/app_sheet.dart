import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_layout.dart';
import '../theme/app_spacing.dart';
import '../theme/theme_context.dart';

/// Opens a modal bottom sheet on the sheet colour with 28 px top corners, a
/// grab handle and 20 px side padding. The sheet is as tall as what [builder]
/// returns, up to 90% of the screen; a scrolling child fills that height. It
/// rises above the keyboard.
Future<T?> showAppSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height *
            AppLayout.sheetMaxHeightFraction,
      ),
      builder: (context) => AppSheetFrame(child: builder(context)),
    );

/// The inside of a sheet: the grab handle, 20 px side padding and a bottom
/// that clears the home indicator. [showAppSheet] and any sheet-shaped route
/// share it.
class AppSheetFrame extends StatelessWidget {
  const AppSheetFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final handle = AppLayout.sheetHandle;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.only(bottom: AppLayout.sheetBottom.h),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl.w,
            AppLayout.sheetTop.h,
            AppSpacing.xl.w,
            0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  key: const Key('sheetHandle'),
                  width: handle.width.w,
                  height: handle.height.h,
                  decoration: BoxDecoration(
                    color: context.palette.tickOff,
                    borderRadius: BorderRadius.circular(handle.height / 2),
                  ),
                ),
              ),
              SizedBox(height: AppLayout.sheetHandleGap.h),
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
