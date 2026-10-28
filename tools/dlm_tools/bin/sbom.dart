import 'dart:io';

import 'package:dlm_tools/sbom.dart';

/// Usage: dart run dlm_tools:sbom [version] > sbom.cdx.json
void main(List<String> args) {
  final lock = File('pubspec.lock');
  if (!lock.existsSync()) {
    stderr.writeln(
      'pubspec.lock not found; run `dart pub get` at the repository root',
    );
    exit(2);
  }
  stdout.writeln(
    sbomJson(
      lock.readAsStringSync(),
      appName: 'dlm-app',
      appVersion: args.isNotEmpty ? args.first : '0.0.0',
    ),
  );
}
