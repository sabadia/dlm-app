import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/app.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';
import 'support/fakes.dart';

void main() {
  appTest('a category is a page of the sidebar that filters the list', (
    tester,
  ) async {
    final h = await pumpApp(
      tester,
      queues: [queue('main', 'Default')],
      categories: const [
        Category(
          dir: '/media',
          id: 'c1',
          name: 'Media',
          position: 0,
          extensions: ['mkv'],
        ),
      ],
      tasks: [task('a', name: 'one.iso')],
    );
    // The section of categories in the sidebar.
    expect(find.text('Categories'), findsOneWidget);
    await tester.tap(find.text('Media'));
    await settle(tester);
    expect(h.tasks.listCalls.last.$1.category, 'c1');
  });

  appTest('without categories the sidebar has no section for them', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Categories'), findsNothing);
  });

  appTest('the gear opens Tools in a window, and a click opens a page', (
    tester,
  ) async {
    await pumpApp(tester);
    // The sidebar no longer lists them.
    expect(find.text('Statistics'), findsNothing);
    await tester.tap(
      find.byWidgetPredicate(
        (w) =>
            w is DlmMenuButton &&
            w.semanticLabel == 'Tools, manage and settings',
      ),
    );
    await settle(tester);
    await tester.tap(find.text('Tools'));
    await settle(tester);
    for (final t in ['Browser tool', 'Import and export', 'Statistics']) {
      expect(find.text(t), findsWidgets);
    }
    await tester.tap(find.text('Statistics'));
    await settle(tester);
    // The list entry and the page title.
    expect(find.text('Statistics'), findsNWidgets(2));
  });

  appTest('a link to a settings page opens the window on it', (tester) async {
    final h = await pumpApp(tester);
    h.container.read(routerProvider).go('/manage/about');
    await settle(tester);
    expect(find.text('Manage'), findsOneWidget, reason: 'the window header');
    expect(find.text('About'), findsWidgets);
    expect(
      h.container.read(routerProvider).state.uri.path,
      '/downloads/all',
      reason: 'the page behind goes back to the downloads',
    );
  });
}
