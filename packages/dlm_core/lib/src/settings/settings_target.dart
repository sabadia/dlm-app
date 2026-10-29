import 'package:dlm_api/dlm_api.dart';
import 'package:riverpod/riverpod.dart';

import '../providers.dart';
import 'settings_draft.dart';
import 'settings_repository.dart';

/// Which layer of settings a form edits.
class SettingsTarget {
  /// The global settings.
  const SettingsTarget.global() : level = SettingLevel.global, id = null;

  /// The overrides of the queue [id].
  const SettingsTarget.queue(String this.id) : level = SettingLevel.queue;

  /// The overrides of the task [id].
  const SettingsTarget.task(String this.id) : level = SettingLevel.task;

  /// The level.
  final SettingLevel level;

  /// The queue or task; null for the global layer.
  final String? id;

  @override
  bool operator ==(Object other) =>
      other is SettingsTarget && other.level == level && other.id == id;

  @override
  int get hashCode => Object.hash(level, id);
}

/// What the form of [SettingsTarget] starts from.
final settingsSnapshotProvider = FutureProvider.autoDispose
    .family<SettingsSnapshot, SettingsTarget>((ref, target) async {
      final repo = ref.watch(settingsRepositoryProvider);
      switch (target.level) {
        case SettingLevel.queue:
          final id = target.id!;
          final queues = await ref.watch(queuesProvider.future);
          final queue = queues.firstWhere((q) => q.id == id);
          return SettingsSnapshot.of(
            SettingLevel.queue,
            queue.settings,
            await repo.effectiveForQueue(id),
          );
        case SettingLevel.task:
          final id = target.id!;
          final task =
              ref.watch(taskProvider(id)) ??
              await ref.watch(taskRepositoryProvider).get(id);
          return SettingsSnapshot.of(
            SettingLevel.task,
            task.settings,
            await repo.effectiveForTask(id),
          );
        case SettingLevel.global || SettingLevel.defaults:
          return SettingsSnapshot.global(
            await ref.watch(globalSettingsProvider.future),
          );
      }
    });

/// Saves the edits of [draft] to [target]. A refused save throws the
/// [ApiProblem]; the caller keeps the draft and shows the field errors.
final settingsSaverProvider =
    Provider<Future<void> Function(SettingsTarget, SettingsDraft)>(
      (ref) => (target, draft) async {
        final patch = draft.patch;
        if (patch.isEmpty) return;
        switch (target.level) {
          case SettingLevel.queue:
            await ref
                .read(queuesProvider.notifier)
                .replaceSettings(target.id!, Settings.fromJson(draft.result));
          case SettingLevel.task:
            await ref
                .read(taskRepositoryProvider)
                .update(target.id!, settings: patch)
                .then((t) => ref.read(taskStoreProvider).tasks.put(t.id, t));
          case SettingLevel.global || SettingLevel.defaults:
            await ref.read(globalSettingsProvider.notifier).patch(patch);
        }
        ref.invalidate(settingsSnapshotProvider(target));
      },
    );
