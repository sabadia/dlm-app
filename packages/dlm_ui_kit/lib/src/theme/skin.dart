import 'appearance.dart';
import 'shell.dart';
import 'tokens.dart';

/// A complete look: tokens for every appearance and the shell pattern.
///
/// Implemented by `dlm_skin_macos`, `_fluent`, `_adwaita` and `_breeze`.
/// Component builders are added to this contract by F2.2.
abstract class DlmSkin {
  /// Creates a [DlmSkin].
  const DlmSkin();

  /// Stable identifier used in the registry and in preferences: lowercase
  /// letters and digits, starting with a letter.
  String get id;

  /// How the window is arranged and what its chrome looks like.
  DlmShellPattern get shell;

  /// The tokens for [appearance] (brightness, contrast, accent).
  ///
  /// Density, reduce-motion and reduce-transparency are applied afterwards by
  /// the kit (`DlmThemeData`), so a skin does not handle them. Use
  /// `AccentPalette` to honour `appearance.accent`.
  DlmTokens tokens(DlmAppearance appearance);
}
