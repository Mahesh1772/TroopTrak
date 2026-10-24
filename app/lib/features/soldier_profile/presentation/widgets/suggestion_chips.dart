import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../statuses/domain/services/status_suggestions.dart';

/// Quick picks for the status name, narrowed by what is typed in [controller].
/// Takes no room for a type without suggestions.
class SuggestionChips extends StatelessWidget {
  const SuggestionChips({
    super.key,
    required this.controller,
    required this.type,
  });

  final TextEditingController controller;
  final String? type;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final names = suggestStatusNames(type, controller.text);
        if (names.isEmpty) return const SizedBox.shrink();
        final typed = controller.text.trim();
        return Padding(
          padding: EdgeInsets.only(top: AppSpacing.md.h),
          child: Wrap(
            spacing: AppSpacing.sm.w,
            runSpacing: AppSpacing.sm.h,
            children: [
              for (final name in names)
                ChoiceChip(
                  key: Key('suggestion-$name'),
                  label: Text(name),
                  selected: name == typed,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onSelected: (_) => controller.text = name,
                ),
            ],
          ),
        );
      },
    );
  }
}
