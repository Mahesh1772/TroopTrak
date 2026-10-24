import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/hero_sheet.dart';
import '../providers/enlistment_qr_provider.dart';
import '../widgets/qr_code_tile.dart';
import '../widgets/qr_countdown_card.dart';

/// Rebuild of `P2/screens/detailed_screen/qr_screen.dart` (R15), shown as a
/// bottom sheet in a [HeroDialogRoute]; pops itself when the code expires.
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
    final palette = context.palette;
    return HeroSheet(
      tag: GenerateQrPage.heroTag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'ADD A NEW SOLDIER',
                  style: AppTextStyles.compactTitle(palette.onCard),
                ),
              ),
              IconButton(
                key: const Key('closeQr'),
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                color: palette.onCard,
                style: IconButton.styleFrom(
                  fixedSize: Size.square(AppLayout.sheetCloseButton.r),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg.h),
          QrCodeTile(code: qr.code, error: qr.error),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.sm.w,
              AppSpacing.lg.h,
              AppSpacing.sm.w,
              AppLayout.qrHelpBottom.h,
            ),
            child: Text(
              'Have a commander scan the above QR code to add your '
              'details on their end.',
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle(palette.secondaryText),
            ),
          ),
          QrCountdownCard(countdown: qr.countdown, fraction: qr.fraction),
        ],
      ),
    );
  }
}
