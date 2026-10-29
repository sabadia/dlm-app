@Tags(['golden'])
library;

import 'package:dlm_gallery/sections/sections.dart';
import 'package:dlm_gallery/skins.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/golden_harness.dart';

String _slug(String title) =>
    title.toLowerCase().replaceAll(RegExp('[^a-z0-9]+'), '_');

void main() {
  setUpAll(loadGoldenFonts);

  for (final skin in gallerySkins) {
    for (final title in gallerySectionTitles) {
      for (final (mode, dark, hc) in const [
        ('light', false, false),
        ('dark', true, false),
        ('contrast', false, true),
      ]) {
        testWidgets('${skin.id} / $title / $mode', (tester) async {
          final toasts = DlmToastController();
          addTearDown(toasts.dispose);
          final key = await pumpGolden(
            tester,
            skin: skin,
            dark: dark,
            highContrast: hc,
            child: Builder(
              builder: (context) => gallerySections(
                context,
                toasts,
              ).firstWhere((s) => s.$1 == title).$2,
            ),
          );
          await expectLater(
            find.byKey(key),
            matchesGoldenFile('goldens/${skin.id}/${_slug(title)}_$mode.png'),
          );
          await tester.pump(const Duration(seconds: 1));
        });
      }
    }
  }
}
