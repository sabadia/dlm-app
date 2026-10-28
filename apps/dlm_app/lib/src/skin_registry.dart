import 'package:dlm_skin_adwaita/dlm_skin_adwaita.dart';
import 'package:dlm_skin_breeze/dlm_skin_breeze.dart';
import 'package:dlm_skin_fluent/dlm_skin_fluent.dart';
import 'package:dlm_skin_macos/dlm_skin_macos.dart';

/// The skins this build contains. This file is the only place in the app that
/// may import a skin (tools/import_rules.yaml); features ask the registry.
const List<String> skinIds = [
  macosSkinId,
  fluentSkinId,
  adwaitaSkinId,
  breezeSkinId,
];
