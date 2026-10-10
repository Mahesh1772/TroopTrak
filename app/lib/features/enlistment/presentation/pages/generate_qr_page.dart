import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/feedback_views.dart';
import '../../../../core/widgets/hero_dialog_route.dart';
import '../providers/enlistment_qr_provider.dart';

/// Rebuild of `P2/screens/detailed_screen/qr_screen.dart` (R15), shown in a
/// [HeroDialogRoute]; pops itself when the code expires.
class GenerateQrPage extends StatefulWidget {
  const GenerateQrPage({super.key});

  static const heroTag = 'QRCodeScreen';

  @override
  State<GenerateQrPage> createState() => _GenerateQrPageState();
}

class _GenerateQrPageState extends State<GenerateQrPage> {
  late final EnlistmentQrProvider _qr = context.read<EnlistmentQrProvider>();

  @override
  void initState() {
    super.initState();
    _qr.addListener(_popOnExpiry);
  }

  void _popOnExpiry() {
    if (_qr.expired && mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _qr.removeListener(_popOnExpiry);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qr = context.watch<EnlistmentQrProvider>();
    final text = context.textStyles;
    final palette = context.palette;
    final qrSize = 300.sp;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg.sp),
        child: Hero(
          tag: GenerateQrPage.heroTag,
          createRectTween: (begin, end) =>
              CustomRectTween(begin: begin!, end: end!),
          child: Material(
            color: palette.card,
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.md.r)),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  vertical: AppSpacing.xxxl.h, horizontal: AppSpacing.lg.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      key: const Key('closeQr'),
                      onPressed: () => Navigator.of(context).pop(),
                      icon:
                          Icon(Icons.close, color: palette.onCard, size: 30.sp),
                    ),
                  ),
                  Text('ADD A NEW SOLDIER',
                      style: text.displayMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  Divider(color: palette.onCard, thickness: 0.2.h),
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.lg.sp),
                    child: SizedBox.square(
                      dimension: qrSize,
                      child: switch ((qr.code, qr.error)) {
                        (final String code, _) => QrImageView(
                            key: const Key('qrImage'),
                            data: code,
                            size: qrSize,
                            backgroundColor: AppColors.white,
                          ),
                        (_, final String error) => ErrorView(message: error),
                        _ => const LoadingView(),
                      },
                    ),
                  ),
                  Text(
                    'Have a commander scan the above QR code to add your '
                    'details on their end.',
                    textAlign: TextAlign.center,
                    style: text.titleLarge,
                  ),
                  SizedBox(height: AppSpacing.xxl.h),
                  Text('QR will vanish in:',
                      style: text.displaySmall
                          ?.copyWith(fontWeight: FontWeight.w500)),
                  SizedBox(height: AppSpacing.md.h),
                  Text(
                    qr.countdown,
                    key: const Key('qrCountdown'),
                    style: text.displayLarge
                        ?.copyWith(fontSize: 35.sp, color: palette.accent),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
