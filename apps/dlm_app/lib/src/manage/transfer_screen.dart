import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../add/add_dialog.dart' show addFilePickerProvider, importFormatOf;
import '../add/add_results.dart';
import '../shell/feedback.dart';
import 'cookies_screen.dart' show saveTextFileProvider;

/// Importing and exporting download lists: read a list (links, dlm JSON, an
/// aria2 input file), preview what would be added, then add it; or write the
/// tasks out as a list.
class TransferScreen extends ConsumerStatefulWidget {
  /// Creates the page.
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  // Import
  final TextEditingController _content = TextEditingController();
  ImportTasksBodyFormat _format = ImportTasksBodyFormat.urls;
  String? _queueId;
  bool _paused = false;
  bool _allowDuplicate = false;
  List<BatchItem>? _preview;
  List<BatchItem>? _imported;
  bool _busy = false;

  // Export
  Format2 _exportFormat = Format2.valueJson;
  String? _exportQueue;
  String _exportStatus = '';
  ExportedTasks? _exported;
  final TextEditingController _exportText = TextEditingController();

  @override
  void dispose() {
    _content.dispose();
    _exportText.dispose();
    super.dispose();
  }

  void _editedList() => setState(() {
    _preview = null;
    _imported = null;
  });

  Future<void> _choose() async {
    try {
      final picked = await ref.read(addFilePickerProvider)();
      if (picked == null || !mounted) return;
      setState(() {
        _content.text = picked.content;
        _format = importFormatOf(picked.name);
        _preview = null;
        _imported = null;
      });
    } on Object catch (e) {
      if (mounted) showFailure(context, ref, e);
    }
  }

  Future<List<BatchItem>> _run({required bool dryRun}) => ref
      .read(addRepositoryProvider)
      .importList(
        _content.text,
        _format,
        queueId: _queueId,
        paused: _paused,
        dryRun: dryRun,
        allowDuplicate: _allowDuplicate,
      );

