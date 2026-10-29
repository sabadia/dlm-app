import 'package:dlm_core/dlm_core.dart';
import 'package:flutter/widgets.dart';

/// The unit system and locale sizes are written with. A change rebuilds
/// whatever asked for a size.
class DlmFormat extends InheritedWidget {
  /// Creates the format for the subtree.
  const DlmFormat({
    required this.units,
    required this.locale,
    required super.child,
    super.key,
  });

  /// IEC or SI.
  final UnitSystem units;

  /// The locale of the digits.
  final String locale;

  /// [bytes] as text, or null when unknown.
  String? bytes(int n) => formatBytes(n, system: units, locale: locale);

  /// A transfer rate, or null when unknown.
  String? speed(int n) => formatSpeed(n, system: units, locale: locale);

  /// The format above [context].
  static DlmFormat of(BuildContext context) {
    final found = context.dependOnInheritedWidgetOfExactType<DlmFormat>();
    assert(found != null, 'DlmFormat is missing above this widget');
    return found!;
  }

  @override
  bool updateShouldNotify(DlmFormat old) =>
      units != old.units || locale != old.locale;
}

/// Sizes from the [DlmFormat] above this context.
extension DlmFormatContext on BuildContext {
  /// [n] bytes in the current units and locale.
  String? bytes(int n) => DlmFormat.of(this).bytes(n);

  /// [n] bytes per second in the current units and locale.
  String? speed(int n) => DlmFormat.of(this).speed(n);
}
