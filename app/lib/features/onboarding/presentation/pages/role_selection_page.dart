import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/sticky_cta_page.dart';
import '../../domain/entities/app_role.dart';
import '../providers/role_selection_provider.dart';
import '../widgets/role_card.dart';

typedef _Option = ({
  AppRole role,
  String key,
  String rank,
  String title,
  String subtitle,
});

const List<_Option> _options = [
  (
    role: AppRole.soldier,
    key: 'role-soldier',
    rank: 'CFC',
    title: 'Men',
    subtitle: 'CFC and below',
  ),
  (
    role: AppRole.commander,
    key: 'role-commander',
    rank: '3SG',
    title: 'Commanders',
    subtitle: '3SG or higher',
  ),
];

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  Future<void> _confirm(BuildContext context) async {
    final provider = context.read<RoleSelectionProvider>();
    final route = await provider.confirm();
    if (!context.mounted) return;
    if (route != null) {
      await Navigator.of(context).pushReplacementNamed(route);
    } else if (provider.error != null) {
      AppSnackbar.error(context, provider.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoleSelectionProvider>();
    return StickyCtaPage(
      top: AppLayout.onboardingGap,
      cta: PrimaryButton(
        key: const Key('role-confirm'),
        label: 'CONTINUE',
        icon: Icons.arrow_forward_rounded,
        iconAtEnd: true,
        onPressed: provider.saving ? null : () => _confirm(context),
      ),
      children: [
        Transform.translate(
          offset: Offset(-AppLayout.onboardingLogoShift.w, 0),
          child: const BrandLogo(width: AppLayout.onboardingLogo),
        ),
        SizedBox(height: AppLayout.onboardingGap.h),
        Text(
          'Please pick your role.',
          style: AppTextStyles.screenTitle(context.colors.onSurface),
        ),
        SizedBox(height: AppSpacing.tight.h),
        Text(
          'If you are rank 3SG or higher, select commanders. '
          'If your rank is CFC or lower, select men.',
          style: AppTextStyles.screenSubtitle(context.palette.secondaryText),
        ),
        SizedBox(height: AppLayout.onboardingGap.h),
        for (final option in _options) ...[
          RoleCard(
            key: Key(option.key),
            rank: option.rank,
            title: option.title,
            subtitle: option.subtitle,
            selected: provider.selected == option.role,
            onTap: () => provider.toggle(option.role),
          ),
          if (option != _options.last) SizedBox(height: AppSpacing.md.h),
        ],
      ],
    );
  }
}
