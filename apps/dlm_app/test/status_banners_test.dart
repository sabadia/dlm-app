import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/bundled_daemon.dart';
import 'package:dlm_app/src/connection/connection_controller.dart';
import 'package:dlm_app/src/shell/status_banners.dart';
import 'package:dlm_platform/dlm_platform.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';
import 'support/fakes.dart';

void main() {
  late StreamController<HubConnectionState> hub;
  late StreamController<DaemonStatus> daemonStatus;
  late FakeDaemon daemon;

  setUp(() {
    hub = StreamController<HubConnectionState>.broadcast();
    daemonStatus = StreamController<DaemonStatus>.broadcast();
    daemon = FakeDaemon();
  });
  tearDown(() async {
    unawaited(hub.close());
    unawaited(daemonStatus.close());
  });

  Future<void> pump(WidgetTester tester) => pumpApp(
    tester,
    tasks: [task('a', name: 'one')],
    overrides: [
      hubStateProvider.overrideWith((ref) => hub.stream),
      daemonStatusProvider.overrideWith((ref) => daemonStatus.stream),
      localDaemonProvider.overrideWithValue(daemon),
    ],
  );

  appTest('no banner while all is well', (tester) async {
    await pump(tester);
    hub.add(HubConnectionState.connected);
    daemonStatus.add(const DaemonStatus(DaemonPhase.running));
    await settle(tester);
    expect(find.byType(DlmBanner), findsNothing);
  });

  appTest('a lost event stream shows a banner until it is back', (
    tester,
  ) async {
    await pump(tester);
    hub.add(HubConnectionState.reconnecting);
    await settle(tester);
    expect(
      find.text('Connection to the download service lost'),
      findsOneWidget,
    );
    hub.add(HubConnectionState.connected);
    await settle(tester);
    expect(find.byType(DlmBanner), findsNothing);
  });

  group('a daemon left over from an older version of the app', () {
    DaemonStatus running(String version, {required bool adopted}) =>
        DaemonStatus(
          DaemonPhase.running,
          adopted: adopted,
          info: RuntimeInfo(
            pid: 1,
            url: 'http://127.0.0.1:1',
            version: version,
          ),
        );

    Future<void> pumpBundled(WidgetTester tester) => pumpApp(
      tester,
      tasks: [task('a', name: 'one')],
      overrides: [
        hubStateProvider.overrideWith((ref) => hub.stream),
        daemonStatusProvider.overrideWith((ref) => daemonStatus.stream),
        localDaemonProvider.overrideWithValue(daemon),
        bundledDaemonVersionProvider.overrideWithValue('0.8.0'),
      ],
    );

    appTest('is named, with a way to restart it into the bundled one', (
      tester,
    ) async {
      await pumpBundled(tester);
      daemonStatus.add(running('0.7.6', adopted: true));
      await settle(tester);
      expect(find.text('The server is older than this app'), findsOneWidget);
      expect(find.textContaining('0.7.6'), findsOneWidget);
      await tester.tap(find.text('Restart the server'));
      await settle(tester);
      expect(daemon.restarts, 1);
    });

    appTest('is not mentioned when it is current, or the app started it', (
      tester,
    ) async {
      await pumpBundled(tester);
      daemonStatus.add(running('0.8.0', adopted: true));
      await settle(tester);
      expect(find.byType(DlmBanner), findsNothing);
      daemonStatus.add(running('0.7.6', adopted: false));
      await settle(tester);
      expect(find.byType(DlmBanner), findsNothing);
    });
  });

  appTest('a restarting daemon says so', (tester) async {
    await pump(tester);
    daemonStatus.add(const DaemonStatus(DaemonPhase.restarting, crashes: 1));
    await settle(tester);
    expect(
      find.text('The download service stopped unexpectedly'),
      findsOneWidget,
    );
    expect(find.text('Restart service'), findsNothing);
  });

  appTest('a daemon that gave up offers a restart with the reason', (
    tester,
  ) async {
    await pump(tester);
    daemonStatus.add(
      const DaemonStatus(DaemonPhase.failed, reason: 'port 17171 is in use'),
    );
    await settle(tester);
    expect(find.text('The download service keeps stopping'), findsOneWidget);
    expect(find.text('port 17171 is in use'), findsOneWidget);
    await tester.tap(find.text('Restart service'));
    await settle(tester);
    expect(daemon.restarts, 1);
  });

  appTest('the daemon banner wins over the stream banner', (tester) async {
    await pump(tester);
    hub.add(HubConnectionState.reconnecting);
    daemonStatus.add(const DaemonStatus(DaemonPhase.restarting));
    await settle(tester);
    expect(find.byType(DlmBanner), findsOneWidget);
    expect(
      find.text('The download service stopped unexpectedly'),
      findsOneWidget,
    );
  });
}
