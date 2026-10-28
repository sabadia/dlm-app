import 'dart:convert';
import 'dart:io';

import 'package:dlm_core/dlm_core.dart';
import 'package:test/test.dart';

void main() {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('dlm_prefs');
    file = File('${dir.path}/prefs.json');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  Future<PreferencesStore> open({
    List<PreferencesMigration> migrations = const [],
  }) => PreferencesStore.open(file, migrations: migrations);

  test('reads defaults, remembers what is set, survives a restart', () async {
    final p = await open();
    expect(p.get(UiPrefs.density), Density.comfortable);
    expect(p.get(UiPrefs.confirmDelete), isTrue);
    expect(p.isSet(UiPrefs.density), isFalse);
    await p.set(UiPrefs.density, Density.compact);
    await p.set(UiPrefs.theme, ThemeChoice.dark);
    await p.set(UiPrefs.skinOverride, 'fluent');
    await p.set(UiPrefs.accent, 0xFF30D158);
    await p.set(UiPrefs.unitSystem, UnitSystem.si);
    await p.dispose();

    final again = await open();
    expect(again.get(UiPrefs.density), Density.compact);
    expect(again.get(UiPrefs.theme), ThemeChoice.dark);
    expect(again.get(UiPrefs.skinOverride), 'fluent');
    expect(again.get(UiPrefs.accent), 0xFF30D158);
    expect(again.get(UiPrefs.unitSystem), UnitSystem.si);
    await again.reset(UiPrefs.skinOverride);
    expect(again.get(UiPrefs.skinOverride), isNull);
  });

  test(
    'window state and column layouts round-trip, per profile where asked',
    () async {
      final p = await open();
      const w = WindowState(
        x: 10,
        y: 20,
        width: 1200,
        height: 800,
        maximized: true,
      );
      await p.set(UiPrefs.windowState, w);
      await p.set(UiPrefs.columns('downloads'), ['name', 'size']);
      await p.set(UiPrefs.columns('downloads'), ['name'], profile: 'nas');
      await p.dispose();
      final again = await open();
      expect(again.get(UiPrefs.windowState), w);
      expect(again.get(UiPrefs.columns('downloads')), ['name', 'size']);
      expect(again.get(UiPrefs.columns('downloads'), profile: 'nas'), ['name']);
      expect(
        again.get(UiPrefs.columns('downloads'), profile: 'other'),
        isEmpty,
      );
    },
  );

  test('a value that cannot be read is the default', () async {
    file.writeAsStringSync(
      jsonEncode({
        'version': 1,
        'values': {
          'ui.density': 'gigantic',
          'ui.window': {'x': 'left'},
          'ui.tray': 'yes',
        },
      }),
    );
    final p = await open();
    expect(p.get(UiPrefs.density), Density.comfortable);
    expect(p.get(UiPrefs.windowState), isNull);
    expect(p.get(UiPrefs.trayEnabled), isTrue);
  });

  test('changes are announced', () async {
    final p = await open();
    final keys = <String>[];
    p.changes.listen(keys.add);
    await p.set(UiPrefs.density, Density.compact, profile: 'nas');
    await p.reset(UiPrefs.density, profile: 'nas');
    expect(keys, ['profiles.nas.ui.density', 'profiles.nas.ui.density']);
  });

  test('forgetting a profile removes only its values', () async {
    final p = await open();
    await p.set(UiPrefs.density, Density.compact);
    await p.set(UiPrefs.density, Density.compact, profile: 'nas');
    await p.forgetProfile('nas');
    expect(p.isSet(UiPrefs.density, profile: 'nas'), isFalse);
    expect(p.isSet(UiPrefs.density), isTrue);
  });

  test('many quick writes are all kept, in order', () async {
    final p = await open();
    final writes = [
      for (var i = 0; i < 25; i++) p.set(UiPrefs.columns('l$i'), ['c$i']),
    ];
    await Future.wait(writes);
    final again = await open();
    for (var i = 0; i < 25; i++) {
      expect(again.get(UiPrefs.columns('l$i')), ['c$i']);
    }
  });

  test('older files are migrated step by step and saved', () async {
    file.writeAsStringSync(
      jsonEncode({
        'version': 1,
        'values': {'ui.compact': true},
      }),
    );
    final p = await open(
      migrations: [
        // v1 -> v2: a boolean became the density enum.
        (v) {
          final compact = v.remove('ui.compact') == true;
          return {...v, 'ui.density': compact ? 'compact' : 'comfortable'};
        },
        // v2 -> v3: the tray flag was renamed.
        (v) => v,
      ],
    );
    expect(p.version, 3);
    expect(p.get(UiPrefs.density), Density.compact);
    final saved = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
    expect(saved['version'], 3);
    expect(
      (saved['values']! as Map<String, Object?>).containsKey('ui.compact'),
      isFalse,
    );
  });

  test('a damaged file is set aside and defaults are used', () async {
    file.writeAsStringSync('{{{{');
    final p = await open();
    expect(p.get(UiPrefs.density), Density.comfortable);
    expect(File('${file.path}.corrupt').existsSync(), isTrue);
    await p.set(UiPrefs.density, Density.compact);
    expect(file.existsSync(), isTrue);
  });

  test(
    'a file from a newer app is backed up before anything is saved',
    () async {
      file.writeAsStringSync(
        jsonEncode({
          'version': 9,
          'values': {'ui.density': 'compact', 'ui.future': 1},
        }),
      );
      final p = await open();
      expect(p.get(UiPrefs.density), Density.compact);
      expect(File('${file.path}.from-v9').existsSync(), isTrue);
      await p.set(UiPrefs.theme, ThemeChoice.light);
      final backup = jsonDecode(
        File('${file.path}.from-v9').readAsStringSync(),
      ) as Map<String, Object?>;
      expect((backup['values']! as Map<String, Object?>)['ui.future'], 1);
    },
  );
}
