import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// The profile the app connects to; defaults to the bundled daemon.
final activeProfileProvider = Provider<ConnectionProfile>(
  (ref) => const ConnectionProfile.local(),
);

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

  @override
  ConnectionStatus build() {
    ref.onDispose(() {
      _attempt++;
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
    if (result is Ready) _session = result.session;
    state = result;
  }

  Future<ConnectionStatus> _open(ConnectionProfile profile) async {
    String? localUrl;
    String? token;
    if (profile.isLocal) {
      final daemon = ref.read(localDaemonProvider);
      final status = await daemon.ensureRunning();
      final info = status.info;
      if (status.phase != DaemonPhase.running || info == null) {
        return ConnectionFailedStatus(profile, reason: status.reason);
      }
      localUrl = info.url;
      token = daemon.token();
    } else {
      token = await ref.read(profileStoreProvider).token(profile.id);
    }
    final outcome = await ref
        .read(connectorProvider)
        .connect(profile, token: token, localUrl: localUrl);
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
