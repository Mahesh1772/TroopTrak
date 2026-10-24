import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_snackbar.dart';
import 'qr_scanner_overlay.dart';
import 'scanner_footer.dart';

/// Full-bleed live camera with the reticle, torch, camera switch and start /
/// stop at the top right, and a gallery fallback under the frame. Reports each
/// code once.
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
    final accent = context.palette.accentText;
    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: _report,
          errorBuilder: (context, error) => ScannerErrorView(error: error),
        ),
        const QrScannerOverlay(),
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) => Padding(
              padding: EdgeInsets.only(
                top: QrScannerOverlay.reticleIn(constraints.biggest).bottom +
                    AppLayout.scanFooterGap.h,
              ),
              child: SingleChildScrollView(
                child: ScannerFooter(onGallery: _pickFromGallery),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: AppSpacing.sm.w,
          child: SafeArea(
            child: SizedBox(
              height: AppLayout.appBarHeight.h,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ValueListenableBuilder(
                    valueListenable: _controller,
                    builder: (context, state, _) => _ScanControl(
                      tooltip: 'Torch',
                      onPressed: _controller.toggleTorch,
                      icon: state.torchState == TorchState.on
                          ? Icons.flashlight_on_rounded
                          : Icons.flashlight_off_rounded,
                      color: state.torchState == TorchState.on
                          ? accent
                          : AppColors.white,
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: _controller,
                    builder: (context, state, _) => _ScanControl(
                      onPressed: _controller.switchCamera,
                      icon: state.cameraDirection == CameraFacing.front
                          ? Icons.camera_front_rounded
                          : Icons.camera_rear_rounded,
                    ),
                  ),
                  _ScanControl(
                    onPressed: _startOrStop,
                    icon: _running
                        ? Icons.stop_rounded
                        : Icons.play_arrow_rounded,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanControl extends StatelessWidget {
  const _ScanControl({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color = AppColors.white,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color color;

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        iconSize: AppLayout.scanControlIcon.r,
        constraints: BoxConstraints.tight(Size.square(AppLayout.scanControl.r)),
        icon: Icon(icon, color: color),
      );
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
    final style = AppTextStyles.caption(AppColors.white);
    return ColoredBox(
      color: AppColors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.sm.h,
          children: [
            const Icon(Icons.error_rounded, color: AppColors.white),
            Text(message, style: style),
            Text(error.errorDetails?.message ?? '', style: style),
          ],
        ),
      ),
    );
  }
}
