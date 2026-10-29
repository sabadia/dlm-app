import 'dart:convert';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../format/dlm_format.dart';
import '../queues/queue_settings_draft.dart';
import 'settings_form.dart' show isDuration;

/// What an editor of a structured setting (a list, a map, an object) gets.
class EditorContext {
  /// Creates the context.
  const EditorContext({
    required this.field,
    required this.value,
    required this.set,
    required this.l,
  });

  /// The setting's description from the daemon's schema.
  final FieldSchema field;

  /// The value that applies now (a `List`, a `Map` or null).
  final Object? value;

  /// Stores a new value for the setting.
  final void Function(Object value) set;

  /// Localised strings.
  final AppLocalizations l;
}

/// Builds the editor of one structured setting.
typedef EditorBuilder = Widget Function(EditorContext c);

/// The editors of the settings that are not a single scalar, by path.
final Map<String, EditorBuilder> settingEditors = {
  'headers': (c) => PairsEditor(context: c),
  'proxy': (c) => ProxyEditor(context: c),
  'proxyRules': (c) => ProxyRulesEditor(context: c),
  'torrent.trackers': (c) => LinesEditor(context: c),
  'refresh.strategies': (c) => OrderedChoicesEditor(context: c),
  'postActions': (c) => PostActionsEditor(context: c),
  'quota': (c) => QuotaEditor(context: c),
  'speedProfiles': (c) => ProfilesEditor(context: c),
};

List<Object?> _list(Object? v) => v is List<Object?> ? v : const [];
Map<String, Object?> _map(Object? v) =>
    v is Map<String, Object?> ? v : const {};
String _text(Object? v) => v is String ? v : '';

/// A small text input that reports every change.
class _Text extends StatelessWidget {
  const _Text({
    required this.value,
    required this.onChanged,
    required this.label,
    this.width = 200,
    this.placeholder,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String label;
  final double width;
  final String? placeholder;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: DlmParsedField<String>(
      value: value,
      allowEmpty: true,
      placeholder: placeholder,
      parse: (t) => t,
      format: (v) => v,
      invalidText: '',
      semanticLabel: label,
      onChanged: (v) => onChanged(v ?? ''),
    ),
  );
}

/// A multi-line text input that keeps its own controller, so typing does not
/// reset the cursor when the form rebuilds.
class _LinesField extends StatefulWidget {
  const _LinesField({
    required this.initial,
    required this.label,
    required this.onChanged,
    this.placeholder,
    this.width = 320,
  });

  final String initial;
  final String label;
  final ValueChanged<String> onChanged;
  final String? placeholder;
  final double width;

  @override
  State<_LinesField> createState() => _LinesFieldState();
}

class _LinesFieldState extends State<_LinesField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: widget.width,
    child: DlmTextField(
      controller: _controller,
      semanticLabel: widget.label,
      placeholder: widget.placeholder,
      minLines: 2,
      maxLines: 6,
      onChanged: widget.onChanged,
    ),
  );
}

/// Name/value rows (request headers).
class PairsEditor extends StatefulWidget {
  /// Creates the editor.
  const PairsEditor({required this.context, super.key});

  /// The setting.
  final EditorContext context;

  @override
  State<PairsEditor> createState() => _PairsEditorState();
}

class _PairsEditorState extends State<PairsEditor> {
  late final List<(String, String)> _rows = [
    for (final e in _map(widget.context.value).entries) (e.key, '${e.value}'),
  ];

  void _emit() => widget.context.set({
    for (final r in _rows)
      if (r.$1.trim().isNotEmpty) r.$1.trim(): r.$2,
  });

