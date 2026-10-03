import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';

import '../../../core/error/result.dart';
import '../../soldiers/domain/entities/soldier.dart';

/// Edit and delete differ per viewer (other soldier, own commander account,
/// own soldier account), so the route that opens the page supplies them.
class ProfileActions {
  const ProfileActions({
    required this.edit,
    required this.delete,
    required this.afterDelete,
    this.deleteMessage = 'This removes the soldier with all statuses and '
        'attendance records.',
  });

  final void Function(BuildContext context, Soldier soldier) edit;
  final Result<Unit> Function(Soldier soldier) delete;

  /// Gets the navigator captured before the delete, as the page may already
  /// show the "not found" state once the record is gone.
  final void Function(NavigatorState navigator) afterDelete;
  final String deleteMessage;
}