  Future<void> _previewList() async {
    setState(() => _busy = true);
    try {
      final results = await _run(dryRun: true);
      if (mounted) {
        setState(() {
          _preview = results;
          _imported = null;
        });
      }
    } on Object catch (e) {
      // 422: the list cannot be read at all.
      if (mounted) showFailure(context, ref, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    setState(() => _busy = true);
    try {
      final results = await _run(dryRun: false);
      final store = ref.read(taskStoreProvider);
      for (final r in results) {
        final t = r.task;
        if (r.ok && t != null) store.tasks.put(t.id, t);
      }
      if (mounted) {
        setState(() {
          _imported = results;
          _preview = null;
        });
      }
    } on Object catch (e) {
      if (mounted) showFailure(context, ref, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final out = await ref
          .read(addRepositoryProvider)
          .exportTasks(
            _exportFormat,
            queueId: _exportQueue,
            statuses: _exportStatus.isEmpty ? const {} : {_exportStatus},
          );
      if (mounted) {
        _exportText.text = out.content;
        setState(() => _exported = out);
      }
    } on Object catch (e) {
      if (mounted) showFailure(context, ref, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String get _exportName {
    final ext = switch (_exportFormat) {
      Format2.valueJson => 'json',
      Format2.aria2 => 'aria2',
      _ => 'txt',
    };
    return 'downloads.$ext';
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    try {
      final saved = await ref.read(saveTextFileProvider)(
        _exportName,
        _exported!.content,
      );
      if (saved && mounted) showNotice(context, ref, l.ck_saved);
    } on Object catch (e) {
      if (mounted) showFailure(context, ref, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final queues = ref.watch(queuesProvider).value ?? const <Queue>[];
    final gap = SizedBox(height: theme.metrics.spacing.md);
    final preview = _preview;
    final imported = _imported;
    final shown = preview ?? imported;
    final ok = shown?.where((r) => r.ok).length ?? 0;

    List<DlmChoice<String?>> queueChoices(String all) => [
      DlmChoice(value: null, label: all),
      for (final q in queues) DlmChoice(value: q.id, label: q.name),
    ];

    return ListView(
      padding: EdgeInsets.all(theme.metrics.spacing.lg),
      children: [
        Text(
          l.tr_intro,
          style: theme.typography.body.copyWith(
            color: theme.colors.textSecondary,
          ),
        ),
        gap,
        DlmFormGroup(
          title: l.tr_import_title,
          children: [
            DlmFormRow(
              label: l.tr_list,
              description: l.tr_list_desc,
              control: SizedBox(
                width: 520,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DlmTextField(
                      controller: _content,
                      semanticLabel: l.tr_list,
                      minLines: 5,
                      maxLines: 8,
                      onChanged: (_) => _editedList(),
                    ),
                    SizedBox(height: theme.metrics.spacing.xs),
                    DlmButton(
                      label: l.tr_choose,
                      icon: const DlmIcon(DlmIconName.file),
                      variant: DlmButtonVariant.plain,
                      onPressed: () => unawaited(_choose()),
                    ),
                  ],
                ),
              ),
            ),
            DlmFormRow(
              label: l.tr_format,
              control: SizedBox(
                width: 240,
                child: DlmDropdown<ImportTasksBodyFormat>(
                  semanticLabel: l.tr_format,
                  value: _format,
                  choices: [
                    DlmChoice(
                      value: ImportTasksBodyFormat.urls,
                      label: l.tr_format_urls,
                    ),
                    DlmChoice(
                      value: ImportTasksBodyFormat.valueJson,
                      label: l.tr_format_json,
                    ),
                    DlmChoice(
                      value: ImportTasksBodyFormat.aria2,
                      label: l.tr_format_aria2,
                    ),
                  ],
                  onChanged: (v) {
                    _format = v;
                    _editedList();
                  },
                ),
              ),
            ),
            if (queues.isNotEmpty)
              DlmFormRow(
                label: l.add_queue,
                control: SizedBox(
                  width: 240,
                  child: DlmDropdown<String?>(
                    semanticLabel: l.add_queue,
                    value: _queueId,
                    choices: queueChoices(l.tr_default_queue),
                    onChanged: (v) {
                      _queueId = v;
                      _editedList();
                    },
                  ),
                ),
              ),
            DlmFormRow(
              label: l.add_paused,
              control: DlmSwitch(
                value: _paused,
                semanticLabel: l.add_paused,
                onChanged: (v) {
                  _paused = v;
                  _editedList();
                },
              ),
            ),
            DlmFormRow(
              label: l.tr_duplicates,
              description: l.tr_duplicates_desc,
              control: DlmSwitch(
                value: _allowDuplicate,
                semanticLabel: l.tr_duplicates,
                onChanged: (v) {
                  _allowDuplicate = v;
                  _editedList();
                },
              ),
            ),
          ],
        ),
        gap,
        Wrap(
          spacing: theme.metrics.spacing.sm,
          children: [
            DlmButton(
              label: l.tr_preview,
              onPressed: _busy || _content.text.trim().isEmpty
                  ? null
                  : () => unawaited(_previewList()),
            ),
            if (preview != null)
              DlmButton(
                label: l.add_import_go(ok),
                variant: DlmButtonVariant.primary,
                onPressed: _busy || ok == 0 ? null : () => unawaited(_import()),
              ),
          ],
        ),
        if (shown != null) ...[
          gap,
          Text(
            preview != null
                ? l.tr_preview_summary(ok, shown.length - ok)
                : l.add_results_summary(ok, shown.length - ok),
            style: theme.typography.subtitle,
          ),
          BatchResultList(results: shown),
        ],
        SizedBox(height: theme.metrics.spacing.lg),
        DlmFormGroup(
          title: l.tr_export_title,
          children: [
            DlmFormRow(
              label: l.tr_format,
              control: SizedBox(
                width: 240,
                child: DlmDropdown<Format2>(
                  semanticLabel: l.tr_export_format,
                  value: _exportFormat,
                  choices: [
                    DlmChoice(
                      value: Format2.valueJson,
                      label: l.tr_format_json,
                    ),
                    DlmChoice(value: Format2.urls, label: l.tr_format_urls),
                    DlmChoice(value: Format2.aria2, label: l.tr_format_aria2),
                  ],
                  onChanged: (v) => setState(() {
                    _exportFormat = v;
                    _exported = null;
                  }),
                ),
              ),
            ),
            if (queues.isNotEmpty)
              DlmFormRow(
                label: l.tr_export_queue,
                control: SizedBox(
                  width: 240,
                  child: DlmDropdown<String?>(
                    semanticLabel: l.tr_export_queue,
                    value: _exportQueue,
                    choices: queueChoices(l.tr_all_queues),
                    onChanged: (v) => setState(() {
                      _exportQueue = v;
                      _exported = null;
                    }),
                  ),
                ),
              ),
            DlmFormRow(
              label: l.tr_export_status,
              control: SizedBox(
                width: 240,
                child: DlmDropdown<String>(
                  semanticLabel: l.tr_export_status,
                  value: _exportStatus,
                  choices: [
                    DlmChoice(value: '', label: l.tr_all_statuses),
                    DlmChoice(value: 'queued', label: l.nav_queued),
                    DlmChoice(value: 'running', label: l.nav_active),
                    DlmChoice(value: 'paused', label: l.nav_paused),
                    DlmChoice(value: 'completed', label: l.nav_completed),
                    DlmChoice(value: 'error', label: l.nav_failed),
                  ],
                  onChanged: (v) => setState(() {
                    _exportStatus = v;
                    _exported = null;
                  }),
                ),
              ),
            ),
          ],
        ),
        gap,
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: DlmButton(
            label: l.tr_export,
            onPressed: _busy ? null : () => unawaited(_export()),
          ),
        ),
        if (_exported != null) ...[
          gap,
          Text(
            l.tr_export_count(_exported!.count),
            style: theme.typography.subtitle,
          ),
          SizedBox(height: theme.metrics.spacing.xs),
          SizedBox(
            height: 180,
            child: DlmTextField(
              controller: _exportText,
              semanticLabel: l.tr_export_text,
              minLines: 7,
              maxLines: 7,
            ),
          ),
          SizedBox(height: theme.metrics.spacing.xs),
          Wrap(
            spacing: theme.metrics.spacing.sm,
            children: [
              DlmButton(
                label: l.ck_copy,
                icon: const DlmIcon(DlmIconName.copy),
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: _exported!.content),
                  );
                  if (context.mounted) showNotice(context, ref, l.ck_copied);
                },
              ),
              DlmButton(label: l.ck_save, onPressed: () => unawaited(_save())),
            ],
          ),
        ],
      ],
    );
  }
}
