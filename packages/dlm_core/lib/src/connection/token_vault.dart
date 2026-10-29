/// Where API tokens are kept. The app backs it with the operating system's
/// secure storage (Keychain, Credential Manager, libsecret); tokens never go
/// to preferences, logs or the profile file.
abstract interface class TokenVault {
  /// The token stored for [profileId], or null.
  Future<String?> read(String profileId);

  /// Stores (replaces) the token of [profileId].
  Future<void> write(String profileId, String token);

  /// Forgets the token of [profileId].
  Future<void> delete(String profileId);
}

/// A vault in memory, for tests and previews.
class MemoryTokenVault implements TokenVault {
  final _tokens = <String, String>{};

  @override
  Future<String?> read(String profileId) async => _tokens[profileId];

  @override
  Future<void> write(String profileId, String token) async {
    _tokens[profileId] = token;
  }

  @override
  Future<void> delete(String profileId) async {
    _tokens.remove(profileId);
  }
}
