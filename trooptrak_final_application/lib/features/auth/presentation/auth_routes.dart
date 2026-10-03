import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/router/route_builder.dart';
import '../domain/usecases/auth_usecases.dart';
import '../domain/usecases/register_commander.dart';
import 'pages/commander_auth_gate.dart';
import 'pages/forgot_password_page.dart';
import 'providers/commander_auth_provider.dart';

CommanderAuthProvider _commanderAuth(BuildContext context) =>
    CommanderAuthProvider(
      signIn: context.read<SignInWithEmail>(),
      register: context.read<RegisterCommander>(),
      sendReset: context.read<SendPasswordReset>(),
    );

Map<String, RouteWidgetBuilder> authRoutes({
  required WidgetBuilder commanderHome,
}) =>
    {
      AppRoutes.commanderGate: (context, _) => ChangeNotifierProvider(
            create: _commanderAuth,
            child: CommanderAuthGate(signedIn: commanderHome),
          ),
      AppRoutes.forgotPassword: (context, _) => ChangeNotifierProvider(
            create: _commanderAuth,
            child: const ForgotPasswordPage(),
          ),
    };
