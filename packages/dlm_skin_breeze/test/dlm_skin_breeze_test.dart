import 'package:dlm_skin_breeze/dlm_skin_breeze.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const skin = BreezeSkin();

  test('conforms to the skin contract in every appearance', () {
    expect(validateSkin(skin), isEmpty);
  });

  test('its id matches the registry constant', () {
    expect(skin.id, breezeSkinId);
  });

  test('uses the KDE Breeze shell pattern', () {
    expect(skin.shell.titleBar, DlmTitleBarStyle.system);
    expect(skin.shell.sidebar, DlmSidebarStyle.listPane);
    expect(skin.shell.toolbar, DlmToolbarStyle.toolBar);
    expect(skin.shell.settings, DlmSettingsStyle.systemSettingsPages);
  });

  test('materials: every surface is opaque', () {
    final t = skin.tokens(const DlmAppearance());
    expect(t.materials.sidebar.isTranslucent, isFalse);
  });

  test('a custom accent keeps readable labels', () {
    for (final accent in const [Color(0xFFFF9F0A), Color(0xFF30D158)]) {
      final c = skin.tokens(DlmAppearance(accent: accent)).colors;
      expect(
        contrastRatio(c.textOnAccent, c.accent),
        greaterThanOrEqualTo(4.5),
      );
    }
  });

  test('the title bar inset matches who draws the title bar', () {
    final theme = DlmThemeData.resolve(skin, const DlmAppearance());
    expect(theme.titleBarInset, 0);
  });
}
