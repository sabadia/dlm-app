import 'dart:io';

import 'package:dlm_tools/import_rules.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const rulesYaml = '''
packages:
  dlm_api: []
  dlm_ui_kit: []
  dlm_core: [dlm_api]
  dlm_skin_macos: [dlm_ui_kit]
  dlm_app: [dlm_core, dlm_ui_kit, dlm_skin_macos]
skin_registry:
  - apps/dlm_app/lib/src/skin_registry.dart
''';

void main() {
  late Directory root;
  final rules = ImportRules.parse(rulesYaml);

  setUp(() => root = Directory.systemTemp.createTempSync('dlm_rules'));
  tearDown(() => root.deleteSync(recursive: true));

  void pkg(
    String group,
    String name, {
    List<String> deps = const [],
    Map<String, String> files = const {},
  }) {
    final dir = Directory(p.join(root.path, group, name))
      ..createSync(recursive: true);
    File(p.join(dir.path, 'pubspec.yaml')).writeAsStringSync(
      'name: $name\n'
      '${deps.isEmpty ? '' : 'dependencies:\n${deps.map((d) => '  $d: any\n').join()}'}',
    );
    files.forEach((path, text) {
      File(p.join(dir.path, path))
        ..createSync(recursive: true)
        ..writeAsStringSync(text);
    });
  }

  test('a conforming workspace passes', () {
    pkg('packages', 'dlm_api');
    pkg(
      'packages',
      'dlm_core',
      deps: ['dlm_api'],
      files: {'lib/a.dart': "import 'package:dlm_api/dlm_api.dart';\n"},
    );
    pkg(
      'apps',
      'dlm_app',
      deps: ['dlm_core'],
      files: {'lib/main.dart': "import 'package:dlm_core/dlm_core.dart';\n"},
    );
    expect(checkWorkspace(root.path, rules), isEmpty);
  });

  test('a forbidden pubspec dependency is reported', () {
    pkg('packages', 'dlm_api');
    pkg('packages', 'dlm_ui_kit', deps: ['dlm_api']);
    final v = checkWorkspace(root.path, rules);
    expect(v, hasLength(1));
    expect(v.single.message, contains('dlm_ui_kit must not depend on dlm_api'));
    expect(v.single.where, 'packages/dlm_ui_kit/pubspec.yaml');
  });

  test('a forbidden import is reported with its file', () {
    pkg('packages', 'dlm_api');
    pkg(
      'packages',
      'dlm_core',
      deps: ['dlm_api'],
      files: {'lib/x.dart': "import 'package:dlm_ui_kit/dlm_ui_kit.dart';\n"},
    );
    pkg('packages', 'dlm_ui_kit');
    final v = checkWorkspace(root.path, rules);
    expect(v.map((e) => e.where), ['packages/dlm_core/lib/x.dart']);
    expect(v.single.message, contains('must not import dlm_ui_kit'));
  });

  test('exports count as imports; tests are checked too', () {
    pkg('packages', 'dlm_api');
    pkg(
      'packages',
      'dlm_core',
      deps: ['dlm_api'],
      files: {
        'lib/x.dart': "export 'package:dlm_app/main.dart';\n",
        'test/x_test.dart': "import 'package:dlm_skin_macos/a.dart';\n",
      },
    );
    expect(checkWorkspace(root.path, rules), hasLength(3));
  });

  test('a skin may be imported only by the registry', () {
    pkg('packages', 'dlm_ui_kit');
    pkg('packages', 'dlm_skin_macos', deps: ['dlm_ui_kit']);
    pkg(
      'apps',
      'dlm_app',
      deps: ['dlm_skin_macos'],
      files: {
        'lib/src/skin_registry.dart':
            "import 'package:dlm_skin_macos/m.dart';\n",
        'lib/src/feature.dart': "import 'package:dlm_skin_macos/m.dart';\n",
      },
    );
    final v = checkWorkspace(root.path, rules);
    expect(v, hasLength(1));
    expect(v.single.where, 'apps/dlm_app/lib/src/feature.dart');
    expect(v.single.message, contains('outside the skin registry'));
  });

  test('a package missing from the rules is an error', () {
    pkg('packages', 'dlm_surprise');
    final v = checkWorkspace(root.path, rules);
    expect(v.single.message, contains('not listed in tools/import_rules.yaml'));
  });

  test('non-dlm packages and the package itself are fine', () {
    pkg(
      'packages',
      'dlm_api',
      files: {
        'lib/a.dart':
            "import 'package:http/http.dart';\n"
            "import 'package:dlm_api/b.dart';\n",
      },
    );
    expect(checkWorkspace(root.path, rules), isEmpty);
  });

  test('the real rules file parses', () {
    final real = File(p.join('..', 'import_rules.yaml')).readAsStringSync();
    final parsed = ImportRules.parse(real);
    expect(parsed.allowed['dlm_core'], {'dlm_api'});
    expect(parsed.allowed['dlm_skin_breeze'], {'dlm_ui_kit'});
    expect(parsed.skinRegistry, isNotEmpty);
  });
}
