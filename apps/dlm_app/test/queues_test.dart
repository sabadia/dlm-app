import 'dart:convert';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/queues/queue_countdown.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

SseData event(String type, Map<String, Object?> data, {String? queueId}) =>
    SseData(
      SseMessage(
        id: 'b-${type.hashCode}',
        event: type,
        data: jsonEncode({
          'id': 1,
          'type': type,
          'queueId': ?queueId,
          'time': '2026-10-29T10:00:00Z',
          'data': data,
        }),
      ),
    );

/// The text inputs of the open dialog (the toolbar search is another).
Finder dialogFields() => find.descendant(
  of: find.byType(DlmDialogContent),
  matching: find.byType(EditableText),
);

FakeQueues fake(AppHarness h) =>
    h.container.read(queuesProvider.notifier) as FakeQueues;

void main() {
  final queues = [
    queue('main', 'Default'),
    queue('night', 'Night', position: 1),
  ];

  Future<void> open(WidgetTester tester, String name) async {
    await tester.tap(find.text(name));
    await settle(tester);
  }

  appTest('a queue page shows its state and starts and stops it', (
    tester,
  ) async {
    final h = await pumpApp(tester, queues: queues);
    await open(tester, 'Night');
    expect(find.text('Stopped'), findsOneWidget);
    await tester.tap(find.text('Start queue'));
    await settle(tester);
    expect(fake(h).calls, ['start night']);
    expect(find.text('Running'), findsOneWidget);
    expect(find.text('“Night” started'), findsOneWidget);
    await tester.tap(find.text('Stop queue'));
    await settle(tester);
    expect(fake(h).calls.last, 'stop night');
  });

  appTest('a new queue is named, created and opened', (tester) async {
    final h = await pumpApp(tester, queues: queues);
    await tester.tap(find.text('New queue'));
    await settle(tester);
    expect(find.text('Create'), findsOneWidget);
    await tester.enterText(dialogFields(), 'Weekend');
    await tester.pump();
    await tester.tap(find.text('Create'));
    await settle(tester);
    expect(fake(h).calls, ['create Weekend']);
    expect(find.text('Created “Weekend”'), findsOneWidget);
    expect(find.text('Weekend'), findsWidgets, reason: 'sidebar and title');
  });

  appTest('a queue is deleted only after confirming, tasks go to default', (
    tester,
  ) async {
    final h = await pumpApp(tester, queues: queues);
    await open(tester, 'Night');
    final semantics = tester.ensureSemantics();
    await tester.tap(find.bySemanticsLabel('Queue actions'));
    await settle(tester);
    await tester.tap(find.text('Delete queue…'));
    await settle(tester);
    expect(fake(h).calls, isEmpty, reason: 'asks first');
    await tester.tap(find.text('Delete queue'));
    await settle(tester);
    expect(fake(h).calls, ['remove night to main']);
    expect(find.text('Deleted “Night”'), findsOneWidget);
    semantics.dispose();
  });

  appTest('the default queue cannot be deleted from its menu', (tester) async {
    await pumpApp(tester, queues: queues);
    await open(tester, 'Default');
    final semantics = tester.ensureSemantics();
    await tester.tap(find.bySemanticsLabel('Queue actions'));
    await settle(tester);
    await tester.tap(find.text('Delete queue…'));
    await settle(tester);
    expect(find.text('Delete queue'), findsNothing);
    semantics.dispose();
  });

  appTest('the settings dialog saves a quota and a stop action', (
    tester,
  ) async {
    final h = await pumpApp(tester, queues: queues);
    await open(tester, 'Night');
    final semantics = tester.ensureSemantics();
    await tester.tap(find.bySemanticsLabel('Queue settings…'));
    await settle(tester);
    expect(find.text('Settings of “Night”'), findsOneWidget);

    await tester.ensureVisible(find.byType(DlmSwitch).at(1));
    await tester.tap(find.byType(DlmSwitch).at(1));
    await settle(tester);
    final fields = dialogFields();
    await tester.ensureVisible(fields.at(2));
    await tester.enterText(fields.at(1), '500 M');
    await tester.enterText(fields.at(2), '1 d');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await settle(tester);

    final saved = fake(h).savedSettings!;
    expect(saved.quota!.bytes, 500 * 1048576);
    expect(saved.quota!.period, '24h0m0s');
    expect(find.text('Saved the settings of “Night”'), findsOneWidget);
    semantics.dispose();
  });

  appTest('save stays off while the quota is incomplete', (tester) async {
    await pumpApp(tester, queues: queues);
    await open(tester, 'Night');
    final semantics = tester.ensureSemantics();
    await tester.tap(find.bySemanticsLabel('Queue settings…'));
    await settle(tester);
    await tester.ensureVisible(find.byType(DlmSwitch).at(1));
    await tester.tap(find.byType(DlmSwitch).at(1));
    await settle(tester);
    await tester.tap(find.text('Save'));
    await settle(tester);
    expect(
      find.text('Settings of “Night”'),
      findsOneWidget,
      reason: 'still open',
    );
    semantics.dispose();
  });

  appTest('a finished queue counts down and cancelling stops it', (
    tester,
  ) async {
    final h = await pumpApp(tester, queues: queues, liveSync: true);
    // The queue has to be running for the daemon to announce an action.
    await fake(h).start('night');
    await tester.pump();
    h.events.add(
      event('queue.completed', {
        'action': 'sleep',
        'completedTasks': 3,
        'executeAt': '2026-10-29T10:01:00Z',
      }, queueId: 'night'),
    );
    await settle(tester);
    expect(find.text('“Night” has finished'), findsOneWidget);
    expect(find.textContaining('Put the computer to sleep in'), findsOneWidget);

    await tester.tap(find.text('Cancel and stop the queue'));
    await settle(tester);
    expect(fake(h).calls.last, 'stop night');

    h.events.add(
      event('queue.action_cancelled', {
        'action': 'sleep',
        'reason': 'queue_stopped',
      }, queueId: 'night'),
    );
    await settle(tester);
    expect(find.text('“Night” has finished'), findsNothing);
    expect(
      find.text('The action after “Night” was cancelled.'),
      findsOneWidget,
    );
    expect(h.container.read(pendingQueueActionsProvider), isEmpty);
  });

  appTest('the countdown ends by itself when the time is up', (tester) async {
    final h = await pumpApp(tester, queues: queues, liveSync: true);
    h.events.add(
      event('queue.completed', {
        'action': 'shutdown',
        'completedTasks': 1,
        'executeAt': '2026-10-29T10:00:03Z',
      }, queueId: 'night'),
    );
    await settle(tester);
    expect(find.text('“Night” has finished'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('“Night” has finished'), findsNothing);
  });
}
