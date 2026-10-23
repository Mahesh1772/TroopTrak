import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/state/view_state.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/rank_plate.dart';
import '../../../../core/widgets/state_chip.dart';
import '../../../../core/widgets/state_tone.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../../core/widgets/tally_strip.dart';
import '../../../statuses/domain/services/parade_roster.dart';
import '../../../statuses/domain/services/parade_state.dart';
import '../../domain/entities/strength_summary.dart';

const _legend = [
  (ParadeState.inCamp, 'In camp'),
  (ParadeState.excuse, 'Excuse'),
  (ParadeState.leave, 'Leave'),
  (ParadeState.medical, 'MA'),
  (ParadeState.out, 'Out'),
];

const _rowTitles = {
  ParadeReportKind.officers: 'Total Officers',
  ParadeReportKind.woses: 'Total WOSEs',
  ParadeReportKind.onStatus: 'On Status',
  ParadeReportKind.onMa: 'On MA',
};

const _rowIcons = {
  ParadeReportKind.officers: Icons.military_tech_rounded,
  ParadeReportKind.woses: Icons.badge_rounded,
  ParadeReportKind.onStatus: Icons.warning_amber_rounded,
  ParadeReportKind.onMa: Icons.medical_services_rounded,
};

const _dotSize = 8.0;
const _rowIconSize = 20.0;
const _chevronSize = 24.0;

/// The strength card: how many are in camp, the parade-state tally strip, a
/// legend and the expandable report rows. The open row highlights its ticks.
class ParadeCard extends StatefulWidget {
  const ParadeCard({
    super.key,
    required this.state,
    required this.stamp,
    required this.onOpenSoldier,
  });

  final ViewState<StrengthSummary> state;
  final String stamp;
  final ValueChanged<String> onOpenSoldier;

  @override
  State<ParadeCard> createState() => _ParadeCardState();
}

class _ParadeCardState extends State<ParadeCard> {
  ParadeReportKind? _open;

