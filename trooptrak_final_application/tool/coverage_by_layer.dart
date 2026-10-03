// Line coverage per clean-architecture layer from coverage/lcov.info.
// Run `flutter test --coverage`, then `dart run tool/coverage_by_layer.dart`.
// Pass `--files` to list every file under its target, lowest first.
import 'dart:io';

const targets = {'domain': 95.0, 'data': 85.0, 'presentation': 70.0};

String layerOf(String path) {
  final match = RegExp(r'lib/features/[a-z_]+/(domain|data|presentation)/')
      .firstMatch(path);
  if (match != null) return match.group(1)!;
  if (path.startsWith('lib/core/data/')) return 'data';
  return 'core';
}

void main(List<String> args) {
  final lcov = File('coverage/lcov.info');
  if (!lcov.existsSync()) {
    stderr.writeln('Run `flutter test --coverage` first.');
    exit(2);
  }
  final files = <String, (int, int)>{};
  String? current;
  var found = 0, hit = 0;
  for (final line in lcov.readAsLinesSync()) {
    if (line.startsWith('SF:')) {
      current = line.substring(3).replaceAll(r'\', '/');
      current = current.substring(current.indexOf('lib/'));
      found = hit = 0;
    } else if (line.startsWith('LF:')) {
      found = int.parse(line.substring(3));
    } else if (line.startsWith('LH:')) {
      hit = int.parse(line.substring(3));
    } else if (line == 'end_of_record' && current != null) {
      files[current] = (found, hit);
    }
  }

  final layers = <String, (int, int)>{};
  for (final MapEntry(key: path, value: (f, h)) in files.entries) {
    final (lf, lh) = layers[layerOf(path)] ?? (0, 0);
    layers[layerOf(path)] = (lf + f, lh + h);
  }

  var failed = false;
  for (final layer in ['domain', 'data', 'presentation', 'core']) {
    final (f, h) = layers[layer] ?? (0, 0);
    final pct = f == 0 ? 100.0 : h * 100 / f;
    final target = targets[layer];
    final ok = target == null || pct >= target;
    failed |= !ok;
    stdout.writeln('${layer.padRight(13)} ${pct.toStringAsFixed(1).padLeft(5)}%'
        '  ($h/$f lines)'
        '${target == null ? '' : '  target $target% ${ok ? 'OK' : 'BELOW'}'}');
  }

  if (args.contains('--files')) {
    final rows = [
      for (final MapEntry(key: path, value: (f, h)) in files.entries)
        if (f > 0 && h < f) (path, h * 100 / f, f - h),
    ]..sort((a, b) => a.$2.compareTo(b.$2));
    for (final (path, pct, missed) in rows) {
      stdout.writeln('${pct.toStringAsFixed(0).padLeft(4)}%  '
          '${missed.toString().padLeft(3)} missed  $path');
    }
  }
  exit(failed ? 1 : 0);
}
