import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter_test/flutter_test.dart';

const _breezeDark = '''
[ColorEffects:Disabled]
Color=56,56,56

[Colors:Window]
BackgroundAlternate=49,54,59
BackgroundNormal=35,38,41
ForegroundNormal=252,252,252

[Colors:Selection]
BackgroundNormal=61,174,233

[General]
AccentColor=146,81,219
ColorScheme=BreezeDark
font=Noto Sans,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1

[KDE]
AnimationDurationFactor=0
widgetStyle=Breeze
''';

class _FakePortal implements PortalSettings {
  final Map<String, Object?> values = {};
  final StreamController<({String namespace, String key})> _changed =
      StreamController<({String namespace, String key})>.broadcast();
  bool closed = false;

  @override
  Future<Object?> read(String namespace, String key) async =>
      values['$namespace/$key'];

  @override
  Stream<({String namespace, String key})> get changed => _changed.stream;

  void change(String namespace, String key, Object? value) {
    values['$namespace/$key'] = value;
    _changed.add((namespace: namespace, key: key));
  }

  @override
  Future<void> close() async => closed = true;
}

class _FakeRegistry implements UserRegistry {
  final Map<String, int> ints = {};
  final Map<String, String> strings = {};

  @override
  int? readInt(String path, String name) => ints['$path|$name'];

  @override
  String? readString(String path, String name) => strings['$path|$name'];
}

