import 'package:flutter/foundation.dart';

import '../../../soldiers/domain/entities/soldier.dart';
import '../../domain/usecases/men_usecases.dart';

sealed class ScanOutcome {
  const ScanOutcome();
}

/// The scanned soldier's registration, ready to prefill the add form.
final class ScanFound extends ScanOutcome {
  const ScanFound(this.profile);

  final Soldier profile;
}

final class ScanNotFound extends ScanOutcome {
  const ScanNotFound();
}

final class ScanFailed extends ScanOutcome {
  const ScanFailed(this.message);

  final String message;
}

class QrScanProvider extends ChangeNotifier {
  QrScanProvider(this._find);

  final FindRegistrationByQr _find;
  bool _busy = false;

  bool get busy => _busy;

  /// Null while a previous code is still being looked up.
  Future<ScanOutcome?> lookup(String code) async {
    if (_busy) return null;
    _busy = true;
    notifyListeners();
    final result = await _find(code);
    _busy = false;
    notifyListeners();
    return result.fold(
      (f) => ScanFailed(f.message),
      (found) =>
          found == null ? const ScanNotFound() : ScanFound(found.profile),
    );
  }
}
