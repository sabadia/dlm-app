import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Reads log records from somewhere: [level] is the lowest level wanted, [q]
/// text the records must contain.
typedef LogLoader = Future<LogList> Function({Level? level, String? q});

/// A filterable list of log records, newest last, with refresh. Used for the
/// daemon's log and a plugin's.
class LogView extends StatefulWidget {
  /// Creates the view over [load].
  const LogView({required this.load, super.key});

  /// Where the records come from.
  final LogLoader load;

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  Level? _level;
  String _text = '';
  late Future<LogList> _future = _read();

  Future<LogList> _read() =>
      widget.load(level: _level, q: _text.trim().isEmpty ? null : _text.trim());

  void _reload() => setState(() {
    _future = _read();
  });

  Color _color(DlmThemeData theme, RecordLevel level) => switch (level) {
    RecordLevel.error => theme.colors.danger,
    RecordLevel.warn => theme.colors.warning,
    _ => theme.colors.textSecondary,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final time = DateFormat.Hms(l.localeName);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: theme.metrics.spacing.sm,
          runSpacing: theme.metrics.spacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: DlmDropdown<Level?>(
                semanticLabel: l.log_level,
                value: _level,
                choices: [
                  DlmChoice(value: null, label: l.log_level_all),
                  DlmChoice(value: Level.info, label: l.log_level_info),
                  DlmChoice(value: Level.warn, label: l.log_level_warn),
                  DlmChoice(value: Level.error, label: l.log_level_error),
                ],
                onChanged: (v) {
                  _level = v;
                  _reload();
                },
              ),
            ),
            SizedBox(
              width: 220,
              child: DlmSearchField(
                placeholder: l.log_search,
                clearLabel: l.toolbar_search_clear,
                onChanged: (v) => _text = v,
                onSubmitted: (_) => _reload(),
              ),
            ),
            DlmButton(label: l.log_refresh, onPressed: _reload),
          ],
        ),
        SizedBox(height: theme.metrics.spacing.sm),
        Flexible(
          child: FutureBuilder<LogList>(
            future: _future,
            builder: (context, snap) {
              if (snap.hasError) {
                return DlmBanner(tone: DlmTone.danger, message: l.log_error);
              }
              final records = snap.data?.records;
              if (snap.data == null) {
                return DlmLoadingState(label: l.list_loading);
              }
              if (records == null || records.isEmpty) {
                return DlmEmptyState(title: l.log_empty);
              }
              return ListView(
                shrinkWrap: true,
                children: [
                  for (final r in records)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: theme.metrics.spacing.xxs,
                      ),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  '${time.format(r.time.toLocal())}  '
                                  '${r.level.json?.toUpperCase()}  ',
                              style: theme.typography.caption.copyWith(
                                color: _color(theme, r.level),
                              ),
                            ),
                            TextSpan(text: r.message),
                            if ((r.attrs ?? const {}).isNotEmpty)
                              TextSpan(
                                text:
                                    '  ${r.attrs!.entries.map((e) => '${e.key}=${e.value}').join(' ')}',
                                style: theme.typography.caption.copyWith(
                                  color: theme.colors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
