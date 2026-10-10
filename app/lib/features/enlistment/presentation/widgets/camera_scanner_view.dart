import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/primary_button.dart';
import 'qr_scanner_overlay.dart';

/// Live camera scanner with torch, start/stop, camera switch and a gallery
/// fallback, as in the source scanner sheet. Reports each code once.
class CameraScannerView extends StatefulWidget {
  const CameraScannerView({super.key, required this.onCode});

  final ValueChanged<String> onCode;

  @override
  State<CameraScannerView> createState() => _CameraScannerViewState();
}

class _CameraScannerViewState extends State<CameraScannerView> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _running = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _report(BarcodeCapture? capture) {
    final code = capture?.barcodes.firstOrNull?.rawValue;
    if (code != null) widget.onCode(code);
  }

  Future<void> _startOrStop() async {
    try {
      _running ? await _controller.stop() : await _controller.start();
      setState(() => _running = !_running);
    } on Exception catch (e) {
      if (mounted) AppSnackbar.error(context, 'Something went wrong! $e');
    }
  }

  Future<void> _pickFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final capture = await _controller.analyzeImage(image.path);
    if (!mounted) return;
    if (capture?.barcodes.firstOrNull?.rawValue == null) {
      AppSnackbar.error(context, 'No barcode found!');
      return;
    }
    _report(capture);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        SizedBox(
          height: 400.h,
          child: Stack(
            children: [
              MobileScanner(
                controller: _controller,
                fit: BoxFit.contain,
                onDetect: _report,
                errorBuilder: (context, error) =>
                    ScannerErrorView(error: error),
              ),
              QrScannerOverlay(overlayColor: colors.primary),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(AppSpacing.lg.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ValueListenableBuilder(
                valueListenable: _controller,
                builder: (context, state, _) => IconButton(
                  iconSize: 30.sp,
                  onPressed: _controller.toggleTorch,
                  icon: state.torchState == TorchState.on
                      ? const Icon(Icons.flash_on, color: AppColors.brandIndigo)
                      : Icon(Icons.flash_off, color: context.palette.muted),
                ),
              ),
              IconButton(
                iconSize: 30.sp,
                onPressed: _startOrStop,
                icon: Icon(_running ? Icons.stop : Icons.play_arrow),
              ),
              ValueListenableBuilder(
                valueListenable: _controller,
                builder: (context, state, _) => IconButton(
                  iconSize: 30.sp,
                  onPressed: _controller.switchCamera,
                  icon: Icon(state.cameraDirection == CameraFacing.front
                      ? Icons.camera_front
                      : Icons.camera_rear),
                ),
              ),
            ],
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            Divider(color: colors.tertiary),
            ColoredBox(
              color: colors.surface,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                child: Text('OR', style: context.textStyles.displaySmall),
              ),
            ),
          ],
        ),
        SizedBox(height: 30.h),
        PrimaryButton(
          label: 'SELECT FROM GALLERY',
          icon: Icons.image,
          style: PrimaryButtonStyle.brand,
          onPressed: _pickFromGallery,
        ),
      ],
    );
  }
}

class ScannerErrorView extends StatelessWidget {
  const ScannerErrorView({super.key, required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    final message = switch (error.errorCode) {
      MobileScannerErrorCode.controllerUninitialized => 'Controller not ready.',
      MobileScannerErrorCode.permissionDenied => 'Permission denied',
      _ => 'Generic Error',
    };
    final style =
        context.textStyles.bodySmall?.copyWith(color: AppColors.white);
    return ColoredBox(
      color: AppColors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, color: AppColors.white),
            SizedBox(height: AppSpacing.lg.h),
            Text(message, style: style),
            Text(error.errorDetails?.message ?? '', style: style),
          ],
        ),
      ),
    );
  }
}
