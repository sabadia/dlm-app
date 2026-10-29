import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'components.dart';

/// Draws the kit's built-in glyphs on a 16 x 16 grid scaled to the box.
class DlmIconPainter extends CustomPainter {
  /// Creates a painter for [name] in [color].
  const DlmIconPainter(this.name, this.color, {this.strokeWidth = 1.5});

  /// Which glyph to draw.
  final DlmIconName name;

  /// The stroke colour.
  final Color color;

  /// Stroke width on the 16 x 16 grid (a skin's icon weight).
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / 16, size.height / 16);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
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

    Path pts(List<double> xy, {bool close = false}) {
      final p = Path()..moveTo(xy[0], xy[1]);
      for (var i = 2; i < xy.length; i += 2) {
        p.lineTo(xy[i], xy[i + 1]);
      }
      if (close) p.close();
      return p;
    }

    RRect box(double l, double t, double r, double b, double rad) =>
        RRect.fromLTRBR(l, t, r, b, Radius.circular(rad));

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
      case DlmIconName.download:
        canvas
          ..drawLine(const Offset(8, 2.5), const Offset(8, 10), stroke)
          ..drawPath(pts([4.5, 7, 8, 10.5, 11.5, 7]), stroke)
          ..drawPath(
            pts([2.5, 10.5, 2.5, 13.5, 13.5, 13.5, 13.5, 10.5]),
            stroke,
          );
      case DlmIconName.upload:
        canvas
          ..drawLine(const Offset(8, 10.5), const Offset(8, 3), stroke)
          ..drawPath(pts([4.5, 6.5, 8, 3, 11.5, 6.5]), stroke)
          ..drawPath(
            pts([2.5, 10.5, 2.5, 13.5, 13.5, 13.5, 13.5, 10.5]),
            stroke,
          );
      case DlmIconName.pause:
        canvas
          ..drawRRect(box(4, 3, 6.7, 13, 0.8), fill)
          ..drawRRect(box(9.3, 3, 12, 13, 0.8), fill);
      case DlmIconName.play:
        canvas.drawPath(pts([5, 3, 12.8, 8, 5, 13], close: true), fill);
      case DlmIconName.stop:
        canvas.drawRRect(box(4, 4, 12, 12, 1.2), fill);
      case DlmIconName.restart:
        _circularArrow(canvas, stroke, fill, clockwise: false);
      case DlmIconName.refresh:
        _circularArrow(canvas, stroke, fill, clockwise: true);
      case DlmIconName.trash:
        canvas
          ..drawLine(const Offset(3, 4.5), const Offset(13, 4.5), stroke)
          ..drawPath(pts([6.5, 4.5, 6.5, 3, 9.5, 3, 9.5, 4.5]), stroke)
          ..drawPath(pts([4.5, 4.5, 5.2, 13.5, 10.8, 13.5, 11.5, 4.5]), stroke)
          ..drawLine(const Offset(7, 7), const Offset(7, 11), stroke)
          ..drawLine(const Offset(9, 7), const Offset(9, 11), stroke);
      case DlmIconName.folder:
        canvas.drawPath(
          pts([
            2,
            4,
            6.5,
            4,
            7.5,
            5.5,
            14,
            5.5,
            14,
            12.5,
            2,
            12.5,
          ], close: true),
          stroke,
        );
      case DlmIconName.file:
        canvas
          ..drawPath(
            pts([4, 2, 9.5, 2, 12.5, 5, 12.5, 14, 4, 14], close: true),
            stroke,
          )
          ..drawPath(pts([9.5, 2, 9.5, 5, 12.5, 5]), stroke);
      case DlmIconName.link:
        canvas
          ..save()
          ..translate(8, 8)
          ..rotate(-math.pi / 4)
          ..translate(-8, -8)
          ..drawRRect(box(0.8, 5.8, 8.2, 10.2, 2.2), stroke)
          ..drawRRect(box(7.8, 5.8, 15.2, 10.2, 2.2), stroke)
          ..restore();
      case DlmIconName.copy:
        canvas
          ..drawRRect(box(5.5, 5.5, 13, 13, 1.5), stroke)
          ..drawPath(pts([3, 10.5, 3, 3, 10.5, 3]), stroke);
      case DlmIconName.settings:
        canvas
          ..drawCircle(const Offset(8, 8), 2.2, stroke)
          ..drawCircle(const Offset(8, 8), 4.8, stroke);
        for (var i = 0; i < 8; i++) {
          final a = i * math.pi / 4;
          canvas.drawLine(
            Offset(8 + 4.8 * math.cos(a), 8 + 4.8 * math.sin(a)),
            Offset(8 + 6.6 * math.cos(a), 8 + 6.6 * math.sin(a)),
            stroke,
          );
        }
      case DlmIconName.queue:
        for (final y in const [4.0, 8.0, 12.0]) {
          canvas
            ..drawLine(Offset(6, y), Offset(13.5, y), stroke)
            ..drawCircle(Offset(3, y), 0.9, fill);
        }
      case DlmIconName.schedule:
        canvas
          ..drawCircle(const Offset(8, 8), 6, stroke)
          ..drawPath(pts([8, 4.5, 8, 8, 10.6, 9.6]), stroke);
      case DlmIconName.tag:
        canvas
          ..drawPath(
            pts([2.5, 2.5, 8.5, 2.5, 14, 8, 8, 14, 2.5, 8.5], close: true),
            stroke,
          )
          ..drawCircle(const Offset(5.4, 5.4), 1, fill);
      case DlmIconName.filter:
        canvas.drawPath(
          pts([
            2.5,
            3.5,
            13.5,
            3.5,
            9.2,
            8.5,
            9.2,
            13,
            6.8,
            11.8,
            6.8,
            8.5,
          ], close: true),
          stroke,
        );
      case DlmIconName.speed:
        canvas
          ..drawArc(
            const Rect.fromLTRB(2, 3, 14, 15),
            math.pi * 0.85,
            math.pi * 1.3,
            false,
            stroke,
          )
          ..drawLine(const Offset(8, 9.5), const Offset(11, 6), stroke)
          ..drawCircle(const Offset(8, 9.5), 1, fill);
      case DlmIconName.chart:
        canvas
          ..drawPath(pts([2.5, 2.5, 2.5, 13.5, 13.5, 13.5]), stroke)
          ..drawLine(const Offset(6, 12), const Offset(6, 9), stroke)
          ..drawLine(const Offset(9, 12), const Offset(9, 6), stroke)
          ..drawLine(const Offset(12, 12), const Offset(12, 4), stroke);
      case DlmIconName.plugin:
        canvas
          ..drawRRect(box(4.5, 6, 11.5, 11, 1.5), stroke)
          ..drawLine(const Offset(6.5, 3), const Offset(6.5, 6), stroke)
          ..drawLine(const Offset(9.5, 3), const Offset(9.5, 6), stroke)
          ..drawLine(const Offset(8, 11), const Offset(8, 14), stroke);
      case DlmIconName.globe:
        canvas
          ..drawCircle(const Offset(8, 8), 6, stroke)
          ..drawOval(const Rect.fromLTRB(5.4, 2, 10.6, 14), stroke)
          ..drawLine(const Offset(2, 8), const Offset(14, 8), stroke);
      case DlmIconName.key:
        canvas
          ..drawCircle(const Offset(5, 8), 2.7, stroke)
          ..drawLine(const Offset(7.7, 8), const Offset(14, 8), stroke)
          ..drawLine(const Offset(11.5, 8), const Offset(11.5, 10.6), stroke)
          ..drawLine(const Offset(14, 8), const Offset(14, 10.2), stroke);
      case DlmIconName.importIcon:
        canvas
          ..drawLine(const Offset(2, 8), const Offset(10, 8), stroke)
          ..drawPath(pts([7, 5, 10, 8, 7, 11]), stroke)
          ..drawLine(const Offset(13, 3), const Offset(13, 13), stroke);
      case DlmIconName.exportIcon:
        canvas
          ..drawLine(const Offset(6, 8), const Offset(14, 8), stroke)
          ..drawPath(pts([11, 5, 14, 8, 11, 11]), stroke)
          ..drawLine(const Offset(3, 3), const Offset(3, 13), stroke);
      case DlmIconName.edit:
        canvas
          ..drawPath(
            pts([
              3,
              13,
              3.8,
              9.8,
              10.8,
              2.8,
              13.2,
              5.2,
              6.2,
              12.2,
            ], close: true),
            stroke,
          )
          ..drawLine(const Offset(9.2, 4.4), const Offset(11.6, 6.8), stroke);
      case DlmIconName.lock:
        canvas
          ..drawRRect(box(3.5, 7, 12.5, 13.5, 1.5), stroke)
          ..drawPath(
            Path()
              ..moveTo(5.5, 7)
              ..lineTo(5.5, 5.5)
              ..arcTo(
                const Rect.fromLTRB(5.5, 3, 10.5, 8),
                math.pi,
                math.pi,
                false,
              )
              ..lineTo(10.5, 7),
            stroke,
          );
      case DlmIconName.bell:
        canvas
          ..drawPath(
            Path()
              ..moveTo(3.5, 11.5)
              ..lineTo(4.5, 10)
              ..lineTo(4.5, 7)
              ..arcTo(
                const Rect.fromLTRB(4.5, 2.5, 11.5, 9.5),
                math.pi,
                math.pi,
                false,
              )
              ..lineTo(11.5, 10)
              ..lineTo(12.5, 11.5)
              ..close(),
            stroke,
          )
          ..drawArc(
            const Rect.fromLTRB(6.3, 11.5, 9.7, 14.5),
            0,
            math.pi,
            false,
            stroke,
          );
      case DlmIconName.sidebar:
        canvas
          ..drawRRect(box(2, 3, 14, 13, 1.8), stroke)
          ..drawLine(const Offset(6, 3), const Offset(6, 13), stroke);
      case DlmIconName.inspector:
        canvas
          ..drawRRect(box(2, 3, 14, 13, 1.8), stroke)
          ..drawLine(const Offset(10, 3), const Offset(10, 13), stroke);
      case DlmIconName.externalLink:
        canvas
          ..drawPath(
            pts([7, 3.5, 3.5, 3.5, 3.5, 12.5, 12.5, 12.5, 12.5, 9]),
            stroke,
          )
          ..drawPath(pts([9, 2.5, 13.5, 2.5, 13.5, 7]), stroke)
          ..drawLine(const Offset(13.5, 2.5), const Offset(7.5, 8.5), stroke);
      case DlmIconName.viewOptions:
        canvas
          ..drawLine(const Offset(2.5, 5), const Offset(13.5, 5), stroke)
          ..drawLine(const Offset(2.5, 11), const Offset(13.5, 11), stroke)
          ..drawCircle(const Offset(10, 5), 1.9, fill)
          ..drawCircle(const Offset(6, 11), 1.9, fill);
      case DlmIconName.group:
        canvas
          ..drawRRect(box(2.5, 2.5, 13.5, 6.5, 1.4), stroke)
          ..drawRRect(box(2.5, 9.5, 13.5, 13.5, 1.4), stroke);
      case DlmIconName.columns:
        canvas
          ..drawRRect(box(2, 3, 14, 13, 1.8), stroke)
          ..drawLine(const Offset(6, 3), const Offset(6, 13), stroke)
          ..drawLine(const Offset(10, 3), const Offset(10, 13), stroke);
      case DlmIconName.cards:
        canvas
          ..drawRRect(box(2.5, 2.5, 13.5, 7, 1.6), stroke)
          ..drawRRect(box(2.5, 9, 13.5, 13.5, 1.6), stroke)
          ..drawCircle(const Offset(5, 4.75), 0.8, fill)
          ..drawCircle(const Offset(5, 11.25), 0.8, fill);
      case DlmIconName.menu:
        for (final y in const [4.0, 8.0, 12.0]) {
          canvas.drawLine(Offset(2.5, y), Offset(13.5, y), stroke);
        }
    }
    canvas.restore();
  }

  void _circularArrow(
    Canvas canvas,
    Paint stroke,
    Paint fill, {
    required bool clockwise,
  }) {
    const rect = Rect.fromLTRB(2.8, 2.8, 13.2, 13.2);
    // A 300 degree arc leaving a gap where the arrow head sits.
    final start = clockwise ? -math.pi * 0.35 : -math.pi * 0.65;
    final sweep = (clockwise ? 1 : -1) * math.pi * 1.7;
    canvas.drawArc(rect, start, sweep, false, stroke);
    final end = start + sweep;
    final tip = Offset(8 + 5.2 * math.cos(end), 8 + 5.2 * math.sin(end));
    final dir = clockwise ? 1.0 : -1.0;
    final tangent = Offset(-math.sin(end) * dir, math.cos(end) * dir);
    final normal = Offset(math.cos(end), math.sin(end));
    final head = Path()
      ..moveTo(tip.dx + tangent.dx * 2.4, tip.dy + tangent.dy * 2.4)
      ..lineTo(tip.dx + normal.dx * 2.1, tip.dy + normal.dy * 2.1)
      ..lineTo(tip.dx - normal.dx * 2.1, tip.dy - normal.dy * 2.1)
      ..close();
    canvas.drawPath(head, fill);
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
      old.name != name || old.color != color || old.strokeWidth != strokeWidth;
}
