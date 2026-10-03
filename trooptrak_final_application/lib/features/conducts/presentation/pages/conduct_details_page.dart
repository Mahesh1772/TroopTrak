import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/rank_avatar.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../domain/entities/conduct.dart';
import '../../domain/usecases/watch_conduct_breakdown.dart';
import '../providers/conduct_details_provider.dart';

/// Rebuild of `CMD/.../conduct_details_screen.dart`. Edit and delete only
/// when [canManage]; the source deleted without asking.
class ConductDetailsPage extends StatelessWidget {
  const ConductDetailsPage({super.key, this.canManage = true});

  final bool canManage;

  Future<void> _delete(BuildContext context, Conduct conduct) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete ${conduct.name}?',
      message: 'This removes the conduct and its participant list.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    final navigator = Navigator.of(context);
    final error = await context.read<ConductDetailsProvider>().delete();
    if (error == null) {
      navigator.pop();
    } else if (context.mounted) {
      AppSnackbar.error(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConductDetailsProvider>();
    return Scaffold(
      body: StateView<ConductBreakdown>(
        state: provider.state,
        builder: (context, all) {
          final visible = provider.visible!;
          return ListView(
            padding: EdgeInsets.only(bottom: AppSpacing.xl.h),
            children: [
              _Header(
                conduct: all.conduct,
                onEdit: canManage
                    ? () => Navigator.of(context).pushNamed(
                        AppRoutes.editConduct,
                        arguments: all.conduct)
                    : null,
                onDelete:
                    canManage ? () => _delete(context, all.conduct) : null,
              ),
              Padding(
                padding: EdgeInsets.all(AppSpacing.xl.sp),
                child: AppSearchField(
                  key: const Key('detailsSearch'),
                  hintText: 'Search Name',
                  onChanged: provider.search,
                ),
              ),
              if (visible.isEmpty && provider.query.isNotEmpty)
                Center(
                  child: Text('Nothing to see here...yet.',
                      textAlign: TextAlign.center,
                      style: context.textStyles.displaySmall?.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.normal)),
                )
              else ...[
                const SectionHeader('Participants'),
                for (final s in visible.participants) _PersonRow(soldier: s),
                SizedBox(height: AppSpacing.xl.h),
                const SectionHeader('Non-Participants'),
                for (final s in visible.nonParticipants)
                  _PersonRow(soldier: s, reason: all.conduct.reasonFor(s.name)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.conduct, this.onEdit, this.onDelete});

  final Conduct conduct;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    TextStyle? white(TextStyle? s, double size) => s?.copyWith(
        color: AppColors.white, fontSize: size.sp, letterSpacing: 1.5);
    final icon = Icon(Icons.edit, color: AppColors.white, size: 25.sp);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg.r),
        gradient: LinearGradient(colors: context.palette.headerGradient),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm.w, vertical: AppSpacing.xl.h),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(Icons.arrow_back_sharp,
                        color: AppColors.white, size: 25.sp),
                  ),
                  const Spacer(),
                  if (onEdit != null)
                    IconButton(
                        key: const Key('editConduct'),
                        onPressed: onEdit,
                        icon: icon),
                  if (onDelete != null)
                    IconButton(
                      key: const Key('deleteConduct'),
                      onPressed: onDelete,
                      icon: Icon(Icons.delete_forever,
                          color: AppColors.white, size: 25.sp),
                    ),
                ],
              ),
              SizedBox(height: AppSpacing.xl.h),
              Text(conduct.type.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: white(text.displayMedium, 24)
                      ?.copyWith(fontWeight: FontWeight.w500)),
              SizedBox(height: AppSpacing.xs.h),
              Text(conduct.name,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  style: white(text.displayLarge, 35)),
              SizedBox(height: AppSpacing.xl.h),
              Text(formatDay(conduct.day).toUpperCase(),
                  style: white(text.headlineLarge, 18)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({required this.soldier, this.reason});

  final Soldier soldier;
  final String? reason;

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    final tertiary = context.colors.tertiary;
    return Padding(
      key: Key('person-${soldier.name}'),
      padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xl.w, vertical: AppSpacing.sm.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.lg.sp),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: tertiary),
            ),
            child: RankAvatar.insignia(soldier.rank, size: 20, color: tertiary),
          ),
          SizedBox(width: AppSpacing.lg.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(soldier.name.titleCase,
                    style: text.headlineLarge
                        ?.copyWith(fontWeight: FontWeight.w600)),
                if (reason != null) Text(reason!, style: text.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
