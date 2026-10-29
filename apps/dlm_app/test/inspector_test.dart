import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/shell/shell_state.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';
import 'support/fakes.dart';

void main() {
  Future<void> select(WidgetTester tester, String name) async {
    await tester.tap(find.text(name));
    await tester.pump(const Duration(milliseconds: 100));
    await settle(tester);
  }

  Future<void> tab(WidgetTester tester, String label) async {
    // "Speed" is also a column of the table, so look inside the tab bar.
    final target = find.descendant(
      of: find.byWidgetPredicate((w) => w is DlmTabBar),
      matching: find.text(label),
    );
    // The strip scrolls when the pane is narrow.
    await tester.ensureVisible(target);
    await tester.tap(target);
    await settle(tester);
  }

  const folderFiles = Resource(
    name: 'pack',
    rangeSupported: true,
    size: 300,
    files: [
      File(
        index: 0,
        name: 'a.txt',
        path: 'docs/a.txt',
        selected: true,
        size: 100,
      ),
      File(
        index: 1,
        name: 'b.txt',
        path: 'docs/b.txt',
        selected: false,
        size: 200,
      ),
      File(index: 2, name: 'c.bin', path: 'c.bin', selected: true, size: 50),
    ],
  );

  appTest('nothing, one or several selected', (tester) async {
    final h = await pumpApp(
      tester,
      tasks: [
        task('a', name: 'one.iso'),
        task('b', name: 'two.iso'),
      ],
    );
    expect(find.text('No download selected'), findsOneWidget);
    h.container.read(selectionProvider.notifier).set({'a', 'b'});
    await settle(tester);
    expect(find.text('2 downloads selected'), findsOneWidget);
    await select(tester, 'one.iso');
    expect(find.text('Overview'), findsOneWidget);
  });

  appTest('the overview shows progress, destination and the error', (
    tester,
  ) async {
    final h = await pumpApp(
      tester,
      queues: [queue('main', 'Default')],
      tasks: [
        task(
          'a',
          status: 'running',
          name: 'ubuntu.iso',
          size: 2000,
          downloaded: 500,
          engine: 'http',
          dir: '/data/isos',
          priority: 'high',
        ),
        task(
          'b',
          status: 'error',
          name: 'broken.zip',
          error: TaskError(
            at: DateTime.utc(2026, 10, 29, 10),
            code: 'http_404',
            message: 'Not found',
            retryable: false,
          ),
        ),
      ],
    );
    h.container
        .read(taskStoreProvider)
        .progress
        .put(
          'a',
          const ProgressData(
            connections: 4,
            downloaded: 500,
            size: 2000,
            speed: 100000,
          ),
        );
    await select(tester, 'ubuntu.iso');
    expect(find.text('/data/isos'), findsOneWidget);
    expect(find.text('Default'), findsWidgets);
    expect(find.text('High'), findsOneWidget);
    expect(find.text('Connections'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);

    await select(tester, 'broken.zip');
    expect(find.text('It stopped with an error'), findsOneWidget);
    expect(find.textContaining('Not found (http_404)'), findsOneWidget);
    expect(find.text('Connections'), findsNothing);
  });

  appTest('the files tab shows the tree and what is skipped', (tester) async {
    await pumpApp(
      tester,
      tasks: [task('a', name: 'pack', resource: folderFiles)],
    );
    await select(tester, 'pack');
    await tab(tester, 'Files');
    expect(find.text('2 of 3 files selected'), findsOneWidget);
    expect(find.text('docs'), findsOneWidget);
    expect(find.text('a.txt'), findsOneWidget);
    expect(find.text('b.txt (not downloaded)'), findsOneWidget);
    expect(find.text('c.bin'), findsOneWidget);
  });

  appTest('a single-file download says so', (tester) async {
    await pumpApp(tester, tasks: [task('a', name: 'one.iso')]);
    await select(tester, 'one.iso');
    await tab(tester, 'Files');
    expect(find.text('This download is a single file.'), findsOneWidget);
  });

  appTest('the speed graph fills while progress arrives', (tester) async {
    final h = await pumpApp(
      tester,
      tasks: [task('a', status: 'running', name: 'one.iso')],
    );
    await select(tester, 'one.iso');
    await tab(tester, 'Speed');
    expect(
      find.text('The graph fills in while the download runs.'),
      findsOneWidget,
    );
    final progress = h.container.read(taskStoreProvider).progress;
    for (final speed in [1000, 4000, 2000]) {
      progress.put(
        'a',
        ProgressData(connections: 1, downloaded: 1, size: 100, speed: speed),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byType(DlmChartFrame), findsOneWidget);
    expect(
      find.text('The graph fills in while the download runs.'),
      findsNothing,
    );
  });

  group('link', () {
    final attempts = [
      RefreshAttempt(
        cause: 'expired',
        createdAt: DateTime.utc(2026, 10, 29, 9),
        downloaded: 10,
        id: 'r1',
        outcome: 'failed',
        strategy: 'resolver',
        taskId: 'a',
        error: 'gone',
      ),
    ];

    Future<FakeRefresh> open(WidgetTester tester, String status) async {
      final repo = FakeTaskRepository([
        task('a', status: status, name: 'one.iso'),
      ]);
      final refresh = FakeRefresh(repo, attempts);
      await pumpApp(
        tester,
        tasks: repo.tasks,
        overrides: [refreshRepositoryProvider.overrideWithValue(refresh)],
      );
      await select(tester, 'one.iso');
      await tab(tester, 'Link');
      return refresh;
    }

    appTest('shows the link and the renewal history', (tester) async {
      await open(tester, 'running');
      expect(find.text('http://example.test/file.bin'), findsOneWidget);
      expect(find.text('resolver · failed'), findsOneWidget);
      expect(find.textContaining('Cause: expired'), findsOneWidget);
    });

    appTest('renew and wait for a link go to the daemon', (tester) async {
      final r = await open(tester, 'running');
      await tester.tap(find.text('Renew link now'));
      await settle(tester);
      await tester.tap(find.text('Wait for a new link'));
      await settle(tester);
      expect(r.calls, ['refresh a', 'await a']);
      expect(find.text('Waiting for a new link'), findsOneWidget);
    });

    appTest('the link can only be replaced while paused', (tester) async {
      await open(tester, 'running');
      expect(
        find.text('Pause the download first to replace its link.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Replace link…'));
      await settle(tester);
      expect(find.text('Replace the link'), findsNothing);
    });

    appTest('replacing the link restarts on a mismatch', (tester) async {
      final r = await open(tester, 'paused');
      await tester.tap(find.text('Replace link…'));
      await settle(tester);
      final field = find.descendant(
        of: find.byType(DlmDialogContent),
        matching: find.byType(EditableText),
      );
      await tester.enterText(field, 'http://mirror.test/new.bin');
      await tester.pump();
      await tester.tap(find.text('Replace'));
      await settle(tester);
      expect(r.calls, ['link a http://mirror.test/new.bin restart']);
      expect(find.text('Link replaced'), findsOneWidget);
    });
  });
}
