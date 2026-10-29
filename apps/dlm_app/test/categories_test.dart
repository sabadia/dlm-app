import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/app.dart';
import 'package:dlm_app/src/manage/categories_screen.dart';
import 'package:dlm_app/src/manage/category_draft.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

const _video = Category(
  dir: '/media/video',
  id: 'c1',
  name: 'Video',
  position: 0,
  extensions: ['mkv', 'mp4'],
  mimeTypes: ['video/*'],
);
const _docs = Category(
  dir: '/docs',
  id: 'c2',
  name: 'Documents',
  position: 1,
  extensions: ['pdf'],
);

void main() {
  group('draft', () {
    test('extensions are lower case, without dots and repeats', () {
      final d = CategoryDraft()..extensions = '.MKV, mp4  mkv;Avi';
      expect(d.parsedExtensions, ['mkv', 'mp4', 'avi']);
      expect(d.extensionsValid, isTrue);
      d.extensions = 'ok, b@d';
      expect(d.extensionsValid, isFalse);
    });

    test('content types are one per line and look like type/subtype', () {
      final d = CategoryDraft()
        ..mimeTypes = 'Video/*\n\napplication/pdf\nvideo/*';
      expect(d.parsedMimeTypes, ['video/*', 'application/pdf']);
      expect(d.mimeTypesValid, isTrue);
      d.mimeTypes = 'video';
      expect(d.mimeTypesValid, isFalse);
    });

    test('a draft needs a name, a folder and at least one rule', () {
      final d = CategoryDraft();
      expect(d.valid, isFalse);
      d
        ..name = 'Video'
        ..dir = '/v';
      expect(d.valid, isFalse, reason: 'no rule');
      d.extensions = 'mkv';
      expect(d.valid, isTrue);
    });

    test('an update sends only what changed', () {
      final d = CategoryDraft(from: _video)..name = 'Films';
      final body = d.toUpdate(_video);
      expect(body.name, 'Films');
      expect(body.dir, isNull);
      expect(body.extensions, isNull);
      expect(body.mimeTypes, isNull);
      d.extensions = 'mkv';
      expect(d.toUpdate(_video).extensions, ['mkv']);
    });
  });

  Future<AppHarness> open(
    WidgetTester tester, {
    List<Category> categories = const [_video, _docs],
  }) async {
    final h = await pumpApp(tester, categories: categories);
    h.container.read(routerProvider).go('/manage/categories');
    await settle(tester);
    return h;
  }

  FakeCategories fake(AppHarness h) =>
      h.container.read(categoriesProvider.notifier) as FakeCategories;

  appTest('the page lists the categories with their rules', (tester) async {
    await open(tester);
    expect(find.text('Video'), findsWidgets);
    expect(find.text('/media/video'), findsOneWidget);
    expect(find.text('.mkv'), findsOneWidget);
    expect(find.text('video/*'), findsOneWidget);
    expect(find.text('Documents'), findsWidgets);
  });

  appTest('a category is added from the dialog', (tester) async {
    final h = await open(tester, categories: const []);
    expect(find.text('No categories yet'), findsOneWidget);
    await tester.tap(find.text('Add a category').first);
    await settle(tester);
    Future<void> fill(String label, String text) async {
      await tester.enterText(
        find
            .descendant(
              of: find.byType(CategoryDialog),
              matching: find.byWidgetPredicate(
                (w) => w is DlmTextField && w.semanticLabel == label,
              ),
            )
            .first,
        text,
      );
      await tester.pump();
    }

    await fill('Name', 'Archives');
    await fill('Folder', '/zips');
    await fill('Extensions', 'zip, .7z');
    await tester.tap(find.widgetWithText(DlmButton, 'Save'));
    await settle(tester);
    expect(fake(h).calls.single, 'create Archives /zips [zip, 7z]');
    expect(find.text('Category saved'), findsOneWidget);
  });

  appTest('the dialog will not save a category without a rule', (tester) async {
    await open(tester, categories: const []);
    await tester.tap(find.text('Add a category').first);
    await settle(tester);
    expect(
      tester
          .widget<DlmButton>(find.widgetWithText(DlmButton, 'Save'))
          .onPressed,
      isNull,
    );
  });

  appTest('editing sends only what changed', (tester) async {
    final h = await open(tester);
    final semantics = tester.ensureSemantics();
    await tester.tap(find.bySemanticsLabel('Edit Documents'));
    await settle(tester);
    await tester.enterText(
      find
          .descendant(
            of: find.byType(CategoryDialog),
            matching: find.byWidgetPredicate(
              (w) => w is DlmTextField && w.semanticLabel == 'Name',
            ),
          )
          .first,
      'Papers',
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(DlmButton, 'Save'));
    await settle(tester);
    expect(fake(h).calls.single, 'edit c2 Papers null null');
    semantics.dispose();
  });

  appTest('deleting asks first', (tester) async {
    final h = await open(tester);
    final semantics = tester.ensureSemantics();
    await tester.tap(find.bySemanticsLabel('Delete Documents'));
    await settle(tester);
    expect(find.text('Delete the category Documents?'), findsOneWidget);
    await tester.tap(find.text('Delete category'));
    await settle(tester);
    expect(fake(h).calls.single, 'remove c2');
    semantics.dispose();
  });

  appTest('the order is changed with the arrows', (tester) async {
    final h = await open(tester);
    final semantics = tester.ensureSemantics();
    await tester.tap(find.bySemanticsLabel('Move Documents up'));
    await settle(tester);
    expect(fake(h).calls.single, 'move c2 0');
    // Documents is first now.
    expect(
      tester
          .widget<DlmIconButton>(
            find.byWidgetPredicate(
              (w) =>
                  w is DlmIconButton && w.semanticLabel == 'Move Documents up',
            ),
          )
          .onPressed,
      isNull,
    );
    semantics.dispose();
  });

  appTest('a category is dragged to a new place by its handle', (tester) async {
    final h = await open(tester);
    final semantics = tester.ensureSemantics();
    final handle = find.descendant(
      of: find.byType(ReorderableDragStartListener).first,
      matching: find.byType(DlmIcon),
    );
    final start = tester.getCenter(handle);
    final gesture = await tester.startGesture(start);
    await tester.pump(const Duration(milliseconds: 100));
    for (var i = 0; i < 12; i++) {
      await gesture.moveBy(const Offset(0, 20));
      await tester.pump(const Duration(milliseconds: 30));
    }
    await gesture.up();
    await settle(tester);
    expect(fake(h).calls.single, 'move c1 1');
    semantics.dispose();
  });

  appTest('the tester says where a file would go', (tester) async {
    await open(tester);
    Future<void> type(String label, String text) async {
      await tester.enterText(
        find
            .descendant(
              of: find.byType(MatchTester),
              matching: find.byWidgetPredicate(
                (w) => w is DlmTextField && w.semanticLabel == label,
              ),
            )
            .first,
        text,
      );
      await tester.pump(matchDelay + const Duration(milliseconds: 50));
      await settle(tester);
    }

    await type('File name', 'movie.mkv');
    expect(find.text('Goes to Video: /media/video'), findsOneWidget);
    await type('File name', 'notes.xyz');
    expect(
      find.text(
        'No category matches: the file stays in the normal download folder.',
      ),
      findsOneWidget,
    );
  });
}
