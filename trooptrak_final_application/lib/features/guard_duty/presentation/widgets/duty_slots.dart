import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/person_tile.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/rank_avatar.dart';
import '../../../../core/widgets/state_view.dart';
import '../../domain/usecases/duty_usecases.dart';
import '../providers/duty_form_provider.dart';

/// Rebuild of the source org chart (`org_chart_tile.dart`): ten slots in rows
/// of 2, 4 and 4. Any slot opens the soldier picker.
class DutySlots extends StatelessWidget {
  const DutySlots({super.key});

  Future<void> _openPicker(BuildContext context) => showDialog<void>(
        context: context,
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<DutyFormProvider>(),
          child: const _SoldierPicker(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final filled =
        context.watch<DutyFormProvider>().participants.entries.toList();
    Widget slot(int i) => _Slot(
          index: i,
          name: i < filled.length ? filled[i].key : null,
          rank: i < filled.length ? filled[i].value : null,
          onTap: () => _openPicker(context),
        );
    Widget row(int from, int count) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [for (var i = from; i < from + count; i++) slot(i)],
        );
    return Column(
      children: [
        row(0, 2),
        SizedBox(height: 40.h),
        row(2, 4),
        SizedBox(height: 40.h),
        row(6, 4),
      ],
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({
    required this.index,
    required this.name,
    required this.rank,
    required this.onTap,
  });

  final int index;
  final String? name;
  final String? rank;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.md.r);
    return InkWell(
      key: Key('slot-$index'),
      onTap: onTap,
      borderRadius: radius,
      child: Container(
        width: 100.w,
        height: 100.h,
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
              colors: [AppColors.personTile, context.colors.surface]),
        ),
        child: name == null
            ? Icon(Icons.add, size: 50.sp)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.black,
                    child: RankAvatar.insignia(rank!,
                        size: 20.w, color: AppColors.white),
                  ),
                  SizedBox(height: AppSpacing.xs.h),
                  SizedBox(
                    width: 90.w,
                    child: AutoSizeText(name!,
                        maxLines: 2,
                        maxFontSize: 12,
                        textAlign: TextAlign.center,
                        style: context.textStyles.labelMedium),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Rebuild of `add_duty_soldiers_card.dart`: search, toggle eligible soldiers;
/// ineligible ones (R6) are greyed out.
class _SoldierPicker extends StatelessWidget {
  const _SoldierPicker();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DutyFormProvider>();
    final text = context.textStyles;
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ADD A NEW SOLDIER', style: text.displayMedium),
            SizedBox(height: AppSpacing.md.h),
            AppSearchField(
              key: const Key('pickerSearch'),
              hintText: 'Search Name',
              onChanged: provider.search,
            ),
            SizedBox(height: AppSpacing.md.h),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 500.h),
              child: StateView<DutyRoster>(
                state: provider.roster,
                builder: (context, _) {
                  final soldiers = provider.searchResults;
                  if (soldiers.isEmpty) {
                    return Center(
                      child: Text('No results Found!',
                          style: text.displaySmall
                              ?.copyWith(color: AppColors.authLink)),
                    );
                  }
                  return ListView(
                    shrinkWrap: true,
                    children: [
                      for (final s in soldiers)
                        PersonTile(
                          key: Key('pick-${s.name}'),
                          name: s.name,
                          rank: s.rank,
                          muted: !provider.canServe(s) && !provider.isOnDuty(s),
                          subtitle: provider.canServe(s) ? null : 'Ineligible',
                          trailing: provider.isOnDuty(s)
                              ? Icon(Icons.check_circle,
                                  color: context.palette.success)
                              : null,
                          onTap: () {
                            final error = provider.toggle(s);
                            if (error != null) {
                              AppSnackbar.error(context, error);
                            }
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: AppSpacing.md.h),
            PrimaryButton(
              key: const Key('pickerDone'),
              label: 'DONE',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
