import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

void main() {
  test('counts add up per filter and queue', () {
    const counts = QueueCountsState({
      'main': {'running': 2, 'queued': 3, 'completed': 4},
      'night': {'paused': 1, 'error': 1},
    });
    expect(counts.count(), 11);
    expect(counts.count(statuses: const {TaskStatus.running}), 2);
    expect(
      counts.count(statuses: const {TaskStatus.queued, TaskStatus.paused}),
      4,
    );
    expect(counts.open('main'), 5);
    expect(counts.open('night'), 1);
  });

  appTest('the sidebar shows how many downloads each page and queue holds', (
    tester,
  ) async {
    await pumpApp(
      tester,
      queues: [queue('main', 'Default'), queue('night', 'Night')],
      counts: {
        'main': {'running': 2, 'queued': 3, 'completed': 4},
        'night': {'paused': 6},
      },
    );
    await settle(tester);
    final sidebar = find.byType(DlmSidebar<String>);
    Finder inSidebar(String text) =>
        find.descendant(of: sidebar, matching: find.text(text));
    expect(inSidebar('15'), findsOneWidget, reason: 'all');
    expect(inSidebar('2'), findsOneWidget, reason: 'active');
    expect(inSidebar('3'), findsOneWidget, reason: 'queued');
    expect(
      inSidebar('6'),
      findsNWidgets(2),
      reason: 'paused + the night queue',
    );
    expect(inSidebar('5'), findsOneWidget, reason: 'open in the default queue');
  });
}
