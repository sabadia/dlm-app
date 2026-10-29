import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../connection/connection_controller.dart';

/// The browser extensions that asked to be paired and wait for the user.
///
/// The daemon announces a request with `pairing.requested` and ends it with
/// `pairing.resolved` (allowed, refused, or out of time: from this app, the
/// command line or another window). One that started before the app did is
/// fetched when the app connects. Only the daemon of this computer pairs
/// extensions, so a remote profile has none.
class PairingRequests extends Notifier<List<Pairing>> {
  @override
  List<Pairing> build() {
    final sub = ref.watch(syncEngineProvider).events.listen(_onEvent);
    ref.onDispose(sub.cancel);
    if (ref.watch(activeProfileProvider).isLocal) {
      unawaited(_load());
    }
    return const [];
  }

  Future<void> _load() async {
    try {
      final waiting = await ref.read(daemonRepositoryProvider).pairings();
      for (final p in waiting) {
        _add(p);
      }
    } on Object {
      // The app is not an admin of this daemon, or the daemon is old: no
      // prompts, which is what happens without the list anyway.
    }
  }

  void _onEvent(StreamEvent event) {
    switch (event) {
      case StreamEventPairingRequestedEvent(:final data, :final time):
        _add(
          Pairing(
            id: data.id,
            name: data.name,
            browser: data.browser,
            clientId: data.clientId,
            clientVersion: data.clientVersion,
            code: data.code,
            createdAt: time,
            expiresAt: data.expiresAt,
            status: 'pending',
          ),
        );
      case StreamEventPairingResolvedEvent(:final data):
        state = [
          for (final p in state)
            if (p.id != data.id) p,
        ];
      default:
        break;
    }
  }

  void _add(Pairing p) {
    if (state.any((x) => x.id == p.id)) return;
    state = [...state, p];
  }

  /// Drops [id] from the list (answered here).
  void dismiss(String id) {
    state = [
      for (final p in state)
        if (p.id != id) p,
    ];
  }
}

/// The pairing requests waiting for an answer, oldest first.
final pairingRequestsProvider =
    NotifierProvider<PairingRequests, List<Pairing>>(PairingRequests.new);
