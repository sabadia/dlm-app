import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A small key-value store for secrets, kept by the operating system:
/// Keychain on macOS, Credential Manager on Windows, libsecret (the Secret
/// Service of GNOME Keyring or KWallet) on Linux.
abstract interface class SecretStore {
  /// The value stored under [key], or null.
  Future<String?> read(String key);

  /// Stores [value] under [key], replacing any previous one.
  Future<void> write(String key, String value);

  /// Removes [key].
  Future<void> delete(String key);
}

/// The [SecretStore] of the platform's secure storage. Keys are prefixed so
/// they never collide with other applications' entries.
class PlatformSecretStore implements SecretStore {
  /// Creates the store; [storage] exists for tests.
  PlatformSecretStore({FlutterSecureStorage? storage, this.prefix = 'dlm.'})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            // The app is not sandboxed and may be unsigned while developing:
            // use the login keychain, not the data-protection keychain that
            // needs a provisioning profile.
            mOptions: MacOsOptions(usesDataProtectionKeychain: false),
          );

  final FlutterSecureStorage _storage;

  /// Prepended to every key.
  final String prefix;

  @override
  Future<String?> read(String key) => _storage.read(key: '$prefix$key');

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: '$prefix$key', value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: '$prefix$key');
}

/// A [SecretStore] in memory, for tests and previews.
class MemorySecretStore implements SecretStore {
  final _values = <String, String>{};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);
}
