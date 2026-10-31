import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../prefs/pref_providers.dart';

import 'local_daemon.dart';

/// Where the app stands with the daemon it talks to.
sealed class ConnectionStatus {
  const ConnectionStatus(this.profile);

  /// The profile being connected to.
  final ConnectionProfile profile;
}

/// Starting the daemon or reaching it.
class Connecting extends ConnectionStatus {
  /// Creates the status.
  const Connecting(super.profile);
}

/// Connected: the rest of the app runs on [session].
class Ready extends ConnectionStatus {
  /// Creates the status.
  const Ready(super.profile, this.session, this.health);

  /// The API and event stream.
  final DlmSession session;

  /// What the daemon reported when connecting.
  final HealthOutputBody health;
}

/// A remote server with a certificate the app has not pinned yet.
class NeedsTrustStatus extends ConnectionStatus {
  /// Creates the status.
  const NeedsTrustStatus(super.profile, this.certificate);

  /// The certificate to show to the user.
  final PresentedCertificate certificate;
}

/// The daemon and the app cannot work together.
class IncompatibleStatus extends ConnectionStatus {
  /// Creates the status.
  const IncompatibleStatus(super.profile, this.compatibility);

  /// Why not.
  final Compatibility compatibility;
}

/// The daemon refused the saved token.
class TokenRejectedStatus extends ConnectionStatus {
  /// Creates the status.
  const TokenRejectedStatus(super.profile);
}

/// The daemon could not be started or reached.
class ConnectionFailedStatus extends ConnectionStatus {
  /// Creates the status.
  const ConnectionFailedStatus(
    super.profile, {
    this.failure,
    this.reason,
    this.certificateChanged = false,
  });

  /// The API failure, when there was one.
  final ApiFailure? failure;

  /// Free text from the supervisor (a crash reason).
  final String? reason;

  /// The pinned certificate no longer matches: a possible attack, shown as such.
  final bool certificateChanged;
}

/// The profiles read at start-up; `main` overrides it, so the profile in use is
/// known before the first connection (a remote one must not start the bundled
/// daemon first).
final initialProfilesProvider = Provider<List<ConnectionProfile>>(
  (ref) => const [ConnectionProfile.local()],
);

/// The saved connection profiles: the bundled daemon first, then the servers
/// the user added.
final profilesProvider = NotifierProvider<Profiles, List<ConnectionProfile>>(
  Profiles.new,
);

/// The profile the app connects to: the one the user chose, the bundled daemon
/// when none was chosen or the chosen one is gone.
final activeProfileProvider = Provider<ConnectionProfile>((ref) {
  final id = ref.watch(activeProfileIdProvider);
  return ref.watch(profilesProvider).where((p) => p.id == id).firstOrNull ??
      const ConnectionProfile.local();
});

/// The saved profiles and the ways to change them.
class Profiles extends Notifier<List<ConnectionProfile>> {
  @override
  List<ConnectionProfile> build() => ref.watch(initialProfilesProvider);

  /// Adds a server and its token, and returns its profile.
  Future<ConnectionProfile> addServer({
    required String name,
    required String url,
    required String token,
  }) async {
    final profile = ConnectionProfile(
      id: 'srv-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      kind: ProfileKind.remote,
      url: url,
    );
    await ref.read(profileStoreProvider).save(profile, token: token);
    state = await ref.read(profileStoreProvider).load();
    return profile;
  }

  /// Removes a server and its token. When it was in use the app goes back to
  /// the bundled daemon.
  Future<void> remove(String id) async {
    if (ref.read(activeProfileIdProvider) == id) {
      await ref
          .read(activeProfileIdProvider.notifier)
          .set(ConnectionProfile.localId);
    }
    await ref.read(profileStoreProvider).delete(id);
    state = await ref.read(profileStoreProvider).load();
  }
}

/// The connection profiles on disk and their tokens.
final profileStoreProvider = Provider<ProfileStore>(
  (ref) => throw StateError('override profileStoreProvider'),
);

/// The bundled daemon.
final localDaemonProvider = Provider<LocalDaemon>(
  (ref) => throw StateError('override localDaemonProvider'),
);

/// Turns a profile into a connection.
final connectorProvider = Provider<ProfileConnector>(
  (ref) => ProfileConnector(),
);

/// The connection to the daemon, and the way to retry or trust a server.
final connectionProvider =
    NotifierProvider<ConnectionController, ConnectionStatus>(
      ConnectionController.new,
    );

/// Connects to the active profile at start-up and on request.
class ConnectionController extends Notifier<ConnectionStatus> {
  var _attempt = 0;
  DlmSession? _session;
  StreamSubscription<DaemonStatus>? _daemonWatch;

  /// The address of the bundled daemon the session was opened to.
  String? _localUrl;

  /// The token the session was opened with.
  String? _usedToken;

