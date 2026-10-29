import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:riverpod/riverpod.dart';

import '../providers.dart';

/// The total speed and the numbers of active and queued tasks, as the daemon
/// last reported them (null before the first report).
class SystemSpeed extends Notifier<SpeedData?> {
  @override
  SpeedData? build() {
    final store = ref.watch(taskStoreProvider);
    final sub = store.speedChanged.listen((s) => state = s);
    ref.onDispose(() => unawaited(sub.cancel()));
    return store.speed;
  }
}

/// The live total speed.
final systemSpeedProvider = NotifierProvider<SystemSpeed, SpeedData?>(
  SystemSpeed.new,
);

/// The speed limits and quotas in force, read again whenever the daemon says
/// they changed.
class LimitsController extends AsyncNotifier<LimitsView> {
  @override
  Future<LimitsView> build() async {
    final store = ref.watch(taskStoreProvider);
    final sub = store.limitsChanged.listen((_) => ref.invalidateSelf());
    ref.onDispose(() => unawaited(sub.cancel()));
    return guard(ref.watch(apiProvider).rest.settings.getLimits);
  }

  SettingsClient get _client => ref.read(apiProvider).rest.settings;

  /// Lifts the speed limit for [minutes] ("turbo").
  Future<void> turbo(int minutes) async {
    state = AsyncData(
      await guard(
        () => _client.setLimitsOverride(
          body: OverrideLimitsBody(minutes: minutes, speedLimit: 0),
        ),
      ),
    );
  }

  /// Ends the temporary override at once.
  Future<void> endTurbo() async {
    state = AsyncData(await guard(_client.clearLimitsOverride));
  }
}

/// The speed limits and quotas.
final limitsProvider = AsyncNotifierProvider<LimitsController, LimitsView>(
  LimitsController.new,
);
