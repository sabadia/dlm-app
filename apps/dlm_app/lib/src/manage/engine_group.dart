import 'dart:async';
import 'dart:io';

import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_platform/dlm_platform.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../connection/connection_controller.dart';
import '../shell/feedback.dart';

/// The server builds this app downloaded (and downloads on request). Tests
/// substitute their own.
final daemonEnginesProvider = Provider<DaemonEngines>(
  (ref) => DaemonEngines(
    '${AppDirs.resolve().root}${Platform.pathSeparator}engines',
  ),
);

/// The version of the server this app started, from the file it writes.
final runningServerVersionProvider = Provider.autoDispose<String?>(
  (ref) => RuntimeInfo.read(AppDirs.resolve().daemonHome)?.version,
);

/// Updating the server this app runs without a new app: look up the newest
/// release, download it, check it and restart into it.
class EngineGroup extends ConsumerStatefulWidget {
  /// Creates the group.
  const EngineGroup({super.key});

  @override
  ConsumerState<EngineGroup> createState() => _EngineGroupState();
}

class _EngineGroupState extends ConsumerState<EngineGroup> {
  var _busy = false;
  var _updating = false;
  EngineRelease? _offer;
  String? _message;

  Future<void> _check() async {
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _message = null;
      _offer = null;
    });
    try {
      final latest = await ref.read(daemonEnginesProvider).latest();
      if (!mounted) return;
      final running = ref.read(runningServerVersionProvider);
      if (running == null || compareVersions(latest.version, running) > 0) {
        setState(() => _offer = latest);
      } else {
        setState(() => _message = l.eng_up_to_date(running));
      }
    } on EngineUpdateException catch (e) {
      if (mounted) setState(() => _message = l.eng_failed(e.message));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _update(EngineRelease release) async {
    final l = AppLocalizations.of(context);
    setState(() {
      _updating = true;
      _message = null;
    });
    try {
      final installed = await ref.read(daemonEnginesProvider).install(release);
      await ref
          .read(localDaemonProvider)
          .useEngine(installed.path, installed.version);
      if (!mounted) return;
      ref.invalidate(runningServerVersionProvider);
      setState(() {
        _offer = null;
        _message = l.eng_done(installed.version);
      });
      showNotice(context, ref, l.eng_done(installed.version));
    } on Object catch (e) {
      final reason = e is EngineUpdateException ? e.message : '$e';
      if (mounted) setState(() => _message = l.eng_failed(reason));
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final local = ref.watch(activeProfileProvider).isLocal;
    final running = ref.watch(runningServerVersionProvider);
    final offer = _offer;
    return DlmFormGroup(
      title: l.eng_title,
      children: [
        DlmFormRow(
          label: running == null
              ? l.eng_running_unknown
              : l.eng_running(running),
          description: local ? _message : l.eng_unsupported,
          control: DlmButton(
            label: _busy ? l.eng_checking : l.eng_check,
            onPressed: !local || _busy || _updating
                ? null
                : () => unawaited(_check()),
          ),
        ),
        if (local && offer != null)
          DlmFormRow(
            label: l.eng_available(offer.version),
            control: DlmButton(
              label: _updating ? l.eng_updating : l.eng_update(offer.version),
              variant: DlmButtonVariant.primary,
              onPressed: _updating ? null : () => unawaited(_update(offer)),
            ),
          ),
      ],
    );
  }
}
