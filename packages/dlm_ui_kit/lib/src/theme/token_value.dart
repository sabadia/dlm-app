import 'package:flutter/foundation.dart';

/// Base of the immutable token classes: value equality over [props].
@immutable
abstract class DlmTokenValue {
  /// Creates a [DlmTokenValue].
  const DlmTokenValue();

  /// The fields that make up the value, in a stable order.
  List<Object?> get props;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other.runtimeType == runtimeType &&
          other is DlmTokenValue &&
          listEquals(props, other.props);

  @override
  int get hashCode => Object.hashAll([runtimeType, ...props]);
}
