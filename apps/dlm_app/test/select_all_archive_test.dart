import 'package:dlm_app/src/app.dart';
import 'package:dlm_app/src/shell/shell_state.dart';
import 'package:dlm_core/dlm_core.dart';
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
}
