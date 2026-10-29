import 'dart:convert';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/pairing/pairing_dialog.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'daemon_access_test.dart' show FakeDaemon;
import 'support/app_harness.dart';

Pairing _pairing({String id = 'p1', DateTime? expiresAt}) => Pairing(
  browser: 'chrome',
  clientVersion: '0.1.0',
  code: '482913',
  createdAt: DateTime.now(),
  expiresAt: expiresAt ?? DateTime.now().add(const Duration(minutes: 2)),
  id: id,
  name: 'DLM extension',
  status: 'pending',
);

void main() {
  test('names and codes read the way a person says them', () {
    expect(browserName('chrome'), 'Chrome');
    expect(browserName('firefox'), 'Firefox');
    expect(browserName('zen'), 'Zen');
    expect(browserName(''), '');
    expect(spacedCode('482913'), '482 913');
    expect(spacedCode('12'), '12');
  });

  group('pairing prompt', () {
    Future<(AppHarness, FakeDaemon)> open(
      WidgetTester tester,
      List<Pairing> waiting,
    ) async {
      final daemon = FakeDaemon(waiting: waiting);
      final h = await pumpApp(
        tester,
        liveSync: true,
        overrides: [daemonRepositoryProvider.overrideWithValue(daemon)],
      );
      return (h, daemon);
    }

    appTest('a waiting request shows its code and can be allowed', (
      tester,
    ) async {
      final (_, daemon) = await open(tester, [_pairing()]);
      expect(find.text('Allow a browser extension?'), findsOneWidget);
      expect(find.text('482 913'), findsOneWidget);
      await tester.tap(find.widgetWithText(DlmButton, 'Allow'));
      await settle(tester);
      expect(daemon.calls, ['approve p1']);
      expect(find.text('Allow a browser extension?'), findsNothing);
    });

    appTest('a request can be refused', (tester) async {
      final (_, daemon) = await open(tester, [_pairing()]);
      await tester.tap(find.widgetWithText(DlmButton, 'Deny'));
      await settle(tester);
      expect(daemon.calls, ['deny p1']);
      expect(find.text('Allow a browser extension?'), findsNothing);
    });

    appTest('a request answered elsewhere closes the prompt', (tester) async {
      final (h, daemon) = await open(tester, [_pairing()]);
      expect(find.text('Allow a browser extension?'), findsOneWidget);
      h.events.add(
        SseData(
          SseMessage(
            id: 'r1',
            event: 'pairing.resolved',
            data: jsonEncode({
              'id': 2,
              'type': 'pairing.resolved',
              'time': DateTime.now().toUtc().toIso8601String(),
              'data': {'id': 'p1', 'status': 'denied'},
            }),
          ),
        ),
      );
      await settle(tester);
      expect(find.text('Allow a browser extension?'), findsNothing);
      expect(daemon.calls, isEmpty);
    });

    appTest('a request nobody answers closes when it runs out', (tester) async {
      await open(tester, [
        _pairing(
          expiresAt: tester.binding.clock.now().add(const Duration(seconds: 5)),
        ),
      ]);
      expect(find.text('Allow a browser extension?'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
      await settle(tester);
      expect(find.text('Allow a browser extension?'), findsNothing);
    });
  });
}
