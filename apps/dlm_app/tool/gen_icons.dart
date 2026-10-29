// Renders the DLM mark to PNG files. Run through tool/gen_icons.sh, which
// then makes every size and format:
//
//   flutter test tool/gen_icons.dart
//
// It is a test only because dart:ui needs the Flutter engine to draw.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _write(String path, int size, {bool monochrome = false}) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  DlmBrandMarkPainter(monochrome: monochrome)
      .paint(canvas, ui.Size.square(size.toDouble()));
  final image = await recorder.endRecording().toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  test('render the mark', () async {
    final out = Platform.environment['DLM_ICON_OUT'] ?? 'build/icons';
    await _write('$out/mark_1024.png', 1024);
    await _write('$out/tray_template.png', 44, monochrome: true);
  });
}
