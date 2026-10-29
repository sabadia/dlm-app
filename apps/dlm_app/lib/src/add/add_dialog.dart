import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../format/dlm_format.dart';
import '../inspector/files_tab.dart';
import '../manage/credential_draft.dart';
import '../manage/logins_screen.dart';
import '../shell/feedback.dart';
import 'add_advanced.dart';
import 'add_input.dart';
import 'add_results.dart';
import 'folder_browser.dart';

/// How long the dialog waits after typing before it looks at the link.
const Duration addLookupDelay = Duration(milliseconds: 400);

/// A list file chosen by the user: its name and text.
typedef PickedList = ({String name, String content});

/// Asks the user for a list of downloads (a text file of links, an exported
/// JSON list, an aria2 input file); null when cancelled. A seam for tests.
final addFilePickerProvider = Provider<Future<PickedList?> Function()>(
  (ref) => () async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'Download lists',
          extensions: ['txt', 'json', 'aria2', 'input', 'lst'],
        ),
      ],
    );
    if (file == null) return null;
    return (name: file.name, content: await file.readAsString());
  },
);

/// A .torrent file chosen by the user: its name and bytes.
typedef PickedTorrent = ({String name, Uint8List bytes});

/// The largest .torrent file the daemon accepts.
const int maxTorrentBytes = 16 << 20;

/// Asks the user for a .torrent file; null when cancelled. A seam for tests.
final addTorrentPickerProvider = Provider<Future<PickedTorrent?> Function()>(
  (ref) => () async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'Torrent files', extensions: ['torrent']),
      ],
    );
    if (file == null) return null;
    return (name: file.name, bytes: await file.readAsBytes());
  },
);

/// The embedded form of a .torrent file that the daemon takes as a link.
String torrentDataUrl(Uint8List bytes) =>
    'data:application/x-bittorrent;base64,${base64.encode(bytes)}';

