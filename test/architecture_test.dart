import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// lib/ 아래 Dart 파일의 import 문으로 계층 규칙을 검사한다.
/// 규칙은 docs/ARCHITECTURE.md와 같아야 한다.
void main() {
  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.endsWith('.g.dart'))
      .where((f) => !f.path.endsWith('.freezed.dart'))
      .toList();

  final importPattern = RegExp(
    r'''^(?:import|export)\s+['"]([^'"]+)['"]''',
    multiLine: true,
  );
  final featurePattern = RegExp('lib/features/([^/]+)/');

  List<String> importsOf(File file) => importPattern
      .allMatches(file.readAsStringSync())
      .map((m) => m.group(1)!)
      .toList();

  test('상대 import를 쓰지 않는다', () {
    for (final file in files) {
      for (final import in importsOf(file)) {
        expect(
          import.startsWith('package:') || import.startsWith('dart:'),
          isTrue,
          reason: '${file.path}: 상대 import "$import"는 금지. package: 경로를 쓴다',
        );
      }
    }
  });

  test('domain은 허용된 대상만 import한다', () {
    // 금지 목록이 아니라 허용 목록이다. core/network나 <feature>_di.dart를 거쳐
    // dio·riverpod이 간접적으로 들어오는 경로까지 막는다.
    const allowedPrefixes = [
      'dart:',
      'package:freezed_annotation/',
      'package:meta/',
      'package:collection/',
      'package:liaison_app/core/error/',
      'package:liaison_app/shared/models/',
    ];
    for (final file in files.where((f) => f.path.contains('/domain/'))) {
      final owner = featurePattern.firstMatch(file.path)?.group(1);
      final ownDomain = owner == null
          ? null
          : 'package:liaison_app/features/$owner/domain/';
      for (final import in importsOf(file)) {
        final allowed =
            allowedPrefixes.any(import.startsWith) ||
            (ownDomain != null && import.startsWith(ownDomain));
        expect(
          allowed,
          isTrue,
          reason:
              '${file.path}: domain에서 "$import" import 금지. '
              '허용: dart:, freezed_annotation, meta, collection, '
              'core/error, shared/models, 같은 feature의 domain',
        );
      }
    }
  });

  test('core와 shared는 features, app을 import하지 않는다', () {
    final targets = files.where(
      (f) => f.path.contains('lib/core/') || f.path.contains('lib/shared/'),
    );
    for (final file in targets) {
      for (final import in importsOf(file)) {
        expect(
          import.contains('liaison_app/features/') ||
              import.contains('liaison_app/app/'),
          isFalse,
          reason:
              '${file.path}: core/shared에서 "$import" import 금지. '
              'core와 shared는 기능과 무관해야 한다',
        );
      }
    }
  });

  test('presentation은 data를 import하지 않는다', () {
    for (final file in files.where((f) => f.path.contains('/presentation/'))) {
      for (final import in importsOf(file)) {
        expect(
          import.contains('/data/'),
          isFalse,
          reason:
              '${file.path}: presentation에서 data import 금지. '
              '<feature>_di.dart를 통해 Repository Provider를 쓴다',
        );
      }
    }
  });

  test('data는 presentation을 import하지 않는다', () {
    for (final file in files.where((f) => f.path.contains('/data/'))) {
      for (final import in importsOf(file)) {
        expect(
          import.contains('/presentation/'),
          isFalse,
          reason: '${file.path}: data에서 presentation import 금지',
        );
      }
    }
  });

  test('feature의 data는 같은 feature의 data 또는 <feature>_di.dart만 import한다', () {
    final dataImportPattern = RegExp('features/([^/]+)/data/');
    for (final file in files) {
      for (final import in importsOf(file)) {
        final target = dataImportPattern.firstMatch(import)?.group(1);
        if (target == null) continue;
        final allowed =
            file.path.contains('lib/features/$target/data/') ||
            file.path.endsWith('lib/features/$target/${target}_di.dart');
        expect(
          allowed,
          isTrue,
          reason:
              '${file.path}: "$import" import 금지. features/$target/data는 '
              '같은 feature의 data 또는 features/$target/${target}_di.dart '
              '에서만 import한다. ${target}_di.dart를 통해 접근하라',
        );
      }
    }
  });

  test('feature끼리 import하지 않는다', () {
    for (final file in files) {
      final owner = featurePattern.firstMatch(file.path)?.group(1);
      if (owner == null) continue;
      for (final import in importsOf(file)) {
        final target = RegExp('features/([^/]+)/').firstMatch(import)?.group(1);
        if (target == null) continue;
        expect(
          target,
          owner,
          reason:
              '${file.path}: 다른 feature "$target" import 금지. 공유가 필요하면 shared/로 올린다',
        );
      }
    }
  });

  test('features와 shared에서 Platform 분기를 쓰지 않는다', () {
    final platformPattern = RegExp(
      r'\bPlatform\.(is[A-Z]\w*|operatingSystem)|\bdefaultTargetPlatform\b',
    );
    final targets = files.where(
      (f) => f.path.contains('lib/features/') || f.path.contains('lib/shared/'),
    );
    for (final file in targets) {
      expect(
        platformPattern.hasMatch(file.readAsStringSync()),
        isFalse,
        reason: '${file.path}: 플랫폼 분기는 core/ 인터페이스 뒤에 숨긴다',
      );
    }
  });
}
