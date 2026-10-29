import 'package:dlm_app/src/prefs/pref_providers.dart';
import 'package:dlm_app/src/shell/app_menus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

void main() {
  appTest('macOS uses the system menu bar and no in-window strip', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      await pumpApp(tester);
      expect(find.byType(PlatformMenuBar), findsOneWidget);
      expect(find.byType(ApplicationMenuStrip), findsNothing);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  appTest('Windows and Linux show the application menu in the window', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    try {
      final h = await pumpApp(tester);
      expect(find.text('File'), findsOneWidget);
      expect(find.text('Go'), findsOneWidget);
      expect(find.text('Help'), findsOneWidget);
      expect(h.container.read(inspectorVisibleProvider), isTrue);

      await tester.tap(find.text('Window'));
      await settle(tester);
      await tester.tap(find.text('Show or hide details'));
      await settle(tester);
      expect(h.container.read(inspectorVisibleProvider), isFalse);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
