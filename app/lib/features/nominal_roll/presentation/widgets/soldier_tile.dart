import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/rank_chip.dart';
import '../../../../core/widgets/rank_plate.dart';
import '../../../../core/widgets/state_chip.dart';
import '../../../../core/widgets/state_tone.dart';
import '../../../statuses/domain/services/parade_roster.dart';

/// One row of the nominal roll: plate, name, rank chip and either the current
/// status or the appointment, with the book in/out switch.
class SoldierTile extends StatelessWidget {
  const SoldierTile({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onToggle,
  });

  final ParadeEntry entry;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final soldier = entry.soldier;
    final status = entry.status;
    return AppListRow(
      key: Key('soldierTile-${soldier.id}'),
      title: soldier.name,
      leading: RankPlate(soldier.rank),
      subtitle: Row(
        spacing: AppSpacing.inline.w,
        children: [
          RankChip(soldier.rank),
          Flexible(
            child: status != null
                ? StateChip(status.name, tone: status.tone)
                : Text(
                    soldier.appointment,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ],
      ),
      trailing: Semantics(
        label: 'Book ${soldier.name} ${soldier.isInCamp ? 'out' : 'in'}',
        child: Switch(
          key: Key('inCampToggle-${soldier.id}'),
          value: soldier.isInCamp,
          onChanged: onToggle,
        ),
      ),
      onTap: onTap,
    );
  }
}
