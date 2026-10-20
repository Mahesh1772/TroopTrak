import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_context.dart';
import 'state_tone.dart';

const _groupGap = 10.0;
const _groupMinWidth = 86.0;
const _tickMinWidth = 2.0;
const _tickRadius = 2.0;
const _ringWidth = 1.5;
const _ringOffset = 1.0;
const _tooltipGap = 6.0;
const _highlightScale = 1.18;
const _fadedOpacity = 0.35;
const _figureTracking = 0.02;

@immutable
class TallyTick {
  const TallyTick({
    required StateTone this.tone,
    this.title,
    this.detail,
    this.isSelf = false,
  });

  const TallyTick.future({this.title, this.detail})
      : tone = null,
        isSelf = false;

  final StateTone? tone;
  final String? title;
  final String? detail;

  /// Outlined by a ring keyed `tick-<group>-<index>-self`.
  final bool isSelf;

  bool get isFuture => tone == null;
}

@immutable
class TallyGroup {
  const TallyGroup({this.label, this.figure, required this.ticks});

  /// The label row, with [figure] on its right, shows only when this is set.
  final String? label;
  final String? figure;
  final List<TallyTick> ticks;
}

/// One thin vertical tick per soldier, day or participant, coloured by state.
/// Tick `i` of group `g` is keyed `tick-<g>-<i>`.
class TallyStrip extends StatelessWidget {
  const TallyStrip({
    super.key,
    required this.groups,
    this.tickHeight = 36,
    this.onGradient = false,
    this.highlight,
  });

  final List<TallyGroup> groups;
  final double tickHeight;
  final bool onGradient;

  /// Ticks it accepts grow and the others fade; `null` leaves every tick as is.
  final bool Function(int group, TallyTick tick)? highlight;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        assert(constraints.hasBoundedWidth, 'TallyStrip needs a bounded width');
        final widths = _groupWidths(groups, constraints.maxWidth);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: _groupGap.w,
          children: [
            for (var i = 0; i < groups.length; i++)
              _Group(strip: this, index: i, width: widths[i]),
          ],
        );
      },
    );
  }
}

// Widths follow the tick counts like `flex: n`, except that a labelled group
// keeps the mockup's 86 px minimum (`.tg`): 5 officers beside 37 others would
// get under 40 px, too little for "Officers 4/5". A group under its minimum is
// pinned there and the others share what is left, as CSS flexbox resolves it.
// A Row cannot do this, since its flex children are always tight.
List<double> _groupWidths(List<TallyGroup> groups, double maxWidth) {
  final space = math.max(0.0, maxWidth - _groupGap.w * (groups.length - 1));
  final flex = [for (final g in groups) math.max(g.ticks.length, 1)];
  var floors = [
    for (final g in groups) g.label == null ? 0.0 : _groupMinWidth.w,
  ];
  if (floors.fold(0.0, (sum, w) => sum + w) > space) {
    floors = List.filled(groups.length, 0.0);
  }

  final widths = List.of(floors);
  final open = [for (var i = 0; i < groups.length; i++) i];
  var room = space;
  while (open.isNotEmpty) {
    final shares = open.fold(0, (sum, i) => sum + flex[i]);
    final pinned = [
      for (final i in open)
        if (room * flex[i] / shares < floors[i]) i,
    ];
    if (pinned.isEmpty) {
      for (final i in open) {
        widths[i] = room * flex[i] / shares;
      }
      break;
    }
    for (final i in pinned) {
      room -= floors[i];
      open.remove(i);
    }
  }
  return widths;
}

class _Group extends StatelessWidget {
  const _Group({
    required this.strip,
    required this.index,
    required this.width,
  });

  final TallyStrip strip;
  final int index;
  final double width;

