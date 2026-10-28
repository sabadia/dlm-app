import 'package:dlm_api/dlm_api.dart';

/// The API revision this build of the app was written for.
const appApiVersion = 1;

/// The oldest daemon API revision this build still works with.
const oldestDaemonApi = 1;

/// Whether the app and a daemon can work together.
sealed class Compatibility {
  const Compatibility();
}

/// They can.
class Compatible extends Compatibility {
  /// Creates the value.
  const Compatible();
}

/// The daemon needs a newer app (its `minClientApi` is above [appApiVersion]).
class AppTooOld extends Compatibility {
  /// Creates the value.
  const AppTooOld(this.daemonMinClientApi);

  /// What the daemon requires.
  final int daemonMinClientApi;
}

/// The daemon is older than this app supports.
class DaemonTooOld extends Compatibility {
  /// Creates the value.
  const DaemonTooOld(this.daemonApi);

  /// The daemon's API revision.
  final int daemonApi;
}

/// Decides from a daemon's `GET /v1/health`.
Compatibility checkCompatibility(HealthOutputBody health) {
  if (health.minClientApi > appApiVersion) {
    return AppTooOld(health.minClientApi);
  }
  if (health.apiVersion < oldestDaemonApi) {
    return DaemonTooOld(health.apiVersion);
  }
  return const Compatible();
}
