import 'dart:async';
import 'dart:ui';

import 'package:dlm_app/src/appearance.dart';
import 'package:dlm_app/src/skin_registry.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_platform/dlm_platform.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter_test/flutter_test.dart';

class _Reader implements SystemAppearanceReader {
  _Reader(this.initial);
  SystemAppearance initial;
  final StreamController<SystemAppearance> controller =
      StreamController<SystemAppearance>.broadcast();
  bool disposed = false;

  @override
  Future<SystemAppearance> read() async => initial;

  @override
  Stream<SystemAppearance> get changes => controller.stream;

  @override
  void dispose() {
    disposed = true;
    unawaited(controller.close());
  }
}

void main() {
  group('PlatformAppearanceSource.merge', () {
    test('the reader wins for brightness and accent', () {
      final a = PlatformAppearanceSource.merge(
        const DlmAppearance(),
        const SystemAppearance(
          brightness: Brightness.dark,
          accent: Color(0xFF123456),
        ),
      );
      expect(a.brightness, Brightness.dark);
      expect(a.accent, const Color(0xFF123456));
    });

    test('Flutter fills in what the reader does not report', () {
      final a = PlatformAppearanceSource.merge(
        const DlmAppearance(brightness: Brightness.dark, textScale: 1.25),
        SystemAppearance.none,
      );
      expect(a.brightness, Brightness.dark);
      expect(a.textScale, 1.25);
      expect(a.accent, isNull);
    });

    test('flags are on if either side says so', () {
      final a = PlatformAppearanceSource.merge(
        const DlmAppearance(reduceMotion: true),
        const SystemAppearance(highContrast: true, reduceTransparency: true),
      );
      expect(a.highContrast, isTrue);
      expect(a.reduceMotion, isTrue);
      expect(a.reduceTransparency, isTrue);
    });
  });

  group('PlatformAppearanceSource', () {
    test('applies the first reading and pushes later changes', () async {
      final reader = _Reader(const SystemAppearance(accent: Color(0xFFFF0000)));
      final source = PlatformAppearanceSource(
        flutter: const FixedAppearanceSource(),
        system: reader,
      );
      addTearDown(source.dispose);
      final seen = <DlmAppearance>[];
      final sub = source.changes.listen(seen.add);
      addTearDown(sub.cancel);
      await Future<void>.delayed(Duration.zero);
      expect(source.current.accent, const Color(0xFFFF0000));
      expect(seen.last.accent, const Color(0xFFFF0000));
      reader.controller.add(
        const SystemAppearance(brightness: Brightness.dark),
      );
      await Future<void>.delayed(Duration.zero);
      expect(seen.last.brightness, Brightness.dark);
      expect(seen.last.accent, isNull);
    });

    test('an unchanged reading is not pushed twice', () async {
      final reader = _Reader(SystemAppearance.none);
      final source = PlatformAppearanceSource(
        flutter: const FixedAppearanceSource(),
        system: reader,
      );
      addTearDown(source.dispose);
      final seen = <DlmAppearance>[];
      final sub = source.changes.listen(seen.add);
      addTearDown(sub.cancel);
      reader.controller
        ..add(SystemAppearance.none)
        ..add(SystemAppearance.none);
      await Future<void>.delayed(Duration.zero);
      expect(seen.length, lessThanOrEqualTo(1));
    });

    test('dispose releases the reader', () async {
      final reader = _Reader(SystemAppearance.none);
      PlatformAppearanceSource(
        flutter: const FixedAppearanceSource(),
        system: reader,
      ).dispose();
      expect(reader.disposed, isTrue);
    });
  });

  group('appearanceOverrideFor', () {
    test('maps the preferences', () {
      final o = appearanceOverrideFor(
        theme: ThemeChoice.dark,
        density: Density.compact,
        accent: const Color(0xFF00FF00),
        textScale: 1.5,
      );
      expect(o.mode, DlmThemeMode.dark);
      expect(o.density, DlmDensity.compact);
      expect(o.accent, const Color(0xFF00FF00));
      expect(o.textScale, 1.5);
    });

    test('system and comfortable are the defaults', () {
      final o = appearanceOverrideFor(
        theme: ThemeChoice.system,
        density: Density.comfortable,
      );
      expect(o.mode, DlmThemeMode.native);
      expect(o.density, DlmDensity.regular);
    });
  });

  group('skin choice', () {
    test('each platform gets the skin that fits it', () {
      expect(defaultSkinId(TargetPlatform.macOS), 'macos');
      expect(defaultSkinId(TargetPlatform.windows), 'fluent');
      expect(defaultSkinId(TargetPlatform.linux), 'adwaita');
      expect(
        defaultSkinId(TargetPlatform.linux, desktops: ['ubuntu', 'GNOME']),
        'adwaita',
      );
      expect(defaultSkinId(TargetPlatform.linux, desktops: ['KDE']), 'breeze');
    });

    test('an override wins when it names a real skin', () {
      expect(pickSkin('fluent', TargetPlatform.macOS).id, 'fluent');
    });

    test('an unknown override falls back to the platform skin', () {
      expect(pickSkin('nope', TargetPlatform.windows).id, 'fluent');
      expect(pickSkin(null, TargetPlatform.macOS).id, 'macos');
    });

    test('every registered skin id matches its map key', () {
      for (final MapEntry(:key, :value) in skins.entries) {
        expect(value.id, key);
      }
      expect(skinIds, ['macos', 'fluent', 'adwaita', 'breeze']);
    });
  });
}
