import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../behavior/states.dart';
import '../components/components.dart';
import '../theme/theme.dart';
import 'button.dart';
import 'icon.dart';

/// A text input. Behaviour (focus, selection, editing, semantics) is the
/// platform's [EditableText]; the skin draws the frame.
class DlmTextField extends StatefulWidget {
  /// Creates a text input.
  const DlmTextField({
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.placeholder,
    this.semanticLabel,
    this.enabled = true,
    this.obscure = false,
    this.maxLines = 1,
    this.minLines,
    this.prefix,
    this.suffix,
    this.errorText,
    this.keyboardType,
    this.inputFormatters,
    this.autofocus = false,
    this.textAlign = TextAlign.start,
    super.key,
  });

  /// Holds the text; an internal one is used when null.
  final TextEditingController? controller;

  /// Focus node to use instead of an internal one.
  final FocusNode? focusNode;

  /// Called on every edit.
  final ValueChanged<String>? onChanged;

  /// Called when the user presses Enter (single line).
  final ValueChanged<String>? onSubmitted;

  /// Hint shown while empty.
  final String? placeholder;

  /// Accessible name; always provide one when there is no visible label.
  final String? semanticLabel;

  /// Whether the field accepts input.
  final bool enabled;

  /// Hide the text (passwords).
  final bool obscure;

  /// Maximum lines; null grows without limit, 1 is single line.
  final int? maxLines;

  /// Minimum lines for a multiline field.
  final int? minLines;

  /// Widget before the text (an icon).
  final Widget? prefix;

  /// Widget after the text (a clear or reveal button).
  final Widget? suffix;

  /// Shown below the field and marks it invalid.
  final String? errorText;

  /// Keyboard type hint.
  final TextInputType? keyboardType;

  /// Input filters.
  final List<TextInputFormatter>? inputFormatters;

  /// Request focus when first built.
  final bool autofocus;

  /// Horizontal alignment of the text.
  final TextAlign textAlign;

  @override
  State<DlmTextField> createState() => _DlmTextFieldState();
}

