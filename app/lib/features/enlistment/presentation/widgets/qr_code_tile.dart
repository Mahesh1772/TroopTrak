import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/widgets/feedback_views.dart';
import '../../../../core/widgets/inline_error.dart';

/// The white tile holding the QR for [code]; a spinner while there is no
/// [code] yet, or the [error] in its place. The code is keyed `qrImage`.
class QrCodeTile extends StatelessWidget {
  const QrCodeTile({super.key, this.code, this.error});

  final String? code;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final code = this.code;
    final error = this.error;
    final side = AppLayout.qrTile.w;
    final inner = side - 2 * AppLayout.qrTilePadding.w;
    return Center(
      child: SizedBox.square(
        dimension: side,
        child: switch ((code, error)) {
          (final String code, _) => DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadii.xl.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppLayout.qrTilePadding.w),
                child: QrImageView(
                  key: const Key('qrImage'),
                  data: code,
                  size: inner,
                  backgroundColor: AppColors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColors.qrInk,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppColors.qrInk,
                  ),
                ),
              ),
            ),
          (_, final String error) => Center(child: InlineError(error)),
          _ => const LoadingView(),
        },
      ),
    );
  }
}
