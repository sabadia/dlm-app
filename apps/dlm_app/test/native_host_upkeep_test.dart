import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/pairing/native_host_upkeep.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'daemon_access_test.dart' show FakeDaemon;
import 'support/app_harness.dart';

void main() {
  appTest('browsers with a registration are registered again', (tester) async {
    final daemon = FakeDaemon(
      hosts: const [
        Result(browser: 'chrome', status: 'installed'),
        Result(browser: 'firefox', status: 'absent'),
      ],
    );
    final h = await pumpApp(
      tester,
      overrides: [daemonRepositoryProvider.overrideWithValue(daemon)],
    );
    final done = await tester.runAsync(
      () => h.container.read(nativeHostUpkeepProvider.future),
    );
    expect(done, ['chrome']);
    expect(daemon.calls, contains('native install [chrome]'));
  });

  appTest('nothing is registered for a browser the user never chose', (
    tester,
  ) async {
    final daemon = FakeDaemon();
    final h = await pumpApp(
      tester,
      overrides: [daemonRepositoryProvider.overrideWithValue(daemon)],
    );
    final done = await tester.runAsync(
      () => h.container.read(nativeHostUpkeepProvider.future),
    );
    expect(done, isEmpty);
    expect(daemon.calls.where((c) => c.startsWith('native')), isEmpty);
  });
}
