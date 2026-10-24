import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/rank_assets.dart';
import '../theme/theme_context.dart';

const _imageFraction = 0.76;
const _radiusFraction = 0.25;

/// A rank's insignia on a rounded plate, sized in design px.
class RankPlate extends StatelessWidget {
  const RankPlate(this.rank, {super.key, this.size = md});

  static const double sm = 32;
  static const double md = 40;
  static const double lg = 64;

  final String rank;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final pale = RankAssets.paleInsignia(rank);
    final side = size.r;
    final inner = side * _imageFraction;
    return SizedBox.square(
      dimension: side,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: pale ? palette.rankPlateDark : palette.rankPlate,
          borderRadius: BorderRadius.circular(side * _radiusFraction),
        ),
        child: Center(
          child: SizedBox.square(
            dimension: inner,
            child: Image.asset(
              RankAssets.insignia(rank),
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              semanticLabel: '$rank insignia',
              errorBuilder: (_, __, ___) => Icon(
                Icons.military_tech_rounded,
                size: inner,
                color: pale ? palette.rankPlate : palette.rankPlateDark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
