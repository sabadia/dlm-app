import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../add/folder_browser.dart';
import '../shell/feedback.dart';
import 'category_draft.dart';

/// How long the tester waits after typing before it asks the daemon.
const Duration matchDelay = Duration(milliseconds: 300);

/// The categories: the rules that sort finished downloads into folders, their
/// order (the first match wins), and a tester that shows where a file would go.
class CategoriesScreen extends ConsumerWidget {
  /// Creates the page.
  const CategoriesScreen({super.key});

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, {
    Category? category,
  }) async {
    final l = AppLocalizations.of(context);
    final draft = await showDlmDialog<CategoryDraft>(
      context,
      semanticLabel: category == null ? l.cat_add_title : l.cat_edit_title,
      builder: (_) => CategoryDialog(category: category),
    );
    if (draft == null || !context.mounted) return;
    try {
      final controller = ref.read(categoriesProvider.notifier);
      if (category == null) {
        await controller.create(draft.toCreate());
      } else {
        await controller.edit(category.id, draft.toUpdate(category));
      }
      if (context.mounted) showNotice(context, ref, l.cat_saved);
    } on Object catch (e) {
      if (context.mounted) showFailure(context, ref, e);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final l = AppLocalizations.of(context);
    final ok = await showDlmConfirm(
      context,
      title: l.cat_delete_title(category.name),
      message: l.cat_delete_message,
      confirmLabel: l.cat_delete_confirm,
      cancelLabel: l.delete_cancel,
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(categoriesProvider.notifier).remove(category.id);
    } on Object catch (e) {
      if (context.mounted) showFailure(context, ref, e);
    }
  }

  Future<void> _move(
    BuildContext context,
    WidgetRef ref,
    Category category,
    int to,
  ) async {
    try {
      await ref.read(categoriesProvider.notifier).moveTo(category.id, to);
    } on Object catch (e) {
      if (context.mounted) showFailure(context, ref, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final async = ref.watch(categoriesProvider);
    final list = async.value;
    if (list == null) {
      return async.hasError
          ? DlmErrorState(
              title: l.list_error_title,
              message: async.error.toString(),
              retryLabel: l.list_retry,
              onRetry: () => ref.invalidate(categoriesProvider),
            )
          : DlmLoadingState(label: l.list_loading);
    }
    final gap = theme.metrics.spacing.md;
    return Padding(
      padding: EdgeInsets.all(theme.metrics.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.cat_intro,
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          SizedBox(height: gap),
          const MatchTester(),
          SizedBox(height: gap),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: DlmButton(
              label: l.cat_add,
              icon: const DlmIcon(DlmIconName.plus),
              variant: DlmButtonVariant.primary,
              onPressed: () => unawaited(_edit(context, ref)),
            ),
          ),
          SizedBox(height: gap),
          Expanded(
            child: list.isEmpty
                ? DlmEmptyState(
                    title: l.cat_empty_title,
                    message: l.cat_empty_message,
                  )
                : ReorderableList(
                    itemCount: list.length,
                    onReorderItem: (from, to) {
                      if (to != from) {
                        unawaited(_move(context, ref, list[from], to));
                      }
                    },
                    itemBuilder: (context, i) {
                      final c = list[i];
                      return _CategoryRow(
                        key: ValueKey(c.id),
                        index: i,
                        category: c,
                        last: i == list.length - 1,
                        onEdit: () =>
                            unawaited(_edit(context, ref, category: c)),
                        onDelete: () => unawaited(_delete(context, ref, c)),
                        onMove: (to) => unawaited(_move(context, ref, c, to)),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.index,
    required this.category,
    required this.last,
    required this.onEdit,
    required this.onDelete,
    required this.onMove,
    super.key,
  });

  final int index;
  final Category category;
  final bool last;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<int> onMove;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final rules = [
      ...?category.extensions?.map((e) => '.$e'),
      ...?category.mimeTypes,
    ];
    return Padding(
      padding: EdgeInsets.only(bottom: theme.metrics.spacing.xs),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.raised,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: EdgeInsets.all(theme.metrics.spacing.sm),
          child: Row(
            children: [
              ReorderableDragStartListener(
                index: index,
                child: Semantics(
                  label: l.cat_drag(category.name),
                  child: const DlmIcon(DlmIconName.menu),
                ),
              ),
              SizedBox(width: theme.metrics.spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.name, style: theme.typography.subtitle),
                    Text(
                      category.dir,
                      style: theme.typography.caption.copyWith(
                        color: theme.colors.textSecondary,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: theme.metrics.spacing.xs),
                      child: Wrap(
                        spacing: theme.metrics.spacing.xs,
                        runSpacing: theme.metrics.spacing.xs,
                        children: [for (final r in rules) DlmBadge(label: r)],
                      ),
                    ),
                  ],
                ),
              ),
              DlmIconButton(
                icon: const DlmIcon(DlmIconName.chevronUp),
                semanticLabel: l.cat_move_up(category.name),
                size: DlmControlSize.small,
                onPressed: index == 0 ? null : () => onMove(index - 1),
              ),
              DlmIconButton(
                icon: const DlmIcon(DlmIconName.chevronDown),
                semanticLabel: l.cat_move_down(category.name),
                size: DlmControlSize.small,
                onPressed: last ? null : () => onMove(index + 1),
              ),
              DlmIconButton(
                icon: const DlmIcon(DlmIconName.edit),
                semanticLabel: l.cat_edit(category.name),
                size: DlmControlSize.small,
                onPressed: onEdit,
              ),
              DlmIconButton(
                icon: const DlmIcon(DlmIconName.trash),
                semanticLabel: l.cat_delete(category.name),
                size: DlmControlSize.small,
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Asks the daemon where a file with a given name and type would be sorted.
class MatchTester extends ConsumerStatefulWidget {
  /// Creates the tester.
  const MatchTester({super.key});

  @override
  ConsumerState<MatchTester> createState() => _MatchTesterState();
}

class _MatchTesterState extends ConsumerState<MatchTester> {
  String _name = '';
  String _mime = '';
  Timer? _debounce;
  int _generation = 0;
  Category? _found;
  bool _asked = false;
  Object? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _changed() {
    _debounce?.cancel();
    _generation++;
    if (_name.trim().isEmpty && _mime.trim().isEmpty) {
      setState(() {
        _asked = false;
        _found = null;
        _error = null;
      });
      return;
    }
    _debounce = Timer(matchDelay, _ask);
  }

  Future<void> _ask() async {
    final mine = _generation;
    try {
      final found = await ref
          .read(categoriesProvider.notifier)
          .match(
            name: _name.trim().isEmpty ? null : _name.trim(),
            mimeType: _mime.trim().isEmpty ? null : _mime.trim(),
          );
      if (!mounted || mine != _generation) return;
      setState(() {
        _asked = true;
        _found = found;
        _error = null;
      });
    } on Object catch (e) {
      if (mounted && mine == _generation) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    // Rules changed since the last answer: ask again.
    ref.listen(categoriesProvider, (_, _) {
      if (_asked) _changed();
    });
    final result = _error != null
        ? l.cat_test_error
        : !_asked
        ? null
        : _found == null
        ? l.cat_test_none
        : l.cat_test_found(_found!.name, _found!.dir);
    return DlmFormGroup(
      title: l.cat_test_title,
      children: [
        DlmFormRow(
          label: l.cat_test_name,
          control: SizedBox(
            width: 260,
            child: DlmTextField(
              semanticLabel: l.cat_test_name,
              placeholder: 'movie.mkv',
              onChanged: (v) {
                _name = v;
                _changed();
              },
            ),
          ),
        ),
        DlmFormRow(
          label: l.cat_test_mime,
          control: SizedBox(
            width: 260,
            child: DlmTextField(
              semanticLabel: l.cat_test_mime,
              placeholder: 'video/x-matroska',
              onChanged: (v) {
                _mime = v;
                _changed();
              },
            ),
          ),
        ),
        if (result != null)
          Padding(
            padding: EdgeInsets.all(theme.metrics.spacing.sm),
            child: Text(
              result,
              style: theme.typography.body.copyWith(
                color: _found == null
                    ? theme.colors.textSecondary
                    : theme.colors.success,
              ),
            ),
          ),
      ],
    );
  }
}

/// The add/edit dialog of a category; pops the [CategoryDraft].
class CategoryDialog extends ConsumerStatefulWidget {
  /// Creates the dialog; [category] is null for a new one.
  const CategoryDialog({this.category, super.key});

  /// The category being edited.
  final Category? category;

  @override
  ConsumerState<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends ConsumerState<CategoryDialog> {
  late final CategoryDraft _draft = CategoryDraft(from: widget.category);
  late final TextEditingController _name = TextEditingController(
    text: _draft.name,
  );
  late final TextEditingController _dir = TextEditingController(
    text: _draft.dir,
  );
  late final TextEditingController _ext = TextEditingController(
    text: _draft.extensions,
  );
  late final TextEditingController _mime = TextEditingController(
    text: _draft.mimeTypes,
  );

  @override
  void dispose() {
    _name.dispose();
    _dir.dispose();
    _ext.dispose();
    _mime.dispose();
    super.dispose();
  }

  Future<void> _browse() async {
    final chosen = await pickDaemonFolder(
      context,
      start: _dir.text.trim().isEmpty ? null : _dir.text.trim(),
    );
    if (chosen != null && mounted) {
      setState(() {
        _dir.text = chosen;
        _draft.dir = chosen;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final d = _draft;
    final body = DlmFormGroup(
      children: [
        DlmFormRow(
          label: l.cat_name,
          control: DlmTextField(
            semanticLabel: l.cat_name,
            controller: _name,
            onChanged: (v) => setState(() => d.name = v),
          ),
        ),
        DlmFormRow(
          label: l.cat_folder,
          description: l.cat_folder_desc,
          control: Row(
            children: [
              Expanded(
                child: DlmTextField(
                  controller: _dir,
                  semanticLabel: l.cat_folder,
                  onChanged: (v) => setState(() => d.dir = v),
                ),
              ),
              SizedBox(width: theme.metrics.spacing.xs),
              DlmIconButton(
                icon: const DlmIcon(DlmIconName.folder),
                semanticLabel: l.add_folder_browse,
                onPressed: () => unawaited(_browse()),
              ),
            ],
          ),
        ),
        DlmFormRow(
          label: l.cat_extensions,
          description: l.cat_extensions_desc,
          control: DlmTextField(
            semanticLabel: l.cat_extensions,
            controller: _ext,
            errorText: d.extensionsValid ? null : l.cat_extensions_invalid,
            onChanged: (v) => setState(() => d.extensions = v),
          ),
        ),
        DlmFormRow(
          label: l.cat_mime,
          description: l.cat_mime_desc,
          control: DlmTextField(
            semanticLabel: l.cat_mime,
            controller: _mime,
            minLines: 2,
            maxLines: 4,
            errorText: d.mimeTypesValid ? null : l.cat_mime_invalid,
            onChanged: (v) => setState(() => d.mimeTypes = v),
          ),
        ),
      ],
    );
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: DlmDialogContent(
        title: widget.category == null ? l.cat_add_title : l.cat_edit_title,
        child: Flexible(child: SingleChildScrollView(child: body)),
        actions: [
          DlmButton(
            label: l.files_cancel,
            onPressed: () => Navigator.of(context).pop(),
          ),
          DlmButton(
            label: l.queue_save,
            variant: DlmButtonVariant.primary,
            onPressed: d.valid ? () => Navigator.of(context).pop(d) : null,
          ),
        ],
      ),
    );
  }
}
