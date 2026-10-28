import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_skin.dart';

void main() {
  final base = const TestSkin().tokens(const DlmAppearance()).metrics;

  test('regular density returns the metrics unchanged', () {
    expect(identical(base.scaled(DlmDensity.regular), base), isTrue);
  });

  test('comfortable grows heights and spacing, compact shrinks them', () {
    final comfortable = base.scaled(DlmDensity.comfortable);
    final compact = base.scaled(DlmDensity.compact);
    expect(comfortable.rowHeight, greaterThan(base.rowHeight));
    expect(compact.rowHeight, lessThan(base.rowHeight));
    expect(comfortable.spacing.md, greaterThan(base.spacing.md));
    expect(compact.spacing.md, lessThan(base.spacing.md));
  });

  test('compact never goes below the minimum hit target', () {
    final compact = base.scaled(DlmDensity.compact);
    expect(compact.controlHeightSmall, base.minHitTarget);
    for (final h in [
      compact.controlHeight,
      compact.controlHeightLarge,
      compact.rowHeight,
    ]) {
      expect(h, greaterThanOrEqualTo(base.minHitTarget));
    }
  });

  test('density leaves radii, borders, icons and bars alone', () {
    final s = base.scaled(DlmDensity.compact);
    expect(s.radii, base.radii);
    expect(s.borderWidth, base.borderWidth);
    expect(s.icon, base.icon);
    expect(s.toolbarHeight, base.toolbarHeight);
    expect(s.sidebarWidth, base.sidebarWidth);
  });

  test('token values compare by value', () {
    expect(const DlmSpacing(), const DlmSpacing());
    expect(const DlmSpacing().hashCode, const DlmSpacing().hashCode);
    expect(const DlmSpacing(), isNot(const DlmSpacing(sm: 9)));
  });
}
