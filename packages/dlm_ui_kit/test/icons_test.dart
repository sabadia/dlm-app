import 'dart:ui' as ui;

import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Future<List<int>> _pixels(DlmIconName name, {double stroke = 1.5}) async {
  final recorder = ui.PictureRecorder();
  DlmIconPainter(
    name,
    const Color(0xFF000000),
    strokeWidth: stroke,
  ).paint(Canvas(recorder), const Size(32, 32));
  final image = await recorder.endRecording().toImage(32, 32);
  final data = await image.toByteData();
  return data!.buffer.asUint8List().toList();
}

int _inked(List<int> rgba) {
  var n = 0;
  for (var i = 3; i < rgba.length; i += 4) {
    if (rgba[i] > 0) n++;
  }
  return n;
}

void main() {
  // Glyphs that are deliberately the same picture.
  const aliases = {
    DlmIconName.sortAscending: DlmIconName.chevronUp,
    DlmIconName.sortDescending: DlmIconName.chevronDown,
    DlmIconName.eyeOff: null, // eye + slash, checked separately below
  };

  test('every built-in glyph draws something inside its box', () async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      for (final name in DlmIconName.values) {
        final px = await _pixels(name);
        expect(_inked(px), greaterThan(20), reason: '${name.name} is blank');
        expect(
          _inked(px),
          lessThan(32 * 32 * 0.7),
          reason: '${name.name} floods',
        );
      }
    });
  });

  test(
    'glyphs are distinct pictures apart from the documented aliases',
    () async {
      await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
        final seen = <String, DlmIconName>{};
        for (final name in DlmIconName.values) {
          if (aliases.containsKey(name) && aliases[name] != null) continue;
          final key = (await _pixels(name)).join(',');
          expect(
            seen[key],
            isNull,
            reason: '${name.name} looks the same as ${seen[key]?.name}',
          );
          seen[key] = name;
        }
      });
    },
  );

  test('the sort arrows reuse the chevrons', () async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      expect(
        await _pixels(DlmIconName.sortAscending),
        await _pixels(DlmIconName.chevronUp),
      );
    });
  });

  test('a heavier stroke inks more pixels', () async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      final thin = _inked(await _pixels(DlmIconName.settings, stroke: 1));
      final thick = _inked(await _pixels(DlmIconName.settings, stroke: 2.5));
      expect(thick, greaterThan(thin));
    });
  });

  test('a skin can change the icon weight', () {
    expect(const _Heavy().weight, 3);
  });
}

class _Heavy extends DlmBaseComponents {
  const _Heavy();

  @override
  double get iconStrokeWidth => 3;

  double get weight => iconStrokeWidth;
}
