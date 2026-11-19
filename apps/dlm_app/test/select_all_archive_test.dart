import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/app.dart';
import 'package:dlm_app/src/shell/shell_state.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/gestures.dart' show kSecondaryButton;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';
import 'support/fakes.dart';

void main() {
  appTest('Select all takes every download of the list, not only the page '
      'that is loaded', (tester) async {
    // The list loads 100 at a time; 250 failed downloads are on the daemon.
    final h = await pumpApp(
      tester,
      tasks: [
        for (var i = 0; i < 250; i++)
          task('t$i', status: 'error', name: 'file$i.bin', position: i),
      ],
    );
    h.container.read(routerProvider).go('/downloads/failed');
    await settle(tester);
    await tester.tap(find.text('file0.bin'));
    await settle(tester);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await settle(tester);

    expect(h.container.read(selectionProvider), hasLength(250));
    expect(h.container.read(selectedTasksProvider), hasLength(250));
  });

  appTest('archived downloads leave the lists and are in the archive', (
    tester,
  ) async {
    final h = await pumpApp(
      tester,
      tasks: [
        task('a', status: 'completed', name: 'kept.iso'),
        task('b', status: 'completed', name: 'old.iso'),
      ],
    );
    h.container.read(routerProvider).go('/downloads/completed');
    await settle(tester);
    expect(find.text('old.iso'), findsOneWidget);

    await h.container.read(taskActionsProvider).archive(['b']);
    h.tasks.tasks = [
      h.tasks.tasks.first,
      h.tasks.tasks.last.copyWith(archived: true),
    ];
    await settle(tester);
    expect(h.tasks.archivedCalls.single.$1, ['b']);
    expect(h.tasks.archivedCalls.single.$2, isTrue);
    expect(find.text('old.iso'), findsNothing);
    expect(find.text('kept.iso'), findsOneWidget);

    h.container.read(routerProvider).go('/downloads/archive');
    await settle(tester);
    expect(find.text('old.iso'), findsOneWidget);
    expect(find.text('kept.iso'), findsNothing);
  });

  group('archiving', () {
    SystemInfo daemon(String version) => systemInfo(const [], version: version);

    appTest(
      'says so when the server is older than the archive, and asks nothing of it',
      (tester) async {
        final h = await pumpApp(
          tester,
          tasks: [task('a', status: 'completed', name: 'old.iso')],
          overrides: [
            systemInfoProvider.overrideWith((ref) async => daemon('0.7.6')),
          ],
        );
        h.container.read(routerProvider).go('/downloads/completed');
        await settle(tester);
        // Let the system info arrive, as it does in the running app.
        await h.container.read(systemInfoProvider.future);
        await tester.tap(find.text('old.iso'), buttons: kSecondaryButton);
        await settle(tester);
        await tester.tap(find.text('Move to archive'));
        await settle(tester);
        expect(find.textContaining('too old for the archive'), findsOneWidget);
        expect(find.textContaining('0.7.6'), findsOneWidget);
        expect(h.tasks.archivedCalls, isEmpty);
      },
    );

    appTest('sends only the finished downloads of a selection to be archived', (
      tester,
    ) async {
      final h = await pumpApp(
        tester,
        tasks: [
          task('a', status: 'completed', name: 'done.iso'),
          task('b', status: 'running', name: 'busy.iso'),
          task('c', name: 'later.iso'),
        ],
        overrides: [
          systemInfoProvider.overrideWith((ref) async => daemon('0.8.0')),
        ],
      );
      await h.container.read(systemInfoProvider.future);
      h.container.read(selectionProvider.notifier).set({'a', 'b', 'c'});
      await settle(tester);
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is DlmIconButton && w.semanticLabel == 'Move to archive',
        ),
      );
      await settle(tester);
      expect(h.tasks.archivedCalls.single.$1, ['a']);
      // The unfinished ones were never sent: the daemon is not asked to refuse them.
      expect(find.text('Moved 1 download to the archive'), findsOneWidget);
    });
  });
}
