import 'dart:async';
import 'dart:math' as math;

import 'package:dlm_core/dlm_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../prefs/pref_providers.dart';
import 'startup.dart';

/// How much of a restored window must sit on a display before it is trusted.
const double _visibleMargin = 48;

/// Where [saved] should open given the displays currently attached.
///
/// A window that still overlaps a display, including one on a second monitor,
/// is unchanged. A window that would open off every display is fitted onto
/// the first display and is not maximised.
WindowState placeWindow(WindowState saved, List<Rect> displays) {
  if (displays.isEmpty) return saved;
  final frame = Rect.fromLTWH(saved.x, saved.y, saved.width, saved.height);
  for (final display in displays) {
    final overlap = frame.intersect(display);
    if (overlap.width >= _visibleMargin && overlap.height >= _visibleMargin) {
      return saved;
    }
  }
  final home = displays.first;
  final width = math.min(saved.width, home.width);
  final height = math.min(saved.height, home.height);
  if (width <= 0 || height <= 0) return saved;
  final x = saved.x.clamp(home.left, math.max(home.left, home.right - width));
  final y = saved.y.clamp(home.top, math.max(home.top, home.bottom - height));
  return WindowState(
    x: x.toDouble(),
    y: y.toDouble(),
    width: width,
    height: height,
  );
}

/// Restores the window from the last session and writes it back when the user
/// moves it. Draws nothing.
class WindowPlacementBinder extends ConsumerStatefulWidget {
  /// Creates the binder.
  const WindowPlacementBinder({super.key});

  @override
  ConsumerState<WindowPlacementBinder> createState() =>
      _WindowPlacementBinderState();
}

class _WindowPlacementBinderState extends ConsumerState<WindowPlacementBinder> {
  StreamSubscription<void>? _frames;
  Timer? _save;
  var _restoring = false;

  @override
  void initState() {
    super.initState();
    final window = ref.read(windowControlProvider);
    _frames = window.frameChanged.listen((_) => _scheduleSave());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_restore());
    });
  }

  Future<void> _restore() async {
    final saved = ref.read(preferencesProvider).get(UiPrefs.windowState);
    if (saved == null || !mounted) return;
    final window = ref.read(windowControlProvider);
    _restoring = true;
    try {
      final placed = placeWindow(saved, await window.displays());
      await window.place(
        x: placed.x,
        y: placed.y,
        width: placed.width,
        height: placed.height,
        maximized: placed.maximized,
      );
    } finally {
      _restoring = false;
    }
  }

  void _scheduleSave() {
    if (_restoring) return;
    _save?.cancel();
    _save = Timer(const Duration(milliseconds: 400), () {
      unawaited(_write());
    });
  }

  Future<void> _write() async {
    final frame = await ref.read(windowControlProvider).readFrame();
    if (frame == null || !mounted) return;
    // The memory updates at once. The file write finishes on its own: waiting
    // for it inside a test's fake clock never returns.
    unawaited(
      ref
          .read(preferencesProvider)
          .set(
            UiPrefs.windowState,
            WindowState(
              x: frame.x,
              y: frame.y,
              width: frame.width,
              height: frame.height,
              maximized: frame.maximized,
            ),
          ),
    );
  }

  @override
  void dispose() {
    _save?.cancel();
    unawaited(_frames?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
