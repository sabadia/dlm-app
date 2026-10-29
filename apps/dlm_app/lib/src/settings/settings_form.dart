import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../format/dlm_format.dart';
import '../shell/feedback.dart';
import 'settings_editors.dart';

/// Whether a settings form holds edits that were not saved. The shell asks
/// before it leaves the page.
class UnsavedSettings extends Notifier<bool> {
  @override
  bool build() => false;

  /// Sets whether there are unsaved edits.
  // ignore: use_setters_to_change_properties
  void mark({required bool dirty}) => state = dirty;
}

/// Whether a settings form has unsaved edits.
final unsavedSettingsProvider = NotifierProvider<UnsavedSettings, bool>(
  UnsavedSettings.new,
);

/// `maxConnections` -> `Max connections`.
String humaniseSetting(String word) {
  final spaced = word.replaceAllMapped(
    RegExp('([a-z0-9])([A-Z])'),
    (m) => '${m[1]} ${m[2]}',
  );
  if (spaced.isEmpty) return spaced;
  final lower = spaced.toLowerCase();
  return lower[0].toUpperCase() + lower.substring(1);
}

/// The label of the setting at [path]: `Max connections`, or for a nested
/// one `Retry: max attempts`.
String settingLabel(String path) {
  final steps = path.split('.');
  return steps.length == 1
      ? humaniseSetting(steps.single)
      : '${humaniseSetting(steps.first)}: ${humaniseSetting(steps.last).toLowerCase()}';
}

/// Types the generic form edits; structured values (a proxy, a schedule, a
/// list of actions) have their own editors.
bool editableType(FieldSchemaType type) => switch (type) {
  FieldSchemaType.boolean ||
  FieldSchemaType.integer ||
  FieldSchemaType.number ||
  FieldSchemaType.string ||
  FieldSchemaType.duration => true,
  _ => false,
};

/// Whether [text] is a Go duration such as `30s`, `1m30s` or `2h`.
bool isDuration(String text) =>
    RegExp(r'^(\d+(\.\d+)?(ns|us|µs|ms|s|m|h))+$').hasMatch(text.trim());

/// A form over the settings of one level, built from the daemon's own
/// description of the fields: grouped, searchable, with the level each value
/// comes from, reset-to-inherit, the daemon's field errors, and a save bar.
class SettingsForm extends ConsumerStatefulWidget {
  /// Creates the form for [target], limited to the field [groups] when given.
  const SettingsForm({
    required this.target,
    this.groups,
    this.paths,
    this.searchable = true,
    super.key,
  });

  /// Which layer is edited.
  final SettingsTarget target;

  /// Only the fields of these groups; null for all.
  final Set<String>? groups;

  /// Only the fields with these paths; null for all (in [groups]).
  final Set<String>? paths;

  /// Whether to show the search field.
  final bool searchable;

  @override
  ConsumerState<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends ConsumerState<SettingsForm> {
  SettingsDraft? _draft;
  SettingsSnapshot? _from;
  String _search = '';
  bool _saving = false;
  bool _changedElsewhere = false;

  late final ProviderContainer _container;

  @override
  void initState() {
    super.initState();
    _container = ProviderScope.containerOf(context, listen: false);
  }

  @override
  void dispose() {
    // The page is gone, so is the guard. Done after the frame: providers
    // cannot change while the tree is torn down.
    final container = _container;
    scheduleMicrotask(() {
      if (container.exists(unsavedSettingsProvider)) {
        container.read(unsavedSettingsProvider.notifier).mark(dirty: false);
      }
    });
    super.dispose();
  }

  void _touch() {
    setState(() {});
    final dirty = _draft?.isDirty ?? false;
    if (ref.read(unsavedSettingsProvider) != dirty) {
      ref.read(unsavedSettingsProvider.notifier).mark(dirty: dirty);
    }
  }

  Future<void> _save(Set<String> known) async {
    final draft = _draft!;
    setState(() => _saving = true);
    try {
      await ref.read(settingsSaverProvider)(widget.target, draft);
      if (!mounted) return;
      // The new snapshot replaces the draft when it arrives.
      _draft = null;
      _from = null;
      ref.read(unsavedSettingsProvider.notifier).mark(dirty: false);
      showNotice(context, ref, AppLocalizations.of(context).settings_saved);
    } on ApiProblem catch (e) {
      if (!mounted) return;
      if (e.isPreconditionFailed) {
        // Somebody else saved first: their version is loaded, ours stays.
        _changedElsewhere = true;
        _draft = null;
        _from = null;
      } else if (e.status == 422) {
        draft.applyProblem(e);
      } else {
        showFailure(context, ref, e);
      }
    } on Object catch (e) {
      if (mounted) showFailure(context, ref, e);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
        _touch();
      }
    }
  }

