import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveAppearance', () {
    const system = DlmAppearance(
      brightness: Brightness.dark,
      contrast: DlmContrast.high,
      accent: Color(0xFF123456),
      reduceMotion: true,
      reduceTransparency: true,
      textScale: 1.25,
    );

    test('follows the system without overrides', () {
      expect(resolveAppearance(system, AppearanceOverride.none), system);
    });

    test('forces light or dark but keeps the rest of the system', () {
      final light = resolveAppearance(
        system,
        const AppearanceOverride(mode: DlmThemeMode.light),
      );
      expect(light.brightness, Brightness.light);
      expect(light.contrast, DlmContrast.high);
      final dark = resolveAppearance(
        const DlmAppearance(),
        const AppearanceOverride(mode: DlmThemeMode.dark),
      );
      expect(dark.brightness, Brightness.dark);
    });

    test('the user accent wins over the system accent', () {
      final a = resolveAppearance(
        system,
        const AppearanceOverride(accent: Color(0xFFFF0000)),
      );
      expect(a.accent, const Color(0xFFFF0000));
    });

    test('text scale multiplies the system scale', () {
      final a = resolveAppearance(
        system,
        const AppearanceOverride(textScale: 2),
      );
      expect(a.textScale, 2.5);
    });

    test('reduce motion can be forced either way', () {
      expect(
        resolveAppearance(
          const DlmAppearance(),
          const AppearanceOverride(reduceMotion: true),
        ).reduceMotion,
        isTrue,
      );
      expect(
        resolveAppearance(
          system,
          const AppearanceOverride(reduceMotion: false),
        ).reduceMotion,
        isFalse,
      );
    });

    test('reduce transparency and contrast are never overridden', () {
      final a = resolveAppearance(
        system,
        const AppearanceOverride(mode: DlmThemeMode.light),
      );
      expect(a.reduceTransparency, isTrue);
      expect(a.contrast, DlmContrast.high);
    });
  });

  test('copyWith replaces only the given fields', () {
    const base = DlmAppearance(textScale: 2);
    final next = base.copyWith(brightness: Brightness.dark);
    expect(next.brightness, Brightness.dark);
    expect(next.textScale, 2);
  });

  group('ManualAppearanceSource', () {
    test('emits only real changes', () async {
      final source = ManualAppearanceSource();
      final seen = <DlmAppearance>[];
      final sub = source.changes.listen(seen.add);
      source
        ..update(const DlmAppearance())
        ..update(const DlmAppearance(brightness: Brightness.dark))
        ..update(const DlmAppearance(brightness: Brightness.dark));
      expect(seen, [const DlmAppearance(brightness: Brightness.dark)]);
      expect(source.current.brightness, Brightness.dark);
      await sub.cancel();
      source.dispose();
    });
  });

  group('FlutterAppearanceSource', () {
    testWidgets('reads the platform and follows changes', (tester) async {
      final dispatcher = tester.platformDispatcher;
      addTearDown(dispatcher.clearAllTestValues);
      dispatcher.platformBrightnessTestValue = Brightness.dark;

      final source = FlutterAppearanceSource(
        dispatcher: dispatcher,
        binding: tester.binding,
      );
      addTearDown(source.dispose);
      expect(source.current.brightness, Brightness.dark);
      expect(source.current.contrast, DlmContrast.standard);

      final seen = <DlmAppearance>[];
      final sub = source.changes.listen(seen.add);
      addTearDown(sub.cancel);

      dispatcher.platformBrightnessTestValue = Brightness.light;
      await tester.pump();
      dispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(
            highContrast: true,
            disableAnimations: true,
          );
      await tester.pump();
      dispatcher.textScaleFactorTestValue = 1.5;
      await tester.pump();

      expect(seen.last.brightness, Brightness.light);
      expect(seen.last.contrast, DlmContrast.high);
      expect(seen.last.reduceMotion, isTrue);
      expect(seen.last.textScale, 1.5);
    });

    testWidgets('stops listening after dispose', (tester) async {
      final dispatcher = tester.platformDispatcher;
      addTearDown(dispatcher.clearAllTestValues);
      final source = FlutterAppearanceSource(
        dispatcher: dispatcher,
        binding: tester.binding,
      )..dispose();
      dispatcher.platformBrightnessTestValue = Brightness.dark;
      await tester.pump();
      expect(source.current.brightness, isNot(Brightness.dark));
    });
  });

  test('FixedAppearanceSource never changes', () async {
    const source = FixedAppearanceSource(DlmAppearance(textScale: 3));
    expect(source.current.textScale, 3);
    expect(await source.changes.isEmpty, isTrue);
  });
}
