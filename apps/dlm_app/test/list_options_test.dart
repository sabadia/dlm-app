import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/screens/list_views.dart';
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

  Future<void> openViewMenu(WidgetTester tester) async {
    await tester.tap(find.byWidgetPredicate((w) => w is DlmMenuButton));
    await settle(tester);
  }

  appTest('the list says how many downloads match', (tester) async {
    await open(tester);
    expect(find.text('3 downloads'), findsOneWidget);
  });

  appTest('clicking a header sorts on the daemon, again reverses it', (
    tester,
  ) async {
    final h = await open(tester);
    final header = find.descendant(
      of: find.byType(DlmDataTable<Task>),
      matching: find.text('Size'),
    );
    await tester.tap(header);
    await settle(tester);
    expect(h.tasks.listCalls.last.$1.sort, Sort.size);
    expect(h.tasks.listCalls.last.$1.order, Order.asc);
    await tester.tap(header);
    await settle(tester);
    expect(h.tasks.listCalls.last.$1.order, Order.desc);
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
}
