import 'package:provider/provider.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/router/route_builder.dart';
import '../domain/usecases/men_usecases.dart';
import 'pages/qr_scanner_page.dart';
import 'providers/qr_scan_provider.dart';

final Map<String, RouteWidgetBuilder> enlistmentRoutes = {
  AppRoutes.qrScanner: (context, _) => ChangeNotifierProvider(
        create: (context) =>
            QrScanProvider(context.read<FindRegistrationByQr>()),
        child: const QrScannerPage(),
      ),
};
