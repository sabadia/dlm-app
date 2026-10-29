import 'dart:convert';

/// A download a launch, a protocol link or an opened file asked the app to add.
///
/// [links] are magnet, ed2k, http, https, ftp, or the link unwrapped from a
/// `dlm:` URL. [torrents] are paths of `.torrent` files. An empty value means
/// the running instance should only come forward.
class HandedOpen {
  /// Creates an open request.
  const HandedOpen({this.links = const [], this.torrents = const []});

  /// Download links, in the order they were given.
  final List<String> links;

  /// Paths of `.torrent` files, in the order they were given.
  final List<String> torrents;

  /// Whether nothing was handed over.
  bool get isEmpty => links.isEmpty && torrents.isEmpty;

  /// The form sent to the running instance. The text is not written to a log.
  Map<String, Object?> toJson() => {'links': links, 'torrents': torrents};

  /// Decodes a hand-off; null when [raw] is not that form.
  static HandedOpen? fromJson(Object? raw) {
    if (raw is! Map) return null;
    return HandedOpen(
      links: _strings(raw['links']),
      torrents: _strings(raw['torrents']),
    );
  }

  static List<String> _strings(Object? raw) => raw is List
      ? [
          for (final v in raw)
            if (v is String) v,
        ]
      : const [];

  @override
  bool operator ==(Object other) =>
      other is HandedOpen &&
      _same(other.links, links) &&
      _same(other.torrents, torrents);

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(links), Object.hashAll(torrents));

  static bool _same(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// The download targets in [args]. Flags (anything starting with `-`) are
/// ignored, and a value seen twice counts once.
///
/// A `dlm:` link is either `dlm:` plus an http, https, ftp, magnet or ed2k
/// URL, or `dlm://add?url=` with that URL percent-encoded. A `.torrent` file
/// path, including a `file:` URL, is kept as a path. Any other http, https or
/// ftp URL is a link, which is how a browser hands a download over.
HandedOpen parseHanded(List<String> args) {
  final links = <String>[];
  final torrents = <String>[];
  final seen = <String>{};
  for (final raw in args) {
    final arg = raw.trim();
    if (arg.isEmpty || arg.startsWith('-')) continue;
    final link = _link(arg);
    if (link != null) {
      if (seen.add('l:$link')) links.add(link);
      continue;
    }
    final torrent = _torrentPath(arg);
    if (torrent != null && seen.add('t:$torrent')) torrents.add(torrent);
  }
  return HandedOpen(links: links, torrents: torrents);
}

String? _link(String arg) {
  if (arg.toLowerCase().startsWith('dlm:')) return _unwrapDlm(arg);
  return _plainDownload(arg);
}

/// The download named by a `dlm:` link, or null when it names nothing we add.
String? _unwrapDlm(String arg) {
  final rest = arg.substring(4);
  if (rest.startsWith('//')) {
    final uri = Uri.tryParse('dlm:$rest');
    final url = uri != null && uri.host == 'add'
        ? uri.queryParameters['url']
        : null;
    return url == null ? null : _plainDownload(url);
  }
  return _plainDownload(rest);
}

/// Whether [value] has a control character or a space. A link that has one
/// could carry a second line into the add dialog, so it is not a link.
bool _hasControlOrSpace(String value) {
  for (final unit in value.codeUnits) {
    if (unit <= 0x20 || unit == 0x7f) return true;
  }
  return false;
}

String? _plainDownload(String value) {
  if (_hasControlOrSpace(value)) return null;
  final lower = value.toLowerCase();
  if (lower.startsWith('magnet:?') || lower.startsWith('magnet://')) {
    return value;
  }
  if (lower.startsWith('ed2k://')) return value;
  final uri = Uri.tryParse(value);
  if (uri == null || uri.host.isEmpty) return null;
  return switch (uri.scheme.toLowerCase()) {
    'http' || 'https' || 'ftp' => value,
    _ => null,
  };
}

String? _torrentPath(String arg) {
  if (arg.toLowerCase().startsWith('file:')) {
    final uri = Uri.tryParse(arg);
    if (uri == null || uri.scheme.toLowerCase() != 'file') return null;
    final path = uri.toFilePath();
    return path.toLowerCase().endsWith('.torrent') ? path : null;
  }
  return arg.toLowerCase().endsWith('.torrent') ? arg : null;
}

/// Encodes [open] as one line. Used by the instance hand-off.
String encodeHanded(HandedOpen open) => jsonEncode(open.toJson());

/// Decodes one hand-off line; null when it is not one.
HandedOpen? decodeHanded(String line) {
  try {
    return HandedOpen.fromJson(jsonDecode(line));
  } on FormatException {
    return null;
  }
}
