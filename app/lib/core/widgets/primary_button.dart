import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_layout.dart';
import '../theme/app_palette.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_context.dart';
import 'state_tone.dart';

const _disabledOpacity = 0.4;
const _outlineWidth = 1.5;
const _ghostAlpha = 0.22;
const _dangerAlpha = 0.55;
const _tonalAlpha = 0.22;
const _spinnerSize = 20.0;
const _spinnerStroke = 2.0;

/// primary: filled gradient. ghost: neutral outline. danger: red outline.
/// tonal: a tinted 40 px pill for a secondary action beside a title.
enum PrimaryButtonStyle { primary, ghost, danger, tonal }

/// A pill button. [expand] fills the available width; a tonal button always
/// wraps its content. [compact] is the 36 px size for buttons side by side
/// (32 px when tonal). A tonal button takes its colours from [tone], the
/// accent when it is null.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.style = PrimaryButtonStyle.primary,
    this.expand = true,
    this.compact = false,
    this.tone,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final PrimaryButtonStyle style;
  final bool expand;
  final bool compact;
  final StateTone? tone;

  @override
  Widget build(BuildContext context) {
    final look = _Look.of(style, context.palette, tone);
    final tonal = style == PrimaryButtonStyle.tonal;
    final enabled = onPressed != null && !loading;
    final size = tonal
        ? (compact ? _Size.tonalCompact : _Size.tonal)
        : compact
            ? _Size.compact
            : _Size.regular;
    final labelStyle = AppTextStyles.barlow(
      size.fontSize,
      FontWeight.w600,
      look.text,
    ).copyWith(letterSpacing: size.fontSize.sp * size.tracking);

    return Opacity(
      opacity: enabled || loading ? 1 : _disabledOpacity,
      child: Semantics(
        button: true,
        enabled: enabled,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            shape: StadiumBorder(side: look.outline ?? BorderSide.none),
            color: look.fill,
            gradient: look.gradient,
            shadows: look.shadows,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: enabled ? onPressed : null,
              child: SizedBox(
                height: size.height.h,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: (tonal && icon != null
                            ? AppSpacing.md
                            : size.horizontal)
                        .w,
                    end: size.horizontal.w,
                  ),
                  child: Row(
                    mainAxisSize:
                        expand && !tonal ? MainAxisSize.max : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: AppSpacing.sm.w,
                    children: [
                      if (loading)
                        SizedBox.square(
                          dimension: _spinnerSize.r,
                          child: CircularProgressIndicator(
                            strokeWidth: _spinnerStroke,
                            color: look.text,
                          ),
                        )
                      else ...[
                        if (icon != null)
                          Icon(
                            icon,
                            size: AppLayout.buttonIconSize.r,
                            color: look.text,
                          ),
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: labelStyle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _Size {
  regular(AppLayout.buttonHeight, 15, 0.04, AppSpacing.lg),
  compact(AppLayout.buttonCompactHeight, 13, 0.04, AppSpacing.control),
  tonal(AppLayout.buttonTonalHeight, 14.5, 0.02, AppSpacing.lg),
  tonalCompact(
      AppLayout.buttonTonalCompactHeight, 13, 0.04, AppSpacing.control);

  const _Size(this.height, this.fontSize, this.tracking, this.horizontal);

  final double height;
  final double fontSize;
  final double tracking;
  final double horizontal;
}

class _Look {
  const _Look({
    required this.text,
    this.fill,
    this.gradient,
    this.outline,
    this.shadows,
  });

  factory _Look.of(
    PrimaryButtonStyle style,
    AppPalette palette,
    StateTone? tone,
  ) =>
      switch (style) {
        PrimaryButtonStyle.primary => _Look(
            text: AppColors.white,
            gradient: LinearGradient(
              colors: palette.buttonGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shadows: AppShadows.button(palette.buttonGradient.last),
          ),
        PrimaryButtonStyle.ghost => _Look(
            text: palette.onCard,
            outline: BorderSide(
              color: Color.alphaBlend(
                palette.onCard.withValues(alpha: _ghostAlpha),
                palette.line,
              ),
              width: _outlineWidth,
            ),
          ),
        PrimaryButtonStyle.danger => _Look(
            text: palette.leaveText,
            outline: BorderSide(
              color: palette.danger.withValues(alpha: _dangerAlpha),
              width: _outlineWidth,
            ),
          ),
        PrimaryButtonStyle.tonal when tone != null => _Look(
            text: tone.text(palette),
            fill: tone.tint(palette),
          ),
        PrimaryButtonStyle.tonal => _Look(
            text: palette.accentText,
            fill: palette.accent.withValues(alpha: _tonalAlpha),
          ),
      };

  final Color text;
  final Color? fill;
  final Gradient? gradient;
  final BorderSide? outline;
  final List<BoxShadow>? shadows;
}
