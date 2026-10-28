import 'colors.dart';
import 'materials.dart';
import 'metrics.dart';
import 'motion.dart';
import 'token_value.dart';
import 'typography.dart';

/// Everything a skin provides for one appearance.
class DlmTokens extends DlmTokenValue {
  /// Creates a [DlmTokens].
  const DlmTokens({
    required this.colors,
    required this.typography,
    required this.metrics,
    required this.materials,
    required this.motion,
  });

  /// Colour roles.
  final DlmColors colors;

  /// Type scale.
  final DlmTypography typography;

  /// Sizes, spacing and radii.
  final DlmMetrics metrics;

  /// Translucency of the surfaces.
  final DlmMaterials materials;

  /// Durations and curves.
  final DlmMotion motion;

  @override
  List<Object?> get props => [colors, typography, metrics, materials, motion];
}
