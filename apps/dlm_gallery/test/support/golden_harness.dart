import 'dart:io';

import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The families the skins ask for. Every one is mapped to Roboto so renders
/// are identical on any machine (see test/fonts/README.md).
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

/// Registers Roboto under every family name a skin uses.
Future<void> loadGoldenFonts() async {
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

/// Renders [child] under [skin] in the given appearance and returns the key of
/// the boundary to compare. Motion is reduced so nothing animates.
Future<Key> pumpGolden(
  WidgetTester tester, {
  required DlmSkin skin,
  required Widget child,
  required bool dark,
  required bool highContrast,
  double width = 760,
}) async {
  tester.view
    ..physicalSize = Size(width, 2400)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final source = ManualAppearanceSource(
    DlmAppearance(
      brightness: dark ? Brightness.dark : Brightness.light,
      contrast: highContrast ? DlmContrast.high : DlmContrast.standard,
      reduceMotion: true,
      reduceTransparency: true,
    ),
  );
  addTearDown(source.dispose);
  const key = ValueKey('golden');
  await tester.pumpWidget(
    WidgetsApp(
      color: const Color(0xFF000000),
      pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, _, _) => builder(context),
      ),
      builder: (context, navigator) =>
          DlmThemeScope(skin: skin, source: source, child: navigator!),
      home: UnconstrainedBox(
        constrainedAxis: Axis.horizontal,
        alignment: Alignment.topLeft,
        child: RepaintBoundary(
          key: key,
          child: Builder(
            builder: (context) => ColoredBox(
              color: DlmTheme.of(context).colors.content,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(width: width - 40, child: child),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 50));
  return key;
}
