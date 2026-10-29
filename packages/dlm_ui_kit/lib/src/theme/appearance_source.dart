import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';

import 'appearance.dart';

/// Where the system appearance comes from, with live updates.
///
/// The Flutter-level source below covers brightness, contrast, reduce-motion
/// and text scale on every OS. Accent, DE-specific colours and reduce
/// transparency come from `dlm_platform` readers adapted to this interface by
/// the app (F2.8); the kit knows nothing about the OS.
abstract interface class AppearanceSource {
  /// The appearance right now.
  DlmAppearance get current;

  /// Emits whenever [current] changes (broadcast stream).
  Stream<DlmAppearance> get changes;

  /// Releases listeners.
  void dispose();
}

/// A source that never changes (tests, previews, fallbacks).
class FixedAppearanceSource implements AppearanceSource {
  /// Creates a [FixedAppearanceSource].
  const FixedAppearanceSource([this.current = const DlmAppearance()]);

  @override
  final DlmAppearance current;

  @override
  Stream<DlmAppearance> get changes => const Stream<DlmAppearance>.empty();

  @override
  void dispose() {}
}

/// A source driven by code: the platform readers push into it, tests update it.
class ManualAppearanceSource implements AppearanceSource {
  /// Creates a [ManualAppearanceSource].
  ManualAppearanceSource([DlmAppearance initial = const DlmAppearance()])
    : _current = initial;

  final StreamController<DlmAppearance> _changes =
      StreamController<DlmAppearance>.broadcast(sync: true);
  DlmAppearance _current;

  @override
  DlmAppearance get current => _current;

  @override
  Stream<DlmAppearance> get changes => _changes.stream;

  /// Sets the appearance; listeners are told only when it differs.
  void update(DlmAppearance next) {
    if (next == _current) return;
    _current = next;
    _changes.add(next);
  }

  @override
  void dispose() => unawaited(_changes.close());
}

/// Reads what Flutter knows from the platform: brightness, the
/// high-contrast, reduce-motion and bold-text accessibility flags, and the
/// text scale. Updates arrive through the widgets binding.
class FlutterAppearanceSource
    with WidgetsBindingObserver
    implements AppearanceSource {
  /// Creates a [FlutterAppearanceSource].
  FlutterAppearanceSource({
    PlatformDispatcher? dispatcher,
    WidgetsBinding? binding,
  }) : _binding = binding ?? WidgetsBinding.instance,
       // The binding's dispatcher, which a test can override.
       _dispatcher =
           dispatcher ??
           (binding ?? WidgetsBinding.instance).platformDispatcher {
    _current = _read();
    _binding.addObserver(this);
  }

  final PlatformDispatcher _dispatcher;
  final WidgetsBinding _binding;
  final StreamController<DlmAppearance> _changes =
      StreamController<DlmAppearance>.broadcast(sync: true);
  late DlmAppearance _current;

  @override
  DlmAppearance get current => _current;

  @override
  Stream<DlmAppearance> get changes => _changes.stream;

  DlmAppearance _read() {
    final features = _dispatcher.accessibilityFeatures;
    return DlmAppearance(
      brightness: _dispatcher.platformBrightness,
      contrast: features.highContrast ? DlmContrast.high : DlmContrast.standard,
      reduceMotion: features.disableAnimations,
      textScale: _dispatcher.scaleFontSize(100) / 100,
    );
  }

  void _refresh() {
    final next = _read();
    if (next == _current) return;
    _current = next;
    _changes.add(next);
  }

  @override
  void didChangePlatformBrightness() => _refresh();

  @override
  void didChangeAccessibilityFeatures() => _refresh();

  @override
  void didChangeTextScaleFactor() => _refresh();

  @override
  void dispose() {
    _binding.removeObserver(this);
    unawaited(_changes.close());
  }
}
