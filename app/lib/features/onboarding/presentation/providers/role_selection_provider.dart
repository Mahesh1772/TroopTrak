import 'package:flutter/foundation.dart';

import '../../../../core/router/app_routes.dart';
import '../../domain/entities/app_role.dart';
import '../../domain/usecases/role_usecases.dart';

String routeForRole(AppRole? role) => switch (role) {
      null => AppRoutes.roleSelection,
      AppRole.soldier => AppRoutes.soldierGate,
      AppRole.commander => AppRoutes.commanderGate,
    };

class RoleSelectionProvider extends ChangeNotifier {
  RoleSelectionProvider(this._setRole);

  final SetRole _setRole;

  AppRole? _selected;
  bool _saving = false;
  String? _error;

  AppRole? get selected => _selected;
  bool get saving => _saving;
  String? get error => _error;

  /// Tapping the selected card again clears it, as in the source.
  void toggle(AppRole role) {
    _selected = _selected == role ? null : role;
    notifyListeners();
  }

  /// Stores the role and returns the route to open, or null if nothing changed.
  Future<String?> confirm() async {
    final role = _selected;
    if (role == null || _saving) return null;
    _saving = true;
    _error = null;
    notifyListeners();
    final result = await _setRole(role);
    _saving = false;
    final route = result.fold((failure) {
      _error = failure.message;
      return null;
    }, (_) => routeForRole(role));
    notifyListeners();
    return route;
  }
}
