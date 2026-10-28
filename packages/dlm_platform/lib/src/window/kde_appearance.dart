import 'dart:async';
import 'dart:io';
import 'dart:ui' show Brightness, Color;

import 'system_appearance.dart';

/// The parts of `kdeglobals` the app uses, parsed from its INI text.
///
/// Reads the accent (`[General] AccentColor`, Plasma 6.1+; else the selection
/// background), the colour scheme (from the window background's luminance),
/// animations (`[KDE] AnimationDurationFactor=0` means reduce motion) and the
/// interface font (`[General] font`).
SystemAppearance parseKdeglobals(String text) {
  final sections = <String, Map<String, String>>{};
  var current = '';
  for (final raw in text.split('\n')) {
    final line = raw.trim();
    if (line.isEmpty || line.startsWith('#') || line.startsWith(';')) continue;
    if (line.startsWith('[') && line.endsWith(']')) {
      current = line.substring(1, line.length - 1);
      continue;
    }
    final eq = line.indexOf('=');
    if (eq <= 0) continue;
    sections.putIfAbsent(current, () => {})[line.substring(0, eq).trim()] = line
        .substring(eq + 1)
        .trim();
  }

  Color? rgb(String? value) {
    if (value == null) return null;
    final parts = value.split(',').map((p) => int.tryParse(p.trim())).toList();
    if (parts.length < 3 ||
        parts.take(3).any((p) => p == null || p < 0 || p > 255)) {
      return null;
    }
    return Color.fromARGB(255, parts[0]!, parts[1]!, parts[2]!);
  }

  final general = sections['General'] ?? const {};
  final accent =
      rgb(general['AccentColor']) ??
      rgb(sections['Colors:Selection']?['BackgroundNormal']);
  final window = rgb(sections['Colors:Window']?['BackgroundNormal']);
  final factor = double.tryParse(
    sections['KDE']?['AnimationDurationFactor'] ?? '',
  );
  String? family;
  double? size;
  final font = general['font']?.split(',');
  if (font != null && font.length >= 2 && font[0].trim().isNotEmpty) {
    family = font[0].trim();
    size = double.tryParse(font[1].trim());
  }
  return SystemAppearance(
    accent: accent,
    brightness: window == null
        ? null
        : (window.computeLuminance() < 0.5
              ? Brightness.dark
              : Brightness.light),
    reduceMotion: factor != null && factor == 0,
    fontFamily: family,
    fontPointSize: size,
  );
}

/// Reads `kdeglobals` and follows changes to it.
class KdeAppearanceReader implements SystemAppearanceReader {
  /// Creates a reader for [file] (default: `$XDG_CONFIG_HOME/kdeglobals`).
  KdeAppearanceReader({
    File? file,
    this.debounce = const Duration(milliseconds: 250),
  }) : _file = file ?? _defaultFile();

  /// How long to wait after a change before reading, since KDE rewrites the
  /// file in several steps.
  final Duration debounce;
  final File _file;
  final StreamController<SystemAppearance> _changes =
      StreamController<SystemAppearance>.broadcast();
  StreamSubscription<FileSystemEvent>? _watch;
  Timer? _timer;
  SystemAppearance? _last;

  static File _defaultFile() {
    final env = Platform.environment;
    final base = env['XDG_CONFIG_HOME'] ?? '${env['HOME'] ?? ''}/.config';
    return File('$base/kdeglobals');
  }

  @override
  Future<SystemAppearance> read() async {
    _startWatching();
    final current = await _readNow();
    _last = current;
    return current;
  }

  Future<SystemAppearance> _readNow() async {
    try {
      return parseKdeglobals(await _file.readAsString());
    } on FileSystemException {
      return SystemAppearance.none;
    }
  }

  void _startWatching() {
    if (_watch != null) return;
    try {
      // KDE replaces the file, so watch the directory.
      _watch = _file.parent.watch().listen((event) {
        if (!event.path.endsWith('kdeglobals')) return;
        _timer?.cancel();
        _timer = Timer(debounce, () async {
          final now = await _readNow();
          if (now != _last && !_changes.isClosed) {
            _last = now;
            _changes.add(now);
          }
        });
      }, onError: (Object _) {});
    } on FileSystemException {
      // No config directory: nothing to watch.
    }
  }

  @override
  Stream<SystemAppearance> get changes {
    _startWatching();
    return _changes.stream;
  }

  @override
  void dispose() {
    _timer?.cancel();
    unawaited(_watch?.cancel());
    unawaited(_changes.close());
  }
}
