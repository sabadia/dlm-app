import 'dart:io' show Platform;

import 'package:dlm_gallery/gallery_app.dart';
import 'package:dlm_gallery/skins.dart';
import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter/widgets.dart';

/// Starts the gallery. Environment variables preset the controls, which makes
/// it easy to script screenshots: GALLERY_SECTION (a section title),
/// GALLERY_DARK, GALLERY_HC, GALLERY_REDUCE_TRANSPARENCY, GALLERY_SKIN (an
/// index) set to 1 or a value; GALLERY_EFFECT is none, vibrancy or glass.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final env = Platform.environment;
  bool flag(String name) => env[name] == '1';
  runApp(
    GalleryApp(
      skins: gallerySkins,
      chrome: platformWindowChrome(),
      system: platformSystemAppearance(),
      initial: GallerySettings(
        skinIndex: int.tryParse(env['GALLERY_SKIN'] ?? '') ?? 0,
        dark: flag('GALLERY_DARK'),
        highContrast: flag('GALLERY_HC'),
        reduceTransparency: flag('GALLERY_REDUCE_TRANSPARENCY'),
        section: env['GALLERY_SECTION'],
        useSystemAccent: flag('GALLERY_SYSTEM_ACCENT'),
        effect: WindowEffect.values.firstWhere(
          (e) => e.name == env['GALLERY_EFFECT'],
          orElse: () => WindowEffect.glass,
        ),
      ),
    ),
  );
}
