import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/state_tone.dart';
import '../../../../core/widgets/tally_strip.dart';
import '../../domain/entities/nominal_roll.dart';

const _tickHeight = 22.0;

/// One tick per soldier, green when booked in, under "Booked in 31 / 41".
class BookedInTally extends StatelessWidget {
  const BookedInTally({super.key, required this.roll});

  final NominalRoll roll;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.control.w,
        AppSpacing.control.h,
        AppSpacing.control.w,
        AppSpacing.lg.h,
      ),
      child: TallyStrip(
        tickHeight: _tickHeight,
        groups: [
          TallyGroup(
            label: 'Booked in',
            figure: '${roll.bookedIn} / ${roll.total}',
            ticks: [
              for (final entry in roll.entries)
                TallyTick(
                  tone:
                      entry.soldier.isInCamp ? StateTone.inCamp : StateTone.out,
                  title: '${entry.soldier.rank} ${entry.soldier.name}',
                  detail: entry.soldier.isInCamp ? 'In camp' : 'Not in camp',
                ),
            ],
          ),
        ],
      ),
    );
  }
}
