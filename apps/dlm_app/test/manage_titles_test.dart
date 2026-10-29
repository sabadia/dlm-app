import 'package:dlm_app/src/manage/manage_screen.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

void main() {
  appTest('every management page has a name in the sidebar, not its id', (
    tester,
  ) async {
    await pumpApp(tester, size: const Size(1400, 2600));
    final sidebar = find.byType(DlmSidebar<String>);
    final texts = tester
        .widgetList<Text>(
          find.descendant(of: sidebar, matching: find.byType(Text)),
        )
        .map((t) => t.data)
        .whereType<String>()
        .toSet();
    for (final page in managePages) {
      expect(
        texts.contains(page),
        isFalse,
        reason: 'the sidebar shows the raw id "$page"',
      );
    }
  });
}
