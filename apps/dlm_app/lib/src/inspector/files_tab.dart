import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../format/dlm_format.dart';
import '../shell/feedback.dart';

/// The files of a download as a folder tree. It shows which files are
/// downloaded; while the download is not running the choice can be changed.
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

  /// The indexes being chosen; null when the choice is not being edited.
  Set<int>? _picked;
  bool _saving = false;

  Future<void> _save(List<File> files) async {
    final picked = _picked!;
    setState(() => _saving = true);
    try {
      final task = await ref
          .read(taskDetailRepositoryProvider)
          .setFiles(widget.id, picked.toList()..sort());
      ref.read(taskStoreProvider).tasks.put(task.id, task);
      if (!mounted) return;
      setState(() => _picked = null);
      showNotice(context, ref, AppLocalizations.of(context).toast_files_saved);
    } on Object catch (e) {
      if (mounted) showFailure(context, ref, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toggle(Iterable<int> indexes, bool on) => setState(() {
    on ? _picked!.addAll(indexes) : _picked!.removeAll(indexes);
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final task = ref.watch(taskProvider(widget.id));
    final files = task?.resource?.files ?? const <File>[];
    if (files.length < 2) {
      return DlmEmptyState(title: l.files_single);
    }
    final editing = _picked != null;
    // A running or finished download cannot change its files.
    final kind = task?.statusKind;
    final editable =
        kind != null && !kind.isActive && kind != TaskStatus.completed;
    final roots = buildFileTree(
      files,
      l,
      sizes: context.bytes,
      picked: _picked,
      onToggle: _toggle,
    );
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
          child: Wrap(
            spacing: theme.metrics.spacing.sm,
            runSpacing: theme.metrics.spacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                editing
                    ? (_picked!.isEmpty
                          ? l.files_pick_one
                          : l.files_count(_picked!.length, files.length))
                    : selected == 0
                    ? l.files_none_selected
                    : editable
                    ? l.files_count(selected, files.length)
                    : '${l.files_count(selected, files.length)} · ${l.files_locked}',
                style: theme.typography.caption.copyWith(
                  color: theme.colors.textSecondary,
                ),
              ),
              if (editing) ...[
                DlmButton(
                  label: l.files_cancel,
                  onPressed: _saving
                      ? null
                      : () => setState(() => _picked = null),
                ),
                DlmButton(
                  label: l.files_save,
                  onPressed: _saving || _picked!.isEmpty
                      ? null
                      : () => _save(files),
                ),
              ] else if (editable)
                DlmButton(
                  label: l.files_edit,
                  onPressed: () => setState(
                    () => _picked = {
                      for (final f in files)
                        if (f.selected) f.index,
                    },
                  ),
                ),
            ],
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
/// a file that is not downloaded says so. With [picked] every file and folder
/// has a checkbox and [onToggle] is called with the file indexes it covers.
List<DlmTreeNode> buildFileTree(
  List<File> files,
  AppLocalizations l, {
  required String? Function(int bytes) sizes,
  Set<int>? picked,
  void Function(Iterable<int> indexes, bool on)? onToggle,
}) {
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
  return root.nodes(l, picked, onToggle, sizes);
}

class _Folder {
  _Folder(this.path);

  final String path;
  final Map<String, _Folder> folders = {};
  final List<(String, File)> files = [];

  int get total =>
      files.fold(0, (s, f) => s + f.$2.size) +
      folders.values.fold(0, (s, d) => s + d.total);

  List<int> get indexes => [
    for (final f in files) f.$2.index,
    for (final d in folders.values) ...d.indexes,
  ];

  List<DlmTreeNode> nodes(
    AppLocalizations l,
    Set<int>? picked,
    void Function(Iterable<int> indexes, bool on)? onToggle,
    String? Function(int bytes) sizes,
  ) => [
    for (final e in folders.entries)
      DlmTreeNode(
        id: 'dir:${e.value.path}',
        label: e.key,
        icon: picked == null
            ? const DlmIcon(DlmIconName.folder)
            : _folderBox(e.value, e.key, picked, onToggle!),
        trailing: Text(sizes(e.value.total) ?? ''),
        children: e.value.nodes(l, picked, onToggle, sizes),
      ),
    for (final (name, f) in files)
      DlmTreeNode(
        id: 'file:${f.index}',
        label: picked != null || f.selected
            ? name
            : '$name (${l.files_skipped})',
        icon: picked == null
            ? const DlmIcon(DlmIconName.file)
            : DlmCheckbox(
                value: picked.contains(f.index)
                    ? DlmCheckState.checked
                    : DlmCheckState.unchecked,
                semanticLabel: l.files_file_label(name),
                onChanged: (v) =>
                    onToggle!([f.index], v == DlmCheckState.checked),
              ),
        trailing: Text(sizes(f.size) ?? ''),
      ),
  ];

  static Widget _folderBox(
    _Folder d,
    String name,
    Set<int> picked,
    void Function(Iterable<int> indexes, bool on) onToggle,
  ) {
    final all = d.indexes;
    final n = all.where(picked.contains).length;
    return DlmCheckbox(
      value: n == 0
          ? DlmCheckState.unchecked
          : n == all.length
          ? DlmCheckState.checked
          : DlmCheckState.mixed,
      semanticLabel: name,
      onChanged: (v) => onToggle(all, v == DlmCheckState.checked),
    );
  }
}