/// How a list file is read, from its name.
ImportTasksBodyFormat importFormatOf(String fileName) {
  final lower = fileName.toLowerCase();
  if (lower.endsWith('.json')) return ImportTasksBodyFormat.valueJson;
  if (lower.endsWith('.aria2') || lower.endsWith('.input')) {
    return ImportTasksBodyFormat.aria2;
  }
  return ImportTasksBodyFormat.urls;
}

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
  const _One(this.result, [this.category]);
  final ResolveResult result;

  /// The category the finished file would be sorted into, if any.
  final Category? category;
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
  bool _showAdvanced = false;

  /// The .torrent files added by hand: the name shown and the embedded link.
  final List<({String name, String url})> _torrents = [];
  final AdvancedDraft _adv = AdvancedDraft();
  final TextEditingController _referrer = TextEditingController();
  final TextEditingController _headers = TextEditingController();
  final TextEditingController _mirrors = TextEditingController();
  final TextEditingController _digest = TextEditingController();

  /// The indexes of the files to download when the link has several; null
  /// until the user changes the choice (then the daemon's default applies).
  Set<int>? _pickedFiles;
  Set<Object>? _expandedFiles;

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
    _referrer.dispose();
    _headers.dispose();
    _mirrors.dispose();
    _digest.dispose();
    super.dispose();
  }

  List<String> get _typed => [
    ...parseLinks(_links.text),
    for (final t in _torrents) t.url,
  ];

  /// What to show for a link: the file name of an embedded torrent.
  String _label(String link) =>
      _torrents.where((t) => t.url == link).firstOrNull?.name ?? link;

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
      _pickedFiles = null;
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
        final result = await repo.resolve(links.single, queueId: _queueId);
        Category? category;
        try {
          category = await ref
              .read(categoriesProvider.notifier)
              .match(name: result.name);
        } on Object {
          // A preview only: the add works without it.
        }
        found = _One(result, category);
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
        found = _Many(count, [for (final u in sample.take(5)) _label(u)]);
      }
    } on Object catch (e) {
      found = _Bad(e);
    }
    if (!mounted || mine != _generation) return;
    setState(() => _lookup = found);
  }

  CreateTaskBody _body(
    String link, {
    String? resolveId,
    String? name,
    bool? paused,
  }) {
    final advanced = !_adv.isEmpty;
    return CreateTaskBody(
      // The advanced options describe the source, so the link goes in it.
      url: advanced ? null : link,
      source: advanced ? _adv.source(link) : null,
      settings: _adv.settings,
      queueId: _queueId,
      dir: _dir.text.trim().isEmpty ? null : _dir.text.trim(),
      name: name == null || name.isEmpty ? null : name,
      paused: (paused ?? _paused) ? true : null,
      allowDuplicate: _allowDuplicate ? true : null,
      resolveId: advanced ? null : resolveId,
    );
  }

  bool get _duplicateBlocks =>
      _lookup is _One &&
      (_lookup as _One).result.duplicateOf != null &&
      !_allowDuplicate;

  bool get _canAdd =>
      !_adding &&
      _adv.valid &&
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
        final files = lookup.result.resource.files ?? const <File>[];
        final picked = _pickedFiles;
        // A changed file choice is applied after the task exists, while it is
        // still paused (an active task cannot change its files).
        final changed =
            picked != null &&
            files.length > 1 &&
            files.any((f) => f.selected != picked.contains(f.index));
        var task = await repo.create(
          _body(
            _typed.single,
            resolveId: lookup.result.resolveId,
            name: _name.text.trim(),
            paused: changed ? true : null,
          ),
        );
        if (changed) {
          task = await ref
              .read(taskDetailRepositoryProvider)
              .setFiles(task.id, picked.toList()..sort());
          store.tasks.put(task.id, task);
          if (!_paused) {
            await ref.read(taskActionsProvider).resume([task.id]);
          }
        } else {
          store.tasks.put(task.id, task);
        }
        if (!mounted) return;
        showNotice(context, ref, l.add_done_one(task.name ?? _typed.single));
        Navigator.of(context).pop();
        return;
      }
      final results = await repo.createMany([
        for (final link in _typed) _body(link),
      ]);
      await _finish(results);
    } on Object catch (e) {
      if (mounted) showFailure(context, ref, e);
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  /// Puts the created tasks in the cache and reports a batch: a short notice
  /// when all went through, the result sheet when some did not.
  Future<void> _finish(List<BatchItem> results) async {
    final l = AppLocalizations.of(context);
    final store = ref.read(taskStoreProvider);
    for (final r in results) {
      final t = r.task;
      if (r.ok && t != null) store.tasks.put(t.id, t);
    }
    final added = results.where((r) => r.ok).length;
    if (results.any((r) => !r.ok)) {
      await showAddResults(
        context,
        title: l.add_results_title,
        results: results,
      );
      if (mounted && added > 0) Navigator.of(context).pop();
      return;
    }
    if (!mounted) return;
    showNotice(context, ref, l.add_done_many(added));
    Navigator.of(context).pop();
  }

  Future<void> _import() async {
    final l = AppLocalizations.of(context);
    final repo = ref.read(addRepositoryProvider);
    try {
      final picked = await ref.read(addFilePickerProvider)();
      if (picked == null || !mounted) return;
      final format = importFormatOf(picked.name);
      final preview = await repo.importList(
        picked.content,
        format,
        queueId: _queueId,
        paused: _paused,
        dryRun: true,
      );
      if (!mounted) return;
      final go = await showAddResults(
        context,
        title: l.add_import_title(picked.name),
        results: preview,
        confirmLabel: l.add_import_go(preview.where((r) => r.ok).length),
      );
      if (!go || !mounted) return;
      setState(() => _adding = true);
      final results = await repo.importList(
        picked.content,
        format,
        queueId: _queueId,
        paused: _paused,
      );
      await _finish(results);
    } on Object catch (e) {
      if (mounted) showFailure(context, ref, e);
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  Future<void> _pickTorrent() async {
    final l = AppLocalizations.of(context);
    try {
      final picked = await ref.read(addTorrentPickerProvider)();
      if (picked == null || !mounted) return;
      if (picked.bytes.length > maxTorrentBytes) {
        showNotice(context, ref, l.add_torrent_too_big, tone: DlmTone.danger);
        return;
      }
      setState(() {
        _torrents.add((name: picked.name, url: torrentDataUrl(picked.bytes)));
      });
      _schedule();
    } on Object catch (e) {
      if (mounted) showFailure(context, ref, e);
    }
  }

  Future<void> _browse() async {
    final chosen = await pickDaemonFolder(
      context,
      start: _dir.text.trim().isEmpty ? null : _dir.text.trim(),
    );
    if (chosen != null && mounted) setState(() => _dir.text = chosen);
  }

  /// The tree of the files of a multi-file link with a checkbox on each.
  Widget _fileChoice(AppLocalizations l, DlmThemeData theme, List<File> files) {
    final picked =
        _pickedFiles ??
        {
          for (final f in files)
            if (f.selected) f.index,
        };
    final roots = buildFileTree(
      files,
      l,
      sizes: context.bytes,
      picked: picked,
      onToggle: (indexes, on) => setState(() {
        final next = {...picked};
        on ? next.addAll(indexes) : next.removeAll(indexes);
        _pickedFiles = next;
      }),
    );
    _expandedFiles ??= {
      for (final n in roots)
        if (n.children.isNotEmpty) n.id,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          picked.isEmpty
              ? l.files_pick_one
              : l.files_count(picked.length, files.length),
          style: theme.typography.caption.copyWith(
            color: theme.colors.textSecondary,
          ),
        ),
        SizedBox(
          height: 180,
          child: DlmTree(
            roots: roots,
            semanticLabel: l.files_tree_label,
            expandedIds: _expandedFiles!,
            onExpandedChanged: (ids) => setState(() => _expandedFiles = ids),
          ),
        ),
      ],
    );
  }

  Widget _advancedSection(AppLocalizations l, DlmThemeData theme) {
    final gap = SizedBox(height: theme.metrics.spacing.sm);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: DlmButton(
            label: l.add_advanced,
            icon: DlmIcon(
              _showAdvanced
                  ? DlmIconName.chevronDown
                  : DlmIconName.chevronRight,
            ),
            variant: DlmButtonVariant.plain,
            onPressed: () => setState(() => _showAdvanced = !_showAdvanced),
          ),
        ),
        if (_showAdvanced) ...[
          DlmFormGroup(
            children: [
              DlmFormRow(
                label: l.add_mode,
                control: DlmDropdown<AddMode>(
                  semanticLabel: l.add_mode,
                  value: _adv.mode,
                  choices: [
                    DlmChoice(value: AddMode.auto, label: l.add_mode_auto),
                    DlmChoice(value: AddMode.direct, label: l.add_mode_direct),
                    DlmChoice(value: AddMode.ytdlp, label: l.add_mode_ytdlp),
                    DlmChoice(
                      value: AddMode.browser,
                      label: l.add_mode_browser,
                    ),
                  ],
                  onChanged: (v) => setState(() => _adv.mode = v),
                ),
              ),
              DlmFormRow(
                label: l.add_referrer,
                control: DlmTextField(
                  controller: _referrer,
                  semanticLabel: l.add_referrer,
                  onChanged: (v) => setState(() => _adv.referrer = v),
                ),
              ),
              DlmFormRow(
                label: l.add_headers,
                description: l.add_headers_hint,
                control: DlmTextField(
                  controller: _headers,
                  semanticLabel: l.add_headers,
                  minLines: 2,
                  maxLines: 4,
                  errorText: _adv.parsedHeaders == null
                      ? l.add_headers_invalid
                      : null,
                  onChanged: (v) => setState(() => _adv.headers = v),
                ),
              ),
              DlmFormRow(
                label: l.add_mirrors,
                description: l.add_mirrors_hint,
                control: DlmTextField(
                  controller: _mirrors,
                  semanticLabel: l.add_mirrors,
                  minLines: 2,
                  maxLines: 4,
                  onChanged: (v) => setState(() => _adv.mirrors = v),
                ),
              ),
              DlmFormRow(
                label: l.add_checksum,
                control: SizedBox(
                  width: 340,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 120,
                        child: DlmDropdown<String>(
                          semanticLabel: l.add_checksum_algorithm,
                          value: _adv.algorithm,
                          choices: [
                            for (final a in checksumHexLength.keys)
                              DlmChoice(value: a, label: a),
                          ],
                          onChanged: (v) => setState(() => _adv.algorithm = v),
                        ),
                      ),
                      SizedBox(width: theme.metrics.spacing.sm),
                      Expanded(
                        child: DlmTextField(
                          controller: _digest,
                          semanticLabel: l.add_checksum,
                          placeholder: l.add_checksum_placeholder,
                          errorText: _adv.digestValid
                              ? null
                              : l.add_checksum_invalid,
                          onChanged: (v) => setState(() => _adv.digest = v),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          gap,
        ],
      ],
    );
  }

  /// Says whether a login and cookies are stored for the site of the link, and
  /// offers to add a login.
  Widget _siteHelpers(
    AppLocalizations l,
    DlmThemeData theme,
    ResolveResult result,
  ) {
    final host = Uri.tryParse(result.source.currentUrl)?.host ?? '';
    if (host.isEmpty) return const SizedBox.shrink();
    final logins = ref.watch(credentialsProvider).value ?? const <Credential>[];
    final cookies = ref.watch(cookiesProvider).value ?? const <CookieInfo>[];
    bool loginFor(Credential c) =>
        c.host == host ||
        (c.host.startsWith('*.') && host.endsWith(c.host.substring(1)));
    bool cookieFor(CookieInfo c) {
      final d = c.domain.startsWith('.') ? c.domain.substring(1) : c.domain;
      return host == d || host.endsWith('.$d');
    }

    final hasLogin = logins.any(loginFor);
    final cookieCount = cookies.where(cookieFor).length;
    final caption = theme.typography.caption.copyWith(
      color: theme.colors.textSecondary,
    );
    return Padding(
      padding: EdgeInsets.only(top: theme.metrics.spacing.xs),
      child: Wrap(
        spacing: theme.metrics.spacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (hasLogin)
            Text(l.add_login_stored(host), style: caption)
          else ...[
            Text(l.add_login_none(host), style: caption),
            DlmButton(
              label: l.add_login_add,
              icon: const DlmIcon(DlmIconName.key),
              variant: DlmButtonVariant.plain,
              onPressed: () => unawaited(_addLogin(host)),
            ),
          ],
          Text(
            cookieCount > 0
                ? l.add_cookies_stored(cookieCount)
                : l.add_cookies_none,
            style: caption,
          ),
        ],
      ),
    );
  }

  Future<void> _addLogin(String host) async {
    final l = AppLocalizations.of(context);
    final draft = await showDlmDialog<CredentialDraft>(
      context,
      semanticLabel: l.login_add_title,
      builder: (_) => LoginDialog(initialHost: host),
    );
    if (draft == null || !mounted) return;
    try {
      await ref.read(credentialsProvider.notifier).create(draft.toCreate());
      if (mounted) showNotice(context, ref, l.login_saved);
    } on Object catch (e) {
      if (mounted) showFailure(context, ref, e);
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
      case _One(:final result, :final category):
        final files = result.resource.files?.length ?? 0;
        final size = result.resource.size >= 0
            ? context.bytes(result.resource.size)
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
            if (category != null && _dir.text.trim().isEmpty)
              Text(l.add_category(category.name, category.dir), style: caption),
            _siteHelpers(l, theme, result),
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
        Wrap(
          spacing: theme.metrics.spacing.xs,
          runSpacing: theme.metrics.spacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DlmButton(
              label: l.add_import,
              icon: const DlmIcon(DlmIconName.importIcon),
              variant: DlmButtonVariant.plain,
              onPressed: _adding ? null : _import,
            ),
            DlmButton(
              label: l.add_torrent,
              icon: const DlmIcon(DlmIconName.file),
              variant: DlmButtonVariant.plain,
              onPressed: _adding ? null : _pickTorrent,
            ),
            for (final t in _torrents)
              DlmChip(
                label: t.name,
                onDeleted: () {
                  setState(() => _torrents.remove(t));
                  _schedule();
                },
                deleteLabel: l.add_torrent_remove(t.name),
              ),
          ],
        ),
        gap,
        _summary(l, theme),
        if (_lookup case _One(:final result)
            when (result.resource.files?.length ?? 0) > 1) ...[
          gap,
          _fileChoice(l, theme, result.resource.files!),
        ],
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
              control: Row(
                children: [
                  Expanded(
                    child: DlmTextField(
                      controller: _dir,
                      semanticLabel: l.add_folder,
                      placeholder: defaultDir ?? l.add_folder_default,
                      // The category preview depends on the folder being empty.
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  SizedBox(width: theme.metrics.spacing.xs),
                  DlmIconButton(
                    icon: const DlmIcon(DlmIconName.folder),
                    semanticLabel: l.add_folder_browse,
                    onPressed: _browse,
                  ),
                ],
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
        _advancedSection(l, theme),
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
