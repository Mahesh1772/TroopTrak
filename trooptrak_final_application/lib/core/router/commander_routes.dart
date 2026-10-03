import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/domain/usecases/delete_commander_account.dart';
import '../../features/conducts/presentation/conducts_routes.dart';
import '../../features/guard_duty/presentation/guard_duty_routes.dart';
import '../../features/nominal_roll/presentation/nominal_roll_routes.dart';
import '../../features/shell/presentation/pages/commander_shell.dart';
import '../../features/soldier_profile/presentation/pages/soldier_profile_page.dart';
import '../../features/soldier_profile/presentation/profile_actions.dart';
import '../../features/soldier_profile/presentation/profile_capabilities.dart';
import '../../features/soldier_profile/presentation/providers/soldier_profile_provider.dart';
import '../../features/soldiers/domain/usecases/soldier_usecases.dart';
import '../usecase/usecase.dart';
import '../widgets/feedback_views.dart';
import 'app_routes.dart';

/// Commander shell; tabs not rebuilt yet show placeholders.
class CommanderHome extends StatelessWidget {
  const CommanderHome({super.key});

  @override
  Widget build(BuildContext context) {
    final me = context.read<WatchAuthState>().current?.displayName;
    return CommanderShell(
      home: (_) => const EmptyState(message: 'Dashboard', image: null),
      nominalRoll: (context) => nominalRollTab(context, currentUserId: me),
      conductTracker: conductTrackerTab,
      guardDuty: guardDutyTab,
    );
  }
}

/// `/commander/me`: the signed-in commander's own `Users/{displayName}`
/// (rebuild of `CMD/.../user_profile_tabs/user_profile_screen.dart`).
Widget commanderProfile(BuildContext context, Object? _) {
  final id = context.read<WatchAuthState>().current?.displayName ?? '';
  return ChangeNotifierProvider(
    create: (context) =>
        SoldierProfileProvider(context.read<WatchSoldier>()(id)),
    child: SoldierProfilePage(
      capabilities: ProfileCapabilities.commanderSelf,
      actions: ProfileActions(
        edit: (context, soldier) => Navigator.of(context)
            .pushNamed(AppRoutes.editSoldier, arguments: soldier),
        delete: (soldier) => context.read<DeleteCommanderAccount>()(soldier.id),
        deleteMessage: 'This deletes your account with all your statuses '
            'and attendance records.',
        afterDelete: (navigator) => navigator.pushNamedAndRemoveUntil(
            AppRoutes.commanderGate, (_) => false),
        signOut: () => context.read<SignOut>()(const NoParams()),
        afterSignOut: (navigator) => navigator.pushNamedAndRemoveUntil(
            AppRoutes.roleSelection, (_) => false),
      ),
    ),
  );
}
