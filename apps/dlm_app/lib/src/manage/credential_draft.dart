import 'package:dlm_api/dlm_api.dart';

/// A site login being added or edited, as typed.
class CredentialDraft {
  /// Creates a draft; [from] fills it from an existing login (the password is
  /// never known to the app).
  CredentialDraft({Credential? from})
    : host = from?.host ?? '',
      username = from?.username ?? '',
      scheme = switch (from?.scheme) {
        'basic' => CreateCredentialBodyScheme.basic,
        'digest' => CreateCredentialBodyScheme.digest,
        _ => CreateCredentialBodyScheme.auto,
      },
      isNew = from == null;

  /// Whether this is a login that does not exist yet.
  final bool isNew;

  /// The site the login is for (`example.com`, or `*.example.com`).
  String host;

  /// The user name.
  String username;

  /// The password; empty when editing means "keep the stored one".
  String password = '';

  /// How the login is sent.
  CreateCredentialBodyScheme scheme;

  /// Whether the draft can be saved: a host and a user, and a password for a
  /// new login.
  bool get valid =>
      host.trim().isNotEmpty &&
      username.trim().isNotEmpty &&
      (!isNew || password.isNotEmpty);

  /// The body of a new login.
  CreateCredentialBody toCreate() => CreateCredentialBody(
    host: host.trim(),
    username: username.trim(),
    password: password,
    scheme: scheme,
  );

  /// The body that turns [old] into the draft; only what changed is sent, and
  /// the password only when one was typed.
  UpdateCredentialBody toUpdate(Credential old) => UpdateCredentialBody(
    host: host.trim() == old.host ? null : host.trim(),
    username: username.trim() == old.username ? null : username.trim(),
    password: password.isEmpty ? null : password,
    scheme: scheme.json == old.scheme ? null : _updateScheme(scheme),
  );

  static UpdateCredentialBodyScheme _updateScheme(
    CreateCredentialBodyScheme s,
  ) => switch (s) {
    CreateCredentialBodyScheme.basic => UpdateCredentialBodyScheme.basic,
    CreateCredentialBodyScheme.digest => UpdateCredentialBodyScheme.digest,
    _ => UpdateCredentialBodyScheme.auto,
  };
}