  @override
  Widget build(BuildContext context) {
    final l = widget.context.l;
    final theme = DlmTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _rows.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: theme.metrics.spacing.xs),
            child: Wrap(
              spacing: theme.metrics.spacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _Text(
                  value: _rows[i].$1,
                  label: l.se_name,
                  width: 140,
                  placeholder: l.se_name,
                  onChanged: (v) {
                    setState(() => _rows[i] = (v, _rows[i].$2));
                    _emit();
                  },
                ),
                _Text(
                  value: _rows[i].$2,
                  label: l.se_value,
                  placeholder: l.se_value,
                  onChanged: (v) {
                    setState(() => _rows[i] = (_rows[i].$1, v));
                    _emit();
                  },
                ),
                DlmIconButton(
                  icon: const DlmIcon(DlmIconName.trash),
                  semanticLabel: l.se_remove,
                  size: DlmControlSize.small,
                  onPressed: () {
                    setState(() => _rows.removeAt(i));
                    _emit();
                  },
                ),
              ],
            ),
          ),
        DlmButton(
          label: l.se_add,
          icon: const DlmIcon(DlmIconName.plus),
          variant: DlmButtonVariant.plain,
          onPressed: () => setState(() => _rows.add(('', ''))),
        ),
      ],
    );
  }
}

/// The proxy: none, the system's, or a custom one with its address.
class ProxyEditor extends StatelessWidget {
  /// Creates the editor.
  const ProxyEditor({required this.context, super.key});

  /// The setting.
  final EditorContext context;

  @override
  Widget build(BuildContext buildContext) {
    final l = context.l;
    final v = _map(context.value);
    final mode = _text(v['mode']).isEmpty ? 'none' : _text(v['mode']);
    void emit(String m, String url) =>
        context.set({'mode': m, 'url': m == 'custom' ? url : null});
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 180,
          child: DlmDropdown<String>(
            semanticLabel: l.se_proxy_mode,
            value: mode,
            choices: [
              DlmChoice(value: 'none', label: l.se_proxy_none),
              DlmChoice(value: 'system', label: l.se_proxy_system),
              DlmChoice(value: 'custom', label: l.se_proxy_custom),
            ],
            onChanged: (m) => emit(m, _text(v['url'])),
          ),
        ),
        if (mode == 'custom')
          _Text(
            value: _text(v['url']),
            label: l.se_proxy_url,
            width: 260,
            placeholder: 'http://host:3128',
            onChanged: (u) => emit('custom', u),
          ),
      ],
    );
  }
}

/// Rules that send some hosts through another proxy.
class ProxyRulesEditor extends StatefulWidget {
  /// Creates the editor.
  const ProxyRulesEditor({required this.context, super.key});

  /// The setting.
  final EditorContext context;

  @override
  State<ProxyRulesEditor> createState() => _ProxyRulesEditorState();
}

class _ProxyRulesEditorState extends State<ProxyRulesEditor> {
  // hosts text, mode, url
  late final List<(String, String, String)> _rows = [
    for (final r in _list(widget.context.value))
      (
        [for (final h in _list(_map(r)['hosts'])) '$h'].join(', '),
        _text(_map(_map(r)['proxy'])['mode']),
        _text(_map(_map(r)['proxy'])['url']),
      ),
  ];

  void _emit() => widget.context.set([
    for (final r in _rows)
      {
        'hosts': [
          for (final h in r.$1.split(RegExp('[,\\s]+')))
            if (h.isNotEmpty) h,
        ],
        'proxy': {
          'mode': r.$2.isEmpty ? 'none' : r.$2,
          if (r.$2 == 'custom') 'url': r.$3,
        },
      },
  ]);

  @override
  Widget build(BuildContext context) {
    final l = widget.context.l;
    final theme = DlmTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _rows.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: theme.metrics.spacing.sm),
            child: Wrap(
              spacing: theme.metrics.spacing.xs,
              runSpacing: theme.metrics.spacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _Text(
                  value: _rows[i].$1,
                  label: l.se_rule_hosts,
                  placeholder: l.se_rule_hosts_hint,
                  onChanged: (v) {
                    setState(() => _rows[i] = (v, _rows[i].$2, _rows[i].$3));
                    _emit();
                  },
                ),
                SizedBox(
                  width: 160,
                  child: DlmDropdown<String>(
                    semanticLabel: l.se_proxy_mode,
                    value: _rows[i].$2.isEmpty ? 'none' : _rows[i].$2,
                    choices: [
                      DlmChoice(value: 'none', label: l.se_proxy_none),
                      DlmChoice(value: 'system', label: l.se_proxy_system),
                      DlmChoice(value: 'custom', label: l.se_proxy_custom),
                    ],
                    onChanged: (m) {
                      setState(() => _rows[i] = (_rows[i].$1, m, _rows[i].$3));
                      _emit();
                    },
                  ),
                ),
                if (_rows[i].$2 == 'custom')
                  _Text(
                    value: _rows[i].$3,
                    label: l.se_proxy_url,
                    width: 220,
                    onChanged: (u) {
                      setState(() => _rows[i] = (_rows[i].$1, _rows[i].$2, u));
                      _emit();
                    },
                  ),
                DlmIconButton(
                  icon: const DlmIcon(DlmIconName.trash),
                  semanticLabel: l.se_remove,
                  size: DlmControlSize.small,
                  onPressed: () {
                    setState(() => _rows.removeAt(i));
                    _emit();
                  },
                ),
              ],
            ),
          ),
        DlmButton(
          label: l.se_add_rule,
          icon: const DlmIcon(DlmIconName.plus),
          variant: DlmButtonVariant.plain,
          onPressed: () => setState(() => _rows.add(('', 'none', ''))),
        ),
      ],
    );
  }
}

