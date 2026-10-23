import 'package:flutter/material.dart';

import '../../../../core/widgets/rank_plate.dart';

/// The app bar's profile button: the commander's rank on a round plate.
class CommanderAvatar extends StatelessWidget {
  const CommanderAvatar({super.key, required this.rank, required this.onTap});

  final String rank;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'My profile',
      excludeSemantics: true,
      child: ClipOval(
        child: Stack(
          children: [
            RankPlate(rank),
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(onTap: onTap),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
