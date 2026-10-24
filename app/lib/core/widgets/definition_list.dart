import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_layout.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_context.dart';
import 'app_card.dart';

const _labelSize = 15.0;
const _valueSize = 18.0;

/// A card of label and value rows, the value right-aligned, with a hairline
/// between rows inset to the card's padding.
class DefinitionList extends StatelessWidget {
  const DefinitionList({super.key, required this.entries});

  final List<(String label, String value)> entries;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AppCard(
      padding: EdgeInsets.symmetric(
        horizontal: AppLayout.definitionInset.w,
        vertical: AppSpacing.xs.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: palette.line),
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: AppLayout.definitionRowMinHeight.h,
              ),
              child: Row(
                spacing: AppSpacing.md.w,
                children: [
                  Text(
                    entries[i].$1,
                    style: AppTextStyles.barlow(
                      _labelSize,
                      FontWeight.w400,
                      palette.secondaryText,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entries[i].$2,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: AppTextStyles.figure(
                        _valueSize,
                        FontWeight.w600,
                        palette.onCard,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