/// One text entry per line (tracker addresses).
class LinesEditor extends StatelessWidget {
  /// Creates the editor.
  const LinesEditor({required this.context, super.key});

  /// The setting.
  final EditorContext context;

  @override
  Widget build(BuildContext buildContext) => _LinesField(
    initial: [for (final v in _list(context.value)) '$v'].join('\n'),
    label: context.l.se_lines,
    onChanged: (text) => context.set([
      for (final line in text.split(RegExp(r'\r?\n')))
        if (line.trim().isNotEmpty) line.trim(),
    ]),
  );
}

/// A list of values from a closed set whose order matters (refresh
/// strategies, tried one after the other).
class OrderedChoicesEditor extends StatelessWidget {
  /// Creates the editor.
  const OrderedChoicesEditor({required this.context, super.key});

  /// The setting.
  final EditorContext context;

  @override
  Widget build(BuildContext buildContext) {
    final l = context.l;
    final theme = DlmTheme.of(buildContext);
    final chosen = [for (final v in _list(context.value)) '$v'];
    final rest = [
      for (final v in context.field.enumValue ?? const <String>[])
        if (!chosen.contains(v)) v,
    ];
    String name(String v) => v
        .replaceAll('-', ' ')
        .replaceFirstMapped(RegExp('^.'), (m) => m[0]!.toUpperCase());
    void emit(List<String> next) => context.set(next);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < chosen.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: theme.metrics.spacing.xs),
            child: Wrap(
              spacing: theme.metrics.spacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('${i + 1}. ${name(chosen[i])}'),
                DlmIconButton(
                  icon: const DlmIcon(DlmIconName.chevronUp),
                  semanticLabel: l.se_move_up,
                  size: DlmControlSize.small,
                  onPressed: i == 0
                      ? null
                      : () {
                          final next = [...chosen];
                          next.insert(i - 1, next.removeAt(i));
                          emit(next);
                        },
                ),
                DlmIconButton(
                  icon: const DlmIcon(DlmIconName.chevronDown),
                  semanticLabel: l.se_move_down,
                  size: DlmControlSize.small,
                  onPressed: i == chosen.length - 1
                      ? null
                      : () {
                          final next = [...chosen];
                          next.insert(i + 1, next.removeAt(i));
                          emit(next);
                        },
                ),
                DlmIconButton(
                  icon: const DlmIcon(DlmIconName.trash),
                  semanticLabel: l.se_remove,
                  size: DlmControlSize.small,
                  onPressed: () => emit([...chosen]..removeAt(i)),
                ),
              ],
            ),
          ),
        if (rest.isNotEmpty)
          SizedBox(
            width: 220,
            child: DlmDropdown<String>(
              semanticLabel: l.se_add,
              value: null,
              placeholder: l.se_add,
              choices: [
                for (final v in rest) DlmChoice(value: v, label: name(v)),
              ],
              onChanged: (v) => emit([...chosen, v]),
            ),
          ),
      ],
    );
  }
}

/// The actions run after a download completes, in order.
class PostActionsEditor extends StatefulWidget {
  /// Creates the editor.
  const PostActionsEditor({required this.context, super.key});

  /// The setting.
  final EditorContext context;

  @override
  State<PostActionsEditor> createState() => _PostActionsEditorState();
}

