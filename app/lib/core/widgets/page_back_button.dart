import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_layout.dart';
import '../theme/app_spacing.dart';
import '../theme/theme_context.dart';

/// A 44 px back arrow for a page with no app bar. It sits 12 px left of the
/// page inset so the arrow lines up with the title below it.
class PageBackButton extends StatelessWidget {
  const PageBackButton({super.key});

  @override
  Widget build(BuildContext context) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Transform.translate(
          offset: Offset(-AppSpacing.md.w, 0),
          child: IconButton(
            tooltip: 'Back',
            color: context.colors.onSurface,
            style: IconButton.styleFrom(
              fixedSize: Size.square(AppLayout.pageBackButton.r),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
      );
}
