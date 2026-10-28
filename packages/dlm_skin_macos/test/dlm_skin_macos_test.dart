import 'package:dlm_skin_macos/dlm_skin_macos.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const skin = MacosSkin();

  test('conforms to the skin contract in every appearance', () {
    expect(validateSkin(skin), isEmpty);
  });

  test('its id matches the registry constant', () {
    expect(skin.id, macosSkinId);
  });

  test('uses the unified-toolbar shell with a translucent sidebar', () {
    expect(skin.shell.titleBar, DlmTitleBarStyle.unifiedTransparent);
    expect(skin.shell.toolbar, DlmToolbarStyle.unified);
    final tokens = skin.tokens(const DlmAppearance());
    expect(tokens.materials.sidebar.kind, DlmMaterialKind.glass);
    expect(tokens.materials.sidebar.isTranslucent, isTrue);
  });

  test('follows the system accent and darkens it only as far as needed', () {
    final tokens = skin.tokens(
      const DlmAppearance(accent: MacosSkin.defaultAccent),
    );
    expect(
      contrastRatio(tokens.colors.textOnAccent, tokens.colors.accent),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('standard control heights keep the 24 px hit target', () {
    final m = skin.tokens(const DlmAppearance()).metrics;
    expect(m.controlHeightSmall, greaterThanOrEqualTo(24));
  });

  test('the title bar inset covers the traffic lights', () {
    final theme = DlmThemeData.resolve(skin, const DlmAppearance());
    expect(theme.titleBarInset, 28);
    expect(
      theme.windowBackground.a,
      0,
      reason: 'the sidebar shows the backdrop',
    );
  });
}
