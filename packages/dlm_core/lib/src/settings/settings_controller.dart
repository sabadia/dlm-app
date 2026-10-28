import 'package:dlm_api/dlm_api.dart';
import 'package:riverpod/riverpod.dart';

import '../providers.dart';
import 'settings_repository.dart';

/// The global settings: loaded once, changed by merge patches that carry the
/// version they were based on.
class GlobalSettingsController extends AsyncNotifier<GlobalSettings> {
  @override
  Future<GlobalSettings> build() =>
      ref.watch(settingsRepositoryProvider).load();

  /// Changes settings. [mergePatch] is an RFC 7396 document; `null` values
  /// unset a field (it inherits the default again).
  ///
  /// When somebody else changed the settings since they were read, the
  /// daemon answers 412 (`settings.changed`): the newest settings are loaded
  /// and the [ApiProblem] is rethrown, so the caller can show what changed and
  /// let the user decide.
  Future<void> patch(Map<String, Object?> mergePatch) async {
    final current = state.requireValue;
    final repo = ref.read(settingsRepositoryProvider);
    try {
      final next = await repo.patch(mergePatch, etag: current.etag);
      state = AsyncData(next);
    } on ApiProblem catch (e) {
      if (e.isPreconditionFailed) {
        state = AsyncData(await repo.load());
      }
      rethrow;
    }
  }

  /// Reads the settings again (after a `settings.updated` event).
  Future<void> reload() async {
    state = AsyncData(await ref.read(settingsRepositoryProvider).load());
  }
}
