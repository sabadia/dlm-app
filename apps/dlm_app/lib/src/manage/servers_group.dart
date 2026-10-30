import 'dart:async';

import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../connection/connection_controller.dart';
import '../prefs/pref_providers.dart';
import '../shell/feedback.dart';

/// Which DLM daemon the app talks to: the one on this computer, or servers
/// the user added. Choosing one connects to it; an https server asks to trust
/// its certificate the first time.
class ServersGroup extends ConsumerStatefulWidget {
  /// Creates the group.
  const ServersGroup({super.key});

  @override
  ConsumerState<ServersGroup> createState() => ServersGroupState();
}

/// The state of [ServersGroup]; public for the address check.
@visibleForTesting
class ServersGroupState extends ConsumerState<ServersGroup> {
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _token = TextEditingController();
  String? _addressError;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _token.dispose();
    super.dispose();
  }

  /// The address as the daemon is reached, or null when it cannot be one.
  static String? parseAddress(String text) {
    final uri = Uri.tryParse(text.trim());
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }
    return '${uri.scheme}://${uri.authority}';
  }

  Future<void> _add() async {
    final l = AppLocalizations.of(context);
    final url = parseAddress(_address.text);
    if (url == null) {
      setState(() => _addressError = l.sv_bad_address);
      return;
    }
    setState(() {
      _addressError = null;
      _busy = true;
    });
    try {
      final name = _name.text.trim().isEmpty
          ? Uri.parse(url).host
          : _name.text.trim();
      final profile = await ref
          .read(profilesProvider.notifier)
          .addServer(name: name, url: url, token: _token.text.trim());
      await ref.read(activeProfileIdProvider.notifier).set(profile.id);
      if (!mounted) return;
      _name.clear();
      _address.clear();
      _token.clear();
    } on Object catch (e) {
      if (mounted) showFailure(context, ref, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final profiles = ref.watch(profilesProvider);
    final active = ref.watch(activeProfileProvider);
    final gap = theme.metrics.spacing.lg;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DlmFormGroup(
          title: l.sv_title,
          footer: l.sv_desc,
          children: [
            for (final p in profiles)
              DlmFormRow(
                label: p.isLocal ? l.sv_local : p.name,
                description: p.url,
                control: Wrap(
                  spacing: theme.metrics.spacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (p.id == active.id)
                      DlmBadge(label: l.sv_in_use, tone: DlmTone.accent)
                    else
                      DlmButton(
                        label: l.sv_use,
                        onPressed: () => unawaited(
                          ref.read(activeProfileIdProvider.notifier).set(p.id),
                        ),
                      ),
                    if (!p.isLocal)
                      DlmButton(
                        label: l.sv_remove,
                        onPressed: () => unawaited(_remove(p)),
                      ),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: gap),
        DlmFormGroup(
          title: l.sv_add_title,
          children: [
            DlmFormRow(
              label: l.sv_name,
              control: SizedBox(
                width: 260,
                child: DlmTextField(
                  controller: _name,
                  placeholder: l.sv_name_hint,
                  semanticLabel: l.sv_name,
                ),
              ),
            ),
            DlmFormRow(
              label: l.sv_address,
              control: SizedBox(
                width: 260,
                child: DlmTextField(
                  controller: _address,
                  placeholder: l.sv_address_hint,
                  semanticLabel: l.sv_address,
                  errorText: _addressError,
                  onChanged: (_) {
                    if (_addressError != null) {
                      setState(() => _addressError = null);
                    }
                  },
                ),
              ),
            ),
            DlmFormRow(
              label: l.sv_token,
              control: SizedBox(
                width: 260,
                child: DlmTextField(
                  controller: _token,
                  placeholder: l.sv_token_hint,
                  semanticLabel: l.sv_token,
                  obscure: true,
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: DlmButton(
                label: l.sv_save,
                onPressed: _busy ? null : () => unawaited(_add()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _remove(ConnectionProfile p) async {
    final l = AppLocalizations.of(context);
    try {
      await ref.read(profilesProvider.notifier).remove(p.id);
      if (mounted) showNotice(context, ref, l.sv_removed(p.name));
    } on Object catch (e) {
      if (mounted) showFailure(context, ref, e);
    }
  }
}
