import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/router/route_builder.dart';
import '../domain/entities/duty.dart';
import '../domain/usecases/duty_usecases.dart';
import 'pages/duty_form_page.dart';
import 'providers/duty_form_provider.dart';

Widget _form(BuildContext context, Duty? initial) => ChangeNotifierProvider(
      create: (context) => DutyFormProvider(
        roster: context.read<GetDutyRoster>(),
        add: context.read<AddDuty>(),
        update: context.read<UpdateDuty>(),
        initial: initial,
      ),
      child: const DutyFormPage(),
    );

/// Edit takes the duty being changed.
final Map<String, RouteWidgetBuilder> dutyRoutes = {
  AppRoutes.addDuty: (context, _) => _form(context, null),
  AppRoutes.editDuty: (context, arguments) =>
      _form(context, arguments! as Duty),
};
