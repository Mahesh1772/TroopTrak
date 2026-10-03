import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_context.dart';
import '../../domain/validators/password_rules.dart';

class PasswordChecklist extends StatelessWidget {
  const PasswordChecklist({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final rule in PasswordRule.values)
            Row(
              children: [
                Icon(
                  rule.passes(value.text) ? Icons.check_circle : Icons.cancel,
                  size: 18,
                  color: rule.passes(value.text)
                      ? AppColors.success
                      : AppColors.danger,
                ),
                const SizedBox(width: 8),
                Text(rule.label, style: context.textStyles.bodySmall),
              ],
            ),
        ],
      ),
    );
  }
}
