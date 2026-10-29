import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

void main() {
  appTest('the status bar follows the daemon\'s speed reports', (tester) async {
    final h = await pumpApp(tester);
    expect(find.text('↓ 0 B/s  ↑ 0 B/s'), findsOneWidget);
    h.container
        .read(taskStoreProvider)
        .apply(
          StreamEventSystemSpeedEvent(
            data: const SpeedData(
              active: 2,
              down: 1048576,
              queued: 3,
              up: 2048,
            ),
            id: 1,
            queueId: null,
            taskId: null,
            time: DateTime.utc(2026, 10, 29),
            type: SystemSpeedEventType.undefined0,
          ),
        );
    await settle(tester);
    expect(find.text('↓ 1.00 MiB/s  ↑ 2.00 KiB/s'), findsOneWidget);
    expect(find.text('2 active, 3 waiting'), findsOneWidget);
    expect(find.text('Connected'), findsOneWidget);
  });

  appTest('a quota shows how much of it is used', (tester) async {
    await pumpApp(
      tester,
      limits: const LimitsView(
        global: const ScopeLimits(
          configuredSpeedLimit: 0,
          speedLimit: 0,
          quota: const QuotaView(
            bytes: 1 << 30,
            exhausted: false,
            period: 'month',
            used: 1 << 29,
          ),
        ),
        queues: [],
      ),
    );
    expect(find.text('512 MiB of 1.00 GiB'), findsOneWidget);
  });

  appTest('turbo lifts the limit and can be ended', (tester) async {
    final h = await pumpApp(tester);
    final limits = h.container.read(limitsProvider.notifier) as FakeLimits;
    await tester.tap(find.text('Turbo'));
    await settle(tester);
    expect(limits.calls, ['turbo 60']);
    expect(find.text('Turbo on'), findsOneWidget);
    await tester.tap(find.text('Turbo on'));
    await settle(tester);
    expect(limits.calls, ['turbo 60', 'end']);
    expect(find.text('Turbo'), findsOneWidget);
  });

  appTest('pause all and resume all go to the daemon', (tester) async {
    final h = await pumpApp(tester);
    final semantics = tester.ensureSemantics();
    await tester.tap(find.bySemanticsLabel('Pause all'));
    await settle(tester);
    await tester.tap(find.bySemanticsLabel('Resume all'));
    await settle(tester);
    expect(h.tasks.calls, ['pauseAll', 'resumeAll']);
    semantics.dispose();
  });
}
