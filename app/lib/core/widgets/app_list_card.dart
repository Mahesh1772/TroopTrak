import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_layout.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_context.dart';

const _metaSize = 13.5;
const _dimmedOpacity = 0.45;

/// A rounded card of stacked rows. A hairline sits between neighbouring
/// children, inset by [dividerInset] design px so it clears a leading plate.
/// The optional [header] sits above the first row without a divider. [color]
/// replaces the card colour where the card sits on a surface of its own, such
/// as a sheet.
class AppListCard extends StatelessWidget {
  const AppListCard({
    super.key,
    required this.children,
    this.header,
    this.dividerInset = AppLayout.listDividerInset,
    this.color,
  });

  final List<Widget> children;
  final Widget? header;
  final double dividerInset;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: color ?? palette.card,
      borderRadius: BorderRadius.circular(AppRadii.xl.r),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null) header!,
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                indent: dividerInset.w,
                color: palette.line,
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// One row of an [AppListCard]: [leading], a one-line [title] over an optional
/// [subtitle], then [trailing]. A plain Text [subtitle] gets the meta style;
/// widgets that style themselves, such as chips, keep their own.
class AppListRow extends StatelessWidget {
  const AppListRow({
    super.key,
    required this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleStyle,
    this.enabled = true,
    this.dimmed = false,
  });

  final String title;
  final Widget? leading;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final TextStyle? titleStyle;

  /// When false the row ignores taps and its leading and text fade; the
  /// trailing widget stays as it is.
  final bool enabled;

  /// Fades the leading and text like a disabled row but still takes taps.
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final meta = subtitle;
    final faded = !enabled || dimmed;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: enabled ? onTap : null,
        hoverColor: palette.hover,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: AppLayout.listRowMinHeight.h),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.control.w,
              vertical: AppLayout.listRowVertical.h,
            ),
            child: Row(
              spacing: AppSpacing.md.w,
              children: [
                if (leading != null) _Fade(faded: faded, child: leading!),
                Expanded(
                  child: _Fade(
                    faded: faded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      spacing: AppSpacing.xxs.h,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: titleStyle ?? AppTextStyles.h3(palette.onCard),
                        ),
                        if (meta != null)
                          DefaultTextStyle(
                            style: AppTextStyles.barlow(
                              _metaSize,
                              FontWeight.w400,
                              palette.secondaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            child: meta,
                          ),
                      ],
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Fade extends StatelessWidget {
  const _Fade({required this.faded, required this.child});

  final bool faded;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      faded ? Opacity(opacity: _dimmedOpacity, child: child) : child;
}
