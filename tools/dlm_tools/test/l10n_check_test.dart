import 'dart:convert';
import 'dart:io';

import 'package:dlm_tools/l10n_check.dart';
import 'package:test/test.dart';

void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('dlm_l10n'));
  tearDown(() => dir.deleteSync(recursive: true));

  void write(String name, Map<String, Object?> content) =>
      File('${dir.path}/$name').writeAsStringSync(jsonEncode(content));

  setUp(() {
    write('app_en.arb', {
      '@@locale': 'en',
      'hello': 'Hello {name}',
      'count': '{n, plural, one{1 item} other{{n} items}}',
      'plain': 'Plain',
    });
  });

  test('a faithful translation is fine and the rest counts as missing', () {
    write('app_de.arb', {
      '@@locale': 'de',
      'hello': 'Hallo {name}',
      'count': '{n, plural, one{1 Ding} other{{n} Dinge}}',
    });
    final r = checkArbs(dir);
    expect(r.problems, isEmpty);
    expect(r.missing['app_de.arb'], 1);
  });

  test('a dropped or renamed placeholder is a problem', () {
    write('app_de.arb', {'@@locale': 'de', 'hello': 'Hallo {who}'});
    expect(checkArbs(dir).problems.single.toString(), contains('placeholders'));
    write('app_de.arb', {'@@locale': 'de', 'hello': 'Hallo'});
    expect(checkArbs(dir).problems, hasLength(1));
  });

  test(
    'a plural without other, an unknown key and an empty text are problems',
    () {
      write('app_de.arb', {
        '@@locale': 'de',
        'count': '{n, plural, one{1 Ding}}',
        'ghost': 'x',
        'plain': '  ',
      });
      final texts = checkArbs(dir).problems.map((p) => p.text).join('|');
      expect(texts, contains('other'));
      expect(texts, contains('not in app_en.arb'));
      expect(texts, contains('empty'));
    },
  );

  test('the real files of the repository pass', () {
    final real = Directory('../../packages/dlm_l10n/lib/l10n');
    if (!real.existsSync()) return;
    expect(checkArbs(real).problems, isEmpty);
  });

  test('no visible text is written into the code instead of the ARB file', () {
    final roots = [
      Directory('../../apps/dlm_app/lib'),
      Directory('../../packages/dlm_ui_kit/lib'),
    ];
    if (!roots.every((d) => d.existsSync())) return;
    final literal = RegExp(
      r"""(?:Text\(\s*|semanticLabel:\s*|tooltip:\s*|label:\s*|title:\s*|message:\s*|hint:\s*)'([A-Za-z][^']*)'""",
    );
    // Examples inside input fields and the names of file-type groups in the
    // system file dialogs are not interface text.
    const allowed = {'Download lists', 'Torrent files'};
    final found = <String>[];
    for (final root in roots) {
      for (final f in root.listSync(recursive: true).whereType<File>()) {
        if (!f.path.endsWith('.dart')) continue;
        final lines = f.readAsLinesSync();
        for (var n = 0; n < lines.length; n++) {
          final m = literal.firstMatch(lines[n]);
          if (m != null && !allowed.contains(m.group(1))) {
            found.add('${f.path}:${n + 1}: ${lines[n].trim()}');
          }
        }
      }
    }
    expect(found, isEmpty, reason: found.join('\n'));
  });
}
