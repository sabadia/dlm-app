import 'dart:async';

import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../add/add_dialog.dart';
import '../prefs/pref_providers.dart';
import 'clipboard_links.dart';

/// Reads the clipboard text. Tests substitute their own.
final clipboardReaderProvider = Provider<Future<String?> Function()>((ref) {
  return () async => (await Clipboard.getData(Clipboard.kTextPlain))?.text;
});

/// The link currently offered from the clipboard, or null.
final clipboardOfferProvider =
    NotifierProvider<ClipboardOfferController, String?>(
      ClipboardOfferController.new,
    );

/// Holds the link the banner is showing.
class ClipboardOfferController extends Notifier<String?> {
  @override
  String? build() => null;

  /// Shows [link].
  void present(String link) => state = link;

  /// Hides the offer. The watcher still remembers it, so it is not offered
  /// again.
  void clear() => state = null;
}

/// How often the clipboard is read while the window is in front.
const Duration clipboardPollInterval = Duration(seconds: 2);

/// Watches the clipboard while [clipboardWatchProvider] is on and the window
/// is in front: once when it gains focus, then every [clipboardPollInterval].
/// The clipboard text is never logged.
class ClipboardWatcher extends ConsumerStatefulWidget {
  /// Creates the watcher. It draws nothing.
  const ClipboardWatcher({super.key});

  @override
  ConsumerState<ClipboardWatcher> createState() => _ClipboardWatcherState();
}

class _ClipboardWatcherState extends ConsumerState<ClipboardWatcher>
    with WidgetsBindingObserver {
  Timer? _timer;
  final _seen = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _arm(pollNow: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _arm(pollNow: state == AppLifecycleState.resumed);
  }

  /// Only while the app has the focus (`resumed`): an unfocused window
  /// (`inactive`) is not where the user copied from, and the clipboard is
  /// private. At start-up the state is not known yet and counts as focused.
  bool get _inFront {
    final life = WidgetsBinding.instance.lifecycleState;
    return life == null || life == AppLifecycleState.resumed;
  }

  void _arm({required bool pollNow}) {
    _timer?.cancel();
    _timer = null;
    final enabled = ref.read(clipboardWatchProvider);
    if (!enabled) {
      _seen.clear();
      ref.read(clipboardOfferProvider.notifier).clear();
      return;
    }
    if (!_inFront) return;
    if (pollNow) unawaited(_poll());
    _timer = Timer.periodic(clipboardPollInterval, (_) => unawaited(_poll()));
  }

  Future<void> _poll() async {
    if (!mounted || !ref.read(clipboardWatchProvider)) return;
    final text = await ref.read(clipboardReaderProvider)();
    if (!mounted || text == null || text.isEmpty) return;
    final link = firstDownloadLink(text);
    if (link == null || !_seen.add(link)) return;
    ref.read(clipboardOfferProvider.notifier).present(link);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(clipboardWatchProvider, (_, _) => _arm(pollNow: true));
    return const SizedBox.shrink();
  }
}

/// The offer for a link found on the clipboard.
class ClipboardOfferBanner extends ConsumerWidget {
  /// Creates the banner.
  const ClipboardOfferBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final link = ref.watch(clipboardOfferProvider);
    if (link == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    return DlmBanner(
      title: l.clip_offer_title,
      message: link,
      actionLabel: l.clip_offer_add,
      onAction: () {
        ref.read(clipboardOfferProvider.notifier).clear();
        unawaited(showAddDownload(context, ref, initialText: link));
      },
      dismissLabel: l.clip_offer_dismiss,
      onDismiss: () => ref.read(clipboardOfferProvider.notifier).clear(),
    );
  }
}
