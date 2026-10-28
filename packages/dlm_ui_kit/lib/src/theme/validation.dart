import 'dart:ui';

import 'appearance.dart';
import 'colors.dart';
import 'contrast.dart';
import 'metrics.dart';
import 'skin.dart';
import 'tokens.dart';

/// Checks that [skin] honours the contract for every appearance (light and
/// dark, standard and high contrast, with and without an accent) and every
/// density. Returns one message per violation; empty means the skin conforms.
///
/// Every skin's own test calls this, so a skin cannot ship low-contrast text,
/// undersized hit targets or an unusable accent.
List<String> validateSkin(DlmSkin skin) {
  final problems = <String>[];
  void check(String context, bool ok, String message) {
    if (!ok) problems.add('${skin.id} [$context]: $message');
  }

  check('id', RegExp(r'^[a-z][a-z0-9]*$').hasMatch(skin.id), 'invalid skin id');

  const accents = <Color?>[
    null,
    Color(0xFF0A84FF),
    Color(0xFFFFD60A),
    Color(0xFF30D158),
    Color(0xFF111111),
  ];
  for (final brightness in Brightness.values) {
    for (final contrast in DlmContrast.values) {
      for (final accent in accents) {
        final appearance = DlmAppearance(
          brightness: brightness,
          contrast: contrast,
          accent: accent,
        );
        final context =
            '${brightness.name}/${contrast.name}/'
            '${accent == null ? 'no accent' : accent.toARGB32().toRadixString(16)}';
        final tokens = skin.tokens(appearance);
        _checkColors(tokens.colors, appearance, check, context);
        _checkMetrics(tokens, check, context);
        _checkType(tokens, check, context);
        check(
          context,
          tokens.motion.fast <= tokens.motion.normal &&
              tokens.motion.normal <= tokens.motion.slow,
          'motion durations must grow from fast to slow',
        );
      }
    }
  }
  return problems;
}

void _checkColors(
  DlmColors c,
  DlmAppearance appearance,
  void Function(String, bool, String) check,
  String context,
) {
  check(context, c.brightness == appearance.brightness, 'wrong brightness');
  check(
    context,
    c.highContrast == appearance.highContrast,
    'highContrast flag does not match the appearance',
  );
  final names = ['window', 'content', 'raised', 'sidebar', 'overlay'];
  for (var i = 0; i < c.surfaces.length; i++) {
    check(
      context,
      c.surfaces[i].a == 1,
      'surface ${names[i]} must be opaque (describe translucency in materials)',
    );
  }

  final high = appearance.highContrast;
  final text = high ? 7.0 : 4.5;
  final graphics = high ? 4.5 : 3.0;

  void ratio(String what, Color fg, Color bg, double min) {
    final r = contrastRatio(fg, bg);
    check(
      context,
      r >= min,
      '$what contrast ${r.toStringAsFixed(2)}:1 is below $min:1',
    );
  }

  for (var i = 0; i < c.surfaces.length; i++) {
    ratio('textPrimary on ${names[i]}', c.textPrimary, c.surfaces[i], text);
  }
  ratio('textSecondary on window', c.textSecondary, c.window, text);
  ratio('textSecondary on content', c.textSecondary, c.content, text);
  ratio('textSecondary on raised', c.textSecondary, c.raised, text);
  ratio('textOnAccent on accent', c.textOnAccent, c.accent, text);
  ratio('textLink on content', c.textLink, c.content, text);
  ratio('focusRing on content', c.focusRing, c.content, graphics);
  ratio('focusRing on window', c.focusRing, c.window, graphics);
  for (final (name, color) in [
    ('success', c.success),
    ('warning', c.warning),
    ('danger', c.danger),
    ('info', c.info),
  ]) {
    ratio('$name on content', color, c.content, graphics);
  }
  if (high) ratio('border on content', c.border, c.content, graphics);
}

void _checkMetrics(
  DlmTokens t,
  void Function(String, bool, String) check,
  String context,
) {
  final m = t.metrics;
  check(context, m.minHitTarget >= 24, 'minHitTarget must be at least 24');
  for (final density in DlmDensity.values) {
    final s = m.scaled(density);
    final at = '$context/${density.name}';
    check(
      at,
      s.controlHeightSmall >= m.minHitTarget &&
          s.controlHeight >= m.minHitTarget &&
          s.controlHeightLarge >= m.minHitTarget &&
          s.rowHeight >= m.minHitTarget,
      'a control or row height is below the minimum hit target',
    );
    check(
      at,
      s.controlHeightSmall <= s.controlHeight &&
          s.controlHeight <= s.controlHeightLarge,
      'control heights must grow from small to large',
    );
    final sp = s.spacing.scale;
    check(
      at,
      [for (var i = 1; i < sp.length; i++) sp[i - 1] <= sp[i]].every((v) => v),
      'spacing scale must not decrease',
    );
  }
  final r = m.radii;
  check(
    context,
    r.small <= r.control && r.control <= r.container,
    'radii must grow from small to container',
  );
  for (final range in [m.sidebarWidth, m.inspectorWidth]) {
    check(
      context,
      range.min <= range.ideal && range.ideal <= range.max,
      'a width range must satisfy min <= ideal <= max',
    );
  }
  check(
    context,
    m.iconSmall <= m.icon && m.icon <= m.iconLarge,
    'icon sizes must grow from small to large',
  );
  for (final material in t.materials.all) {
    check(
      context,
      material.tintOpacity >= 0 && material.tintOpacity <= 1,
      'material tintOpacity must be within 0..1',
    );
    check(
      context,
      !material.isTranslucent || material.blurSigma > 0,
      'a translucent material needs a blur radius',
    );
  }
}

void _checkType(
  DlmTokens t,
  void Function(String, bool, String) check,
  String context,
) {
  final sizes = [for (final s in t.typography.scale) s.fontSize];
  check(
    context,
    sizes.every((s) => s != null),
    'every type style needs a font size',
  );
  if (sizes.any((s) => s == null)) return;
  final px = sizes.whereType<double>().toList();
  check(context, px.first >= 11, 'caption text must be at least 11 px');
  check(
    context,
    [for (var i = 1; i < px.length; i++) px[i - 1] <= px[i]].every((v) => v),
    'type scale must not decrease from caption to headline',
  );
}
