import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/dark_section.dart';
import '../../../../core/widgets/header_buttons.dart';
import '../providers/qr_scan_provider.dart';
import '../widgets/camera_scanner_view.dart';
import '../widgets/scan_result_dialog.dart';

typedef ScannerViewBuilder = Widget Function(
    BuildContext context, ValueChanged<String> onCode);

Widget _cameraScanner(BuildContext context, ValueChanged<String> onCode) =>
    CameraScannerView(onCode: onCode);

/// Rebuild of `CMD/screens/nominal_roll_screen/qr_code_scanner_page.dart`
/// (R15), always dark like the camera behind it. [scanner] fills the page and
/// is swapped for a fake in tests, where no camera exists.
class QrScannerPage extends StatelessWidget {
  const QrScannerPage({super.key, this.scanner = _cameraScanner});

  final ScannerViewBuilder scanner;

  Future<void> _onCode(BuildContext context, String code) async {
    final outcome = await context.read<QrScanProvider>().lookup(code);
    if (outcome == null || !context.mounted) return;
    switch (outcome) {
      case ScanFound(:final profile):
        final open = await showDialog<bool>(
          context: context,
          builder: (_) => ScanResultDialog(profile: profile),
        );
        if ((open ?? false) && context.mounted) {
          await Navigator.of(context)
              .pushNamed(AppRoutes.addSoldier, arguments: profile);
        }
      case ScanNotFound():
        await showDialog<void>(
          context: context,
          builder: (_) => const ScanResultDialog(),
        );
      case ScanFailed(:final message):
        AppSnackbar.error(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DarkSection(
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.black,
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: Stack(
              children: [
                Positioned.fill(
                  child: scanner(context, (code) => _onCode(context, code)),
                ),
                SafeArea(
                  child: Align(
                    alignment: AlignmentDirectional.topStart,
                    child: SizedBox(
                      height: AppLayout.appBarHeight.h,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HeaderIconButton(
                            icon: Icons.arrow_back_rounded,
                            tooltip: 'Back',
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                          Text(
                            'Scan QR Code',
                            style: AppTextStyles.compactTitle(AppColors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
