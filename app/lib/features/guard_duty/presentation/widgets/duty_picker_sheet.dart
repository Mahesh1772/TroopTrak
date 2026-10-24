import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../../../core/widgets/feedback_views.dart';
import '../../../../core/widgets/inline_error.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/soldier_row.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../domain/entities/duty.dart';
import '../../domain/usecases/duty_usecases.dart';
import '../providers/duty_form_provider.dart';

const _countSize = 15.0;

/// Opens the soldier picker over the duty form, with a fresh search.
Future<void> showDutyPicker(BuildContext context) {
  final provider = context.read<DutyFormProvider>()..search('');
  return showAppSheet<void>(
    context: context,
    builder: (_) => ChangeNotifierProvider.value(
      value: provider,
      child: const _DutyPickerSheet(),
    ),
  );
}

/// Search the roster and toggle soldiers into the duty. Ineligible ones (R6)
/// are dimmed and say why; tapping one, or a full duty, shows the reason here
/// because a snackbar would sit behind the sheet.
class _DutyPickerSheet extends StatefulWidget {
  const _DutyPickerSheet();

  @override
  State<_DutyPickerSheet> createState() => _DutyPickerSheetState();
}

class _DutyPickerSheetState extends State<_DutyPickerSheet> {
  String? _error;

  void _toggle(DutyFormProvider provider, Soldier soldier) =>
      setState(() => _error = provider.toggle(soldier));

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DutyFormProvider>();
    final palette = context.palette;
    final error = _error;
    return SizedBox(
      height: AppLayout.dutyPickerHeight.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.md.h,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  'ADD A NEW SOLDIER',
                  style: AppTextStyles.compactTitle(palette.onCard),
                ),
              ),
              Text(
                '${provider.participants.length} of ${Duty.maxSlots} selected',
                style: AppTextStyles.figure(
                  _countSize,
                  FontWeight.w500,
                  palette.secondaryText,
                ),
              ),
            ],
          ),
          AppSearchField(
            key: const Key('pickerSearch'),
            hintText: 'Search Name',
            fill: context.colors.surface,
            onChanged: provider.search,
          ),
          if (error != null) InlineError(error),
          Expanded(
            child: StateView<DutyRoster>(
              state: provider.roster,
              builder: (context, _) {
                final soldiers = provider.searchResults;
                if (soldiers.isEmpty) {
                  return const EmptyState(
                    message: 'No results Found!',
                    icon: Icons.person_search_rounded,
                  );
                }
                return SingleChildScrollView(
                  child: AppListCard(
                    color: context.colors.surface,
                    children: [
                      for (final s in soldiers)
                        SoldierRow(
                          key: Key('pick-${s.name}'),
                          soldier: s,
                          note: _noteFor(provider, s),
                          dimmed: !provider.canServe(s),
                          trailing: _Mark(
                            picked: provider.isOnDuty(s),
                            eligible: provider.canServe(s),
                          ),
                          onTap: () => _toggle(provider, s),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          PrimaryButton(
            key: const Key('pickerDone'),
            label: 'DONE',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  String _noteFor(DutyFormProvider provider, Soldier soldier) {
    if (provider.canServe(soldier)) return soldier.appointment;
    final reason = provider.reasonFor(soldier);
    return reason == null ? 'Ineligible' : 'Ineligible · $reason';
  }
}

class _Mark extends StatelessWidget {
  const _Mark({required this.picked, required this.eligible});

  final bool picked;
  final bool eligible;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    if (picked) {
      return Icon(Icons.check_circle_rounded, color: palette.success);
    }
    if (!eligible) return const SizedBox.shrink();
    return Icon(
      Icons.radio_button_unchecked_rounded,
      color: palette.secondaryText,
    );
  }
}
