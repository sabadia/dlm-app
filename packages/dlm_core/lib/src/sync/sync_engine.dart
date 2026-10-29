import 'dart:async';

import 'package:dlm_api/dlm_api.dart';

import '../tasks/task_store.dart';

/// Connects the daemon's event stream to the cached state.
///
/// Events patch the [TaskStore]. A `reset` (the daemon restarted, or the app
/// fell too far behind) means the cache cannot be trusted: it is emptied and
/// [onReset] runs so the owners refetch what they show.
class SyncEngine {
  /// Creates an engine.
  SyncEngine({
    required this.hub,
    required this.store,
    this.onReset,
    this.onSettingsUpdated,
  });

  /// The event stream.
  final EventHub hub;

  /// The cache to keep current.
  final TaskStore store;

  /// Called after the cache was emptied because of a reset.
  final Future<void> Function()? onReset;

  /// Called when somebody changed the global settings.
  final void Function()? onSettingsUpdated;

  final _connection = StreamController<HubConnectionState>.broadcast();
  final _events = StreamController<StreamEvent>.broadcast();
  StreamSubscription<HubEvent>? _sub;

  /// The connection state, for the status bar.
  Stream<HubConnectionState> get connection => _connection.stream;

  /// The daemon's events, after they were applied to the cache, for screens
  /// that react to one (a queue finishing, a quota running out).
  Stream<StreamEvent> get events => _events.stream;

  /// Starts following the stream.
  void start() {
    if (_sub != null) return;
    _sub = hub.events.listen(_onEvent);
    hub.start();
  }

  /// Stops following; the cache stays as it is.
  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    await hub.stop();
  }

  void _onEvent(HubEvent e) {
    switch (e) {
      case HubStreamEvent(:final event):
        store.apply(event);
        _events.add(event);
        if (event is StreamEventSettingsUpdatedEvent) onSettingsUpdated?.call();
      case HubReset():
        store.clear();
        unawaited(onReset?.call());
      case HubConnection(:final state):
        _connection.add(state);
    }
  }

  /// Stops and releases everything.
  Future<void> dispose() async {
    await stop();
    await _connection.close();
    await _events.close();
  }
}
