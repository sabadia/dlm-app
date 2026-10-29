import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shell/feedback.dart';
import 'add_input.dart';

/// How long the dialog waits after typing before it looks at the link.
const Duration addLookupDelay = Duration(milliseconds: 400);

/// Opens the add-download dialog. [initialText] pre-fills the links (the
/// clipboard, a dropped link).
Future<void> showAddDownload(
  BuildContext context,
  WidgetRef ref, {
  String initialText = '',
}) async {
  final l = AppLocalizations.of(context);
  await showDlmDialog<void>(
    context,
    semanticLabel: l.add_title,
    builder: (_) => AddDownloadDialog(initialText: initialText),
  );
}

/// What looking at the typed links found.
sealed class _Lookup {
  const _Lookup();
}

class _Idle extends _Lookup {
  const _Idle();
}

class _Busy extends _Lookup {
  const _Busy();
}

class _One extends _Lookup {
  const _One(this.result);
  final ResolveResult result;
}

class _Many extends _Lookup {
  const _Many(this.count, this.sample);
  final int count;
  final List<String> sample;
}

class _Bad extends _Lookup {
  const _Bad(this.error);
  final Object error;
}

/// The add-download dialog: links (one per line, or a pattern), a look at what
/// they are, where they go, and a warning for what is already there.
class AddDownloadDialog extends ConsumerStatefulWidget {
  /// Creates the dialog.
  const AddDownloadDialog({this.initialText = '', super.key});

  /// Links to start with.
  final String initialText;

  @override
  ConsumerState<AddDownloadDialog> createState() => _AddDownloadDialogState();
}

class _AddDownloadDialogState extends ConsumerState<AddDownloadDialog> {
  late final TextEditingController _links = TextEditingController(
    text: widget.initialText,
  );
  final TextEditingController _dir = TextEditingController();
  final TextEditingController _name = TextEditingController();
  Timer? _debounce;
  _Lookup _lookup = const _Idle();
  int _generation = 0;
  String? _queueId;
  bool _paused = false;
  bool _allowDuplicate = false;
  bool _adding = false;
  List<BatchItem> _failed = const [];

  @override
  void initState() {
    super.initState();
    if (widget.initialText.isNotEmpty) _schedule();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _links.dispose();
    _dir.dispose();
    _name.dispose();
    super.dispose();
  }

  List<String> get _typed => parseLinks(_links.text);

  void _schedule() {
    _debounce?.cancel();
    _generation++;
    if (_typed.isEmpty) {
      setState(() => _lookup = const _Idle());
      return;
    }
    setState(() {
      _lookup = const _Busy();
      _allowDuplicate = false;
    });
    _debounce = Timer(addLookupDelay, _look);
  }

  Future<void> _look() async {
    final mine = _generation;
    final links = _typed;
    if (links.isEmpty) return;
    final repo = ref.read(addRepositoryProvider);
    _Lookup found;
    try {
      if (links.length == 1 && !isPattern(links.single)) {
        found = _One(await repo.resolve(links.single, queueId: _queueId));
      } else {
        var count = 0;
        final sample = <String>[];
        for (final link in links) {
          if (isPattern(link)) {
            final e = await repo.expand(link);
            count += e.count;
            sample.addAll(e.urls ?? const []);
          } else {
            count++;
            sample.add(link);
          }
        }
        found = _Many(count, sample.take(5).toList());
      }
    } on Object catch (e) {
      found = _Bad(e);
    }
    if (!mounted || mine != _generation) return;
    setState(() => _lookup = found);
  }

  CreateTaskBody _body(String link, {String? resolveId, String? name}) =>
      CreateTaskBody(
        url: link,
        queueId: _queueId,
        dir: _dir.text.trim().isEmpty ? null : _dir.text.trim(),
        name: name == null || name.isEmpty ? null : name,
        paused: _paused ? true : null,
        allowDuplicate: _allowDuplicate ? true : null,
        resolveId: resolveId,
      );

  bool get _duplicateBlocks =>
      _lookup is _One &&
      (_lookup as _One).result.duplicateOf != null &&
      !_allowDuplicate;

  bool get _canAdd =>
      !_adding &&
      _lookup is! _Idle &&
      _lookup is! _Busy &&
      _lookup is! _Bad &&
      !_duplicateBlocks;

