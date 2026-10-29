// Writes lib/l10n/app_en_XA.arb, the pseudo-locale: every message accented and
// lengthened by about a third and wrapped in brackets, so a string that is not
// translated stands out and a layout that cannot take longer text breaks.
//
//   dart run tool/gen_pseudo.dart
//
// Placeholders ({name}) and plural/select branches are left intact.
import 'dart:convert';
import 'dart:io';

const _accents = {
  'a': 'à',
  'e': 'é',
  'i': 'î',
  'o': 'ô',
  'u': 'û',
  'y': 'ý',
  'c': 'ç',
  'n': 'ñ',
  's': 'š',
  'z': 'ž',
  'A': 'Â',
  'E': 'É',
  'I': 'Î',
  'O': 'Ô',
  'U': 'Û',
  'Y': 'Ý',
  'C': 'Ç',
  'N': 'Ñ',
  'S': 'Š',
  'Z': 'Ž',
};

String _accent(String text) =>
    text.split('').map((c) => _accents[c] ?? c).join();

/// Transforms the literal text of an ICU message, keeping what is in braces.
String pseudo(String message) {
  final out = StringBuffer();
  var literal = StringBuffer();

  void flushLiteral() {
    if (literal.isEmpty) return;
    out.write(_accent(literal.toString()));
    literal = StringBuffer();
  }

  // Walks [s] from [i]; returns the index after the closing brace of the
  // construct that started at [i] (a '{').
  int construct(String s, int i, StringBuffer sink) {
    var depth = 0;
    final start = i;
    var j = i;
    for (; j < s.length; j++) {
      if (s[j] == '{') depth++;
      if (s[j] == '}') {
        depth--;
        if (depth == 0) {
          j++;
          break;
        }
      }
    }
    final body = s.substring(start + 1, j - 1);
    final comma = body.indexOf(',');
    if (comma < 0) {
      sink.write('{$body}'); // a plain placeholder
      return j;
    }
    final comma2 = body.indexOf(',', comma + 1);
    if (comma2 < 0) {
      sink.write('{$body}'); // {n, number} and the like
      return j;
    }
    // {name, plural|select, key{text} key{text} ...}
    sink.write('{${body.substring(0, comma2 + 1)}');
    var k = comma2 + 1;
    while (k < body.length) {
      final open = body.indexOf('{', k);
      if (open < 0) {
        sink.write(body.substring(k));
        break;
      }
      sink.write(body.substring(k, open + 1));
      var d = 1;
      var m = open + 1;
      while (m < body.length && d > 0) {
        if (body[m] == '{') d++;
        if (body[m] == '}') d--;
        m++;
      }
      sink
        ..write(pseudo(body.substring(open + 1, m - 1)))
        ..write('}');
      k = m;
    }
    sink.write('}');
    return j;
  }

  var i = 0;
  while (i < message.length) {
    if (message[i] == '{') {
      flushLiteral();
      i = construct(message, i, out);
    } else {
      literal.write(message[i]);
      i++;
    }
  }
  flushLiteral();
  return out.toString();
}

String lengthen(String message) {
  final extra = '~' * ((message.length * 0.3).ceil());
  return '[$message$extra]';
}

void main() {
  final template = jsonDecode(
    File('lib/l10n/app_en.arb').readAsStringSync(),
  ) as Map<String, Object?>;
  final out = <String, Object?>{'@@locale': 'en_XA'};
  for (final e in template.entries) {
    if (e.key.startsWith('@')) continue;
    final v = e.value;
    if (v is String) out[e.key] = lengthen(pseudo(v));
  }
  File(
    'lib/l10n/app_en_XA.arb',
  ).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(out)}\n');
  stdout.writeln('wrote lib/l10n/app_en_XA.arb (${out.length - 1} messages)');
}