  bool _matches(FieldSchema f) {
    if (_search.trim().isEmpty) return true;
    final q = _search.trim().toLowerCase();
    return f.path.toLowerCase().contains(q) ||
        settingLabel(f.path).toLowerCase().contains(q) ||
        f.description.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final schema = ref.watch(settingsSchemaProvider);
    final snapshot = ref.watch(settingsSnapshotProvider(widget.target));

    final fields = schema.value?.fields;
    final snap = snapshot.value;
    if (fields == null || snap == null) {
      final error = schema.error ?? snapshot.error;
      return error != null
          ? DlmErrorState(
              title: l.list_error_title,
              message: error.toString(),
              retryLabel: l.list_retry,
              onRetry: () {
                ref
                  ..invalidate(settingsSchemaProvider)
                  ..invalidate(settingsSnapshotProvider(widget.target));
              },
            )
          : DlmLoadingState(label: l.list_loading);
    }
    // A new snapshot (first load, after a save, after a change elsewhere)
    // starts a new draft.
    if (_draft == null || !identical(_from, snap)) {
      _from = snap;
      _draft = SettingsDraft(snap);
    }
    final draft = _draft!;

    final level = widget.target.level.name;
    final visible = [
      for (final f in fields)
        if ((editableType(f.type) || settingEditors.containsKey(f.path)) &&
            (f.levels?.contains(level) ?? true) &&
            (widget.groups?.contains(f.group) ?? true) &&
            (widget.paths?.contains(f.path) ?? true) &&
            _matches(f))
          f,
    ];
    final known = {for (final f in visible) f.path};
    final groups = <String, List<FieldSchema>>{};
    for (final f in visible) {
      groups.putIfAbsent(f.group, () => []).add(f);
    }

    final children = <Widget>[
      if (widget.searchable)
        Padding(
          padding: EdgeInsets.only(bottom: theme.metrics.spacing.md),
          child: DlmSearchField(
            placeholder: l.settings_search,
            clearLabel: l.toolbar_search_clear,
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
      if (_changedElsewhere)
        Padding(
          padding: EdgeInsets.only(bottom: theme.metrics.spacing.md),
          child: DlmBanner(
            tone: DlmTone.warning,
            message: l.settings_changed_elsewhere,
          ),
        ),
      for (final message in draft.unmatchedErrors(known))
        Padding(
          padding: EdgeInsets.only(bottom: theme.metrics.spacing.sm),
          child: DlmBanner(tone: DlmTone.danger, message: message),
        ),
      if (groups.isEmpty)
        DlmEmptyState(title: l.settings_no_match)
      else
        for (final entry in groups.entries)
          Padding(
            padding: EdgeInsets.only(bottom: theme.metrics.spacing.lg),
            child: DlmFormGroup(
              title: humaniseSetting(entry.key),
              children: [
                for (final f in entry.value)
                  _FieldRow(
                    key: ValueKey(f.path),
                    field: f,
                    draft: draft,
                    onChanged: _touch,
                  ),
              ],
            ),
          ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(theme.metrics.spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
        ColoredBox(
          color: theme.colors.raised,
          child: Padding(
            padding: EdgeInsets.all(theme.metrics.spacing.md),
            child: Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: theme.metrics.spacing.sm,
              runSpacing: theme.metrics.spacing.xs,
              children: [
                if (draft.isDirty)
                  Text(
                    l.settings_unsaved,
                    style: theme.typography.caption.copyWith(
                      color: theme.colors.textSecondary,
                    ),
                  ),
                DlmButton(
                  label: l.settings_revert,
                  onPressed: draft.isDirty && !_saving
                      ? () {
                          draft.revert();
                          _changedElsewhere = false;
                          _touch();
                        }
                      : null,
                ),
                DlmButton(
                  label: l.settings_save,
                  variant: DlmButtonVariant.primary,
                  onPressed: draft.isDirty && !_saving
                      ? () => unawaited(_save(known))
                      : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// One setting: its label and help, the control of its type, where its value
/// comes from, and reset-to-inherit.
class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.field,
    required this.draft,
    required this.onChanged,
    super.key,
  });

  final FieldSchema field;
  final SettingsDraft draft;
  final VoidCallback onChanged;

  String _levelName(AppLocalizations l, SettingLevel level) => switch (level) {
    SettingLevel.defaults => l.settings_level_default,
    SettingLevel.global => l.settings_level_global,
    SettingLevel.queue => l.settings_level_queue,
    SettingLevel.task => l.settings_level_task,
  };

  Widget _control(BuildContext context, AppLocalizations l) {
    final path = field.path;
    final value = draft.valueOf(path);
    final label = settingLabel(path);
    void set(Object? v) {
      if (v == null) {
        draft.reset(path);
      } else {
        draft.set(path, v);
      }
      onChanged();
    }

    switch (field.type) {
      case FieldSchemaType.boolean:
        return DlmSwitch(
          value: value == true,
          semanticLabel: label,
          onChanged: set,
        );
      case FieldSchemaType.integer || FieldSchemaType.number:
        final unit = field.unit ?? '';
        if (unit.startsWith('bytes')) {
          return SizedBox(
            width: 200,
            child: DlmParsedField<int>(
              value: value is num ? value.toInt() : null,
              allowEmpty: true,
              parse: parseSize,
              format: (v) => context.bytes(v) ?? '$v',
              invalidText: l.settings_invalid_size,
              semanticLabel: label,
              suffix: unit == 'bytes/s' ? const Text('/s') : null,
              onChanged: set,
            ),
          );
        }
        return SizedBox(
          width: 160,
          child: DlmNumberField(
            value: value is num ? value : null,
            min: field.min,
            max: field.max,
            decimals: field.type == FieldSchemaType.number ? 2 : 0,
            allowEmpty: true,
            invalidText: l.settings_invalid_number,
            semanticLabel: label,
            suffix: unit.isEmpty ? null : Text(unit),
            onChanged: set,
          ),
        );
      case FieldSchemaType.string when (field.enumValue ?? const []).isNotEmpty:
        return SizedBox(
          width: 220,
          child: DlmDropdown<String>(
            semanticLabel: label,
            value: value is String && field.enumValue!.contains(value)
                ? value
                : null,
            placeholder: value is String ? value : l.settings_unset,
            choices: [
              for (final v in field.enumValue!)
                DlmChoice(value: v, label: humaniseSetting(v)),
            ],
            onChanged: set,
          ),
        );
      case FieldSchemaType.string || FieldSchemaType.duration:
        final isDur = field.type == FieldSchemaType.duration;
        return SizedBox(
          width: 260,
          child: DlmParsedField<String>(
            value: value is String ? value : null,
            allowEmpty: true,
            parse: (t) => t.trim().isEmpty
                ? null
                : isDur && !isDuration(t)
                ? null
                : t.trim(),
            format: (v) => v,
            invalidText: l.settings_invalid_duration,
            semanticLabel: label,
            onChanged: set,
          ),
        );
      case FieldSchemaType.array ||
          FieldSchemaType.object ||
          FieldSchemaType.$unknown:
        final editor = settingEditors[path];
        if (editor == null) return const SizedBox.shrink();
        // The row lays its control out without a width: give the editor one.
        return SizedBox(
          width: 520,
          child: KeyedSubtree(
            key: ValueKey('$path-${draft.revision}'),
            child: editor(
              EditorContext(
                field: field,
                value: draft.valueOf(path),
                set: (v) {
                  draft.set(path, v);
                  onChanged();
                },
                l: l,
              ),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final path = field.path;
    final overridden = draft.isOverridden(path);
    final errors = draft.errorsOf(path);
    final level = draft.levelOf(path);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DlmFormRow(
          label: settingLabel(path),
          description: field.description,
          control: Wrap(
            spacing: theme.metrics.spacing.sm,
            runSpacing: theme.metrics.spacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _control(context, l),
              DlmBadge(
                label: overridden
                    ? _levelName(l, draft.snapshot.level)
                    : _levelName(l, level),
                tone: overridden ? DlmTone.accent : DlmTone.neutral,
              ),
              if (field.restartRequired ?? false)
                DlmBadge(label: l.settings_restart, tone: DlmTone.warning),
              if (overridden)
                DlmIconButton(
                  icon: const DlmIcon(DlmIconName.restart),
                  semanticLabel: l.settings_reset(settingLabel(path)),
                  size: DlmControlSize.small,
                  onPressed: () {
                    draft.reset(path);
                    onChanged();
                  },
                ),
            ],
          ),
        ),
        for (final e in errors)
          Padding(
            padding: EdgeInsets.only(
              left: theme.metrics.spacing.md,
              bottom: theme.metrics.spacing.xs,
            ),
            child: Text(
              e,
              style: theme.typography.caption.copyWith(
                color: theme.colors.danger,
              ),
            ),
          ),
      ],
    );
  }
}
