import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:recase/recase.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/rank_chip.dart';
import '../../../../core/widgets/rank_plate.dart';
import '../../../soldiers/domain/entities/soldier.dart';

/// A soldier on a conduct list: plate, name, rank chip and a [note], keyed
/// `person-<name>`.
class ConductPersonRow extends StatelessWidget {
  const ConductPersonRow(
      {super.key, required this.soldier, required this.note});

  final Soldier soldier;
  final String note;

  @override
  Widget build(BuildContext context) {
    return AppListRow(
      key: Key('person-${soldier.name}'),
      title: soldier.name.titleCase,
      leading: RankPlate(soldier.rank),
      subtitle: Row(
        spacing: AppSpacing.inline.w,
        children: [
          RankChip(soldier.rank),
          Flexible(
            child: Text(note, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
