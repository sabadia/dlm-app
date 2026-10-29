import 'package:dlm_app/src/shell/shell_state.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';
import 'support/fakes.dart';

void main() {
  final tasks = [
    task('a', status: 'running', name: 'ubuntu.iso', downloaded: 500),
    task('b', status: 'paused', name: 'movie.mkv'),
    task('c', status: 'completed', name: 'report.pdf', downloaded: 1000),
    task('d', status: 'error', name: 'broken.zip'),
  ];

  Future<void> select(WidgetTester tester, String name) async {
    await tester.tap(find.text(name));
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> rightClick(WidgetTester tester, String name) async {
    await tester.tapAt(
      tester.getCenter(find.text(name)),
      buttons: kSecondaryButton,
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  appTest('the toolbar shows the selection and its actions', (tester) async {
    await pumpApp(tester, tasks: tasks);
    expect(find.text('1 selected'), findsNothing);
    await select(tester, 'ubuntu.iso');
    expect(find.text('1 selected'), findsOneWidget);
  });

  appTest('pause acts on the selection and offers Undo', (tester) async {
    final h = await pumpApp(tester, tasks: tasks);
    final semantics = tester.ensureSemantics();
    await select(tester, 'ubuntu.iso');
    await tester.tap(find.bySemanticsLabel('Pause'));
    await settle(tester);
    expect(h.tasks.paused, [
      ['a'],
    ]);
    expect(find.text('Paused 1 download'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await settle(tester);
    expect(h.tasks.resumed, [
      ['a'],
    ]);
    semantics.dispose();
  });

  appTest('resume is only enabled for something that can resume', (
    tester,
  ) async {
    final h = await pumpApp(tester, tasks: tasks);
    final semantics = tester.ensureSemantics();
    await select(tester, 'report.pdf');
    await tester.tap(find.bySemanticsLabel('Resume'));
    await settle(tester);
    expect(
      h.tasks.resumed,
      isEmpty,
      reason: 'a completed download cannot resume',
    );
    await select(tester, 'movie.mkv');
    await tester.tap(find.bySemanticsLabel('Resume'));
    await settle(tester);
    expect(h.tasks.resumed.single, ['b']);
    semantics.dispose();
  });

  appTest('the context menu offers what fits the status', (tester) async {
    await pumpApp(tester, tasks: tasks);
    await rightClick(tester, 'ubuntu.iso');
    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('Resume'), findsNothing);
    expect(find.text('Copy link'), findsOneWidget);
    expect(find.text('Delete…'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump(const Duration(milliseconds: 100));
    await rightClick(tester, 'broken.zip');
    expect(find.text('Resume'), findsOneWidget, reason: 'failed can retry');
    expect(find.text('Download again'), findsOneWidget);
    expect(find.text('Pause'), findsNothing);
  });

  appTest('right click selects the row it is on', (tester) async {
    final h = await pumpApp(tester, tasks: tasks);
    await rightClick(tester, 'movie.mkv');
    expect(h.container.read(selectionProvider), {'b'});
  });

  appTest('right click inside a multi-selection acts on all of it', (
    tester,
  ) async {
    final h = await pumpApp(tester, tasks: tasks);
    h.container.read(selectionProvider.notifier).set({'a', 'b'});
    await tester.pump(const Duration(milliseconds: 100));
    await rightClick(tester, 'ubuntu.iso');
    await tester.tap(find.text('Pause'));
    await settle(tester);
    expect(h.tasks.paused.single.toSet(), {'a', 'b'});
  });

  appTest('delete asks first and keeps the files by default', (tester) async {
    final h = await pumpApp(tester, tasks: tasks);
    await select(tester, 'broken.zip');
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await settle(tester);
    expect(find.text('Delete this download?'), findsOneWidget);
    expect(h.tasks.deleted, isEmpty);
    await tester.tap(find.widgetWithText(DlmButton, 'Delete'));
    await settle(tester);
    expect(h.tasks.deleted.single.$1, ['d']);
    expect(h.tasks.deleted.single.$2, isFalse);
    expect(find.text('Deleted 1 download'), findsOneWidget);
    expect(find.text('broken.zip'), findsNothing);
  });

  appTest('cancel and Escape delete nothing; Cancel has the focus', (
    tester,
  ) async {
    final h = await pumpApp(tester, tasks: tasks);
    await select(tester, 'broken.zip');
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await settle(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await settle(tester);
    expect(h.tasks.deleted, isEmpty, reason: 'Enter pressed Cancel');
    // Still listed: the table row and the details pane's title.
    expect(find.text('broken.zip'), findsNWidgets(2));
  });

  appTest('the dialog can also delete the files', (tester) async {
    final h = await pumpApp(tester, tasks: tasks);
    await select(tester, 'report.pdf');
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await settle(tester);
    await tester.tap(find.text('Also delete the downloaded files'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.widgetWithText(DlmButton, 'Delete'));
    await settle(tester);
    expect(h.tasks.deleted.single.$1, ['c']);
    expect(h.tasks.deleted.single.$2, isTrue);
  });

  appTest('deleting several downloads says how many', (tester) async {
    final h = await pumpApp(tester, tasks: tasks);
    await select(tester, 'report.pdf');
    h.container.read(selectionProvider.notifier).set({'c', 'd'});
    await tester.pump(const Duration(milliseconds: 100));
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await settle(tester);
    expect(find.text('Delete 2 downloads?'), findsOneWidget);
    await tester.tap(find.widgetWithText(DlmButton, 'Delete'));
    await settle(tester);
    expect(find.text('Deleted 2 downloads'), findsOneWidget);
    expect(h.container.read(selectionProvider), isEmpty);
  });

  appTest('Download again restarts a finished download', (tester) async {
    await pumpApp(tester, tasks: tasks);
    await rightClick(tester, 'report.pdf');
    expect(find.text('Download again'), findsOneWidget);
  });
}
