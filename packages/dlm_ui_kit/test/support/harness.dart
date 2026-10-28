import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_skin.dart';

/// Pumps [child] inside a minimal app (overlay, shortcuts, media query) with
/// the test skin's theme. Returns the source so tests can change the
/// appearance.
Future<ManualAppearanceSource> pumpKit(
  WidgetTester tester,
  Widget child, {
  DlmAppearance appearance = const DlmAppearance(),
  AppearanceOverride override = AppearanceOverride.none,
  Size size = const Size(800, 600),
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  // The app is desktop-only: hover and focus highlights are always shown.
  FocusManager.instance.highlightStrategy =
      FocusHighlightStrategy.alwaysTraditional;
  addTearDown(
    () => FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.automatic,
  );
  final source = ManualAppearanceSource(appearance);
  addTearDown(source.dispose);
  await tester.pumpWidget(
    WidgetsApp(
      color: const Color(0xFFFFFFFF),
      pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, _, _) => builder(context),
      ),
      home: DlmThemeScope(
        skin: const TestSkin(),
        source: source,
        userOverride: override,
        child: Align(alignment: Alignment.topLeft, child: child),
      ),
    ),
  );
  return source;
}
