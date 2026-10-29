import 'package:dlm_api/dlm_api.dart';

/// The daemon's boot configuration as `GET /v1/config` answers it (the
/// generated model is called `View`, which clashes with Flutter's widget).
typedef ConfigView = View;

/// What the app asks of the daemon about itself: its boot configuration and
/// restart, its log, who may use it (tokens), the browser extension's native
/// host, and the extensions that ask to be paired.
abstract interface class DaemonRepository {
  /// The effective boot configuration with the source of every value.
  Future<ConfigView> config();

  /// Changes boot configuration values (`null` unsets one). They take effect
  /// after a restart; the answer says which are pending.
  Future<ConfigView> updateConfig(Map<String, Object?> values);

  /// Stops the daemon and starts it again.
  Future<void> restart();

  /// The latest log records (at least [level], containing [q]).
  Future<LogList> logs({Level? level, String? q});

  /// Who the app's token says it is: its name and scope.
  Future<WhoAmI> whoami();

  /// The named tokens (never their secrets).
  Future<List<Token>> tokens();

  /// Creates a named token; the secret is in the answer, once.
  Future<CreatedToken> createToken(String name, CreateTokenBodyScope scope);

  /// Revokes a named token.
  Future<void> deleteToken(String id);

  /// Replaces the primary token; the new secret is in the answer, once.
  Future<CreatedToken> rotateToken();

  /// Whether the extension's native host is registered, per browser.
  Future<NativeHostStatus> nativeHost();

  /// Registers or removes the native host for [browsers] (all when empty).
  Future<List<Result>> updateNativeHost(
    NativeHostRequestAction action, {
    List<String> extensionIds = const [],
    List<String> firefoxIds = const [],
    List<String> browsers = const [],
  });

  /// The browser extensions waiting for the user to allow or refuse them.
  Future<List<Pairing>> pairings();

  /// Allows a pairing: the extension is issued a token of its own.
  Future<Pairing> approvePairing(String id);

  /// Refuses a pairing.
  Future<Pairing> denyPairing(String id);
}

/// The REST implementation.
class ApiDaemonRepository implements DaemonRepository {
  /// Creates the repository over [api].
  ApiDaemonRepository(DlmApi api) : _rest = api.rest;

  final RestClient _rest;

  @override
  Future<ConfigView> config() => guard(_rest.config.getConfig);

  @override
  Future<ConfigView> updateConfig(Map<String, Object?> values) => guard(
    () => _rest.config.updateConfig(body: UpdateConfigBody(values: values)),
  );

  @override
  Future<void> restart() => guard(_rest.system.restartDaemon);

  @override
  Future<LogList> logs({Level? level, String? q}) =>
      guard(() => _rest.logs.getLogs(level: level, q: q));

  @override
  Future<WhoAmI> whoami() => guard(_rest.auth.whoami);

  @override
  Future<List<Token>> tokens() async =>
      (await guard(_rest.auth.listTokens)).tokens ?? const [];

  @override
  Future<CreatedToken> createToken(String name, CreateTokenBodyScope scope) =>
      guard(
        () => _rest.auth.createToken(
          body: CreateTokenBody(name: name, scope: scope),
        ),
      );

  @override
  Future<void> deleteToken(String id) =>
      guard(() => _rest.auth.deleteToken(id: id));

  @override
  Future<CreatedToken> rotateToken() => guard(_rest.auth.rotateToken);

  @override
  Future<NativeHostStatus> nativeHost() =>
      guard(_rest.nativeHost.getNativeHost);

  @override
  Future<List<Result>> updateNativeHost(
    NativeHostRequestAction action, {
    List<String> extensionIds = const [],
    List<String> firefoxIds = const [],
    List<String> browsers = const [],
  }) async {
    final out = await guard(
      () => _rest.nativeHost.updateNativeHost(
        body: NativeHostRequest(
          action: action,
          extensionIds: extensionIds.isEmpty ? null : extensionIds,
          firefoxIds: firefoxIds.isEmpty ? null : firefoxIds,
          browsers: browsers.isEmpty ? null : browsers,
        ),
      ),
    );
    return out ?? const [];
  }

  @override
  Future<List<Pairing>> pairings() async =>
      (await guard(_rest.pairing.listPairings)).pairings ?? const [];

  @override
  Future<Pairing> approvePairing(String id) =>
      guard(() => _rest.pairing.approvePairing(id: id));

  @override
  Future<Pairing> denyPairing(String id) =>
      guard(() => _rest.pairing.denyPairing(id: id));
}