/// The post-action kinds and the parameters each understands.
const Map<String, List<String>> postActionParams = {
  'extract': ['dir', 'delete', 'password'],
  'add-torrent': ['dir', 'delete'],
  'command': ['cmd', 'args', 'timeout'],
  'av-scan': ['cmd', 'args', 'timeout', 'infectedExit', 'onInfected'],
};

class _PostActionsEditorState extends State<PostActionsEditor> {
  late final List<(String, Map<String, String>)> _actions = [
    for (final a in _list(widget.context.value))
      (
        _text(_map(a)['kind']),
        {for (final e in _map(_map(a)['params']).entries) e.key: '${e.value}'},
      ),
  ];

  void _emit() => widget.context.set([
    for (final a in _actions)
      {'kind': a.$1, if (a.$2.isNotEmpty) 'params': a.$2},
  ]);

  void _param(int i, String key, String value) {
    setState(() {
      if (value.isEmpty) {
        _actions[i].$2.remove(key);
      } else {
        _actions[i].$2[key] = value;
      }
    });
    _emit();
  }

  /// Lines of arguments <-> the JSON array the daemon stores.
  static String _argsToLines(String? json) {
    if (json == null || json.isEmpty) return '';
    try {
      return [for (final a in jsonDecode(json) as List<Object?>) '$a']
          .join('\n');
    } on FormatException {
      return json;
    }
  }

  static String _linesToArgs(String text) {
    final lines = [
      for (final l in text.split(RegExp(r'\r?\n')))
        if (l.isNotEmpty) l,
    ];
    return lines.isEmpty ? '' : jsonEncode(lines);
  }

  String _kindLabel(AppLocalizations l, String kind) => switch (kind) {
    'extract' => l.se_pa_extract,
    'add-torrent' => l.se_pa_add_torrent,
    'command' => l.se_pa_command,
    'av-scan' => l.se_pa_av_scan,
    _ => kind,
  };

