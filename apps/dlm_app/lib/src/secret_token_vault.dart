import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_platform/dlm_platform.dart';

/// Keeps the profile tokens of `dlm_core` in the platform's [SecretStore]. The
/// app is the only place that knows both packages.
class SecretTokenVault implements TokenVault {
  /// Creates the vault.
  const SecretTokenVault(this._store);

  final SecretStore _store;

  static String _key(String profileId) => 'profile.$profileId.token';

  @override
  Future<String?> read(String profileId) => _store.read(_key(profileId));

  @override
  Future<void> write(String profileId, String token) =>
      _store.write(_key(profileId), token);

  @override
  Future<void> delete(String profileId) => _store.delete(_key(profileId));
}
