import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/feedback_views.dart';
import '../../../../core/widgets/inline_error.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/state_tone.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../../core/widgets/tally_strip.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../providers/conduct_form_provider.dart';
import 'conduct_person_row.dart';
import 'participation_tally.dart';

/// The "Add Participants" half of the conduct form: the live "Added x / y"
/// strip, the name search and one ADD / REMOVE row per soldier.
class ConductParticipantsSection extends StatelessWidget {
  const ConductParticipantsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConductFormProvider>();
    final error = provider.rosterError;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.md.h,
      children: [
        SectionHeader(
          'Add Participants',
          caption: provider.isUpdate ? null : 'Auto-filled from statuses',
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xs.w,
            AppSpacing.lg.h,
            AppSpacing.xs.w,
            0,
          ),
        ),
        if (error != null) InlineError(error),
        if (provider.soldiers.dataOrNull != null)
          _AddedStrip(provider: provider),
        AppSearchField(
          key: const Key('participantSearch'),
          hintText: 'Search Name',
          onChanged: provider.search,
        ),
        StateView<List<Soldier>>(
          state: provider.soldiers,
          builder: (context, _) => _ParticipantList(provider: provider),
        ),
      ],
    );
  }
}

class _AddedStrip extends StatelessWidget {
  const _AddedStrip({required this.provider});

  final ConductFormProvider provider;

  @override
  Widget build(BuildContext context) {
    final ticks = provider.ticks;
    return AppCard(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.control.w,
        AppSpacing.control.h,
        AppSpacing.control.w,
        AppSpacing.lg.h,
      ),
      child: TallyStrip(
        tickHeight: AppLayout.conductFormTick,
        groups: [
          TallyGroup(
            label: 'Added',
            figure: '${ticks.participating} / ${ticks.total}',
            ticks: participationTallyTicks(ticks),
          ),
        ],
      ),
    );
  }
}

class _ParticipantList extends StatelessWidget {
  const _ParticipantList({required this.provider});

  final ConductFormProvider provider;

  @override
  Widget build(BuildContext context) {
    final soldiers = provider.visibleSoldiers;
    if (soldiers.isEmpty && provider.query.isNotEmpty) {
      return const EmptyState(
        message: 'No results Found!',
        icon: Icons.person_search_rounded,
      );
    }
    return AppListCard(
      children: [
        for (final s in soldiers)
          ConductPersonRow(
            key: Key('participant-${s.name}'),
            soldier: s,
            note: provider.noteFor(s),
            trailing: _ToggleButton(
              key: Key('toggle-${s.name}'),
              participating: provider.isParticipating(s.name),
              onPressed: () => provider.toggle(s.name),
            ),
          ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    super.key,
    required this.participating,
    required this.onPressed,
  });

  final bool participating;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => PrimaryButton(
        label: participating ? 'REMOVE' : 'ADD',
        style: PrimaryButtonStyle.tonal,
        compact: true,
        tone: participating ? StateTone.leave : StateTone.inCamp,
        onPressed: onPressed,
      );
}
