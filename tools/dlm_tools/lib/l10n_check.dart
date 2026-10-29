import 'dart:convert';
import 'dart:io';

/// A problem found in a translation file.
class L10nProblem {
  /// Creates a problem.
  const L10nProblem(this.file, this.key, this.text);

  /// The ARB file.
  final String file;

  /// The message key, or empty for the whole file.
  final String key;

  /// What is wrong.
  final String text;

  @override
  String toString() => '$file${key.isEmpty ? '' : ' [$key]'}: $text';
}

/// The placeholders of an ICU message: `{name}` and the variable of a
/// `{name, plural|select, ...}` construct, at any depth.
Set<String> placeholdersOf(String message) {
  final names = <String>{};
  final pattern = RegExp(r'\{\s*([A-Za-z_][A-Za-z0-9_]*)\s*(?=[,}])');
  for (final m in pattern.allMatches(message)) {
    names.add(m.group(1)!);
  }
  // Branch keys such as `one{...}` look like placeholders to the pattern
  // above only when they are followed by a comma or a closing brace, which a
  // branch key never is; plural keywords are dropped for safety.
  names.removeAll(const {'plural', 'select', 'one', 'other', 'few', 'many'});
  return names;
}

/// Whether every plural or select construct has an `other` branch.
bool hasOtherBranch(String message) {
  final construct = RegExp(r'\{[^{},]+,\s*(plural|select)\s*,');
  var from = 0;
  while (true) {
    final m = construct.firstMatch(message.substring(from));
    if (m == null) return true;
    final start = from + m.end;
    var depth = 1;
    var i = start;
    for (; i < message.length && depth > 0; i++) {
      if (message[i] == '{') depth++;
      if (message[i] == '}') depth--;
    }
    final body = message.substring(start, i - 1);
    if (!RegExp(r'(^|\s)other\s*\{').hasMatch(body)) return false;
    from = start;
  }
}

/// Checks every `app_<locale>.arb` in [dir] against the template
/// `app_en.arb`: no key the template lacks, the same placeholders, every
/// plural with an `other`, nothing empty. Missing translations are not
/// problems (they fall back to English); [missing] counts them per locale.
({List<L10nProblem> problems, Map<String, int> missing}) checkArbs(
  Directory dir,
) {
  final problems = <L10nProblem>[];
  final missing = <String, int>{};
  Map<String, Object?> read(File f) =>
      jsonDecode(f.readAsStringSync()) as Map<String, Object?>;
  final template = read(File('${dir.path}/app_en.arb'));
  final messages = {
    for (final e in template.entries)
      if (!e.key.startsWith('@') && e.value is String)
        e.key: e.value! as String,
  };
  for (final f in dir.listSync().whereType<File>()) {
    final name = f.uri.pathSegments.last;
    if (!name.startsWith('app_') ||
        !name.endsWith('.arb') ||
        name == 'app_en.arb') {
      continue;
    }
    final doc = read(f);
    var translated = 0;
    for (final e in doc.entries) {
      if (e.key.startsWith('@')) continue;
      final source = messages[e.key];
      if (source == null) {
        problems.add(L10nProblem(name, e.key, 'not in app_en.arb'));
        continue;
      }
      final text = e.value;
      if (text is! String || text.trim().isEmpty) {
        problems.add(L10nProblem(name, e.key, 'empty'));
        continue;
      }
      translated++;
      final want = placeholdersOf(source);
      final got = placeholdersOf(text);
      if (want.difference(got).isNotEmpty || got.difference(want).isNotEmpty) {
        problems.add(
          L10nProblem(name, e.key, 'placeholders $got, the English has $want'),
        );
      }
      if (!hasOtherBranch(text)) {
        problems.add(
          L10nProblem(name, e.key, 'a plural or select has no other'),
        );
      }
    }
    missing[name] = messages.length - translated;
  }
  return (problems: problems, missing: missing);
}
