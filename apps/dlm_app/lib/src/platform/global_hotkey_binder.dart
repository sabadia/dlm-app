import 'dart:async';

import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../prefs/pref_providers.dart';
import '../shell/shell_state.dart';
import '../shell/shortcuts.dart';
import 'startup.dart';

/// Registers the global shortcuts the user set, and again whenever they
/// change. Draws nothing.
class GlobalHotkeyBinder extends ConsumerStatefulWidget {
  /// Wraps [child].
  const GlobalHotkeyBinder({required this.child, super.key});

  /// The app.
  final Widget child;

  @override
  ConsumerState<GlobalHotkeyBinder> createState() => _GlobalHotkeyBinderState();
}

class _GlobalHotkeyBinderState extends ConsumerState<GlobalHotkeyBinder> {
  late final GlobalHotkeys _hotkeys;

  @override
  void initState() {
    super.initState();
    // Kept for dispose, where ref cannot be used.
    _hotkeys = ref.read(globalHotkeysProvider);
    ref.listenManual(
      shortcutsProvider,
      (_, _) => unawaited(_sync()),
      fireImmediately: true,
    );
  }

  Future<void> _sync() async {
    final hotkeys = ref.read(globalHotkeysProvider);
    if (!hotkeys.supported) return;
    await hotkeys.unregisterAll();
    final chords = effectiveShortcuts(
      ref.read(shortcutsProvider),
      primaryIsMeta: defaultTargetPlatform == TargetPlatform.macOS,
    );
    for (final id in globalShortcutIds) {
      final chord = chords[id];
      if (chord == null) continue;
      await hotkeys.register(
        id,
        GlobalChord(
          key: chord.key,
          control: chord.control,
          alt: chord.alt,
          shift: chord.shift,
          meta: chord.meta,
        ),
        () => unawaited(_run(id)),
      );
    }
  }

  Future<void> _run(String id) async {
    final window = ref.read(windowControlProvider);
    switch (id) {
      case 'global.toggleWindow':
        await ((await window.isVisible()) ? window.hide() : window.show());
      case 'global.addFromClipboard':
        await window.show();
        final data = await Clipboard.getData(Clipboard.kTextPlain);
        final links = parseHanded((data?.text ?? '').split(RegExp(r'\r?\n')));
        ref
            .read(addRequestProvider.notifier)
            .request(text: links.links.isEmpty ? null : links.links.join('\n'));
    }
  }

  @override
  void dispose() {
    unawaited(_hotkeys.unregisterAll());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
