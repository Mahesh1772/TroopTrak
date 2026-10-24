import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:recase/recase.dart';

import '../../features/soldiers/domain/entities/soldier.dart';
import '../theme/app_spacing.dart';
import 'app_list_card.dart';
import 'rank_chip.dart';
import 'rank_plate.dart';

/// A soldier in a list: plate, name, rank chip and a [note], keyed
/// `person-<name>`, with an optional [trailing] action. [dimmed] fades the row
/// but keeps it tappable.
class SoldierRow extends StatelessWidget {
  const SoldierRow({
    super.key,
    required this.soldier,
    required this.note,
    this.trailing,
    this.onTap,
    this.dimmed = false,
  });

  final Soldier soldier;
  final String note;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return AppListRow(
      key: Key('person-${soldier.name}'),
      title: soldier.name.titleCase,
      leading: RankPlate(soldier.rank),
      dimmed: dimmed,
      onTap: onTap,
      subtitle: Row(
        spacing: AppSpacing.inline.w,
        children: [
          RankChip(soldier.rank),
          Flexible(
            child: Text(note, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
      trailing: trailing,
    );
  }
}
