import 'dart:async';

import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'startup.dart';

/// What the dock, the taskbar and the power lock should show.
class ActivityInput {
  /// Creates an input for [active] downloads. [fraction] is null when the
  /// bar should pulse because a size is unknown.
  const ActivityInput({required this.active, this.fraction});

  /// Creates an idle input: nothing running, progress cleared.
  const ActivityInput.idle() : active = 0, fraction = null;

  /// How many downloads are being worked on.
  final int active;

  /// Combined fraction of the active downloads, from 0 to 1.
  final double? fraction;

  @override
  bool operator ==(Object other) =>
      other is ActivityInput &&
      other.active == active &&
      other.fraction == fraction;

  @override
  int get hashCode => Object.hash(active, fraction);
}

/// The fraction of [slices], or null when one of them has no known size.
/// Empty means there is nothing to measure.
double? combinedProgress(Iterable<({int downloaded, int size})> slices) {
  var got = 0;
  var total = 0;
  var count = 0;
  for (final slice in slices) {
    count++;
    if (slice.size <= 0) return null;
    got += slice.downloaded;
    total += slice.size;
  }
  if (count == 0 || total <= 0) return null;
  return (got / total).clamp(0.0, 1.0);
}

/// The progress of the downloads the store currently calls active.
double? progressOf(TaskStore store) {
  final slices = <({int downloaded, int size})>[];
  for (final id in store.tasks.ids) {
    final task = store.tasks[id];
    if (task == null || !task.statusKind.isActive) continue;
    final live = store.progress[id];
    slices.add((
      downloaded: live?.downloaded ?? task.downloaded,
      size: live?.size ?? task.size,
    ));
  }
  return combinedProgress(slices);
}

/// The power lock. `main` overrides it; tests leave the no-op.
final awakeLockProvider = Provider<AwakeLock>(
  (ref) => const UnsupportedAwakeLock(),
);

/// What the badge and the progress bar should show. Rebuilt when the daemon
/// reports speed, which is about once a second while anything is running.
final activityInputProvider = Provider<ActivityInput>((ref) {
  final speed = ref.watch(systemSpeedProvider);
  final active = speed?.active ?? 0;
  if (active <= 0) return const ActivityInput.idle();
  return ActivityInput(
    active: active,
    fraction: progressOf(ref.read(taskStoreProvider)),
  );
});

/// Applies [activityInputProvider] to the dock or taskbar and the power lock.
/// Draws nothing.
class ActivityBinder extends ConsumerStatefulWidget {
  /// Creates the binder.
  const ActivityBinder({super.key});

  @override
  ConsumerState<ActivityBinder> createState() => _ActivityBinderState();
}

class _ActivityBinderState extends ConsumerState<ActivityBinder> {
  AwakeLock? _awake;

  @override
  void initState() {
    super.initState();
    ref.listenManual(activityInputProvider, (_, next) {
      unawaited(_apply(next));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_apply(ref.read(activityInputProvider)));
    });
  }

  Future<void> _apply(ActivityInput input) async {
    final window = ref.read(windowControlProvider);
    final awake = ref.read(awakeLockProvider);
    _awake = awake;
    if (input.active <= 0) {
      await window.setProgress(-1);
      await window.setBadge('');
      await awake.setAwake(awake: false);
      return;
    }
    await window.setBadge('${input.active}');
    await window.setProgress(input.fraction ?? 2);
    await awake.setAwake(awake: true);
  }

  @override
  void dispose() {
    unawaited(_awake?.setAwake(awake: false));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
