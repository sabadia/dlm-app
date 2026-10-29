import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The files of a download as a folder tree. Which files are downloaded is
/// chosen when the download is added; the tree shows the choice.
class FilesTab extends ConsumerStatefulWidget {
  /// Creates the tab for the task [id].
  const FilesTab({required this.id, super.key});

  /// The task.
  final String id;

  @override
  ConsumerState<FilesTab> createState() => _FilesTabState();
}

class _FilesTabState extends ConsumerState<FilesTab> {
  Set<Object>? _expanded;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final task = ref.watch(taskProvider(widget.id));
    final files = task?.resource?.files ?? const <File>[];
    if (files.length < 2) {
      return DlmEmptyState(title: l.files_single);
    }
    final roots = buildFileTree(files, l);
    _expanded ??= {for (final id in _folderIds(roots)) id};
    final selected = files.where((f) => f.selected).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: theme.metrics.spacing.md,
            vertical: theme.metrics.spacing.xs,
          ),
          child: Text(
            selected == 0
                ? l.files_none_selected
                : l.files_count(selected, files.length),
            style: theme.typography.caption.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: DlmTree(
            roots: roots,
            semanticLabel: l.files_tree_label,
            expandedIds: _expanded!,
            onExpandedChanged: (ids) => setState(() => _expanded = ids),
          ),
        ),
      ],
    );
  }

  static Iterable<Object> _folderIds(List<DlmTreeNode> nodes) sync* {
    for (final n in nodes) {
      if (n.children.isNotEmpty) {
        yield n.id;
        yield* _folderIds(n.children);
      }
    }
  }
}

/// The folder tree of [files]: each file sits under the folders of its path;
/// a file that is not downloaded says so.
List<DlmTreeNode> buildFileTree(List<File> files, AppLocalizations l) {
  final root = _Folder('');
  for (final f in files) {
    final parts = (f.path ?? f.name)
        .split('/')
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) parts.add(f.name);
    var dir = root;
    for (final p in parts.take(parts.length - 1)) {
      dir = dir.folders.putIfAbsent(p, () => _Folder('${dir.path}$p/'));
    }
    dir.files.add((parts.last, f));
  }
  return root.nodes(l);
}

class _Folder {
  _Folder(this.path);

  final String path;
  final Map<String, _Folder> folders = {};
  final List<(String, File)> files = [];

  int get total =>
      files.fold(0, (s, f) => s + f.$2.size) +
      folders.values.fold(0, (s, d) => s + d.total);

  List<DlmTreeNode> nodes(AppLocalizations l) => [
    for (final e in folders.entries)
      DlmTreeNode(
        id: 'dir:${e.value.path}',
        label: e.key,
        icon: const DlmIcon(DlmIconName.folder),
        trailing: Text(formatBytes(e.value.total) ?? ''),
        children: e.value.nodes(l),
      ),
    for (final (name, f) in files)
      DlmTreeNode(
        id: 'file:${f.index}',
        label: f.selected ? name : '$name (${l.files_skipped})',
        icon: const DlmIcon(DlmIconName.file),
        trailing: Text(formatBytes(f.size) ?? ''),
      ),
  ];
}
