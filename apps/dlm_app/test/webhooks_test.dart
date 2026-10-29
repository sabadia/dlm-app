import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/app.dart';
import 'package:dlm_app/src/manage/webhook_draft.dart';
import 'package:dlm_app/src/manage/webhooks_screen.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

final _hook = Webhook(
  createdAt: DateTime.utc(2026),
  enabled: true,
  events: const ['task.status', 'queue.completed'],
  hasSecret: true,
  id: 'w1',
  updatedAt: DateTime.utc(2026),
  url: 'https://example.com/hook',
);

Finder iconButton(String label) => find.byWidgetPredicate(
  (w) => w is DlmIconButton && w.semanticLabel == label,
);

void main() {
  group('draft', () {
    test('the address must be http or https', () {
      final d = WebhookDraft()..url = 'ftp://x/y';
      expect(d.valid, isFalse);
      d.url = 'not a url';
      expect(d.valid, isFalse);
      d.url = 'https://example.com/hook';
      expect(d.valid, isTrue);
    });

    test('events are sent in the daemon\'s order', () {
      final d = WebhookDraft()
        ..url = 'https://x.io'
        ..events.addAll(['queue.completed', 'task.created']);
      expect(d.toCreate().events, ['task.created', 'queue.completed']);
      expect(d.toCreate().secret, isNull);
      expect(d.toCreate().disabled, isNull);
      d.enabled = false;
      expect(d.toCreate().disabled, isTrue);
    });

    test('an update sends only what changed; an empty secret removes it', () {
      final d = WebhookDraft(from: _hook);
      final none = d.toUpdate(_hook);
      expect(none.url, isNull);
      expect(none.events, isNull);
      expect(none.enabled, isNull);
      expect(none.secret, isNull);
      d
        ..removeSecret = true
        ..enabled = false
        ..events.add('task.created');
      final body = d.toUpdate(_hook);
      expect(body.secret, '');
      expect(body.enabled, isFalse);
      expect(body.events, ['task.created', 'task.status', 'queue.completed']);
    });
  });

  Future<AppHarness> open(
    WidgetTester tester, {
    List<Webhook> hooks = const [],
    List<Delivery> deliveries = const [],
    bool failTest = false,
  }) async {
    final h = await pumpApp(
      tester,
      overrides: [
        webhooksProvider.overrideWith(
          () =>
              FakeWebhooks(hooks, deliveryList: deliveries, failTest: failTest),
        ),
      ],
    );
    h.container.read(routerProvider).go('/manage/webhooks');
    await settle(tester);
    return h;
  }

  FakeWebhooks fake(AppHarness h) =>
      h.container.read(webhooksProvider.notifier) as FakeWebhooks;

  Future<void> fill(WidgetTester tester, String label, String text) async {
    await tester.enterText(
      find
          .descendant(
            of: find.byType(WebhookDialog),
            matching: find.byWidgetPredicate(
              (w) =>
                  (w is DlmTextField && w.semanticLabel == label) ||
                  (w is DlmPasswordField && w.semanticLabel == label),
            ),
          )
          .first,
      text,
    );
    await tester.pump();
  }

  appTest('the list shows the address, its events and whether it is signed', (
    tester,
  ) async {
    await open(tester, hooks: [_hook]);
    expect(find.text('https://example.com/hook'), findsOneWidget);
    expect(find.text('2 events'), findsOneWidget);
    expect(find.text('Signed'), findsOneWidget);
  });

  appTest('a webhook is added with events and a secret', (tester) async {
    final h = await open(tester);
    expect(find.text('No webhooks yet'), findsOneWidget);
    await tester.tap(find.text('Add a webhook').first);
    await settle(tester);
    expect(
      tester
          .widget<DlmButton>(find.widgetWithText(DlmButton, 'Save'))
          .onPressed,
      isNull,
    );
    await fill(tester, 'Address', 'https://hooks.example.org/in');
    await fill(tester, 'Secret', 's3');
    await tester.tap(find.text('task.created'));
    await tester.pump();
    await tester.ensureVisible(find.text('quota.reset'));
    await tester.tap(find.text('quota.reset'));
    await tester.pump();
    await tester.tap(find.widgetWithText(DlmButton, 'Save'));
    await settle(tester);
    expect(
      fake(h).calls.single,
      'create https://hooks.example.org/in [task.created, quota.reset] s3 null',
    );
  });

  appTest('a wrong address is flagged', (tester) async {
    await open(tester);
    await tester.tap(find.text('Add a webhook').first);
    await settle(tester);
    await fill(tester, 'Address', 'example.com');
    expect(
      find.text('Use an address that starts with http:// or https://.'),
      findsOneWidget,
    );
  });

  appTest('a secret can be removed when editing', (tester) async {
    final h = await open(tester, hooks: [_hook]);
    await tester.tap(iconButton('Edit https://example.com/hook'));
    await settle(tester);
    expect(find.text('Leave empty to keep the stored secret.'), findsOneWidget);
    final removeSwitch = find.byWidgetPredicate(
      (w) => w is DlmSwitch && w.semanticLabel == 'Remove the secret',
    );
    await tester.ensureVisible(removeSwitch);
    await tester.tap(removeSwitch);
    await tester.pump();
    await tester.tap(find.widgetWithText(DlmButton, 'Save'));
    await settle(tester);
    expect(fake(h).calls.single, 'edit w1 null null  null');
  });

  appTest('the switch turns deliveries off', (tester) async {
    final h = await open(tester, hooks: [_hook]);
    await tester.tap(
      find.byWidgetPredicate(
        (w) =>
            w is DlmSwitch &&
            w.semanticLabel == 'Send deliveries to https://example.com/hook',
      ),
    );
    await settle(tester);
    expect(fake(h).calls.single, 'edit w1 null null null false');
  });

  appTest('Test sends a test event and says what came back', (tester) async {
    final h = await open(tester, hooks: [_hook]);
    await tester.tap(find.text('Test'));
    await settle(tester);
    expect(fake(h).calls.single, 'test w1');
    expect(
      find.text('https://example.com/hook accepted the test event.'),
      findsOneWidget,
    );
  });

  appTest('a refused test is reported', (tester) async {
    await open(tester, hooks: [_hook], failTest: true);
    await tester.tap(find.text('Test'));
    await settle(tester);
    expect(
      find.text('https://example.com/hook did not accept the test event.'),
      findsOneWidget,
    );
  });

  appTest('the delivery log lists the attempts', (tester) async {
    final h = await open(
      tester,
      hooks: [_hook],
      deliveries: [
        Delivery(
          attempt: 1,
          durationMs: 40,
          event: 'task.status',
          eventId: 7,
          id: 1,
          ok: true,
          status: 200,
          time: DateTime.utc(2026, 5, 4, 10),
          willRetry: false,
        ),
        Delivery(
          attempt: 2,
          durationMs: 5000,
          error: 'connection refused',
          event: 'queue.completed',
          eventId: 8,
          id: 2,
          ok: false,
          status: 0,
          time: DateTime.utc(2026, 5, 4, 11),
          willRetry: true,
        ),
      ],
    );
    await tester.tap(find.text('Deliveries'));
    await settle(tester);
    expect(find.text('task.status'), findsOneWidget);
    expect(find.textContaining('HTTP 200'), findsOneWidget);
    expect(find.text('connection refused'), findsOneWidget);
    expect(find.textContaining('no answer'), findsOneWidget);
    expect(find.textContaining('will retry'), findsOneWidget);
    // Refresh reads the log again.
    await tester.tap(
      find.descendant(
        of: find.byType(DeliveriesDialog),
        matching: find.text('Refresh'),
      ),
    );
    await settle(tester);
    expect(fake(h).calls.where((c) => c.startsWith('deliveries')).length, 2);
  });

  appTest('deleting asks first', (tester) async {
    final h = await open(tester, hooks: [_hook]);
    await tester.tap(iconButton('Delete https://example.com/hook'));
    await settle(tester);
    expect(
      find.text('Delete the webhook https://example.com/hook?'),
      findsOneWidget,
    );
    await tester.tap(find.text('Delete webhook'));
    await settle(tester);
    expect(fake(h).calls.single, 'remove w1');
  });
}
