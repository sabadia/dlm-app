import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'components.dart';

/// Draws the kit's built-in glyphs on a 16 x 16 grid scaled to the box.
class DlmIconPainter extends CustomPainter {
  /// Creates a painter for [name] in [color].
  const DlmIconPainter(this.name, this.color);

  /// Which glyph to draw.
  final DlmIconName name;

  /// The stroke colour.
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / 16, size.height / 16);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color;
    Path poly(List<Offset> pts) {
      final p = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final o in pts.skip(1)) {
        p.lineTo(o.dx, o.dy);
      }
      return p;
    }

    switch (name) {
      case DlmIconName.chevronRight:
        canvas.drawPath(
          poly(const [Offset(6, 3), Offset(11, 8), Offset(6, 13)]),
          stroke,
        );
      case DlmIconName.chevronLeft:
        canvas.drawPath(
          poly(const [Offset(10, 3), Offset(5, 8), Offset(10, 13)]),
          stroke,
        );
      case DlmIconName.chevronDown:
      case DlmIconName.sortDescending:
        canvas.drawPath(
          poly(const [Offset(3, 6), Offset(8, 11), Offset(13, 6)]),
          stroke,
        );
      case DlmIconName.chevronUp:
      case DlmIconName.sortAscending:
        canvas.drawPath(
          poly(const [Offset(3, 10), Offset(8, 5), Offset(13, 10)]),
          stroke,
        );
      case DlmIconName.close:
        canvas
          ..drawLine(const Offset(3.5, 3.5), const Offset(12.5, 12.5), stroke)
          ..drawLine(const Offset(12.5, 3.5), const Offset(3.5, 12.5), stroke);
      case DlmIconName.check:
        canvas.drawPath(
          poly(const [Offset(3, 8.5), Offset(6.5, 12), Offset(13, 4.5)]),
          stroke,
        );
      case DlmIconName.minus:
        canvas.drawLine(const Offset(3, 8), const Offset(13, 8), stroke);
      case DlmIconName.plus:
        canvas
          ..drawLine(const Offset(3, 8), const Offset(13, 8), stroke)
          ..drawLine(const Offset(8, 3), const Offset(8, 13), stroke);
      case DlmIconName.search:
        canvas
          ..drawCircle(const Offset(7, 7), 4.5, stroke)
          ..drawLine(const Offset(10.5, 10.5), const Offset(14, 14), stroke);
      case DlmIconName.eye:
        _eye(canvas, stroke, fill);
      case DlmIconName.eyeOff:
        _eye(canvas, stroke, fill);
        canvas.drawLine(
          const Offset(2.5, 13.5),
          const Offset(13.5, 2.5),
          stroke,
        );
      case DlmIconName.more:
        for (final x in const [3.5, 8.0, 12.5]) {
          canvas.drawCircle(Offset(x, 8), 1.2, fill);
        }
      case DlmIconName.info:
        canvas
          ..drawCircle(const Offset(8, 8), 6.25, stroke)
          ..drawLine(const Offset(8, 7.2), const Offset(8, 11), stroke)
          ..drawCircle(const Offset(8, 4.9), 0.5, fill);
      case DlmIconName.error:
        canvas
          ..drawCircle(const Offset(8, 8), 6.25, stroke)
          ..drawLine(const Offset(8, 4.6), const Offset(8, 8.6), stroke)
          ..drawCircle(const Offset(8, 11.1), 0.5, fill);
      case DlmIconName.success:
        canvas
          ..drawCircle(const Offset(8, 8), 6.25, stroke)
          ..drawPath(
            poly(const [Offset(5.3, 8.2), Offset(7.2, 10.2), Offset(10.8, 6)]),
            stroke,
          );
      case DlmIconName.warning:
        canvas
          ..drawPath(
            poly(const [
              Offset(8, 2.2),
              Offset(14.2, 13.2),
              Offset(1.8, 13.2),
              Offset(8, 2.2),
            ]),
            stroke,
          )
          ..drawLine(const Offset(8, 6.2), const Offset(8, 9.6), stroke)
          ..drawCircle(const Offset(8, 11.5), 0.5, fill);
    }
    canvas.restore();
  }

  void _eye(Canvas canvas, Paint stroke, Paint fill) {
    final path = Path()
      ..moveTo(1.5, 8)
      ..quadraticBezierTo(8, 1.5, 14.5, 8)
      ..quadraticBezierTo(8, 14.5, 1.5, 8);
    canvas
      ..drawPath(path, stroke)
      ..drawCircle(const Offset(8, 8), math.sqrt(2.2), fill);
  }

  @override
  bool shouldRepaint(DlmIconPainter old) =>
      old.name != name || old.color != color;
}
