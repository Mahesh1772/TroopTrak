import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/qr_scan_provider.dart';
import '../widgets/camera_scanner_view.dart';

typedef ScannerViewBuilder = Widget Function(
    BuildContext context, ValueChanged<String> onCode);

Widget _cameraScanner(BuildContext context, ValueChanged<String> onCode) =>
    CameraScannerView(onCode: onCode);

/// Rebuild of `CMD/screens/nominal_roll_screen/qr_code_scanner_page.dart`
/// (R15). [scanner] is swapped for a fake in tests, where no camera exists.
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
          builder: (_) => const _ScanResultDialog(found: true),
        );
        if ((open ?? false) && context.mounted) {
          await Navigator.of(context)
              .pushNamed(AppRoutes.addSoldier, arguments: profile);
        }
      case ScanNotFound():
        await showDialog<void>(
          context: context,
          builder: (_) => const _ScanResultDialog(found: false),
        );
      case ScanFailed(:final message):
        AppSnackbar.error(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    final hint = context.colors.tertiary.withValues(alpha: 0.7);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md.sp),
          child: Column(
            children: [
              Text('Scan QR Code',
                  textAlign: TextAlign.center, style: text.displayMedium),
              SizedBox(height: AppSpacing.xl.h),
              Text(
                "Please scan the QR code on the soldier's profile by placing "
                'it within the frame to add their details.',
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(color: hint),
              ),
              SizedBox(height: AppSpacing.xl.h),
              scanner(context, (code) => _onCode(context, code)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanResultDialog extends StatelessWidget {
  const _ScanResultDialog({required this.found});

  final bool found;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.black54,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(found ? Icons.check_circle : Icons.remove_circle_rounded,
                color: found ? AppColors.success : AppColors.danger,
                size: 40.sp),
            SizedBox(height: AppSpacing.xl.h),
            Text(
              found
                  ? 'QR Code Successfully Scanned!'
                  : 'Invalid QR / No such key found!',
              textAlign: TextAlign.center,
              style: context.textStyles.headlineLarge
                  ?.copyWith(color: AppColors.white),
            ),
            if (found) ...[
              SizedBox(height: AppSpacing.md.h),
              PrimaryButton(
                key: const Key('goToEditPage'),
                label: 'GO TO EDIT PAGE',
                icon: Icons.edit_document,
                style: PrimaryButtonStyle.brand,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