  Widget _field(
    int i,
    String key,
    String label, {
    double width = 240,
    String? placeholder,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 110, child: Text(label)),
        _Text(
          value: _actions[i].$2[key] ?? '',
          label: label,
          width: width,
          placeholder: placeholder,
          onChanged: (v) => _param(i, key, v),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l = widget.context.l;
    final theme = DlmTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _actions.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: theme.metrics.spacing.sm),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colors.separator),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: EdgeInsets.all(theme.metrics.spacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: theme.metrics.spacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '${i + 1}. ${_kindLabel(l, _actions[i].$1)}',
                          style: theme.typography.subtitle,
                        ),
                        DlmIconButton(
                          icon: const DlmIcon(DlmIconName.chevronUp),
                          semanticLabel: l.se_move_up,
                          size: DlmControlSize.small,
                          onPressed: i == 0
                              ? null
                              : () {
                                  setState(
                                    () => _actions.insert(
                                      i - 1,
                                      _actions.removeAt(i),
                                    ),
                                  );
                                  _emit();
                                },
                        ),
                        DlmIconButton(
                          icon: const DlmIcon(DlmIconName.chevronDown),
                          semanticLabel: l.se_move_down,
                          size: DlmControlSize.small,
                          onPressed: i == _actions.length - 1
                              ? null
                              : () {
                                  setState(
                                    () => _actions.insert(
                                      i + 1,
                                      _actions.removeAt(i),
                                    ),
                                  );
                                  _emit();
                                },
                        ),
                        DlmIconButton(
                          icon: const DlmIcon(DlmIconName.trash),
                          semanticLabel: l.se_remove,
                          size: DlmControlSize.small,
                          onPressed: () {
                            setState(() => _actions.removeAt(i));
                            _emit();
                          },
                        ),
                      ],
                    ),
                    if (_actions[i].$1 == 'extract' ||
                        _actions[i].$1 == 'add-torrent') ...[
                      _field(
                        i,
                        'dir',
                        l.se_pa_dir,
                        placeholder: l.se_pa_dir_hint,
                      ),
                      DlmCheckbox(
                        value: _actions[i].$2['delete'] == 'true'
                            ? DlmCheckState.checked
                            : DlmCheckState.unchecked,
                        label: l.se_pa_delete,
                        onChanged: (v) => _param(
                          i,
                          'delete',
                          v == DlmCheckState.checked ? 'true' : '',
                        ),
                      ),
                    ],
                    if (_actions[i].$1 == 'extract')
                      _field(i, 'password', l.se_pa_password),
                    if (_actions[i].$1 == 'command' ||
                        _actions[i].$1 == 'av-scan') ...[
                      DlmBanner(
                        tone: DlmTone.warning,
                        message: _actions[i].$1 == 'av-scan'
                            ? l.se_pa_av_warning
                            : l.se_pa_command_warning,
                      ),
                      SizedBox(height: theme.metrics.spacing.xs),
                      _field(
                        i,
                        'cmd',
                        l.se_pa_cmd,
                        placeholder: l.se_pa_cmd_hint,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 110, child: Text(l.se_pa_args)),
                          _LinesField(
                            initial: _argsToLines(_actions[i].$2['args']),
                            label: l.se_pa_args,
                            width: 240,
                            placeholder: l.se_pa_args_hint('{path}'),
                            onChanged: (t) =>
                                _param(i, 'args', _linesToArgs(t)),
                          ),
                        ],
                      ),
                      _field(
                        i,
                        'timeout',
                        l.se_pa_timeout,
                        width: 120,
                        placeholder: '5m',
                      ),
                    ],
                    if (_actions[i].$1 == 'av-scan') ...[
                      _field(
                        i,
                        'infectedExit',
                        l.se_pa_infected_exit,
                        width: 80,
                        placeholder: '1',
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 110,
                            child: Text(l.se_pa_on_infected),
                          ),
                          SizedBox(
                            width: 200,
                            child: DlmDropdown<String>(
                              semanticLabel: l.se_pa_on_infected,
                              value: _actions[i].$2['onInfected'] ?? 'delete',
                              choices: [
                                DlmChoice(
                                  value: 'delete',
                                  label: l.se_pa_infected_delete,
                                ),
                                DlmChoice(
                                  value: 'keep',
                                  label: l.se_pa_infected_keep,
                                ),
                              ],
                              onChanged: (v) => _param(i, 'onInfected', v),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        SizedBox(
          width: 260,
          child: DlmDropdown<String>(
            semanticLabel: l.se_pa_add,
            value: null,
            placeholder: l.se_pa_add,
            choices: [
              for (final kind in postActionParams.keys)
                DlmChoice(value: kind, label: _kindLabel(l, kind)),
            ],
            onChanged: (kind) {
              setState(() => _actions.add((kind, <String, String>{})));
              _emit();
            },
          ),
        ),
      ],
    );
  }
}

/// A traffic quota: how much may be transferred in how long.
class QuotaEditor extends StatefulWidget {
  /// Creates the editor.
  const QuotaEditor({required this.context, super.key});

  /// The setting.
  final EditorContext context;

  @override
  State<QuotaEditor> createState() => _QuotaEditorState();
}

class _QuotaEditorState extends State<QuotaEditor> {
  late int? _bytes = _map(widget.context.value)['bytes'] is num
      ? (_map(widget.context.value)['bytes']! as num).toInt()
      : null;
  late String _period = _text(_map(widget.context.value)['period']);

  /// The quota is stored once both parts are valid.
  void _emit() {
    final b = _bytes;
    if (b != null && b > 0 && isDuration(_period)) {
      widget.context.set({'bytes': b, 'period': _period});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.context.l;
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 160,
          child: DlmParsedField<int>(
            value: _bytes,
            allowEmpty: true,
            parse: parseSize,
            format: (b) => context.bytes(b) ?? '$b',
            invalidText: l.settings_invalid_size,
            semanticLabel: l.se_quota_bytes,
            onChanged: (b) {
              _bytes = b;
              _emit();
            },
          ),
        ),
        Text(l.se_quota_per),
        _Text(
          value: _period,
          label: l.se_quota_period,
          width: 120,
          placeholder: '720h',
          onChanged: (p) {
            _period = p;
            _emit();
          },
        ),
      ],
    );
  }
}

/// Speed limits that apply during certain hours of the week.
class ProfilesEditor extends StatefulWidget {
  /// Creates the editor.
  const ProfilesEditor({required this.context, super.key});