  void _toggle(ParadeReportKind kind) =>
      setState(() => _open = _open == kind ? null : kind);

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(AppRadii.xl.r),
        boxShadow: AppShadows.raised(dark: context.isDark),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg.w,
          18.h,
          AppSpacing.lg.w,
          AppSpacing.xs.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              spacing: AppSpacing.sm.w,
              children: [
                Text('Strength In-Camp',
                    style: AppTextStyles.h2(palette.onCard)),
                Expanded(
                  child: Text(
                    'As of ${widget.stamp}',
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.figure(
                        14, FontWeight.w500, palette.secondaryText),
                  ),
                ),
              ],
            ),
            StateView<StrengthSummary>(
              state: widget.state,
              builder: (context, summary) => _Body(
                summary: summary,
                open: _open,
                onToggle: _toggle,
                onOpenSoldier: widget.onOpenSoldier,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.summary,
    required this.open,
    required this.onToggle,
    required this.onOpenSoldier,
  });

  final StrengthSummary summary;
  final ParadeReportKind? open;
  final ValueChanged<ParadeReportKind> onToggle;
  final ValueChanged<String> onOpenSoldier;

  List<TallyTick> _ticks(List<ParadeEntry> entries) => [
        for (final e in entries)
          TallyTick(
            tone: e.state.tone,
            title: '${e.soldier.rank} ${e.soldier.name}',
            detail: e.state.label,
          ),
      ];

  bool _highlight(int group, TallyTick tick) {
    final row = summary.row(open!);
    final states = row.highlightedStates(ParadeGroup.values[group]);
    return states.any((state) => state.tone == tick.tone);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final officers = summary.row(ParadeReportKind.officers);
    final woses = summary.row(ParadeReportKind.woses);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(top: AppSpacing.inline.h, bottom: 16.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            spacing: AppSpacing.sm.w,
            children: [
              Text(
                '${summary.inCampCount}',
                key: const Key('inCampCount'),
                style: AppTextStyles.figure(44, FontWeight.w700, palette.onCard)
                    .copyWith(height: 1),
              ),
              Expanded(
                child: Text(
                  'of ${summary.total} soldiers in camp',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.barlow(
                      16, FontWeight.w400, palette.secondaryText),
                ),
              ),
            ],
          ),
        ),
        TallyStrip(
          tickHeight: AppLayout.tallyTall,
          highlight: open == null ? null : _highlight,
          groups: [
            TallyGroup(
              label: 'Officers',
              figure: '${officers.current}/${officers.total}',
              ticks: _ticks(summary.officersByState),
            ),
            TallyGroup(
              label: 'WOSEs',
              figure: '${woses.current}/${woses.total}',
              ticks: _ticks(summary.wosesByState),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: 14.h),
          child: Wrap(
            spacing: 14.w,
            runSpacing: AppSpacing.inline.h,
            children: [
              for (final (state, label) in _legend)
                _LegendItem(
                  key: Key('legend-${state.name}'),
                  tone: state.tone,
                  label: label,
                  count: summary.count(state),
                ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 18.h),
          child: _Report(
            rows: summary.rows,
            open: open,
            onToggle: onToggle,
            onOpenSoldier: onOpenSoldier,
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    super.key,
    required this.tone,
    required this.label,
    required this.count,
  });

  final StateTone tone;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.inline.w,
      children: [
        SizedBox.square(
          dimension: _dotSize.r,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: tone.fill(palette),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Text(label,
            style: AppTextStyles.barlow(
                13, FontWeight.w400, palette.secondaryText)),
        Text('$count',
            style: AppTextStyles.figure(14, FontWeight.w600, palette.onCard)),
      ],
    );
  }
}

class _Report extends StatelessWidget {
  const _Report({
    required this.rows,
    required this.open,
    required this.onToggle,
    required this.onOpenSoldier,
  });

  final List<ParadeReportRow> rows;
  final ParadeReportKind? open;
  final ValueChanged<ParadeReportKind> onToggle;
  final ValueChanged<String> onOpenSoldier;

  @override
  Widget build(BuildContext context) {
    final line = context.palette.line;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(height: 1, thickness: 1, color: line),
        for (final (i, row) in rows.indexed) ...[
          _ReportRow(
            row: row,
            expanded: open == row.kind,
            onToggle: () => onToggle(row.kind),
            onOpenSoldier: onOpenSoldier,
          ),
          if (i < rows.length - 1)
            Divider(height: 1, thickness: 1, color: line),
        ],
      ],
    );
  }
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({
    required this.row,
    required this.expanded,
    required this.onToggle,
    required this.onOpenSoldier,
  });

  final ParadeReportRow row;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<String> onOpenSoldier;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final total = row.total;
    final title = _rowTitles[row.kind]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          key: Key('tile-$title'),
          onTap: onToggle,
          hoverColor: palette.hover,
          child: ConstrainedBox(
            constraints:
                BoxConstraints(minHeight: AppLayout.reportRowMinHeight.h),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xs.h),
              child: Row(
                spacing: AppSpacing.tight.w,
                children: [
                  Icon(_rowIcons[row.kind],
                      size: _rowIconSize.r, color: palette.onCard),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.barlow(
                          15.5, FontWeight.w400, palette.onCard),
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      text: '${row.current}',
                      children: [
                        if (total != null)
                          TextSpan(
                            text: ' / $total',
                            style: AppTextStyles.figure(
                                15, FontWeight.w500, palette.secondaryText),
                          ),
                      ],
                    ),
                    style: AppTextStyles.figure(
                        22, FontWeight.w600, palette.onCard),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: AppMotion.standard,
                    curve: AppMotion.ease,
                    child: Icon(Icons.expand_more_rounded,
                        size: _chevronSize.r, color: palette.secondaryText),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: AppMotion.standard,
          curve: AppMotion.ease,
          alignment: Alignment.topCenter,
          child: expanded
              ? _Roster(row: row, onOpenSoldier: onOpenSoldier)
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _Roster extends StatelessWidget {
  const _Roster({required this.row, required this.onOpenSoldier});

  final ParadeReportRow row;
  final ValueChanged<String> onOpenSoldier;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: EdgeInsets.only(top: AppSpacing.xs.h, bottom: AppSpacing.md.h),
      child: row.entries.isEmpty
          ? Text('No personnel',
              style: AppTextStyles.caption(palette.secondaryText))
          : Column(
              children: [
                for (final entry in row.entries)
                  InkWell(
                    key: Key('soldier-${entry.soldier.id}'),
                    onTap: () => onOpenSoldier(entry.soldier.id),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 7.h),
                      child: Row(
                        spacing: AppSpacing.tight.w,
                        children: [
                          RankPlate(entry.soldier.rank, size: RankPlate.sm),
                          Expanded(
                            child: Text(
                              entry.soldier.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.barlow(
                                  15, FontWeight.w500, palette.onCard),
                            ),
                          ),
                          StateChip(
                            row.labelOf(entry),
                            tone: row.statusOf(entry)?.tone ?? entry.state.tone,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
