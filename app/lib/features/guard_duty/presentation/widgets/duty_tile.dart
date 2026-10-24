import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/state_chip.dart';
import '../../../../core/widgets/state_tone.dart';
import '../../../../core/widgets/tally_strip.dart';
import '../../domain/entities/duty.dart';
import 'duty_participant_row.dart';
import 'duty_points_chip.dart';
import 'duty_slot_count.dart';

const _timeSize = 24.0;
const _nextDaySize = 16.0;
const _dateSize = 14.0;
const _timeLineHeight = 1.1;

/// A duty card: points, day type, time (with "(Next day)" for an overnight
/// duty), date and the ten-slot bar. A tap opens the participants and, for
/// commanders, EDIT / DELETE. With [participating] set (the soldier side) a
/// chip says whether the signed-in soldier is on the duty; [isSelf] marks
/// their own row.
class DutyTile extends StatefulWidget {
  const DutyTile({
    super.key,
    required this.duty,
    this.onEdit,
    this.onDelete,
    this.participating,
    this.isSelf,
  });

  final Duty duty;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool? participating;
  final bool Function(String name)? isSelf;

  @override
  State<DutyTile> createState() => _DutyTileState();
}

class _DutyTileState extends State<DutyTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final duty = widget.duty;
    return AppCard(
      key: Key('duty-${duty.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            expanded: _open,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadii.xl),
              onTap: () => setState(() => _open = !_open),
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg.r),
                child:
                    _Summary(duty: duty, participating: widget.participating),
              ),
            ),
          ),
          AnimatedSize(
            duration: AppMotion.standard,
            curve: AppMotion.ease,
            alignment: Alignment.topCenter,
            child: _open
                ? _Details(
                    duty: duty,
                    isSelf: widget.isSelf,
                    onEdit: widget.onEdit,
                    onDelete: widget.onDelete,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.duty, required this.participating});

  final Duty duty;
  final bool? participating;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final on = participating;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          spacing: AppSpacing.tight.w,
          children: [
            DutyPointsChip(duty.points),
            Expanded(
              child: Text(
                duty.dayLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption(palette.secondaryText),
              ),
            ),
            if (on != null)
              StateChip(
                on ? 'On duty' : 'Not on duty',
                key: Key('${on ? 'onDuty' : 'offDuty'}-${duty.id}'),
                tone: on ? StateTone.inCamp : StateTone.out,
                icon: on ? Icons.check_rounded : Icons.close_rounded,
              ),
          ],
        ),
        SizedBox(height: AppSpacing.md.h),
        Text.rich(
          TextSpan(
            text: formatTimeRange(duty.start, duty.end),
            children: [
              if (duty.endsNextDay)
                TextSpan(
                  text: ' (Next day)',
                  style: AppTextStyles.figure(
                    _nextDaySize,
                    FontWeight.w500,
                    palette.secondaryText,
                  ),
                ),
            ],
          ),
          style: AppTextStyles.figure(
            _timeSize,
            FontWeight.w600,
            palette.onCard,
          ).copyWith(height: _timeLineHeight),
        ),
        SizedBox(height: AppSpacing.xxs.h),
        Text(
          formatWeekdayDay(duty.day),
          style: AppTextStyles.barlow(
            _dateSize,
            FontWeight.w400,
            palette.secondaryText,
          ),
        ),
        SizedBox(height: AppSpacing.control.h),
        Semantics(
          container: true,
          label: '${duty.filledSlots} of ${Duty.maxSlots} slots filled',
          child: TallyStrip(
            tickHeight: AppLayout.dutySlotBar,
            maxGap: AppSpacing.xs,
            groups: [
              TallyGroup(
                ticks: [
                  for (final filled in duty.slots)
                    TallyTick(tone: filled ? StateTone.duty : StateTone.out),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.sm.h),
        DutySlotCount(label: 'Participants', filled: duty.filledSlots),
      ],
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({
    required this.duty,
    required this.isSelf,
    required this.onEdit,
    required this.onDelete,
  });

  final Duty duty;
  final bool Function(String name)? isSelf;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final self = isSelf;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg.w,
        0,
        AppSpacing.lg.w,
        AppSpacing.lg.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final MapEntry(key: name, value: rank)
              in duty.participants.entries)
            DutyParticipantRow(
              name: name,
              rank: rank,
              isSelf: self?.call(name) ?? false,
            ),
          if (onEdit != null || onDelete != null) ...[
            SizedBox(height: AppSpacing.md.h),
            Row(
              spacing: AppSpacing.md.w,
              children: [
                if (onEdit != null)
                  Expanded(
                    child: PrimaryButton(
                      key: Key('editDuty-${duty.id}'),
                      label: 'EDIT DUTY',
                      icon: Icons.edit_rounded,
                      style: PrimaryButtonStyle.ghost,
                      compact: true,
                      onPressed: onEdit,
                    ),
                  ),
                if (onDelete != null)
                  Expanded(
                    child: PrimaryButton(
                      key: Key('deleteDuty-${duty.id}'),
                      label: 'DELETE DUTY',
                      icon: Icons.delete_rounded,
                      style: PrimaryButtonStyle.danger,
                      compact: true,
                      onPressed: onDelete,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
