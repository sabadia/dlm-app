import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Draws the DLM mark: a download arrow inside an open progress ring, on a
/// rounded square with an indigo-to-blue gradient.
///
/// With [monochrome] only the ring and arrow are drawn, in [ink], on nothing:
/// the shape the menu bar and notification area use as a template image.
class DlmBrandMarkPainter extends CustomPainter {
  /// Creates the painter.
  const DlmBrandMarkPainter({this.monochrome = false, this.ink});

  /// Draws the ring and arrow only, no background.
  final bool monochrome;

  /// The colour of the ring and arrow when [monochrome]; white otherwise.
  final Color? ink;

  /// Top-left colour of the background gradient.
  static const Color gradientStart = Color(0xFF6B73FF);

  /// Bottom-right colour of the background gradient.
  static const Color gradientEnd = Color(0xFF2563D8);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    canvas
      ..save()
      ..translate((size.width - s) / 2, (size.height - s) / 2);
    final line = monochrome
        ? (ink ?? const Color(0xFF000000))
        : const Color(0xFFFFFFFF);
    if (!monochrome) {
      // The usual icon margin and corner radius.
      final inset = s * 0.06;
      final plate = RRect.fromRectAndRadius(
        Rect.fromLTWH(inset, inset, s - 2 * inset, s - 2 * inset),
        Radius.circular(s * 0.205),
      );
      canvas
        ..drawRRect(
          plate.shift(Offset(0, s * 0.012)),
          Paint()
            ..color = const Color(0x33000000)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.02),
        )
        ..drawRRect(
          plate,
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [gradientStart, gradientEnd],
            ).createShader(Rect.fromLTWH(0, 0, s, s)),
        );
    }
    final c = Offset(s / 2, s / 2);
    final stroke = Paint()
      ..color = line
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = s * (monochrome ? 0.085 : 0.062);
    // The ring is open at the top, where progress starts.
    final radius = s * (monochrome ? 0.40 : 0.27);
    const gap = 0.62;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: radius),
      -math.pi / 2 + gap / 2,
      2 * math.pi - gap,
      false,
      stroke,
    );
    // The arrow, from the opening down into the ring.
    final top = c.dy - radius * 0.62;
    final tip = c.dy + radius * 0.36;
    final head = radius * 0.40;
    canvas
      ..drawLine(Offset(c.dx, top), Offset(c.dx, tip), stroke)
      ..drawPath(
        Path()
          ..moveTo(c.dx - head, tip - head)
          ..lineTo(c.dx, tip)
          ..lineTo(c.dx + head, tip - head),
        stroke,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(DlmBrandMarkPainter old) =>
      old.monochrome != monochrome || old.ink != ink;
}

/// The DLM mark at [size].
class DlmBrandMark extends StatelessWidget {
  /// Creates the mark.
  const DlmBrandMark({this.size = 64, super.key});

  /// Width and height.
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: const CustomPaint(painter: DlmBrandMarkPainter()),
  );
}
