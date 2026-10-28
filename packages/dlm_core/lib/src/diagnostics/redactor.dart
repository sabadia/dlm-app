/// Removes secrets from text before it is logged, shown or copied.
///
/// Tokens, cookies, passwords and URL credentials never belong in a log or a
/// support bundle. The rules are deliberately broad: a diagnostics bundle that
/// hides a harmless long identifier is better than one that leaks a token.
class Redactor {
  /// Creates a redactor.
  Redactor({this.homeDirectory});

  /// The user's home directory; replaced by `~` so file paths do not reveal
  /// the account name.
  final String? homeDirectory;

  final _secrets = <String>{};

  /// The mask that replaces a secret.
  static const mask = '[redacted]';

  /// Registers a value (the current API token) that is removed wherever it
  /// appears. Values shorter than 6 characters are ignored (too likely to
  /// match ordinary text).
  void addSecret(String value) {
    if (value.length >= 6) _secrets.add(value);
  }

  /// Forgets a secret that is no longer in use.
  void removeSecret(String value) => _secrets.remove(value);

  static final _rules = <(RegExp, String Function(Match))>[
    // Authorization and cookie headers, in any case.
    (
      RegExp(
        r'(authorization|proxy-authorization)\s*[:=]\s*[^\r\n]+',
        caseSensitive: false,
      ),
      (m) => '${m.group(1)}: $mask',
    ),
    (
      RegExp(r'((?:set-)?cookie)\s*[:=]\s*[^\r\n]+', caseSensitive: false),
      (m) => '${m.group(1)}: $mask',
    ),
    // Bearer tokens anywhere.
    (
      RegExp(r'bearer\s+[A-Za-z0-9._~+/=-]+', caseSensitive: false),
      (_) => 'Bearer $mask',
    ),
    // Credentials in URLs: scheme://user:password@host
    (
      RegExp(
        r'([a-z][a-z0-9+.-]*://)[^\s/@:]+(?::[^\s/@]*)?@',
        caseSensitive: false,
      ),
      (m) => '${m.group(1)}$mask@',
    ),
    // key=value or "key": "value" for secret-looking keys; a quoted value may
    // contain spaces.
    (
      RegExp(
        r'''(["']?(?:token|access_token|api[_-]?key|secret|password|passwd|pwd|signature|sig|auth|session|sessionid|csrf)["']?\s*[:=]\s*)(?:"[^"]*"|'[^']*'|[^\s&,;}]+)''',
        caseSensitive: false,
      ),
      (m) {
        final value = m.group(0)!.substring(m.group(1)!.length);
        final quote = value.startsWith('"') || value.startsWith("'")
            ? value[0]
            : '';
        return '${m.group(1)}$quote$mask$quote';
      },
    ),
  ];

  /// [text] with every secret removed.
  String redact(String text) {
    var out = text;
    for (final secret in _secrets) {
      out = out.replaceAll(secret, mask);
    }
    for (final (pattern, replace) in _rules) {
      out = out.replaceAllMapped(pattern, replace);
    }
    final home = homeDirectory;
    if (home != null && home.length > 1) out = out.replaceAll(home, '~');
    return out;
  }
}
