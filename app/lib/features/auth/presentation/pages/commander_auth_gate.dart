import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/dark_section.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../providers/commander_auth_provider.dart';
import 'commander_register_page.dart';
import 'commander_sign_in_page.dart';

/// R19: signed-in commanders see [signedIn]; others sign in or register.
class CommanderAuthGate extends StatelessWidget {
  const CommanderAuthGate({super.key, required this.signedIn});

  final WidgetBuilder signedIn;

  @override
  Widget build(BuildContext context) {
    final watch = context.read<WatchAuthState>();
    return StreamBuilder<AuthUser?>(
      stream: watch(),
      initialData: watch.current,
      builder: (context, snapshot) {
        if (snapshot.data != null) return signedIn(context);
        final mode = context.watch<CommanderAuthProvider>().mode;
        return DarkSection(
          child: PopScope(
            canPop: false,
            child: mode == CommanderAuthMode.signIn
                ? const CommanderSignInPage()
                : const CommanderRegisterPage(),
          ),
        );
      },
    );
  }
}
