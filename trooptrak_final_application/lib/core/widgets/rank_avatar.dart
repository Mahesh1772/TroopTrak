import 'package:flutter/material.dart';

import '../constants/rank_assets.dart';
import '../theme/app_colors.dart';

enum RankAvatarKind { insignia, person }

class RankAvatar extends StatelessWidget {
  const RankAvatar.insignia(
    this.rank, {
    super.key,
    this.size = 30,
    this.tint = true,
    this.color,
  }) : kind = RankAvatarKind.insignia;

  const RankAvatar.person(this.rank, {super.key, this.size = 30, this.color})
      : kind = RankAvatarKind.person,
        tint = false;

  final String rank;
  final double size;
  final bool tint;
  final Color? color;
  final RankAvatarKind kind;

  String get assetPath => kind == RankAvatarKind.insignia
      ? RankAssets.insignia(rank)
      : RankAssets.personIcon(rank);

  @override
  Widget build(BuildContext context) {
    final imageColor = color ??
        (tint && RankAssets.tintInsignia(rank) ? AppColors.white70 : null);
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      color: imageColor,
      errorBuilder: (_, __, ___) =>
          Icon(Icons.military_tech, size: size, color: imageColor),
    );
  }
}
