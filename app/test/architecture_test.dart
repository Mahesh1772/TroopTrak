import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Plan 6.2: the layering and "build it once" rules, checked on every run.
void main() {
  const package = 'package:trooptrak_final_application/';
  const sharedDomains = {'soldiers', 'statuses', 'attendance', 'enlistment'};
  final importPattern =
      RegExp(r'''^(?:import|export)\s+'([^']+)'.*;''', multiLine: true);

  final sources = {
    for (final entity in Directory('lib').listSync(recursive: true))
      if (entity is File && entity.path.endsWith('.dart'))
        entity.path.replaceAll(r'\', '/'): entity.readAsStringSync(),
  };

  /// Imports of [file], resolved to `lib/...` paths or left as `package:`.
  Iterable<String> importsOf(String file) sync* {
    for (final match in importPattern.allMatches(sources[file]!)) {
      final uri = match.group(1)!;
      if (uri.startsWith(package)) {
        yield 'lib/${uri.substring(package.length)}';
      } else if (uri.startsWith('package:') || uri.startsWith('dart:')) {
        yield uri;
      } else {
        yield Uri(path: file).resolve(uri).path;
      }
    }
  }

  String? featureOf(String path) =>
      RegExp(r'^lib/features/([a-z_]+)/').firstMatch(path)?.group(1);

  String? layerOf(String path) =>
      RegExp(r'^lib/features/[a-z_]+/(domain|data|presentation)/')
          .firstMatch(path)
          ?.group(1);

  List<String> violations(bool Function(String file, String import) bad) => [
        for (final file in sources.keys)
          for (final import in importsOf(file))
            if (bad(file, import)) '$file -> $import',
      ];

  List<String> filesContaining(Pattern pattern,
          {Set<String> except = const {}}) =>
      [
        for (final MapEntry(key: file, value: code) in sources.entries)
          if (!except.contains(file) && code.contains(pattern)) file,
      ];

  test('lib has sources and relative imports resolve across features', () {
    expect(sources.length, greaterThan(100));
    expect(
        violations((file, import) =>
            featureOf(file) == 'conducts' &&
            featureOf(import) == 'soldiers' &&
            layerOf(import) == 'domain'),
        isNotEmpty);
  });

  test('no feature imports another feature\'s data or presentation', () {
    expect(violations((file, import) {
      final from = featureOf(file);
      final to = featureOf(import);
      return from != null &&
          to != null &&
          from != to &&
          (layerOf(import) == 'data' || layerOf(import) == 'presentation');
    }), isEmpty);
  });

  test('only the shared domains cross feature lines', () {
    expect(violations((file, import) {
      final from = featureOf(file);
      final to = featureOf(import);
      return from != null &&
          to != null &&
          from != to &&
          layerOf(import) == 'domain' &&
          !sharedDomains.contains(to);
    }), isEmpty);
  });

  test('domain is pure Dart and points nowhere outward', () {
    expect(
        violations((file, import) =>
            layerOf(file) == 'domain' &&
            (import.startsWith('package:flutter') ||
                import.startsWith('package:firebase') ||
                import.startsWith('package:cloud_firestore') ||
                import.startsWith('lib/core/data/') ||
                import.startsWith('lib/core/di/') ||
                import.startsWith('lib/core/router/') ||
                import.startsWith('lib/core/widgets/') ||
                import.startsWith('lib/core/theme/') ||
                layerOf(import) == 'data' ||
                layerOf(import) == 'presentation')),
        isEmpty);
  });

  test('Firebase is imported only by data layers and the composition root', () {
    expect(
        violations((file, import) =>
            (import.startsWith('package:cloud_firestore') ||
                import.startsWith('package:firebase_auth') ||
                import.startsWith('package:firebase_core')) &&
            !file.contains('/data/') &&
            !file.startsWith('lib/core/di/') &&
            file != 'lib/firebase_options.dart'),
        isEmpty);
    expect(
        filesContaining(RegExp(r'FirebaseFirestore|FirebaseAuth'))
            .where((f) => layerOf(f) == 'presentation'),
        isEmpty);
  });

  test('hardcoded colours live only in core/theme', () {
    expect(
        filesContaining(RegExp(r'Color\.fromARGB|Color\.fromRGBO|Color\(0x'))
            .where((f) => !f.startsWith('lib/core/theme/')),
        isEmpty);
  });

  test('DateTime.now() only behind the Clock', () {
    expect(
        filesContaining('DateTime.now()',
            except: {'lib/core/services/clock.dart'}),
        isEmpty);
  });

  test('date patterns are formatted only in core/utils/date_formats.dart', () {
    expect(
        filesContaining('DateFormat',
            except: {'lib/core/utils/date_formats.dart'}),
        isEmpty);
  });

  test('search fields and rank assets are built once in core', () {
    expect(
        filesContaining('Icons.search')
            .where((f) => !f.startsWith('lib/core/widgets/')),
        isEmpty);
    expect(
        filesContaining('army-ranks')
            .where((f) => f != 'lib/core/constants/rank_assets.dart'),
        isEmpty);
  });
}
