import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final lib = Directory('lib');
  final dartFiles = lib
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();

  test('core remains independent from framework and outer modules', () {
    final violations = <String>[];
    final forbiddenPackages = RegExp(
      r"package:(flutter|flutter_riverpod|go_router|drift|supabase)",
    );

    for (final file in dartFiles.where(_isInside('lib/core'))) {
      for (final import in _imports(file)) {
        if (forbiddenPackages.hasMatch(import) ||
            _resolvesInside(file, import, const [
              'lib/app',
              'lib/shared',
              'lib/features',
            ])) {
          violations.add('${file.path} imports $import');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Core must stay usable without Flutter or outer app modules.',
    );
  });

  test('shared code does not depend on product features', () {
    final violations = <String>[];
    for (final file in dartFiles.where(_isInside('lib/shared'))) {
      for (final import in _imports(file)) {
        if (_resolvesInside(file, import, const ['lib/features']) ||
            import.startsWith('package:pollar_app/features/')) {
          violations.add('${file.path} imports $import');
        }
      }
    }
    expect(violations, isEmpty);
  });

  test('features do not import one another directly', () {
    final violations = <String>[];
    for (final file in dartFiles.where(_isInside('lib/features'))) {
      final sourceFeature = _featureName(_normalized(file.absolute.path));
      for (final import in _imports(file)) {
        final target = _resolvedPath(file, import);
        if (target == null) continue;
        final targetFeature = _featureName(target);
        if (targetFeature != null && targetFeature != sourceFeature) {
          violations.add(
            '${file.path} ($sourceFeature) imports $import ($targetFeature)',
          );
        }
      }
    }
    expect(
      violations,
      isEmpty,
      reason:
          'Coordinate features through app composition or shared contracts.',
    );
  });
}

bool Function(File) _isInside(String directory) {
  final marker = '/${_normalized(directory)}/';
  return (file) => _normalized(file.absolute.path).contains(marker);
}

Iterable<String> _imports(File file) sync* {
  final pattern = RegExp(r'''^import\s+['"]([^'"]+)['"]''', multiLine: true);
  for (final match in pattern.allMatches(file.readAsStringSync())) {
    yield match.group(1)!;
  }
}

bool _resolvesInside(File source, String import, List<String> directories) {
  final resolved = _resolvedPath(source, import);
  if (resolved == null) return false;
  return directories.any(
    (directory) => resolved.contains('/${_normalized(directory)}/'),
  );
}

String? _resolvedPath(File source, String import) {
  if (import.startsWith('package:pollar_app/')) {
    return '/lib/${import.substring('package:pollar_app/'.length)}';
  }
  if (!import.startsWith('.')) return null;
  return _normalized(source.parent.uri.resolve(import).toFilePath());
}

String? _featureName(String path) {
  final match = RegExp(r'/lib/features/([^/]+)/').firstMatch(path);
  return match?.group(1);
}

String _normalized(String path) => path.replaceAll('\\', '/');
