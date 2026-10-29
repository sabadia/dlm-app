import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../behavior/interactive.dart';
import '../components/components.dart';
import '../theme/theme.dart';
import 'dialog.dart';
import 'text_field.dart';

/// One entry of the command palette.
class DlmCommand {
  /// Creates a command.
  const DlmCommand({
    required this.id,
    required this.label,
    required this.onInvoke,
    this.group,
    this.shortcut,
    this.keywords = const [],
  });

  /// Stable identifier.
  final String id;

  /// The visible, localised text.
  final String label;

  /// Heading the command is listed under.
  final String? group;

  /// The keyboard shortcut as text, shown at the trailing edge.
  final String? shortcut;

  /// Extra words that find the command (synonyms, localised).
  final List<String> keywords;

  /// Runs the command (after the palette has closed).
  final VoidCallback onInvoke;
}

/// Localised strings of the palette.
class DlmPaletteLabels {
  /// Creates the labels.
  const DlmPaletteLabels({
    required this.placeholder,
    required this.noResults,
    required this.semanticLabel,
  });

  /// Hint of the search field.
  final String placeholder;

  /// Shown when nothing matches.
  final String noResults;

  /// Accessible name of the dialog.
  final String semanticLabel;
}

/// The commands that match [query]: every word of the query must start a word
/// of the label, the group or a keyword (case-insensitive). An empty query
/// matches everything; commands whose label starts with the query come first.
List<DlmCommand> matchCommands(List<DlmCommand> commands, String query) {
  final words = query
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return commands;
  bool startsAWord(String haystack, String w) =>
      haystack.toLowerCase().split(RegExp(r'\s+')).any((t) => t.startsWith(w));
  final matches = [
    for (final c in commands)
      if (words.every(
        (w) =>
            startsAWord(c.label, w) ||
            (c.group != null && startsAWord(c.group!, w)) ||
            c.keywords.any((k) => startsAWord(k, w)),
      ))
        c,
  ];
  final q = query.toLowerCase().trim();
  matches.sort((a, b) {
    final as = a.label.toLowerCase().startsWith(q) ? 0 : 1;
    final bs = b.label.toLowerCase().startsWith(q) ? 0 : 1;
    return as - bs;
  });
  return matches;
}

/// Opens the command palette: a search field over a list of [commands].
/// Up/Down move, Enter runs, Escape closes; the chosen command runs after the
/// palette has closed.
Future<void> showDlmCommandPalette(
  BuildContext context, {
  required List<DlmCommand> commands,
  required DlmPaletteLabels labels,
}) async {
  final chosen = await showDlmDialog<DlmCommand>(
    context,
    semanticLabel: labels.semanticLabel,
    kind: DlmDialogKind.sheet,
    builder: (context) => _Palette(commands: commands, labels: labels),
  );
  chosen?.onInvoke();
}

class _Palette extends StatefulWidget {
  const _Palette({required this.commands, required this.labels});

  final List<DlmCommand> commands;
  final DlmPaletteLabels labels;

  @override
  State<_Palette> createState() => _PaletteState();
}

class _PaletteState extends State<_Palette> {
  String _query = '';
  int _highlight = 0;

  List<DlmCommand> get _matches => matchCommands(widget.commands, _query);

  void _move(int delta) {
    final n = _matches.length;
    if (n == 0) return;
    setState(() => _highlight = (_highlight + delta) % n);
  }

  void _run(DlmCommand c) => Navigator.of(context).pop(c);

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    final matches = _matches;
    final highlight = matches.isEmpty
        ? -1
        : _highlight.clamp(0, matches.length - 1);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowDown): () => _move(1),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () => _move(-1),
        const SingleActivator(LogicalKeyboardKey.enter): () {
          // From the state, not the build: keys can arrive within one frame.
          final current = _matches;
          if (current.isNotEmpty) {
            _run(current[_highlight.clamp(0, current.length - 1)]);
          }
        },
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DlmTextField(
            autofocus: true,
            placeholder: widget.labels.placeholder,
            semanticLabel: widget.labels.placeholder,
            onChanged: (v) => setState(() {
              _query = v;
              _highlight = 0;
            }),
          ),
          SizedBox(height: theme.metrics.spacing.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: matches.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(theme.metrics.spacing.lg),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        widget.labels.noResults,
                        textAlign: TextAlign.center,
                        style: theme.typography.body.copyWith(
                          color: theme.colors.textSecondary,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: matches.length,
                    itemBuilder: (context, i) =>
                        _row(context, theme, matches[i], i == highlight),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    DlmThemeData theme,
    DlmCommand c,
    bool highlighted,
  ) {
    return DlmInteractive(
      role: DlmRole.menuItem,
      semanticLabel: c.group == null ? c.label : '${c.group}: ${c.label}',
      canRequestFocus: false,
      ensureHitTarget: false,
      onTap: () => _run(c),
      builder: (context, states) => theme.components.menuItem(
        context,
        states: highlighted ? states.copyWith(hovered: true) : states,
        destructive: false,
        content: Row(
          children: [
            Expanded(
              child: Text(
                c.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (c.group != null) ...[
              SizedBox(width: theme.metrics.spacing.md),
              Text(
                c.group!,
                style: theme.typography.caption.copyWith(
                  color: highlighted || states.hovered
                      ? null
                      : theme.colors.textSecondary,
                ),
              ),
            ],
            if (c.shortcut != null) ...[
              SizedBox(width: theme.metrics.spacing.md),
              Text(c.shortcut!, style: theme.typography.caption),
            ],
          ],
        ),
      ),
    );
  }
}
