import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// A package of the pub workspace.
class Member {
  /// Creates a member at [dir] (relative to the root) named [name].
  const Member({
    required this.dir,
    required this.name,
    required this.hasTests,
    required this.usesFlutter,
  });

  /// Directory relative to the repository root, posix separators.
  final String dir;

  /// Package name.
  final String name;

  /// Whether the package has a `test/` directory.
  final bool hasTests;

  /// Whether the package depends on the Flutter SDK (so it needs
  /// `flutter test`, not `dart test`).
  final bool usesFlutter;
}

/// Lists the members named by the `workspace:` key of the root pubspec.
List<Member> workspaceMembers(String root) {
  final doc = loadYaml(
    File(p.join(root, 'pubspec.yaml')).readAsStringSync(),
  ) as YamlMap;
  final members = <Member>[];
  for (final dir in (doc['workspace'] as YamlList?) ?? YamlList()) {
    final path = p.join(root, dir as String);
    final pubspec = File(p.join(path, 'pubspec.yaml'));
    if (!pubspec.existsSync()) continue;
    final m = loadYaml(pubspec.readAsStringSync()) as YamlMap;
    final deps = <dynamic>[
      ...((m['dependencies'] as YamlMap?)?.values ?? const []),
      ...((m['dev_dependencies'] as YamlMap?)?.values ?? const []),
    ];
    members.add(
      Member(
        dir: p.posix.normalize(dir),
        name: m['name'] as String,
        hasTests: Directory(p.join(path, 'test')).existsSync(),
        usesFlutter: deps.any((d) => d is YamlMap && d['sdk'] == 'flutter'),
      ),
    );
  }
  return members;
}

/// Arguments only `flutter test` understands.
const _flutterOnly = {'--update-goldens'};

/// The command that runs the tests of [m] with the extra [args]
/// (for example `--exclude-tags golden`). Flutter-only arguments are
/// dropped for plain Dart packages.
List<String> testCommand(Member m, List<String> args) => [
  if (m.usesFlutter) 'flutter' else 'dart',
  'test',
  ...args.where((a) => m.usesFlutter || !_flutterOnly.contains(a)),
];
