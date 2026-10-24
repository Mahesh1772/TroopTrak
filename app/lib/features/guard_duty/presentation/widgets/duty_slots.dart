import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/name_formats.dart';
import '../../../../core/widgets/rank_plate.dart';
import '../providers/duty_form_provider.dart';
import 'duty_picker_sheet.dart';

const _rows = [2, 4, 4];
const _emptyBorder = 1.5;
const _wideNameSize = 14.5;
const _narrowNameSize = 13.0;
const _nameLineHeight = 1.15;

/// The ten slots in rows of 2, 4 and 4. Any slot opens the soldier picker.
class DutySlots extends StatelessWidget {
  const DutySlots({super.key});

  @override
  Widget build(BuildContext context) {
    final filled =
        context.watch<DutyFormProvider>().participants.entries.toList();
    var from = 0;
    final rows = <Widget>[];
    for (final count in _rows) {
      final first = from;
      rows.add(
        Row(
          spacing: AppSpacing.tight.w,
          children: [
            for (var i = first; i < first + count; i++)
              Expanded(
                child: _Slot(
                  index: i,
                  wide: count == _rows.first,
                  name: i < filled.length ? filled[i].key : null,
                  rank: i < filled.length ? filled[i].value : null,
                  onTap: () => showDutyPicker(context),
                ),
              ),
          ],
        ),
      );
      from += count;
    }
    return Column(spacing: AppSpacing.tight.h, children: rows);
  }
}

class _Slot extends StatelessWidget {
  const _Slot({
    required this.index,
    required this.wide,
    required this.name,
    required this.rank,
    required this.onTap,
  });

  final int index;
  final bool wide;
  final String? name;
  final String? rank;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final name = this.name;
    final rank = this.rank;
    final filled = name != null && rank != null;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.tile.r),
      side: filled
          ? BorderSide.none
          : BorderSide(color: palette.tickOff, width: _emptyBorder.r),
    );
    final color = filled ? palette.onCard : palette.secondaryText;
    final style = AppTextStyles.barlow(
      wide ? _wideNameSize : _narrowNameSize,
      FontWeight.w600,
      color,
    ).copyWith(height: _nameLineHeight);

    final content = filled
        ? [
            RankPlate(rank, size: AppLayout.dutySlotPlate),
            Flexible(
              child: Text(
                wide ? name : formatShortName(name),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ),
          ]
        : [
            Icon(Icons.add_rounded, size: AppLayout.dutySlotAddIcon.r),
            if (wide) Text('Add soldier', style: style),
          ];
    final spacing = wide ? AppSpacing.tight.w : AppSpacing.inline.h;

    return Semantics(
      button: true,
      label: filled ? name : 'Add soldier',
      excludeSemantics: true,
      child: SizedBox(
        height: AppLayout.dutySlotHeight.h,
        child: Material(
          key: Key('slot-$index'),
          type: MaterialType.transparency,
          child: Ink(
            decoration: ShapeDecoration(
              color: filled ? palette.card : null,
              shape: shape,
            ),
            child: InkWell(
              onTap: onTap,
              customBorder: shape,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: wide ? AppSpacing.md.w : AppSpacing.inline.w,
                  vertical: AppSpacing.inline.h,
                ),
                child: wide
                    ? Row(spacing: spacing, children: content)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: spacing,
                        children: content,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
