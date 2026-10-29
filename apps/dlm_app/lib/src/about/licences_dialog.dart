import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/foundation.dart' show LicenseEntry, LicenseRegistry;
import 'package:flutter/widgets.dart';

/// One package with the licence texts that Flutter's registry holds for it.
class PackageLicences {
  /// Creates the entry.
  const PackageLicences(this.name, this.texts);

  /// The package.
  final String name;

  /// Its licence texts.
  final List<String> texts;
}

/// Groups the registered licences by package, sorted by name. Every package
/// of a licence that names several is listed with it.
Future<List<PackageLicences>> loadLicences(Stream<LicenseEntry> entries) async {
  final byPackage = <String, List<String>>{};
  await for (final entry in entries) {
    final text = [
      for (final p in entry.paragraphs)
        '${'  ' * p.indent.clamp(0, 6)}${p.text}',
    ].join('\n');
    for (final package in entry.packages) {
      byPackage.putIfAbsent(package, () => []).add(text);
    }
  }
  return [
    for (final name in byPackage.keys.toList()..sort())
      PackageLicences(name, byPackage[name]!),
  ];
}

/// The licences of the open-source packages the app is built from.
class LicencesDialog extends StatefulWidget {
  /// Creates the dialog; [entries] defaults to Flutter's registry.
  const LicencesDialog({this.entries, super.key});

  /// Where the licences come from; null for the registry of the build.
  final Stream<LicenseEntry>? entries;

  @override
  State<LicencesDialog> createState() => _LicencesDialogState();
}

class _LicencesDialogState extends State<LicencesDialog> {
  late final Future<List<PackageLicences>> _future = loadLicences(
    widget.entries ?? LicenseRegistry.licenses,
  );
  String? _open;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 720,
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: DlmDialogContent(
        title: l.ab_licences,
        child: Flexible(
          child: FutureBuilder<List<PackageLicences>>(
            future: _future,
            builder: (context, snap) {
              final list = snap.data;
              if (list == null) return DlmLoadingState(label: l.list_loading);
              if (list.isEmpty) return DlmEmptyState(title: l.ab_licences_none);
              return ListView(
                shrinkWrap: true,
                children: [
                  for (final p in list) ...[
                    DlmListRow(
                      title: p.name,
                      subtitle: l.ab_licences_count(p.texts.length),
                      leading: DlmIcon(
                        _open == p.name
                            ? DlmIconName.chevronDown
                            : DlmIconName.chevronRight,
                      ),
                      onTap: () => setState(
                        () => _open = _open == p.name ? null : p.name,
                      ),
                    ),
                    if (_open == p.name)
                      Padding(
                        padding: EdgeInsets.all(theme.metrics.spacing.sm),
                        child: Text(
                          p.texts.join('\n\n--------\n\n'),
                          style: theme.typography.caption,
                        ),
                      ),
                  ],
                ],
              );
            },
          ),
        ),
        actions: [
          DlmButton(
            label: l.add_close,
            variant: DlmButtonVariant.primary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
