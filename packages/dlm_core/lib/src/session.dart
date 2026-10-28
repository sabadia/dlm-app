import 'package:dlm_api/dlm_api.dart';

/// One live connection to a daemon: its API client and its event stream.
class DlmSession {
  /// Creates a session.
  const DlmSession({required this.api, required this.hub});

  /// Opens a session on [api]: the hub reads the event stream through the
  /// same client (same token, same pinned certificate).
  factory DlmSession.open(
    DlmApi api, {
    EventFilter filter = const EventFilter(),
  }) {
    return DlmSession(
      api: api,
      hub: EventHub(open: dioSseOpener(api.dio), filter: filter),
    );
  }

  /// The REST client.
  final DlmApi api;

  /// The event stream (not started until the sync engine starts it).
  final EventHub hub;
}
