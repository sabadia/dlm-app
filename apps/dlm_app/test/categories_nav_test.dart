import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/app.dart';
import 'package:dlm_app/src/manage/manage_screen.dart';
import 'package:dlm_app/src/routing/app_routes.dart';
import 'package:dlm_app/src/shell/settings_hub.dart';
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

  test('every page of a section has an icon of its own', () {
    for (final section in HubSection.values) {
      final icons = [
        for (final p in hubPages(section)) hubPageIcon(section, p),
      ];
      expect(
        icons.toSet().length,
        icons.length,
        reason: '${section.name}: $icons',
      );
    }
    // The pages of all sections together may share only the globe, once
    // as the browser tool and once as the network settings.
    final all = [
      for (final s in HubSection.values)
        for (final p in hubPages(s)) hubPageIcon(s, p),
    ];
    expect(all.length - all.toSet().length, lessThanOrEqualTo(1));
    expect(setupPages, isNotEmpty);
    expect(settingsGroups, isNotEmpty);
  });
}
