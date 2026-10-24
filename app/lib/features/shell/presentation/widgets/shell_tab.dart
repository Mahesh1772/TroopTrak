import 'package:flutter/widgets.dart';

class ShellTab {
  const ShellTab({
    required this.key,
    required this.label,
    required this.title,
    required this.icon,
    required this.builder,
    this.selectedIcon,
  });

  final String key;
  final String label;
  final String title;
  final IconData icon;

  /// Shown on the active tab; falls back to [icon].
  final IconData? selectedIcon;
  final WidgetBuilder builder;
}
