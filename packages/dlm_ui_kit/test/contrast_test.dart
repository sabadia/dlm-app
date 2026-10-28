import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const white = Color(0xFFFFFFFF);
  const black = Color(0xFF000000);

  group('contrastRatio', () {
    test('matches the WCAG reference values', () {
      expect(contrastRatio(black, white), closeTo(21, 0.001));
      expect(contrastRatio(white, white), closeTo(1, 0.001));
      expect(
        contrastRatio(const Color(0xFF777777), white),
        closeTo(4.48, 0.01),
      );
    });

    test('is symmetric', () {
      const a = Color(0xFF336699);
      expect(contrastRatio(a, white), contrastRatio(white, a));
    });
  });

  group('ensureContrast', () {
    test('keeps a colour that already passes', () {
      expect(ensureContrast(black, white), black);
    });

    test('darkens a light colour on a light background', () {
      final fixed = ensureContrast(const Color(0xFFAAAAAA), white);
      expect(contrastRatio(fixed, white), greaterThanOrEqualTo(4.5));
    });

    test('lightens a dark colour on a dark background', () {
      final fixed = ensureContrast(
        const Color(0xFF333333),
        const Color(0xFF1E1E1E),
      );
      expect(
        contrastRatio(fixed, const Color(0xFF1E1E1E)),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('falls back to black or white when the ratio is unreachable', () {
      const grey = Color(0xFF808080);
      expect(ensureContrast(grey, grey, minRatio: 30), isIn([white, black]));
    });
  });

  group('AccentPalette', () {
    const accents = [
      Color(0xFF000000),
      Color(0xFFFFFFFF),
      Color(0xFFFFD60A),
      Color(0xFF0A84FF),
      Color(0xFF34C759),
      Color(0xFF7F7F7F),
      Color(0xFFFF2D55),
      Color(0xFF8E8E93),
    ];
    for (final accent in accents) {
      for (final surface in [white, const Color(0xFF1E1E1E)]) {
        test('${accent.toARGB32().toRadixString(16)} on '
            '${surface.toARGB32().toRadixString(16)} is readable', () {
          final p = AccentPalette.derive(accent, surface: surface);
          expect(
            contrastRatio(p.onAccent, p.accent),
            greaterThanOrEqualTo(4.5),
          );
          expect(
            contrastRatio(p.accentText, surface),
            greaterThanOrEqualTo(4.5),
          );
          expect(p.accentSubtle.a, lessThan(1));
        });
      }
    }

    test('high contrast moves the accent fill until its text reaches 7:1', () {
      const accent = Color(0xFF0A84FF);
      final normal = AccentPalette.derive(accent, surface: white);
      final high = AccentPalette.derive(
        accent,
        surface: white,
        minTextContrast: 7,
        minOnAccentContrast: 7,
      );
      expect(normal.onAccent, white);
      expect(
        contrastRatio(normal.onAccent, normal.accent),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        normal.accent.computeLuminance(),
        lessThan(accent.computeLuminance()),
      );
      expect(
        contrastRatio(high.onAccent, high.accent),
        greaterThanOrEqualTo(7),
      );
      expect(
        high.accent.computeLuminance(),
        lessThan(normal.accent.computeLuminance()),
      );
    });

    test('light accents get black text and keep their colour', () {
      const yellow = Color(0xFFFFD60A);
      final p = AccentPalette.derive(yellow, surface: white);
      expect(p.onAccent, black);
      expect(p.accent, yellow);
    });

    test('blue gets white text on a slightly darkened fill', () {
      final p = AccentPalette.derive(const Color(0xFF007AFF), surface: white);
      expect(p.onAccent, white);
      expect(p.accent, isNot(const Color(0xFF007AFF)));
    });

    test('drops the alpha of the given accent', () {
      final p = AccentPalette.derive(const Color(0x800A84FF), surface: white);
      expect(p.accent.a, 1);
    });
  });
}