  @override
  ConnectionStatus build() {
    ref.onDispose(() {
      _attempt++;
      unawaited(_daemonWatch?.cancel());
      _daemonWatch = null;
      _session?.api.close(force: true);
      _session = null;
    });
    final profile = ref.watch(activeProfileProvider);
    unawaited(Future.microtask(connect));
    return Connecting(profile);
  }

  /// (Re)connects to the active profile.
  Future<void> connect() async {
    final attempt = ++_attempt;
    final profile = ref.read(activeProfileProvider);
    _session?.api.close(force: true);
    _session = null;
    state = Connecting(profile);
    ConnectionStatus result;
    try {
      result = await _open(profile);
    } on Object catch (e) {
      result = ConnectionFailedStatus(profile, reason: '$e');
    }
    if (attempt != _attempt || !ref.mounted) {
      if (result is Ready) result.session.api.close(force: true);
      return;
    }
    if (result case Ready(:final session)) {
      _session = session;
      session.api.onUnauthorized = () => _rejected(session);
    }
    state = result;
  }

  Future<ConnectionStatus> _open(ConnectionProfile profile) async {
    String? localUrl;
    String? localPin;
    String? token;
    if (profile.isLocal) {
      final daemon = ref.read(localDaemonProvider);
      final status = await daemon.ensureRunning();
      final info = status.info;
      if (status.phase != DaemonPhase.running || info == null) {
        return ConnectionFailedStatus(profile, reason: status.reason);
      }
      localUrl = info.url;
      localPin = info.tlsFingerprint;
      _localUrl = info.url;
      _watch(daemon);
      token = daemon.token();
    } else {
      token = await ref.read(profileStoreProvider).token(profile.id);
    }
    _usedToken = token;
    final outcome = await ref
        .read(connectorProvider)
        .connect(profile, token: token, localUrl: localUrl, localPin: localPin);
    return switch (outcome) {
      Connected(:final api, :final health) => Ready(
        profile,
        DlmSession.open(api),
        health,
      ),
      NeedsTrust(:final certificate) => NeedsTrustStatus(profile, certificate),
      Incompatible(:final compatibility) => IncompatibleStatus(
        profile,
        compatibility,
      ),
      TokenRejected() => TokenRejectedStatus(profile),
      ConnectFailed(:final failure, :final certificateChanged) =>
        ConnectionFailedStatus(
          profile,
          failure: failure,
          certificateChanged: certificateChanged,
        ),
    };
  }

  /// The bundled daemon starts on a random port, so every restart (a crash, the
  /// Daemon page, the service being turned on or off) gives it a new address.
  /// The session follows it instead of calling the old one for ever.
  void _watch(LocalDaemon daemon) {
    if (_daemonWatch != null) return;
    _daemonWatch = daemon.status.listen((status) {
      final info = status.info;
      if (status.phase != DaemonPhase.running || info == null) return;
      if (info.url == _localUrl) return;
      _localUrl = info.url;
      unawaited(connect());
    });
  }

  /// The daemon answered 401 to [session]: its token was rotated or revoked
  /// while the app ran. The bundled daemon's new token is read again; for any
  /// other the app says so, instead of reconnecting for ever.
  void _rejected(DlmSession session) {
    if (!ref.mounted || !identical(_session, session)) return;
    final profile = ref.read(activeProfileProvider);
    if (profile.isLocal) {
      final fresh = ref.read(localDaemonProvider).token();
      if (fresh != null && fresh.isNotEmpty && fresh != _usedToken) {
        unawaited(connect());
        return;
      }
    }
    _attempt++;
    session.api.close(force: true);
    _session = null;
    state = TokenRejectedStatus(profile);
  }

  /// Pins [certificate] for the active (remote) profile and connects.
  Future<void> trust(PresentedCertificate certificate) async {
    final profile = ref.read(activeProfileProvider);
    await ref
        .read(profileStoreProvider)
        .save(profile.copyWith(tlsPin: certificate.pin));
    await connect();
  }
}

/// The session of the current connection, for the whole app to use: wired in
/// `main` as the override of [sessionProvider]. Everything that depends on the
/// daemon rebuilds when the connection changes; reading it while not
/// connected is a bug (the gate only shows the app when [Ready]).
final connectedSessionOverride = sessionProvider.overrideWith((ref) {
  final status = ref.watch(connectionProvider);
  if (status is Ready) return status.session;
  throw StateError('no daemon is connected');
});

/// A fresh entity store for every connection, wired in `main` as the override
/// of [taskStoreProvider]: tasks cached from another daemon (or from before a
/// reconnect) must not leak into the new session.
final connectedTaskStoreOverride = taskStoreProvider.overrideWith((ref) {
  ref.watch(sessionProvider);
  final store = TaskStore();
  ref.onDispose(store.dispose);
  return store;
});
