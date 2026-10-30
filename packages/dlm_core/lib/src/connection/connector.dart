import 'package:dlm_api/dlm_api.dart';

import 'compatibility.dart';
import 'profile.dart';

/// What [ProfileConnector.connect] found.
sealed class ConnectOutcome {
  const ConnectOutcome();
}

/// Connected and compatible: [api] is ready to use.
class Connected extends ConnectOutcome {
  /// Creates the outcome.
  const Connected(this.api, this.health, this.compatibility);

  /// The client.
  final DlmApi api;

  /// The daemon's health answer.
  final HealthOutputBody health;

  /// Always [Compatible] unless the caller asked to keep incompatible daemons.
  final Compatibility compatibility;
}

/// The remote daemon presents a certificate nobody trusted yet: show
/// [certificate] to the user; on approval save the profile with
/// `tlsPin: certificate.pin` and connect again.
class NeedsTrust extends ConnectOutcome {
  /// Creates the outcome.
  const NeedsTrust(this.certificate);

  /// What the daemon presented.
  final PresentedCertificate certificate;
}

/// The daemon is reachable but the app and it cannot work together.
class Incompatible extends ConnectOutcome {
  /// Creates the outcome.
  const Incompatible(this.compatibility, this.health);

  /// Why.
  final Compatibility compatibility;

  /// The daemon's health answer.
  final HealthOutputBody health;
}

/// The daemon refused the token (or none is stored).
class TokenRejected extends ConnectOutcome {
  /// Creates the outcome.
  const TokenRejected();
}

/// The daemon could not be reached, or the pinned certificate changed.
class ConnectFailed extends ConnectOutcome {
  /// Creates the outcome.
  const ConnectFailed(this.failure, {this.certificateChanged = false});

  /// What went wrong.
  final ApiFailure failure;

  /// Whether the server now presents a different certificate than the pinned
  /// one (a stronger warning than "unreachable").
  final bool certificateChanged;
}

/// Opens connections to daemons described by profiles.
class ProfileConnector {
  /// Creates a connector. [fetchCertificate] and [createApi] exist for tests.
  ProfileConnector({
    this.userAgent = 'dlm-app',
    Future<PresentedCertificate> Function(String host, int port)?
    fetchCertificate,
    DlmApi Function(DlmEndpoint endpoint)? createApi,
  }) : _fetch = fetchCertificate ?? _defaultFetch,
       _createApi = createApi ?? DlmApi.new;

  /// `User-Agent` of the connections.
  final String userAgent;

  final Future<PresentedCertificate> Function(String, int) _fetch;
  final DlmApi Function(DlmEndpoint) _createApi;

  static Future<PresentedCertificate> _defaultFetch(String host, int port) =>
      fetchCertificate(host, port);

  /// Connects to [profile] with [token]. For the local profile [localUrl] is
  /// where the supervisor says the daemon listens.
  Future<ConnectOutcome> connect(
    ConnectionProfile profile, {
    String? token,
    String? localUrl,
    String? localPin,
  }) async {
    final baseUrl = profile.isLocal ? localUrl : profile.url;
    final uri = baseUrl == null ? null : Uri.tryParse(baseUrl);
    if (uri == null || !uri.hasAuthority || uri.host.isEmpty) {
      return const ConnectFailed(
        ApiConnectionFailure('the daemon address is not valid'),
      );
    }

    var pinned = false;
    if (!profile.isLocal && uri.scheme == 'https') {
      final pin = profile.tlsPin;
      if (pin == null) {
        try {
          return NeedsTrust(await _fetch(uri.host, uri.port));
        } on Object catch (e) {
          return ConnectFailed(ApiConnectionFailure('$e'));
        }
      }
      pinned = true;
    }

    // The bundled daemon with a certificate of its own: it published the
    // fingerprint, and that is the one certificate to trust.
    final pin = pinned
        ? profile.tlsPin
        : (profile.isLocal && uri.scheme == 'https' ? localPin : null);
    final api = _createApi(
      pin != null
          ? DlmEndpoint.pinned(
              baseUrl: baseUrl!,
              pin: pin,
              token: token,
              userAgent: userAgent,
            )
          : DlmEndpoint(baseUrl: baseUrl!, token: token, userAgent: userAgent),
    );
    try {
      final health = await guard(() => api.rest.system.getHealth());
      final compatibility = checkCompatibility(health);
      if (compatibility is! Compatible) {
        api.close(force: true);
        return Incompatible(compatibility, health);
      }
      // No token counts too: the app would open and every call would then
      // answer 401.
      if (!health.authenticated) {
        api.close(force: true);
        return const TokenRejected();
      }
      return Connected(api, health, compatibility);
    } on ApiFailure catch (e) {
      api.close(force: true);
      return ConnectFailed(
        e,
        certificateChanged:
            profile.tlsPin != null &&
            e is ApiConnectionFailure &&
            e.message.contains('certificate'),
      );
    }
  }
}
