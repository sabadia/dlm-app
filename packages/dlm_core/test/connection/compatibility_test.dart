import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:test/test.dart';

HealthOutputBody health(int api, int min) => HealthOutputBody(
  apiVersion: api,
  authenticated: true,
  minClientApi: min,
  status: HealthOutputBodyStatus.ok,
  version: 'x',
);

void main() {
  test('compatible when the daemon accepts this app and is recent enough', () {
    expect(checkCompatibility(health(appApiVersion, 1)), isA<Compatible>());
    expect(checkCompatibility(health(appApiVersion + 3, 1)), isA<Compatible>());
  });

  test('the app is too old when the daemon requires a newer client', () {
    final c = checkCompatibility(health(appApiVersion + 1, appApiVersion + 1));
    expect(c, isA<AppTooOld>());
  });

  test('the daemon is too old below the supported API', () {
    expect(
      checkCompatibility(health(oldestDaemonApi - 1, 0)),
      isA<DaemonTooOld>(),
    );
  });
}
