import 'package:dlm_app/src/shell/shell_state.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';
import 'support/fakes.dart';

void main() {
  final tasks = [
    task('a', status: 'running', name: 'ubuntu.iso', downloaded: 500),
    task('b', status: 'paused', name: 'movie.mkv'),
    task('c', status: 'completed', name: 'report.pdf', downloaded: 1000),
    task('d', status: 'error', name: 'broken.zip'),
    task('e', name: 'queued-one.bin', queueId: 'night'),
  ];
  final queues = [
    queue('main', 'Main'),
    queue('night', 'Overnight', position: 1),
  ];

  appTest('shows the sidebar, the title and the downloads', (tester) async {
    await pumpApp(tester, tasks: tasks, queues: queues);
    for (final t in [
      'All Downloads',
      'Active',
      'Queued',
      'Paused',
      'Completed',
      'Failed',
      'Queues',
      'Main',
      'Overnight',
    ]) {
      expect(find.text(t), findsWidgets, reason: t);
    }
    for (final n in ['ubuntu.iso', 'movie.mkv', 'report.pdf', 'broken.zip']) {
      expect(find.text(n), findsOneWidget, reason: n);
    }
  });

  testWidgets(
    'choosing a sidebar item filters the list and retitles the page',
    (tester) async {
      final h = await pumpApp(tester, tasks: tasks, queues: queues);
      await tester.tap(find.widgetWithText(DlmInteractive, 'Paused'));
      await settle(tester);
      expect(find.text('movie.mkv'), findsOneWidget);
      expect(find.text('ubuntu.iso'), findsNothing);
      expect(h.tasks.listCalls.last.$1.statuses.length, 1);
    },
  );

  appTest('a queue page lists only that queue', (tester) async {
    await pumpApp(tester, tasks: tasks, queues: queues);
    await tester.tap(find.widgetWithText(DlmInteractive, 'Overnight'));
    await settle(tester);
    expect(find.text('queued-one.bin'), findsOneWidget);
    expect(find.text('ubuntu.iso'), findsNothing);
  });

  appTest('the search field narrows the list', (tester) async {
    await pumpApp(tester, tasks: tasks, queues: queues);
    await tester.enterText(find.byType(EditableText).first, 'movie');
    await settle(tester);
    expect(find.text('movie.mkv'), findsOneWidget);
    expect(find.text('ubuntu.iso'), findsNothing);
  });

  appTest('an empty filter shows the empty state, a miss says so', (
    tester,
  ) async {
    await pumpApp(tester, tasks: [task('x', status: 'running')]);
    await tester.tap(find.widgetWithText(DlmInteractive, 'Completed'));
    await settle(tester);
    expect(find.text('No downloads here'), findsOneWidget);
    await tester.enterText(find.byType(EditableText).first, 'zzz');
    await settle(tester);
    expect(find.text('Nothing matches your search'), findsOneWidget);
  });

  appTest('Ctrl+K opens the palette and a command navigates', (tester) async {
    await pumpApp(tester, tasks: tasks, queues: queues);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(find.text('Type a command'), findsOneWidget);
    await tester.enterText(find.byType(EditableText).last, 'go failed');
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    await settle(tester);
    expect(find.text('broken.zip'), findsOneWidget);
    expect(find.text('ubuntu.iso'), findsNothing);
  });

  appTest('the details pane can be hidden and shown', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpApp(tester, tasks: tasks, queues: queues);
    expect(find.text('No download selected'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Hide details'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('No download selected'), findsNothing);
    await tester.tap(find.bySemanticsLabel('Show details'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('No download selected'), findsOneWidget);
    semantics.dispose();
  });

  appTest('selecting a row selects it in the shared selection', (tester) async {
    final h = await pumpApp(tester, tasks: tasks, queues: queues);
    await tester.tap(find.text('movie.mkv'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(h.container.read(selectionProvider), {'b'});
  });
}
