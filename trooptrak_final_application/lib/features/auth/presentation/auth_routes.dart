import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/router/route_builder.dart';
import '../domain/usecases/auth_usecases.dart';
import '../domain/usecases/register_commander.dart';
import '../domain/usecases/soldier_entry.dart';
import 'pages/commander_auth_gate.dart';
import 'pages/forgot_password_page.dart';
import 'pages/phone_entry_page.dart';
import 'pages/soldier_welcome_page.dart';
import 'providers/commander_auth_provider.dart';
import 'providers/phone_auth_provider.dart';

CommanderAuthProvider _commanderAuth(BuildContext context) =>
    CommanderAuthProvider(
      signIn: context.read<SignInWithEmail>(),
      register: context.read<RegisterCommander>(),
      sendReset: context.read<SendPasswordReset>(),
    );

PhoneAuthProvider _phoneAuth(BuildContext context) => PhoneAuthProvider(
      verifyPhone: context.read<VerifyPhone>(),
      verifyOtp: context.read<VerifyOtp>(),
      completeSignIn: context.read<CompleteSoldierSignIn>(),
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
      AppRoutes.soldierGate: (_, __) => const SoldierWelcomePage(),
      AppRoutes.phoneEntry: (context, _) => ChangeNotifierProvider(
            create: _phoneAuth,
            child: const PhoneEntryPage(),
          ),
    };
