import 'package:dlm_app/src/secret_token_vault.dart';
import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tokens are stored per profile in the secret store', () async {
    final secrets = MemorySecretStore();
    final vault = SecretTokenVault(secrets);
    await vault.write('nas', 'tok');
    expect(await vault.read('nas'), 'tok');
    expect(await secrets.read('profile.nas.token'), 'tok');
    expect(await vault.read('other'), isNull);
    await vault.delete('nas');
    expect(await secrets.read('profile.nas.token'), isNull);
  });
}
