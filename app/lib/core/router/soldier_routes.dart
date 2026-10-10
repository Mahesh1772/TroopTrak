import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/domain/usecases/update_soldier_profile.dart';
import '../../features/conducts/presentation/conducts_routes.dart';
import '../../features/enlistment/domain/usecases/men_usecases.dart';
import '../../features/enlistment/presentation/pages/generate_qr_page.dart';
import '../../features/enlistment/presentation/providers/enlistment_qr_provider.dart';
import '../../features/guard_duty/presentation/guard_duty_routes.dart';
import '../../features/nominal_roll/presentation/pages/soldier_form_page.dart';
import '../../features/shell/presentation/pages/soldier_shell.dart';
import '../../features/soldier_profile/presentation/pages/soldier_profile_page.dart';
import '../../features/soldier_profile/presentation/profile_actions.dart';
import '../../features/soldier_profile/presentation/profile_capabilities.dart';
import '../../features/soldier_profile/presentation/providers/soldier_profile_provider.dart';
import '../../features/soldier_profile/presentation/widgets/profile_header_actions.dart';
import '../../features/soldiers/domain/entities/soldier.dart';
import '../constants/ranks.dart';
import '../services/clock.dart';
import '../services/tick_source.dart';
import '../usecase/usecase.dart';
import '../widgets/hero_dialog_route.dart';
import 'app_routes.dart';
import 'route_builder.dart';

/// Soldier shell. Conducts and duties link soldiers by name, so both tabs
/// match on the Auth display name, as the source.
class SoldierHome extends StatelessWidget {
  const SoldierHome({super.key});

  String _name(BuildContext context) =>
      context.read<WatchAuthState>().current?.displayName ?? '';

  @override
  Widget build(BuildContext context) => SoldierShell(
        profile: soldierProfileTab,
        conductTracker: (context) =>
            soldierConductTrackerTab(context, _name(context)),
        guardDuty: (context) => soldierGuardDutyTab(context, _name(context)),
      );
}

/// My Profile: the soldier's own `Men/{uid}` record; statuses and attendance
/// come from the linked `Users/{name}` (rebuild of
/// `P2/screens/detailed_screen/tabs/user_profile_tabs copy/*`).
Widget soldierProfileTab(BuildContext context) {
  final uid = context.read<WatchAuthState>().current?.uid ?? '';
  const capabilities = ProfileCapabilities.soldierSelf;
  return ChangeNotifierProvider(
    create: (context) =>
        SoldierProfileProvider(context.read<WatchOwnRegistration>()(uid)),
    child: SoldierProfilePage(
      capabilities: capabilities,
      inShell: true,
      actions: ProfileActions(
        edit: (context, soldier) => Navigator.of(context)
            .pushNamed(AppRoutes.editOwnProfile, arguments: soldier),
        signOut: () => context.read<SignOut>()(const NoParams()),
        afterSignOut: (navigator) => navigator.pushNamedAndRemoveUntil(
            AppRoutes.roleSelection, (_) => false),
      ),
      headerActions: [
        if (capabilities.showQr)
          Builder(
            builder: (context) => Hero(
              tag: GenerateQrPage.heroTag,
              createRectTween: (begin, end) =>
                  CustomRectTween(begin: begin!, end: end!),
              child: HeaderPillButton(
                key: const Key('showQr'),
                label: 'SHOW QR CODE',
                icon: Icons.qr_code_2_rounded,
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.generateQr),
              ),
            ),
          ),
      ],
    ),
  );
}

final Map<String, RouteWidgetBuilder> soldierRoutes = {
  AppRoutes.editOwnProfile: (context, arguments) => SoldierFormPage(
        mode: SoldierFormMode.edit,
        initial: arguments! as Soldier,
        ranks: Ranks.soldierRegistration,
        save: (soldier) => context.read<UpdateSoldierProfile>()(soldier),
      ),
  AppRoutes.generateQr: (context, _) => ChangeNotifierProvider(
        create: (context) => EnlistmentQrProvider(
          uid: context.read<WatchAuthState>().current?.uid ?? '',
          publish: context.read<PublishEnlistmentQr>(),
          clear: context.read<ClearEnlistmentQr>(),
          clock: context.read<Clock>(),
          ticks: context.read<TickSource>(),
        )..start(),
        child: const GenerateQrPage(),
      ),
};
