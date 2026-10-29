import 'package:dlm_gallery/gallery_app.dart';
import 'package:dlm_gallery/sections/sections.dart';
import 'package:dlm_gallery/skins.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (var skin = 0; skin < gallerySkins.length; skin++) {
    for (final title in gallerySectionTitles) {
      for (final (dark, hc) in [(false, false), (true, false), (false, true)]) {
        testWidgets(
          '${gallerySkins[skin].id}: $title (${dark
              ? 'dark'
              : hc
              ? 'high contrast'
              : 'light'})',
          (tester) async {
            tester.view
              ..physicalSize = const Size(1280, 900)
              ..devicePixelRatio = 1;
            addTearDown(tester.view.reset);
            await tester.pumpWidget(
              GalleryApp(
                skins: gallerySkins,
                initial: GallerySettings(
                  skinIndex: skin,
                  dark: dark,
                  highContrast: hc,
                  section: title,
                ),
              ),
            );
            await tester.pump(const Duration(milliseconds: 100));
            expect(tester.takeException(), isNull);
            // Let any double-click or toast timers expire.
            await tester.pump(const Duration(seconds: 1));
          },
        );
      }
    }
  }

  testWidgets('the whole gallery builds with every control changed', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1280, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const GalleryApp(
        skins: gallerySkins,
        initial: GallerySettings(
          dark: true,
          highContrast: true,
          reduceMotion: true,
          reduceTransparency: true,
          textScale: 2,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });
}
