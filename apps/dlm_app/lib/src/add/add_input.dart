/// The links typed or pasted into the add dialog: one per line; blank lines
/// and lines starting with `#` are skipped, and a link seen twice counts once.
List<String> parseLinks(String text) {
  final seen = <String>{};
  return [
    for (final raw in text.split(RegExp(r'\r?\n')))
      if (raw.trim().isNotEmpty &&
          !raw.trim().startsWith('#') &&
          seen.add(raw.trim()))
        raw.trim(),
  ];
}

/// Whether [link] is a pattern the daemon expands into many links, such as
/// `http://host/img[001-120].jpg` or `http://host/{a,b,c}.zip`.
bool isPattern(String link) =>
    RegExp(r'\[[^\]]*\d+\s*-\s*\d+[^\]]*\]').hasMatch(link) ||
    RegExp(r'\{[^}]*,[^}]*\}').hasMatch(link);
