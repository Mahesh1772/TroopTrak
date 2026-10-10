import 'package:flutter/material.dart';

import '../theme/dark_theme.dart';

/// Forces the dark theme for screens the source always drew dark (auth flows).
class DarkSection extends StatelessWidget {
  const DarkSection({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Theme(data: buildDarkTheme(), child: child);
}
