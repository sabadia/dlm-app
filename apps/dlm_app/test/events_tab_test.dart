import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';
import 'support/fakes.dart';

StreamEvent _status(String from, String to, {Map<String, Object?>? error}) =>
    StreamEvent.fromJson({
      'id': 1,
      'type': 'task.status',
      'taskId': 'a',
      'time': '2026-10-30T10:00:00Z',
      'data': {'from': from, 'to': to, if (error != null) 'error': error},
    });

void main() {
  Future<AppHarness> open(WidgetTester tester, {Task? t}) async {
    final h = await pumpApp(
      tester,
      tasks: [t ?? task('a', status: 'running', name: 'one.iso')],
    );
    await tester.tap(find.text('one.iso'));
    await settle(tester);
    final tab = find.descendant(
      of: find.byWidgetPredicate((w) => w is DlmTabBar),
      matching: find.text('Events'),
    );
    await tester.ensureVisible(tab);
    await tester.tap(tab);
    await settle(tester);
    return h;
  }

  appTest('with nothing seen it says so and where the limit is', (
    tester,
  ) async {
    await open(tester);
    expect(
      find.text(
        'Nothing has happened to this download since the app connected.',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining('does not keep a longer history'),
      findsOneWidget,
    );
  });

  appTest('status changes appear as they arrive, newest first', (tester) async {
    final h = await open(tester);
    final store = h.container.read(taskStoreProvider)
      ..apply(_status('queued', 'running'));
    await settle(tester);
    store.apply(
      _status(
        'running',
        'error',
        error: {
          'at': '2026-10-30T10:00:03Z',
          'code': 'http_404',
          'message': 'not found',
          'retryable': false,
        },
      ),
    );
    await settle(tester);
    expect(find.text('Queued → Downloading'), findsOneWidget);
    expect(find.text('Downloading → Failed'), findsOneWidget);
    // The failure is also shown as the current one.
    expect(find.text('Failed'), findsWidgets);
    expect(find.textContaining('not found'), findsWidgets);
    final first = tester.getTopLeft(find.text('Downloading → Failed')).dy;
    final second = tester.getTopLeft(find.text('Queued → Downloading')).dy;
    expect(first, lessThan(second), reason: 'newest first');
  });
}
