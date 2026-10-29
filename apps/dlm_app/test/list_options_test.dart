import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/prefs/pref_providers.dart';
import 'package:dlm_app/src/screens/list_views.dart';
import 'package:dlm_app/src/screens/task_card.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';
import 'support/fakes.dart';

void main() {
  Future<AppHarness> open(WidgetTester tester) => pumpApp(
    tester,
    queues: [queue('main', 'Default')],
    tasks: [
      task('a', name: 'one.iso', engine: 'http'),
      task('b', name: 'two.iso', engine: 'bt'),
      task('c', name: 'three.iso', engine: 'http'),
    ],
  );

  Future<void> openViewMenu(
    WidgetTester tester, {
    String label = 'View',
  }) async {
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is DlmMenuButton && w.semanticLabel == label,
      ),
    );
    await settle(tester);
  }

  appTest('the list says how many downloads match', (tester) async {
    await open(tester);
    expect(find.text('3 downloads'), findsOneWidget);
  });

  appTest('the display menu sorts on the daemon, and reverses the order', (
    tester,
  ) async {
    final h = await open(tester);
    await openViewMenu(tester, label: 'Display');
    await tester.ensureVisible(find.text('Size'));
    await tester.tap(find.text('Size'));
    await settle(tester);
    expect(h.tasks.listCalls.last.$1.sort, Sort.size);
    expect(h.tasks.listCalls.last.$1.order, Order.asc);
    await openViewMenu(tester, label: 'Display');
    await tester.ensureVisible(find.text('Descending'));
    await tester.tap(find.text('Descending'));
    await settle(tester);
    expect(h.tasks.listCalls.last.$1.order, Order.desc);
  });

  appTest('downloads are cards: no table header and no sideways scroll', (
    tester,
  ) async {
    await open(tester);
    expect(find.byType(TaskCard), findsNWidgets(3));
    expect(
      find.descendant(
        of: find.byType(DlmDataTable<Task>),
        matching: find.byWidgetPredicate(
          (w) =>
              w is SingleChildScrollView &&
              w.scrollDirection == Axis.horizontal,
        ),
      ),
      findsNothing,
      reason: 'cards only scroll vertically',
    );
  });

  appTest('the view menu narrows the list to one engine', (tester) async {
    final h = await open(tester);
    await openViewMenu(tester);
    await tester.tap(find.text('bt').first);
    await settle(tester);
    expect(h.tasks.listCalls.last.$1.engine, 'bt');
  });

  appTest('a view is saved with its search and engine, and applied again', (
    tester,
  ) async {
    final h = await open(tester);
    await openViewMenu(tester);
    await tester.tap(find.text('bt').first);
    await settle(tester);
    await openViewMenu(tester);
    // The menu is long and scrolls.
    await tester.ensureVisible(find.text('Save current view…'));
    await tester.tap(find.text('Save current view…'));
    await settle(tester);
    await tester.enterText(
      find
          .descendant(
            of: find.byType(DlmDialogContent),
            matching: find.byType(EditableText),
          )
          .first,
      'Torrents',
    );
    // The Save button enables with the text.
    await tester.pump();
    await tester.tap(find.text('Save'));
    await settle(tester);
    expect(h.container.read(savedViewsProvider).single.name, 'Torrents');

    // Back to everything, then apply the view.
    await openViewMenu(tester);
    await tester.tap(find.text('All engines'));
    await settle(tester);
    expect(h.container.read(listOptionsProvider).engine, isNull);
    await openViewMenu(tester);
    await tester.ensureVisible(find.text('Torrents'));
    await tester.tap(find.text('Torrents'));
    await settle(tester);
    expect(h.container.read(listOptionsProvider).engine, 'bt');
    expect(h.tasks.listCalls.last.$1.engine, 'bt');
  });

  appTest('the row height can be changed from the view menu', (tester) async {
    final h = await open(tester);
    expect(h.container.read(densityProvider), Density.comfortable);
    await openViewMenu(tester, label: 'Display');
    await tester.tap(find.text('Compact'));
    await settle(tester);
    expect(h.container.read(densityProvider), Density.compact);
  });

  appTest('grouping puts a heading with a count over each engine', (
    tester,
  ) async {
    final h = await open(tester);
    await openViewMenu(tester, label: 'Display');
    await tester.tap(find.text('Engine').first);
    await settle(tester);
    expect(h.container.read(listOptionsProvider).grouping, ListGrouping.engine);
    expect(find.text('http (2)'), findsOneWidget);
    expect(find.text('bt (1)'), findsOneWidget);
  });
}
