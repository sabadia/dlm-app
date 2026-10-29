import 'package:dlm_skin_adwaita/dlm_skin_adwaita.dart';
import 'package:dlm_skin_breeze/dlm_skin_breeze.dart';
import 'package:dlm_skin_fluent/dlm_skin_fluent.dart';
import 'package:dlm_skin_macos/dlm_skin_macos.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/foundation.dart' show TargetPlatform;

/// The skins this build contains. This file is the only place in the app that
/// may import a skin (tools/import_rules.yaml); features ask the registry.
const Map<String, DlmSkin> skins = {
  macosSkinId: MacosSkin(),
  fluentSkinId: FluentSkin(),
  adwaitaSkinId: AdwaitaSkin(),
  breezeSkinId: BreezeSkin(),
};

/// The ids of the skins, in display order.
List<String> get skinIds => skins.keys.toList();

/// The id of the skin that fits [platform]: macOS, Fluent on Windows, Breeze
/// on KDE Plasma and Adwaita on every other Linux desktop. [desktops] is the
/// `XDG_CURRENT_DESKTOP` list.
String defaultSkinId(
  TargetPlatform platform, {
  List<String> desktops = const [],
}) {
  switch (platform) {
    case TargetPlatform.macOS:
    case TargetPlatform.iOS:
      return macosSkinId;
    case TargetPlatform.windows:
      return fluentSkinId;
    case TargetPlatform.linux:
      return desktops.map((d) => d.toUpperCase()).contains('KDE')
          ? breezeSkinId
          : adwaitaSkinId;
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
      return adwaitaSkinId;
  }
}

/// The skin to use: the user's override when it names a known skin, otherwise
/// the one that fits [platform].
DlmSkin pickSkin(
  String? override,
  TargetPlatform platform, {
  List<String> desktops = const [],
}) => skins[override] ?? skins[defaultSkinId(platform, desktops: desktops)]!;
