import 'token_value.dart';

/// How a surface is rendered.
enum DlmMaterialKind {
  /// Flat colour.
  opaque,

  /// Blurred, translucent backdrop (vibrancy, acrylic, Mica).
  translucent,

  /// The macOS 26 glass effect.
  glass,
}

/// The material of one surface.
///
/// Translucent kinds are only drawn when the window can show the effect
/// (`dlm_platform` window chrome, F2.7) and the user has not asked for reduced
/// transparency; otherwise the surface falls back to its opaque colour.
class DlmMaterial extends DlmTokenValue {
  /// Creates a [DlmMaterial].
  const DlmMaterial({
    this.kind = DlmMaterialKind.opaque,
    this.blurSigma = 0,
    this.tintOpacity = 1,
  });

  /// Opaque.
  static const DlmMaterial opaque = DlmMaterial();

  /// Kind.
  final DlmMaterialKind kind;

  /// Backdrop blur radius for translucent kinds.
  final double blurSigma;

  /// Opacity of the surface colour laid over the backdrop (1 = opaque).
  final double tintOpacity;

  /// Is translucent.
  bool get isTranslucent => kind != DlmMaterialKind.opaque;

  @override
  List<Object?> get props => [kind, blurSigma, tintOpacity];
}

/// The materials of the surfaces that can be translucent.
class DlmMaterials extends DlmTokenValue {
  /// Creates a [DlmMaterials].
  const DlmMaterials({
    this.titleBar = DlmMaterial.opaque,
    this.toolbar = DlmMaterial.opaque,
    this.sidebar = DlmMaterial.opaque,
    this.popover = DlmMaterial.opaque,
  });

  /// All surfaces opaque (reduce transparency, unsupported window effect).
  static const DlmMaterials opaque = DlmMaterials();

  /// Title bar.
  final DlmMaterial titleBar;

  /// Toolbar.
  final DlmMaterial toolbar;

  /// Sidebar.
  final DlmMaterial sidebar;

  /// Popover.
  final DlmMaterial popover;

  /// All.
  List<DlmMaterial> get all => [titleBar, toolbar, sidebar, popover];

  @override
  List<Object?> get props => [titleBar, toolbar, sidebar, popover];
}
