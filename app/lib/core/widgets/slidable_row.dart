import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../theme/app_colors.dart';
import '../theme/app_layout.dart';
import '../theme/theme_context.dart';

/// Slide a row left to reveal edit and delete. A null callback leaves its
/// action out; with neither, the row is returned as it is. The row sits on a
/// card-coloured backing so the actions do not show through it.
class SlidableRow extends StatelessWidget {
  const SlidableRow({
    super.key,
    required this.child,
    this.onEdit,
    this.onDelete,
    this.editKey,
    this.deleteKey,
  });

  final Widget child;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Key? editKey;
  final Key? deleteKey;

  @override
  Widget build(BuildContext context) {
    final onEdit = this.onEdit;
    final onDelete = this.onDelete;
    final count = (onEdit == null ? 0 : 1) + (onDelete == null ? 0 : 1);
    if (count == 0) return child;
    final palette = context.palette;
    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: AppLayout.slideActionExtent * count,
        children: [
          if (onEdit != null)
            SlidableAction(
              key: editKey,
              onPressed: (_) => onEdit(),
              icon: Icons.edit_rounded,
              backgroundColor: palette.statusMedical,
              foregroundColor: AppColors.white,
            ),
          if (onDelete != null)
            SlidableAction(
              key: deleteKey,
              onPressed: (_) => onDelete(),
              icon: Icons.delete_rounded,
              backgroundColor: palette.danger,
              foregroundColor: AppColors.white,
            ),
        ],
      ),
      child: ColoredBox(color: palette.card, child: child),
    );
  }
}