  /// The setting.
  final EditorContext context;

  @override
  State<ProfilesEditor> createState() => _ProfilesEditorState();
}

class _ProfilesEditorState extends State<ProfilesEditor> {
  late final List<ProfileDraft> _profiles = [
    for (final raw in _list(widget.context.value))
      if (raw is Map<String, Object?>) _fromJson(raw),
  ];

  static ProfileDraft _fromJson(Map<String, Object?> json) {
    final p = SpeedProfile.fromJson(json);
    return ProfileDraft(
      windows: WindowsDraft.from(p.timezone, p.windows),
      speedLimit: p.speedLimit > 0 ? p.speedLimit : null,
    );
  }

  void _emit() => widget.context.set([
    for (final p in _profiles)
      {
        'speedLimit': p.speedLimit ?? 0,
        if (p.windows.timezone != null) 'timezone': p.windows.timezone,
        'windows': [
          for (final w in p.windows.custom ?? p.windows.toWindows()) w.toJson(),
        ],
      },
  ]);

  List<String> _dayLabels(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    // 1 January 2024 was a Monday, the first row of the grid.
    return [
      for (var i = 0; i < 7; i++)
        DateFormat.E(locale).format(DateTime(2024, 1, 1 + i)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.context.l;
    final theme = DlmTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.qs_profiles_desc,
          style: theme.typography.caption.copyWith(
            color: theme.colors.textSecondary,
          ),
        ),
        for (var i = 0; i < _profiles.length; i++)
          Padding(
            padding: EdgeInsets.only(top: theme.metrics.spacing.sm),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colors.separator),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: EdgeInsets.all(theme.metrics.spacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: theme.metrics.spacing.sm,
                      runSpacing: theme.metrics.spacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          l.qs_profile_title(i + 1),
                          style: theme.typography.subtitle,
                        ),
                        SizedBox(
                          width: 180,
                          child: DlmParsedField<int>(
                            value: _profiles[i].speedLimit,
                            allowEmpty: true,
                            parse: parseSize,
                            format: (b) => context.bytes(b) ?? '$b',
                            invalidText: l.settings_invalid_size,
                            semanticLabel: l.qs_profile_limit,
                            placeholder: l.qs_profile_limit,
                            suffix: const Text('/s'),
                            onChanged: (v) {
                              _profiles[i].speedLimit = v;
                              _emit();
                            },
                          ),
                        ),
                        DlmIconButton(
                          icon: const DlmIcon(DlmIconName.trash),
                          semanticLabel: l.qs_profile_remove,
                          size: DlmControlSize.small,
                          onPressed: () {
                            setState(() => _profiles.removeAt(i));
                            _emit();
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: theme.metrics.spacing.xs),
                    Text(
                      l.qs_profile_unlimited,
                      style: theme.typography.caption.copyWith(
                        color: theme.colors.textSecondary,
                      ),
                    ),
                    SizedBox(height: theme.metrics.spacing.xs),
                    if (_profiles[i].windows.exact)
                      DlmScheduleGrid(
                        cells: _profiles[i].windows.cells,
                        dayLabels: _dayLabels(context),
                        slotLabel: (slot) =>
                            '${slot.toString().padLeft(2, '0')}:00',
                        semanticLabel: l.qs_profile_title(i + 1),
                        onChanged: (cells) {
                          setState(() {
                            _profiles[i].windows.cells
                              ..clear()
                              ..addAll(cells);
                          });
                          _emit();
                        },
                      )
                    else
                      DlmBanner(
                        message: l.qs_schedule_custom,
                        actionLabel: l.qs_schedule_use_grid,
                        onAction: () {
                          setState(
                            () => _profiles[i].windows.useGrid(
                              _profiles[i].windows.toWindows(),
                            ),
                          );
                          _emit();
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        Padding(
          padding: EdgeInsets.only(top: theme.metrics.spacing.sm),
          child: DlmButton(
            label: l.qs_profile_add,
            icon: const DlmIcon(DlmIconName.plus),
            variant: DlmButtonVariant.plain,
            onPressed: () => setState(
              () => _profiles.add(ProfileDraft(windows: WindowsDraft())),
            ),
          ),
        ),
      ],
    );
  }
}