  @override
  Widget build(BuildContext context) {
    final group = strip.groups[index];
    final ticks = group.ticks;
    final label = group.label;
    final matches = [
      for (final tick in ticks) strip.highlight?.call(index, tick),
    ];
    // A crowded group closes its gaps before its ticks get thinner than 2 px.
    final gap = ticks.length < 2
        ? 0.0
        : ((width - ticks.length * _tickMinWidth.w) / (ticks.length - 1))
            .clamp(0.0, AppSpacing.xxs.w);

    Widget slots(Widget Function(int i) slot) => Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: gap,
          children: [
            for (var i = 0; i < ticks.length; i++) Expanded(child: slot(i)),
          ],
        );

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.sm.h,
        children: [
          if (label != null)
            _LabelRow(
              label: label,
              figure: group.figure,
              onGradient: strip.onGradient,
            ),
          SizedBox(
            height: strip.tickHeight.h,
            child: Stack(
              clipBehavior: Clip.none,
              fit: StackFit.expand,
              children: [
                slots(
                  (i) => _Tick(
                    tick: ticks[i],
                    id: ValueKey('tick-$index-$i'),
                    matched: matches[i],
                    onGradient: strip.onGradient,
                    height: strip.tickHeight,
                  ),
                ),
                // Its own layer: inside the tick, the next tick would paint over
                // the ring's outer half pixel (a CSS outline paints above).
                if (ticks.any((tick) => tick.isSelf))
                  IgnorePointer(
                    child: slots(
                      (i) => ticks[i].isSelf
                          ? _Emphasis(
                              matched: matches[i],
                              child: _SelfRing(
                                id: ValueKey('tick-$index-$i-self'),
                                onGradient: strip.onGradient,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LabelRow extends StatelessWidget {
  const _LabelRow({
    required this.label,
    required this.figure,
    required this.onGradient,
  });

  final String label;
  final String? figure;
  final bool onGradient;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final figureStyle = AppTextStyles.figure(
      15,
      FontWeight.w600,
      onGradient ? AppColors.white : palette.onCard,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      spacing: AppSpacing.sm.w,
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption(
              onGradient ? AppColors.onGradientLabel : palette.secondaryText,
            ),
          ),
        ),
        if (figure != null)
          Text(
            figure!,
            maxLines: 1,
            style: figureStyle.copyWith(
              letterSpacing: figureStyle.fontSize! * _figureTracking,
            ),
          ),
      ],
    );
  }
}

class _Tick extends StatelessWidget {
  const _Tick({
    required this.tick,
    required this.id,
    required this.matched,
    required this.onGradient,
    required this.height,
  });

  final TallyTick tick;
  final Key id;
  final bool? matched;
  final bool onGradient;
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final body = _Emphasis(
      boxKey: id,
      matched: matched,
      decoration: BoxDecoration(
        color: _fill(tick.tone, palette, onGradient),
        border: tick.isFuture && !onGradient
            ? Border.all(color: palette.line, width: 1.r)
            : null,
        borderRadius: BorderRadius.circular(_tickRadius.r),
      ),
    );

    final title = tick.title;
    if (title == null) return body;
    final detail = tick.detail;
    return Tooltip(
      richMessage: TextSpan(
        text: title,
        children: [
          if (detail != null)
            TextSpan(
              text: ' · $detail',
              style: const TextStyle(color: AppColors.tooltipDetail),
            ),
        ],
      ),
      triggerMode: TooltipTriggerMode.longPress,
      preferBelow: false,
      verticalOffset: height.h / 2 + _tooltipGap.h,
      ignorePointer: true,
      child: body,
    );
  }
}

// The mockup's CSS only scales the matches; the plan also fades the rest.
class _Emphasis extends StatelessWidget {
  const _Emphasis({
    this.boxKey,
    required this.matched,
    this.decoration,
    this.child,
  });

  final Key? boxKey;
  final bool? matched;
  final Decoration? decoration;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: matched == false ? _fadedOpacity : 1,
      duration: AppMotion.standard,
      curve: AppMotion.ease,
      child: AnimatedContainer(
        key: boxKey,
        duration: AppMotion.standard,
        curve: AppMotion.ease,
        transform: Matrix4.diagonal3Values(
          1,
          matched == true ? _highlightScale : 1,
          1,
        ),
        transformAlignment: Alignment.center,
        decoration: decoration,
        child: child,
      ),
    );
  }
}

// Reaches past its slot, so it never changes a tick's size or its neighbours.
class _SelfRing extends StatelessWidget {
  const _SelfRing({required this.id, required this.onGradient});

  final Key id;
  final bool onGradient;

  @override
  Widget build(BuildContext context) {
    final reach = (_ringOffset + _ringWidth).r;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: -reach,
          top: -reach,
          right: -reach,
          bottom: -reach,
          child: DecoratedBox(
            key: id,
            decoration: BoxDecoration(
              border: Border.all(
                color: onGradient ? AppColors.white : context.palette.onCard,
                width: _ringWidth.r,
              ),
              borderRadius: BorderRadius.circular(_tickRadius.r + reach),
            ),
          ),
        ),
      ],
    );
  }
}

Color _fill(StateTone? tone, AppPalette palette, bool onGradient) {
  if (tone == null) {
    return onGradient ? AppColors.onGradientTickFuture : palette.tickFuture;
  }
  if (!onGradient) return tone.fill(palette);
  return switch (tone) {
    StateTone.inCamp => AppColors.onGradientInCamp,
    StateTone.excuse => AppColors.onGradientExcuse,
    StateTone.leave => AppColors.onGradientLeave,
    StateTone.medical => AppColors.onGradientMedical,
    StateTone.out => AppColors.onGradientTickOff,
    StateTone.accent => AppColors.white,
  };
}
