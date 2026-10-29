import 'dart:convert';
import 'dart:io';

import 'package:dlm_core/dlm_core.dart';
import 'package:test/test.dart';

/// Whatever is in the preferences file, the app starts: it never throws, it
/// uses defaults for what it cannot read, and it can save again afterwards.
void main() {
  late Directory dir;
  late File file;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('dlm_damaged_');
    file = File('${dir.path}/preferences.json');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  final damage = <String, List<int>>{
    'an empty file': const [],
    'only whitespace': utf8.encode('  \n\t '),
    'binary noise': List<int>.generate(512, (i) => (i * 37 + 11) % 256),
    'a truncated file': utf8.encode(
      '{"version":1,"values":{"ui.density":"comp',
    ),
    'not an object': utf8.encode('[1,2,3]'),
    'a null body': utf8.encode('null'),
    'values of the wrong kind': utf8.encode('{"version":1,"values":[1,2]}'),
    'invalid UTF-8': const [0xC3, 0x28, 0xA0, 0xA1, 0xFF],
  };

  for (final e in damage.entries) {
    test('${e.key} reads as defaults and the store works again', () async {
      file.writeAsBytesSync(e.value);
      final store = await PreferencesStore.open(file);
      expect(store.get(UiPrefs.density), Density.comfortable);
      expect(store.get(UiPrefs.theme), ThemeChoice.system);
      expect(store.get(UiPrefs.confirmDelete), isTrue);
      await store.set(UiPrefs.density, Density.compact);
      final again = await PreferencesStore.open(file);
      expect(again.get(UiPrefs.density), Density.compact);
    });
  }

  test('values of the wrong type are defaults, the rest are kept', () async {
    file.writeAsStringSync(
      jsonEncode({
        'version': 1,
        'values': {
          'ui.density': 42,
          'ui.theme': {'x': 1},
          'ui.confirmDelete': 'yes',
          'ui.sidebarWidth': 'wide',
          'ui.units': 'si',
        },
      }),
    );
    final store = await PreferencesStore.open(file);
    expect(store.get(UiPrefs.density), Density.comfortable);
    expect(store.get(UiPrefs.theme), ThemeChoice.system);
    expect(store.get(UiPrefs.confirmDelete), isTrue);
    expect(store.get(UiPrefs.sidebarWidth), 240);
    expect(store.get(UiPrefs.unitSystem), UnitSystem.si);
  });

  test('a saved view with a missing field is skipped, not fatal', () async {
    file.writeAsStringSync(
      jsonEncode({
        'version': 1,
        'values': {
          'list.savedViews': [
            {'name': 'only a name'},
            {
              'name': 'ok',
              'filter': 'all',
              'text': '',
              'sort': 'position',
              'descending': false,
            },
            'junk',
          ],
        },
      }),
    );
    final store = await PreferencesStore.open(file);
    final views = store.get(UiPrefs.savedViews);
    expect(views.map((v) => v.name), ['ok']);
  });
}
