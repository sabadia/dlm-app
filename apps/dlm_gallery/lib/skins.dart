import 'package:dlm_skin_adwaita/dlm_skin_adwaita.dart';
import 'package:dlm_skin_breeze/dlm_skin_breeze.dart';
import 'package:dlm_skin_fluent/dlm_skin_fluent.dart';
import 'package:dlm_skin_macos/dlm_skin_macos.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';

/// The skins the gallery can show. Like the app's skin registry, this is the
/// only file of the gallery that names a skin (tools/import_rules.yaml).
const List<DlmSkin> gallerySkins = [
  MacosSkin(),
  FluentSkin(),
  AdwaitaSkin(),
  BreezeSkin(),
];
