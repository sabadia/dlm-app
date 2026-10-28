import 'package:flutter/widgets.dart';

import '../components/components.dart';
import '../theme/theme.dart';

/// One of the kit's built-in glyphs, drawn by the active skin.
class DlmIcon extends StatelessWidget {
  /// Creates an icon; [size] and [color] default to the ambient icon theme
  /// and the theme's secondary text colour.
  const DlmIcon(this.name, {this.size, this.color, super.key});

  /// Which glyph.
  final DlmIconName name;

  /// Edge length; defaults to the icon size of the ambient icon theme.
  final double? size;

  /// Stroke colour; defaults to the ambient icon theme colour.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    final ambient = IconTheme.of(context);
    return ExcludeSemantics(
      child: theme.components.icon(
        context,
        name,
        size: size ?? ambient.size ?? theme.metrics.icon,
        color: color ?? ambient.color ?? theme.colors.textSecondary,
      ),
    );
  }
}
