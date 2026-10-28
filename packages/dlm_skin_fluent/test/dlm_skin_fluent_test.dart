import 'package:dlm_skin_fluent/dlm_skin_fluent.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const skin = FluentSkin();

  test('conforms to the skin contract in every appearance', () {
    expect(validateSkin(skin), isEmpty);
  });

  test('its id matches the registry constant', () {
    expect(skin.id, fluentSkinId);
  });

  test('uses the Windows Fluent shell pattern', () {
    expect(skin.shell.titleBar, DlmTitleBarStyle.customCaption);
    expect(skin.shell.sidebar, DlmSidebarStyle.navigationPane);
    expect(skin.shell.toolbar, DlmToolbarStyle.commandBar);
    expect(skin.shell.settings, DlmSettingsStyle.settingsCards);
  });

  test('materials: the sidebar is Mica/Acrylic', () {
    final t = skin.tokens(const DlmAppearance());
    expect(t.materials.sidebar.isTranslucent, isTrue);
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
