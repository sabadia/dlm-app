import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:dlm_app/src/platform/startup.dart';
import 'package:dlm_app/src/platform/window_placement.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

void main() {
  const home = Rect.fromLTWH(0, 0, 1440, 900);
  const side = Rect.fromLTWH(1440, 0, 1920, 1080);

  test('a window on a second display stays there', () {
    const saved = WindowState(
      x: 1500,
      y: 40,
      width: 800,
      height: 600,
      maximized: true,
    );
    expect(placeWindow(saved, const [home, side]), saved);
  });

  test('a window whose display is gone is fitted onto the first', () {
    const saved = WindowState(x: 4000, y: -2000, width: 2000, height: 400);
    final placed = placeWindow(saved, const [home]);
    expect(placed.maximized, isFalse);
    expect(placed.width, home.width);
    expect(placed.x, 0);
    expect(placed.y, greaterThanOrEqualTo(0));
    expect(placed.y + placed.height, lessThanOrEqualTo(home.bottom));
  });

  appTest('the saved frame is restored, and a move is written back', (
    tester,
  ) async {
    final dir = Directory.systemTemp.createTempSync('dlm_window');
    addTearDown(() => dir.deleteSync(recursive: true));
    final prefs = (await tester.runAsync(() async {
      final store = await PreferencesStore.open(
        File('${dir.path}/preferences.json'),
      );
      await store.set(UiPrefs.onboardingDone, true);
      await store.set(
        UiPrefs.windowState,
        const WindowState(x: 1500, y: 40, width: 800, height: 600),
      );
      return store;
    }))!;
    final window = _FrameWindow();
    addTearDown(window.moved.close);
    await pumpApp(
      tester,
      preferences: prefs,
      overrides: [windowControlProvider.overrideWithValue(window)],
    );
    expect(window.placed?.x, 1500);
    expect(window.placed?.maximized, isFalse);

    window.frame = (x: 20, y: 30, width: 700, height: 500, maximized: false);
    window.moved.add(null);
    await tester.pump(const Duration(milliseconds: 400));
    final again = prefs.get(UiPrefs.windowState);
    expect(again?.x, 20);
    expect(again?.width, 700);
  });
}

class _FrameWindow extends UnsupportedWindowControl {
  // Closed by the test after the binder has stopped listening.
  // ignore: close_sinks
  final moved = StreamController<void>.broadcast();
  ({double x, double y, double width, double height, bool maximized})? placed;
  ({double x, double y, double width, double height, bool maximized}) frame = (
    x: 0,
    y: 0,
    width: 1,
    height: 1,
    maximized: false,
  );

  @override
  Stream<void> get frameChanged => moved.stream;

  @override
  Future<List<Rect>> displays() async => const [
    Rect.fromLTWH(0, 0, 1440, 900),
    Rect.fromLTWH(1440, 0, 1920, 1080),
  ];

  @override
  Future<void> place({
    required double x,
    required double y,
    required double width,
    required double height,
    required bool maximized,
  }) async {
    placed = (x: x, y: y, width: width, height: height, maximized: maximized);
  }

  @override
  Future<({double x, double y, double width, double height, bool maximized})?>
  readFrame() async => frame;
}