void main() {
  group('parseKdeglobals', () {
    test('reads accent, scheme, animations and font', () {
      final a = parseKdeglobals(_breezeDark);
      expect(a.accent, const Color(0xFF9251DB));
      expect(a.brightness, Brightness.dark);
      expect(a.reduceMotion, isTrue);
      expect(a.fontFamily, 'Noto Sans');
      expect(a.fontPointSize, 11);
    });

    test('falls back to the selection colour without an AccentColor', () {
      final a = parseKdeglobals(
        '[Colors:Selection]\nBackgroundNormal=61,174,233\n'
        '[Colors:Window]\nBackgroundNormal=239,240,241\n',
      );
      expect(a.accent, const Color(0xFF3DAEE9));
      expect(a.brightness, Brightness.light);
      expect(a.reduceMotion, isFalse);
    });

    test('ignores comments, junk and out-of-range values', () {
      final a = parseKdeglobals(
        '# comment\n[General]\nAccentColor=999,0,0\nfont=\njunk\n'
        '[KDE]\nAnimationDurationFactor=abc\n',
      );
      expect(a.accent, isNull);
      expect(a.fontFamily, isNull);
      expect(a.reduceMotion, isFalse);
    });

    test('an empty file reports nothing', () {
      expect(parseKdeglobals(''), SystemAppearance.none);
    });

    test('a non-zero animation factor keeps motion', () {
      expect(
        parseKdeglobals('[KDE]\nAnimationDurationFactor=0.5\n').reduceMotion,
        isFalse,
      );
    });
  });

  group('KdeAppearanceReader', () {
    late Directory dir;
    late File file;
    setUp(() {
      dir = Directory.systemTemp.createTempSync('kdeglobals');
      file = File('${dir.path}/kdeglobals');
    });
    tearDown(() => dir.deleteSync(recursive: true));

    test('reads the file', () async {
      file.writeAsStringSync(_breezeDark);
      final reader = KdeAppearanceReader(file: file);
      addTearDown(reader.dispose);
      expect((await reader.read()).accent, const Color(0xFF9251DB));
    });

    test('a missing file reads as nothing', () async {
      final reader = KdeAppearanceReader(file: File('${dir.path}/absent'));
      addTearDown(reader.dispose);
      expect(await reader.read(), SystemAppearance.none);
    });

    test('a change to the file is pushed', () async {
      file.writeAsStringSync(_breezeDark);
      final reader = KdeAppearanceReader(
        file: file,
        debounce: const Duration(milliseconds: 20),
      );
      addTearDown(reader.dispose);
      await reader.read();
      final next = reader.changes.first;
      await Future<void>.delayed(const Duration(milliseconds: 50));
      file.writeAsStringSync(
        _breezeDark.replaceFirst('146,81,219', '10,20,30'),
      );
      final a = await next.timeout(const Duration(seconds: 5));
      expect(a.accent, const Color(0xFF0A141E));
    });
  });

  group('PortalAppearanceReader', () {
    const ns = 'org.freedesktop.appearance';

    test('maps colour scheme, accent and contrast', () async {
      final portal = _FakePortal()
        ..values['$ns/color-scheme'] = 1
        ..values['$ns/accent-color'] = [0.2, 0.4, 1.0]
        ..values['$ns/contrast'] = 1;
      final reader = PortalAppearanceReader(portal);
      addTearDown(reader.dispose);
      final a = await reader.read();
      expect(a.brightness, Brightness.dark);
      expect(a.accent, const Color(0xFF3366FF));
      expect(a.highContrast, isTrue);
    });

    test('light, no-preference and unset values', () async {
      final portal = _FakePortal()..values['$ns/color-scheme'] = 2;
      final reader = PortalAppearanceReader(portal);
      addTearDown(reader.dispose);
      expect((await reader.read()).brightness, Brightness.light);
      portal.values['$ns/color-scheme'] = 0;
      expect((await reader.read()).brightness, isNull);
      expect((await reader.read()).highContrast, isFalse);
    });

    test('an out-of-range accent means no accent', () async {
      final portal = _FakePortal()
        ..values['$ns/accent-color'] = [-1.0, 0.5, 0.5];
      final reader = PortalAppearanceReader(portal);
      addTearDown(reader.dispose);
      expect((await reader.read()).accent, isNull);
    });

    test('a portal without the keys reports nothing', () async {
      final reader = PortalAppearanceReader(_FakePortal());
      addTearDown(reader.dispose);
      expect(await reader.read(), SystemAppearance.none);
    });

    test(
      'a change in the appearance namespace is pushed, others are ignored',
      () async {
        final portal = _FakePortal()..values['$ns/color-scheme'] = 2;
        final reader = PortalAppearanceReader(portal);
        addTearDown(reader.dispose);
        await reader.read();
        final seen = <SystemAppearance>[];
        final sub = reader.changes.listen(seen.add);
        addTearDown(sub.cancel);
        portal
          ..change('org.gnome.desktop.interface', 'font-name', 'x')
          ..change(ns, 'color-scheme', 1);
        await Future<void>.delayed(const Duration(milliseconds: 20));
        expect(seen.length, 1);
        expect(seen.single.brightness, Brightness.dark);
      },
    );

    test('dispose closes the connection', () async {
      final portal = _FakePortal();
      PortalAppearanceReader(portal).dispose();
      await Future<void>.delayed(Duration.zero);
      expect(portal.closed, isTrue);
    });
  });

  group('WindowsAppearanceReader', () {
    const dwm = r'Software\Microsoft\Windows\DWM';
    const personalize =
        r'Software\Microsoft\Windows\CurrentVersion\Themes\Personalize';

    test('decodes the registry values', () async {
      final r = _FakeRegistry()
        ..ints['$dwm|AccentColor'] =
            0xFFD47800 // ABGR for #0078D4
        ..ints['$personalize|AppsUseLightTheme'] = 0
        ..ints['$personalize|EnableTransparency'] = 0
        ..strings[r'Control Panel\Accessibility\HighContrast|Flags'] = '127'
        ..strings[r'Control Panel\Desktop\WindowMetrics|MinAnimate'] = '0';
      final reader = WindowsAppearanceReader(registry: r);
      addTearDown(reader.dispose);
      final a = await reader.read();
      expect(a.accent, const Color(0xFF0078D4));
      expect(a.brightness, Brightness.dark);
      expect(a.reduceTransparency, isTrue);
      expect(a.highContrast, isTrue);
      expect(a.reduceMotion, isTrue);
    });

    test(
      'light theme, defaults and a high-contrast flag that is off',
      () async {
        final r = _FakeRegistry()
          ..ints['$personalize|AppsUseLightTheme'] = 1
          ..strings[r'Control Panel\Accessibility\HighContrast|Flags'] = '126';
        final reader = WindowsAppearanceReader(registry: r);
        addTearDown(reader.dispose);
        final a = await reader.read();
        expect(a.brightness, Brightness.light);
        expect(a.highContrast, isFalse);
        expect(a.reduceMotion, isFalse);
        expect(a.accent, isNull);
      },
    );

    test('an empty registry reports nothing', () async {
      final reader = WindowsAppearanceReader(registry: _FakeRegistry());
      addTearDown(reader.dispose);
      expect(await reader.read(), SystemAppearance.none);
    });

    test('a changed value is picked up by polling', () async {
      final r = _FakeRegistry()..ints['$personalize|AppsUseLightTheme'] = 1;
      final reader = WindowsAppearanceReader(
        registry: r,
        interval: const Duration(milliseconds: 10),
      );
      addTearDown(reader.dispose);
      await reader.read();
      final next = reader.changes.first;
      r.ints['$personalize|AppsUseLightTheme'] = 0;
      expect(
        (await next.timeout(const Duration(seconds: 2))).brightness,
        Brightness.dark,
      );
    });
  });

  test('SystemAppearance decodes the new fields from the channel map', () {
    final a = SystemAppearance.fromMap({
      'brightness': 'dark',
      'fontFamily': 'Noto Sans',
      'fontPointSize': 10,
    });
    expect(a.brightness, Brightness.dark);
    expect(a.fontFamily, 'Noto Sans');
    expect(a.fontPointSize, 10.0);
  });
}
