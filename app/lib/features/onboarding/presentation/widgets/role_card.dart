import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/rank_plate.dart';

const _selectedTint = 0.16;
const _radioStroke = 2.0;

/// One choice of a radio group: a large insignia plate, a title with a line
/// of guidance, and a radio mark. The selected card gets an accent border.
class RoleCard extends StatelessWidget {
  const RoleCard({
    super.key,
    required this.rank,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String rank;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final radius = BorderRadius.circular(AppRadii.xl.r);
    final fill = selected
        ? Color.alphaBlend(
            palette.accent.withValues(alpha: _selectedTint),
            palette.card,
          )
        : palette.card;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          key: const Key('roleCardBody'),
          duration: AppMotion.quick,
          padding: EdgeInsets.all(AppLayout.roleCardPadding.r),
          decoration: BoxDecoration(color: fill, borderRadius: radius),
          foregroundDecoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: selected ? palette.accent : palette.line,
              width: (selected
                      ? AppLayout.roleCardBorderSelected
                      : AppLayout.roleCardBorder)
                  .r,
            ),
          ),
          child: Row(
            spacing: AppSpacing.lg.w,
            children: [
              RankPlate(rank, size: RankPlate.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          AppTextStyles.optionTitle(context.colors.onSurface),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.subtitle(palette.secondaryText),
                    ),
                  ],
                ),
              ),
              _RadioMark(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioMark extends StatelessWidget {
  const _RadioMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = selected ? palette.accentText : palette.secondaryText;
    return Container(
      key: const Key('roleRadio'),
      width: AppLayout.roleRadio.r,
      height: AppLayout.roleRadio.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: _radioStroke.r),
      ),
      child: selected
          ? Container(
              key: const Key('roleRadioDot'),
              width: AppLayout.roleRadioDot.r,
              height: AppLayout.roleRadioDot.r,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            )
          : null,
    );
  }
}
