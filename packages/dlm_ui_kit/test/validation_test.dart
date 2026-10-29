import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_skin.dart';

DlmTokens _with(
  DlmTokens t, {
  DlmColors? colors,
  DlmMetrics? metrics,
  DlmTypography? typography,
  DlmMaterials? materials,
  DlmMotion? motion,
}) => DlmTokens(
  colors: colors ?? t.colors,
  typography: typography ?? t.typography,
  metrics: metrics ?? t.metrics,
  materials: materials ?? t.materials,
  motion: motion ?? t.motion,
);

DlmColors _colors(
  DlmColors c, {
  Color? textPrimary,
  Color? sidebar,
  Color? focusRing,
}) => DlmColors(
  brightness: c.brightness,
  highContrast: c.highContrast,
  window: c.window,
  content: c.content,
  raised: c.raised,
  sidebar: sidebar ?? c.sidebar,
  overlay: c.overlay,
  textPrimary: textPrimary ?? c.textPrimary,
  textSecondary: c.textSecondary,
  textDisabled: c.textDisabled,
  textOnAccent: c.textOnAccent,
  textLink: c.textLink,
  accent: c.accent,
  accentSubtle: c.accentSubtle,
  separator: c.separator,
  border: c.border,
  focusRing: focusRing ?? c.focusRing,
  controlFill: c.controlFill,
  controlFillHover: c.controlFillHover,
  controlFillPressed: c.controlFillPressed,
  controlFillDisabled: c.controlFillDisabled,
  rowHover: c.rowHover,
  selection: c.selection,
  selectionInactive: c.selectionInactive,
  scrim: c.scrim,
  success: c.success,
  warning: c.warning,
  danger: c.danger,
  info: c.info,
);

void main() {
  test('a conforming skin has no violations', () {
    expect(validateSkin(const TestSkin()), isEmpty);
  });

  test('a bad id is reported', () {
    expect(
      validateSkin(const TestSkin(skinId: 'Bad Id')),
      contains(contains('invalid skin id')),
    );
  });

  test('low-contrast text is reported', () {
    final skin = TestSkin(
      tweak: (t) => _with(
        t,
        colors: _colors(t.colors, textPrimary: const Color(0xFF999999)),
      ),
    );
    expect(validateSkin(skin), contains(contains('textPrimary on content')));
  });

  test('a translucent surface colour is reported', () {
    final skin = TestSkin(
      tweak: (t) =>
          _with(t, colors: _colors(t.colors, sidebar: const Color(0x80FFFFFF))),
    );
    expect(
      validateSkin(skin),
      contains(contains('surface sidebar must be opaque')),
    );
  });

  test('an invisible focus ring is reported', () {
    final skin = TestSkin(
      tweak: (t) =>
          _with(t, colors: _colors(t.colors, focusRing: t.colors.content)),
    );
    expect(validateSkin(skin), contains(contains('focusRing on content')));
  });

  test('metrics below the hit target are reported', () {
    final skin = TestSkin(
      tweak: (t) => _with(
        t,
        metrics: DlmMetrics(
          spacing: t.metrics.spacing,
          radii: t.metrics.radii,
          controlHeightSmall: 20,
          controlHeight: 28,
          controlHeightLarge: 36,
          rowHeight: 32,
          minHitTarget: 20,
          borderWidth: 1,
          focusRingWidth: 2,
          focusRingOffset: 1,
          iconSmall: 14,
          icon: 16,
          iconLarge: 24,
          toolbarHeight: 40,
          titleBarHeight: 32,
          sidebarWidth: t.metrics.sidebarWidth,
          inspectorWidth: t.metrics.inspectorWidth,
        ),
      ),
    );
    expect(validateSkin(skin), contains(contains('minHitTarget')));
  });

  test('a translucent material without blur is reported', () {
    final skin = TestSkin(
      tweak: (t) => _with(
        t,
        materials: const DlmMaterials(
          toolbar: DlmMaterial(kind: DlmMaterialKind.glass),
        ),
      ),
    );
    expect(validateSkin(skin), contains(contains('needs a blur radius')));
  });

  test('a shrinking type scale is reported', () {
    final skin = TestSkin(
      tweak: (t) => _with(
        t,
        typography: DlmTypography(
          caption: t.typography.caption,
          body: t.typography.body,
          bodyStrong: t.typography.bodyStrong,
          label: t.typography.label,
          subtitle: const TextStyle(fontSize: 10),
          title: t.typography.title,
          headline: t.typography.headline,
          mono: t.typography.mono,
        ),
      ),
    );
    expect(
      validateSkin(skin),
      contains(contains('type scale must not decrease')),
    );
  });

  test('reversed motion durations are reported', () {
    final skin = TestSkin(
      tweak: (t) => _with(
        t,
        motion: const DlmMotion(
          fast: Duration(milliseconds: 500),
          normal: Duration(milliseconds: 100),
        ),
      ),
    );
    expect(validateSkin(skin), contains(contains('motion durations')));
  });
}
