import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the platform store namespaces keys and round-trips values', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final store = PlatformSecretStore();
    await store.write('profile.nas.token', 'abc');
    expect(await store.read('profile.nas.token'), 'abc');
    expect(
      await const FlutterSecureStorage().read(key: 'dlm.profile.nas.token'),
      'abc',
    );
    await store.delete('profile.nas.token');
    expect(await store.read('profile.nas.token'), isNull);
  });

  test('the memory store behaves the same', () async {
    final store = MemorySecretStore();
    expect(await store.read('k'), isNull);
    await store.write('k', 'v');
    expect(await store.read('k'), 'v');
    await store.delete('k');
    expect(await store.read('k'), isNull);
  });
}