class _DlmTextFieldState extends State<DlmTextField> {
  TextEditingController? _ownController;
  FocusNode? _ownFocus;
  bool _hovered = false;
  bool _focused = false;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
    _focused = _focus.hasFocus;
  }

  void _onFocus() {
    if (mounted && _focused != _focus.hasFocus) {
      setState(() => _focused = _focus.hasFocus);
    }
  }

  @override
  void didUpdateWidget(DlmTextField old) {
    super.didUpdateWidget(old);
    if (old.focusNode != widget.focusNode) {
      (old.focusNode ?? _ownFocus)?.removeListener(_onFocus);
      _focus.addListener(_onFocus);
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _ownFocus?.dispose();
    _ownController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    final c = theme.colors;
    final multiline = widget.maxLines != 1;
    final states = DlmStates(
      hovered: widget.enabled && _hovered,
      focused: widget.enabled && _focused,
      focusVisible: widget.enabled && _focused,
      disabled: !widget.enabled,
    );
    final style = theme.typography.body.copyWith(
      color: widget.enabled ? c.textPrimary : c.textDisabled,
    );
    final editor = ExcludeFocus(
      excluding: !widget.enabled,
      child: EditableText(
        controller: _controller,
        focusNode: _focus,
        style: style,
        cursorColor: c.textPrimary,
        backgroundCursorColor: c.border,
        selectionColor: c.accentSubtle,
        obscureText: widget.obscure,
        autocorrect: false,
        enableSuggestions: false,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        readOnly: !widget.enabled,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        autofocus: widget.autofocus,
        textAlign: widget.textAlign,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
      ),
    );
    final placeholder = widget.placeholder;
    final field = Stack(
      alignment: multiline ? Alignment.topLeft : Alignment.centerLeft,
      children: [
        if (placeholder != null)
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) => _controller.text.isEmpty
                ? IgnorePointer(
                    child: ExcludeSemantics(
                      child: Text(
                        placeholder,
                        style: style.copyWith(color: c.textDisabled),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        editor,
      ],
    );
    final row = Row(
      crossAxisAlignment: multiline
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        if (widget.prefix != null) ...[
          widget.prefix!,
          SizedBox(width: theme.metrics.spacing.sm),
        ],
        Expanded(child: field),
        if (widget.suffix != null) ...[
          SizedBox(width: theme.metrics.spacing.sm),
          widget.suffix!,
        ],
      ],
    );
    final hasError = widget.errorText != null;
    return Semantics(
      container: true,
      label: widget.semanticLabel,
      textField: true,
      enabled: widget.enabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          MouseRegion(
            cursor: widget.enabled
                ? SystemMouseCursors.text
                : SystemMouseCursors.basic,
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: widget.enabled ? (_) => _focus.requestFocus() : null,
              child: theme.components.textFieldFrame(
                context,
                states: states,
                hasError: hasError,
                multiline: multiline,
                child: row,
              ),
            ),
          ),
          if (hasError)
            Padding(
              padding: EdgeInsets.only(top: theme.metrics.spacing.xs),
              child: Semantics(
                container: true,
                liveRegion: true,
                child: Text(
                  widget.errorText!,
                  style: theme.typography.caption.copyWith(color: c.danger),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A single-line search input with a leading magnifier and a clear button
/// that appears while there is text. Escape clears.
class DlmSearchField extends StatefulWidget {
  /// Creates a search field.
  const DlmSearchField({
    required this.onChanged,
    required this.clearLabel,
    this.controller,
    this.placeholder,
    this.semanticLabel,
    this.focusNode,
    this.onSubmitted,
    super.key,
  });

  /// Called on every edit, and with an empty string when cleared.
  final ValueChanged<String> onChanged;

  /// Accessible name of the clear button (localised by the caller).
  final String clearLabel;

  /// Holds the text; an internal one is used when null.
  final TextEditingController? controller;

  /// Hint shown while empty.
  final String? placeholder;

  /// Accessible name of the field.
  final String? semanticLabel;

  /// Focus node to use instead of an internal one.
  final FocusNode? focusNode;

  /// Called when the user presses Enter.
  final ValueChanged<String>? onSubmitted;

  @override
  State<DlmSearchField> createState() => _DlmSearchFieldState();
}

class _DlmSearchFieldState extends State<DlmSearchField> {
  TextEditingController? _own;
  TextEditingController get _controller =>
      widget.controller ?? (_own ??= TextEditingController());

  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): _clear},
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => DlmTextField(
          controller: _controller,
          focusNode: widget.focusNode,
          placeholder: widget.placeholder,
          semanticLabel: widget.semanticLabel,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          prefix: const DlmIcon(DlmIconName.search),
          suffix: _controller.text.isEmpty
              ? null
              : DlmIconButton(
                  icon: const DlmIcon(DlmIconName.close),
                  semanticLabel: widget.clearLabel,
                  size: DlmControlSize.small,
                  onPressed: _clear,
                ),
        ),
      ),
    );
  }
}

/// A password input with a button that reveals the text.
class DlmPasswordField extends StatefulWidget {
  /// Creates a password field.
  const DlmPasswordField({
    required this.showLabel,
    required this.hideLabel,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.placeholder,
    this.semanticLabel,
    this.focusNode,
    this.errorText,
    super.key,
  });

  /// Accessible name of the reveal button while hidden (localised).
  final String showLabel;

  /// Accessible name of the reveal button while shown (localised).
  final String hideLabel;

  /// Holds the text; an internal one is used when null.
  final TextEditingController? controller;

  /// Called on every edit.
  final ValueChanged<String>? onChanged;

  /// Called when the user presses Enter.
  final ValueChanged<String>? onSubmitted;

  /// Hint shown while empty.
  final String? placeholder;

  /// Accessible name of the field.
  final String? semanticLabel;

  /// Focus node to use instead of an internal one.
  final FocusNode? focusNode;

  /// Shown below the field and marks it invalid.
  final String? errorText;

  @override
  State<DlmPasswordField> createState() => _DlmPasswordFieldState();
}

class _DlmPasswordFieldState extends State<DlmPasswordField> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    return DlmTextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      placeholder: widget.placeholder,
      semanticLabel: widget.semanticLabel,
      errorText: widget.errorText,
      obscure: !_revealed,
      suffix: DlmIconButton(
        icon: DlmIcon(_revealed ? DlmIconName.eyeOff : DlmIconName.eye),
        semanticLabel: _revealed ? widget.hideLabel : widget.showLabel,
        size: DlmControlSize.small,
        onPressed: () => setState(() => _revealed = !_revealed),
      ),
    );
  }
}

/// A text input for a typed value (a size, a duration, a number): it parses
/// what is typed, reports valid values as they appear, shows [invalidText]
/// when the user leaves the field with text that does not parse, and rewrites
/// a valid entry in canonical form ([format]) on leaving.
class DlmParsedField<T extends Object> extends StatefulWidget {
  /// Creates a parsed field.
  const DlmParsedField({
    required this.value,
    required this.onChanged,
    required this.parse,
    required this.format,
    required this.invalidText,
    this.allowEmpty = false,
    this.placeholder,
    this.semanticLabel,
    this.enabled = true,
    this.textAlign = TextAlign.start,
    this.suffix,
    super.key,
  });

