import 'dart:async';

import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../add/add_dialog.dart';
import 'startup.dart';

/// What this process was opened with, and what arrives later.
class Openings {
  /// Creates the openings. [native] is the raw text from the system (macOS
  /// Apple events); it is parsed the same way as a launch.
  const Openings({
    this.launch = const HandedOpen(),
    this.later = const Stream.empty(),
    this.native = const Stream.empty(),
  });

  /// What this process was started with.
  final HandedOpen launch;

  /// What a later launch handed over.
  final Stream<HandedOpen> later;

  /// Raw targets from the system, for an app that is already running.
  final Stream<List<String>> native;
}

/// The openings of this run. `main` overrides it; tests do too.
final openingsProvider = Provider<Openings>((ref) => const Openings());

/// Shows [open]: brings the window forward, and opens the add dialog when
/// there is something to add. Tests substitute their own.
typedef HandedPresenter = Future<void> Function(
  BuildContext context,
  WidgetRef ref,
  HandedOpen open,
);

/// The presenter `main` uses.
final handedPresenterProvider = Provider<HandedPresenter>(
  (ref) => presentHandedOpen,
);

/// Brings the window forward and, when [open] names downloads, opens the add
/// dialog with them.
Future<void> presentHandedOpen(
  BuildContext context,
  WidgetRef ref,
  HandedOpen open,
) async {
  await ref.read(windowControlProvider).show();
  if (open.isEmpty || !context.mounted) return;
  await showAddDownload(
    context,
    ref,
    initialText: open.links.join('\n'),
    initialTorrentPaths: open.torrents,
  );
}

/// Presents what the app was opened with, and what later launches hand over.
/// Draws nothing.
class InstanceOpenBinder extends ConsumerStatefulWidget {
  /// Creates the binder.
  const InstanceOpenBinder({super.key});

  @override
  ConsumerState<InstanceOpenBinder> createState() => _InstanceOpenBinderState();
}

class _InstanceOpenBinderState extends ConsumerState<InstanceOpenBinder> {
  StreamSubscription<HandedOpen>? _later;
  StreamSubscription<List<String>>? _native;
  var _launchShown = false;

  @override
  void initState() {
    super.initState();
    final openings = ref.read(openingsProvider);
    _later = openings.later.listen(_present);
    _native = openings.native.listen((raw) => _present(parseHanded(raw)));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _launchShown) return;
      _launchShown = true;
      final launch = ref.read(openingsProvider).launch;
      if (!launch.isEmpty) _present(launch);
    });
  }

  void _present(HandedOpen open) {
    unawaited(ref.read(handedPresenterProvider)(context, ref, open));
  }

  @override
  void dispose() {
    unawaited(_later?.cancel());
    unawaited(_native?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
