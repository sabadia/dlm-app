@Tags(['golden'])
library;

import 'dart:io';

import 'package:dlm_app/src/app.dart';
import 'package:dlm_app/src/shell/shell_state.dart';
import 'package:dlm_app/src/skin_registry.dart';
import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';
import '../support/fakes.dart';

/// Whole screens in every skin, light and dark: the downloads page with cards,
/// the settings window and the add dialog. Images are only valid on the pinned
/// CI image (see .github/workflows/goldens.yml); `flutter test --tags golden
/// --update-goldens` rewrites them.
const _families = <String>[
  '.AppleSystemUIFont',
  'SF Pro Text',
  'Helvetica Neue',
  'SF Mono',
  'Menlo',
  'Monaco',
  'Segoe UI Variable Text',
  'Segoe UI',
  'Cascadia Mono',
  'Consolas',
  'Adwaita Sans',
  'Cantarell',
  'Adwaita Mono',
  'Source Code Pro',
  'DejaVu Sans',
  'DejaVu Sans Mono',
  'Noto Sans',
  'Noto Sans Mono',
  'Hack',
];

Future<void> _loadFonts() async {
  Future<ByteData> bytes(String name) async =>
      ByteData.sublistView(await File('test/fonts/$name').readAsBytes());
  final files = await Future.wait([
    bytes('Roboto-Regular.ttf'),
    bytes('Roboto-Medium.ttf'),
    bytes('Roboto-Bold.ttf'),
  ]);
  for (final family in _families) {
    final loader = FontLoader(family);
    for (final f in files) {
      loader.addFont(Future.value(f));
    }
    await loader.load();
  }
}

class _Fixed implements SystemAppearanceReader {
  _Fixed(this.dark);

  final bool dark;

  @override
  Future<SystemAppearance> read() async => SystemAppearance(
    brightness: dark ? Brightness.dark : Brightness.light,
    reduceMotion: true,
    reduceTransparency: true,
  );

  @override
  Stream<SystemAppearance> get changes => const Stream.empty();

  @override
  void dispose() {}
}

void main() {
  setUpAll(_loadFonts);

  for (final id in skinIds) {
    for (final dark in [false, true]) {
      final mode = dark ? 'dark' : 'light';

      Future<AppHarness> open(WidgetTester tester) => pumpApp(
        tester,
        size: const Size(1100, 720),
        queues: [queue('main', 'Default'), queue('night', 'Night')],
        tasks: [
          task(
            'a',
            name: 'ubuntu-26.04-desktop-amd64.iso',
            engine: 'http',
            status: 'running',
            size: 6 * 1024 * 1024 * 1024,
            downloaded: 2 * 1024 * 1024 * 1024,
          ),
          task(
            'b',
            name: 'conference-recording.mkv',
            engine: 'http',
            status: 'completed',
            size: 1500 * 1024 * 1024,
            downloaded: 1500 * 1024 * 1024,
          ),
          task('c', name: 'broken-archive.zip', engine: 'ftp', status: 'error'),
          task(
            'd',
            name: 'annual-report.pdf',
            engine: 'http',
            status: 'paused',
          ),
        ],
        overrides: [
          skinProvider.overrideWithValue(skins[id]!),
          systemAppearanceProvider.overrideWithValue(_Fixed(dark)),
        ],
      );

      appTest('$id / downloads / $mode', (tester) async {
        final h = await open(tester);
        h.container.read(selectionProvider.notifier).set({'b'});
        await settle(tester);
        await expectLater(
          find.byType(DlmApp),
          matchesGoldenFile('goldens/$id/downloads_$mode.png'),
        );
      });

      appTest('$id / settings window / $mode', (tester) async {
        final h = await open(tester);
        h.container.read(routerProvider).go('/manage/preferences');
        await settle(tester);
        await expectLater(
          find.byType(DlmApp),
          matchesGoldenFile('goldens/$id/settings_$mode.png'),
        );
      });

      appTest('$id / add dialog / $mode', (tester) async {
        final h = await open(tester);
        h.container.read(addRequestProvider.notifier).request();
        await settle(tester);
        await expectLater(
          find.byType(DlmApp),
          matchesGoldenFile('goldens/$id/add_dialog_$mode.png'),
        );
      });
    }
  }
}