  /// The current value; changes from outside rewrite the text.
  final T? value;

  /// Called with each valid value, or null when empty and [allowEmpty].
  final ValueChanged<T?> onChanged;

  /// Parses the text; null means invalid.
  final T? Function(String text) parse;

  /// The canonical text of a value.
  final String Function(T value) format;

  /// Message when the text does not parse (localised by the caller).
  final String invalidText;

  /// Whether an empty field is valid and means "no value".
  final bool allowEmpty;

  /// Hint shown while empty.
  final String? placeholder;

  /// Accessible name of the field.
  final String? semanticLabel;

  /// Whether the field accepts input.
  final bool enabled;

  /// Horizontal alignment of the text.
  final TextAlign textAlign;

  /// Widget after the text (a unit label).
  final Widget? suffix;

  @override
  State<DlmParsedField<T>> createState() => _DlmParsedFieldState<T>();
}

class _DlmParsedFieldState<T extends Object> extends State<DlmParsedField<T>> {
  late final TextEditingController _controller = TextEditingController(
    text: _textOf(widget.value),
  );
  final FocusNode _focus = FocusNode();
  T? _lastReported;
  bool _showError = false;

  String _textOf(T? v) => v == null ? '' : widget.format(v);

  bool _valid(String text) {
    if (text.trim().isEmpty) return widget.allowEmpty;
    return widget.parse(text.trim()) != null;
  }

  @override
  void initState() {
    super.initState();
    _lastReported = widget.value;
    _focus.addListener(() {
      if (!_focus.hasFocus) _commit();
    });
  }

  @override
  void didUpdateWidget(DlmParsedField<T> old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value && widget.value != _lastReported) {
      _lastReported = widget.value;
      _controller.text = _textOf(widget.value);
      _showError = false;
    }
  }

  void _edited(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      if (widget.allowEmpty) {
        _lastReported = null;
        widget.onChanged(null);
      }
    } else {
      final parsed = widget.parse(trimmed);
      if (parsed != null) {
        _lastReported = parsed;
        widget.onChanged(parsed);
      }
    }
    if (_showError && _valid(text)) setState(() => _showError = false);
  }

  void _commit() {
    final text = _controller.text;
    if (_valid(text)) {
      final parsed = text.trim().isEmpty ? null : widget.parse(text.trim());
      _controller.text = _textOf(parsed);
      if (_showError) setState(() => _showError = false);
    } else {
      setState(() => _showError = true);
    }
  }

  @override
  void dispose() {
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DlmTextField(
      controller: _controller,
      focusNode: _focus,
      placeholder: widget.placeholder,
      semanticLabel: widget.semanticLabel,
      enabled: widget.enabled,
      textAlign: widget.textAlign,
      suffix: widget.suffix,
      errorText: _showError ? widget.invalidText : null,
      onChanged: _edited,
      onSubmitted: (_) => _commit(),
    );
  }
}

/// A numeric input for an integer or decimal, with optional bounds.
class DlmNumberField extends StatelessWidget {
  /// Creates a number field.
  const DlmNumberField({
    required this.value,
    required this.onChanged,
    required this.invalidText,
    this.min,
    this.max,
    this.decimals = 0,
    this.allowEmpty = false,
    this.semanticLabel,
    this.enabled = true,
    this.suffix,
    super.key,
  });

  /// The current value.
  final num? value;

  /// Called with each valid, in-range value.
  final ValueChanged<num?> onChanged;

  /// Message for text that is not a number in range (localised).
  final String invalidText;

  /// Smallest accepted value.
  final num? min;

  /// Largest accepted value.
  final num? max;

  /// Digits after the decimal point; 0 means integers only.
  final int decimals;

  /// Whether an empty field means "no value".
  final bool allowEmpty;

  /// Accessible name of the field.
  final String? semanticLabel;

  /// Whether the field accepts input.
  final bool enabled;

  /// Widget after the number (a unit label).
  final Widget? suffix;

  num? _parse(String text) {
    final n = decimals == 0 ? int.tryParse(text) : double.tryParse(text);
    if (n == null || !n.isFinite) return null;
    if (min != null && n < min!) return null;
    if (max != null && n > max!) return null;
    return n;
  }

  @override
  Widget build(BuildContext context) {
    return DlmParsedField<num>(
      value: value,
      onChanged: onChanged,
      parse: _parse,
      format: (n) =>
          decimals == 0 ? n.round().toString() : n.toStringAsFixed(decimals),
      invalidText: invalidText,
      allowEmpty: allowEmpty,
      semanticLabel: semanticLabel,
      enabled: enabled,
      textAlign: TextAlign.end,
      suffix: suffix,
    );
  }
}
