import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/platform/activity.dart';
import 'package:dlm_app/src/platform/startup.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';
import 'support/fakes.dart';

void main() {
  test('progress sums known sizes and pulses when one is unknown', () {
    expect(combinedProgress(const []), isNull);
    expect(
      combinedProgress(const [
        (downloaded: 25, size: 100),
        (downloaded: 25, size: 100),
      ]),
      0.25,
    );
    expect(
      combinedProgress(const [
        (downloaded: 10, size: 100),
        (downloaded: 0, size: 0),
      ]),
      isNull,
    );
  });

  test('only active downloads count toward the bar', () {
    final store = TaskStore();
    store.tasks.put(
      'a',
      task('a', status: 'running', size: 100, downloaded: 40),
    );
    store.tasks.put('b', task('b', status: 'paused', size: 100));
    expect(progressOf(store), 0.4);

    store.progress.put(
      'a',
      const ProgressData(connections: 1, downloaded: 80, size: 100, speed: 1),
    );
    expect(progressOf(store), 0.8);
  });

  appTest('an active download badges the dock and stays awake', (tester) async {
    final window = _Window();
    final awake = _Awake();
    await pumpApp(
      tester,
      overrides: [
        windowControlProvider.overrideWithValue(window),
        awakeLockProvider.overrideWithValue(awake),
        activityInputProvider.overrideWithValue(
          const ActivityInput(active: 2, fraction: 0.5),
        ),
      ],
    );
    expect(window.badge, '2');
    expect(window.progress, 0.5);
    expect(awake.awake, isTrue);
  });

  appTest('nothing running clears the badge and allows sleep', (tester) async {
    final window = _Window();
    final awake = _Awake();
    await pumpApp(
      tester,
      overrides: [
        windowControlProvider.overrideWithValue(window),
        awakeLockProvider.overrideWithValue(awake),
        activityInputProvider.overrideWithValue(const ActivityInput.idle()),
      ],
    );
    expect(window.badge, isEmpty);
    expect(window.progress, -1);
    expect(awake.awake, isFalse);
  });
}

class _Window extends UnsupportedWindowControl {
  double? progress;
  String? badge;

  @override
  Future<void> setProgress(double progress) async => this.progress = progress;

  @override
  Future<void> setBadge(String label) async => badge = label;
}

class _Awake implements AwakeLock {
  bool? awake;

  @override
  Future<void> setAwake({required bool awake}) async => this.awake = awake;
}
