import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  bool supported(String os, [Map<String, String> env = const {}]) =>
      HotkeyManagerGlobalHotkeys(
        operatingSystem: os,
        environment: env,
      ).supported;

  test('macOS and Windows always allow global hotkeys', () {
    expect(supported('macos'), isTrue);
    expect(supported('windows'), isTrue);
  });

  test('Linux allows them on X11 and not on Wayland', () {
    expect(supported('linux', {'XDG_SESSION_TYPE': 'x11'}), isTrue);
    expect(supported('linux', {'XDG_SESSION_TYPE': 'wayland'}), isFalse);
    expect(
      supported('linux', {'WAYLAND_DISPLAY': 'wayland-0'}),
      isFalse,
      reason: 'no session type, only Wayland',
    );
    expect(
      supported('linux', {'WAYLAND_DISPLAY': 'wayland-0', 'DISPLAY': ':0'}),
      isTrue,
      reason: 'XWayland-only hint is not enough to call it Wayland',
    );
    expect(supported('fuchsia'), isFalse);
  });

  test(
    'a chord without a modifier is refused before the system is asked',
    () async {
      final hotkeys = HotkeyManagerGlobalHotkeys(operatingSystem: 'macos');
      final ok = await hotkeys.register(
        'x',
        const GlobalChord(key: LogicalKeyboardKey.keyD),
        () {},
      );
      expect(ok, isFalse);
    },
  );

  test('the unsupported registry accepts nothing', () async {
    const hotkeys = UnsupportedGlobalHotkeys();
    expect(hotkeys.supported, isFalse);
    expect(
      await hotkeys.register(
        'x',
        const GlobalChord(key: LogicalKeyboardKey.keyD, control: true),
        () {},
      ),
      isFalse,
    );
  });
}