  Future<void> _add() async {
    final l = AppLocalizations.of(context);
    final repo = ref.read(addRepositoryProvider);
    final store = ref.read(taskStoreProvider);
    setState(() => _adding = true);
    try {
      final lookup = _lookup;
      if (lookup is _One) {
        final task = await repo.create(
          _body(
            _typed.single,
            resolveId: lookup.result.resolveId,
            name: _name.text.trim(),
          ),
        );
        store.tasks.put(task.id, task);
        if (!mounted) return;
        showNotice(context, ref, l.add_done_one(task.name ?? _typed.single));
        Navigator.of(context).pop();
        return;
      }
      final results = await repo.createMany([
        for (final link in _typed) _body(link),
      ]);
      for (final r in results) {
        final t = r.task;
        if (r.ok && t != null) store.tasks.put(t.id, t);
      }
      final failed = [
        for (final r in results)
          if (!r.ok) r,
      ];
      if (!mounted) return;
      if (failed.isEmpty) {
        showNotice(
          context,
          ref,
          l.add_done_many(results.where((r) => r.ok).length),
        );
        Navigator.of(context).pop();
      } else {
        // Keep the dialog open and say which links failed.
        setState(() => _failed = failed);
      }
    } on Object catch (e) {
      if (mounted) showFailure(context, ref, e);
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  Widget _summary(AppLocalizations l, DlmThemeData theme) {
    final caption = theme.typography.caption.copyWith(
      color: theme.colors.textSecondary,
    );
    switch (_lookup) {
      case _Idle():
        return const SizedBox.shrink();
      case _Busy():
        return Text(l.add_looking, style: caption);
      case _Bad(:final error):
        final presented = presentFailure(error);
        final text = presented == null
            ? null
            : problemMessage(l, presented.messageKey, presented.params) ??
                  presented.fallback;
        return DlmBanner(
          tone: DlmTone.danger,
          message: text == null || text.isEmpty
              ? l.toast_failure_unknown
              : text,
        );
      case _One(:final result):
        final files = result.resource.files?.length ?? 0;
        final size = result.resource.size >= 0
            ? formatBytes(result.resource.size)
            : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.name, style: theme.typography.subtitle),
            Text(
              [
                if (size != null) size,
                if (files > 1) l.add_files(files),
                result.engine,
              ].join(' · '),
              style: caption,
            ),
            if (result.duplicateOf != null) ...[
              SizedBox(height: theme.metrics.spacing.sm),
              DlmBanner(
                tone: DlmTone.warning,
                message: l.add_duplicate(result.duplicateOf!.name),
              ),
              SizedBox(height: theme.metrics.spacing.xs),
              DlmCheckbox(
                value: _allowDuplicate
                    ? DlmCheckState.checked
                    : DlmCheckState.unchecked,
                label: l.add_anyway,
                onChanged: (v) => setState(
                  () => _allowDuplicate = v == DlmCheckState.checked,
                ),
              ),
            ],
          ],
        );
      case _Many(:final count, :final sample):
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.add_many(count), style: theme.typography.subtitle),
            for (final s in sample)
              Text(s, style: caption, overflow: TextOverflow.ellipsis),
            if (count > sample.length) Text(l.add_more, style: caption),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final queues = ref.watch(queuesProvider).value ?? const <Queue>[];
    final defaultDir = ref
        .watch(globalSettingsProvider)
        .value
        ?.settings
        .downloadDir;
    final gap = SizedBox(height: theme.metrics.spacing.md);
    final single = _lookup is _One;

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DlmTextField(
          controller: _links,
          semanticLabel: l.add_links,
          placeholder: l.add_links_placeholder,
          minLines: 3,
          maxLines: 6,
          onChanged: (_) => _schedule(),
        ),
        gap,
        _summary(l, theme),
        for (final f in _failed)
          Padding(
            padding: EdgeInsets.only(top: theme.metrics.spacing.xs),
            child: DlmBanner(
              tone: DlmTone.danger,
              message:
                  '${f.url ?? ''}: ${f.error?.detail ?? f.error?.title ?? ''}',
            ),
          ),
        gap,
        DlmFormGroup(
          children: [
            if (queues.isNotEmpty)
              DlmFormRow(
                label: l.add_queue,
                control: DlmDropdown<String>(
                  semanticLabel: l.add_queue,
                  value:
                      _queueId ??
                      queues
                          .firstWhere(
                            (q) => q.isDefault,
                            orElse: () => queues.first,
                          )
                          .id,
                  choices: [
                    for (final q in queues)
                      DlmChoice(value: q.id, label: q.name),
                  ],
                  onChanged: (v) => setState(() => _queueId = v),
                ),
              ),
            DlmFormRow(
              label: l.add_folder,
              control: DlmTextField(
                controller: _dir,
                semanticLabel: l.add_folder,
                placeholder: defaultDir ?? l.add_folder_default,
              ),
            ),
            if (single)
              DlmFormRow(
                label: l.add_name,
                control: DlmTextField(
                  controller: _name,
                  semanticLabel: l.add_name,
                  placeholder: l.add_name_placeholder,
                ),
              ),
            DlmFormRow(
              label: l.add_paused,
              control: DlmSwitch(
                value: _paused,
                semanticLabel: l.add_paused,
                onChanged: (v) => setState(() => _paused = v),
              ),
            ),
          ],
        ),
      ],
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 560,
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: DlmDialogContent(
        title: l.add_title,
        child: Flexible(child: SingleChildScrollView(child: body)),
        actions: [
          DlmButton(
            label: l.files_cancel,
            onPressed: () => Navigator.of(context).pop(),
          ),
          DlmButton(
            label: l.add_button,
            variant: DlmButtonVariant.primary,
            onPressed: _canAdd ? _add : null,
          ),
        ],
      ),
    );
  }
}
