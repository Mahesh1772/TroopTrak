import 'package:flutter/material.dart';

import '../theme/app_layout.dart';
import '../theme/app_radii.dart';
import '../theme/theme_context.dart';
import 'app_sheet.dart';
import 'hero_dialog_route.dart';

/// A bottom sheet for a [HeroDialogRoute]: anchored to the bottom edge on the
/// sheet colour with 28 px top corners, the grab handle and the same padding as
/// [showAppSheet]. The [Hero] flies from the widget sharing [tag]; content
/// taller than 90% of the screen scrolls.
class HeroSheet extends StatelessWidget {
  const HeroSheet({super.key, required this.tag, required this.child});

  final Object tag;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final surface = Material(
      color: context.palette.sheet,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.sheetCorners),
    );
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: double.infinity,
          maxHeight: MediaQuery.sizeOf(context).height *
              AppLayout.sheetMaxHeightFraction,
        ),
        child: Hero(
          tag: tag,
          createRectTween: (begin, end) =>
              CustomRectTween(begin: begin!, end: end!),
          flightShuttleBuilder: (_, __, ___, ____, _____) => surface,
          child: Material(
            color: context.palette.sheet,
            shape: const RoundedRectangleBorder(
                borderRadius: AppRadii.sheetCorners),
            child: AppSheetFrame(child: SingleChildScrollView(child: child)),
          ),
        ),
      ),
    );
  }
}
