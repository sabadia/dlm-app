import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/app.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';
import 'support/fakes.dart';

TaskError _error(String code, {TaskRetry? retry, String? message}) => TaskError(
  at: DateTime.utc(2026, 11, 5),
  code: code,
  message: message ?? 'engine: transient: segmented: GET https://x/y: reset',
  retryable: true,
  retry: retry,
);

Finder _button(String label) =>
    find.byWidgetPredicate((w) => w is DlmButton && w.label == label);

void main() {
  Future<AppHarness> openFailed(WidgetTester tester, List<Task> tasks) async {
    final h = await pumpApp(tester, tasks: tasks);
    h.container.read(routerProvider).go('/downloads/failed');
    await settle(tester);
    return h;
  }

  appTest('a failed download the daemon will retry says so', (tester) async {
    final soon = DateTime.now().add(const Duration(minutes: 5));
    await openFailed(tester, [
      task(
        'a',
        status: 'error',
        name: 'waiting.mp4',
        error: _error(
          'network',
          retry: TaskRetry(attempt: 1, max: 3, nextAt: soon),
        ),
      ),
    ]);
    expect(find.text('Retrying'), findsOneWidget);
    expect(find.textContaining('Retry 1 of 3 in'), findsOneWidget);
    expect(
      find.byWidgetPredicate((w) => w is DlmBadge && w.label == 'Failed'),
      findsNothing,
    );
  });

  appTest('a download that gave up says why, in plain words', (tester) async {
    await openFailed(tester, [
      task('a', status: 'error', name: 'gone.mp4', error: _error('network')),
      task(
        'b',
        status: 'error',
        name: 'full.bin',
        error: _error('disk_full', message: 'bt: not enough free space'),
      ),
    ]);
    expect(find.text('Network problem'), findsOneWidget);
    expect(find.text('Not enough disk space'), findsOneWidget);
    expect(find.text('Failed'), findsWidgets);
    // The raw engine text, with its addresses, is for the inspector.
    expect(find.textContaining('https://x/y'), findsNothing);
  });

  appTest('a failed download shows a still bar, not an animated one', (
    tester,
  ) async {
    await openFailed(tester, [
      task('a', status: 'error', size: -1, error: _error('network')),
    ]);
    final bar = tester.widget<DlmProgressBar>(find.byType(DlmProgressBar));
    expect(bar.value, 0);
  });

  appTest('Retry all failed asks the daemon to retry the failed downloads', (
    tester,
  ) async {
    final h = await openFailed(tester, [
      task('a', status: 'error', error: _error('network')),
    ]);
    await tester.tap(_button('Retry all failed'));
    await settle(tester);
    expect(h.tasks.calls, contains('retryFailed'));
  });

  appTest('Retry all failed is only on the Failed page', (tester) async {
    final h = await pumpApp(tester, tasks: [task('a', status: 'running')]);
    h.container.read(routerProvider).go('/downloads/active');
    await settle(tester);
    expect(_button('Retry all failed'), findsNothing);
  });

  appTest('a seeding torrent can be stopped and marked complete', (
    tester,
  ) async {
    final h = await pumpApp(
      tester,
      tasks: [task('t', status: 'running', engine: 'bt', downloaded: 1000)],
    );
    h.container.read(routerProvider).go('/downloads/active');
    await settle(tester);
    expect(find.text('Seeding'), findsOneWidget);
    await tester.tap(find.byType(DlmProgressBar));
    await settle(tester);
    final stop = find.byWidgetPredicate(
      (w) =>
          w is DlmIconButton &&
          w.semanticLabel == 'Stop seeding and mark complete',
    );
    expect(stop, findsOneWidget);
    await tester.tap(stop);
    await settle(tester);
    expect(h.tasks.calls, contains('stopSeeding t'));
  });

  appTest('a torrent still downloading has no stop-seeding button', (
    tester,
  ) async {
    final h = await pumpApp(
      tester,
      tasks: [task('t', status: 'running', engine: 'bt', downloaded: 300)],
    );
    h.container.read(routerProvider).go('/downloads/active');
    await settle(tester);
    await tester.tap(find.byType(DlmProgressBar));
    await settle(tester);
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is DlmIconButton &&
            w.semanticLabel == 'Stop seeding and mark complete',
      ),
      findsNothing,
    );
  });
}
