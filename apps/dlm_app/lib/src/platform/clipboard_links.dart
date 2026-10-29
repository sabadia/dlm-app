/// The first download link in [text], or null when there is none.
///
/// Only http, https, ftp, magnet and ed2k count. The rest of the clipboard
/// is ignored, and nothing here is written anywhere.
String? firstDownloadLink(String text) {
  final match = _link.firstMatch(text);
  if (match == null) return null;
  final raw = match.group(0)!;
  return raw.replaceFirst(RegExp(r'[)\]>,.;]+$'), '');
}

final _link = RegExp(
  r'(?:https?|ftp)://\S+|magnet:\?\S+|ed2k://\S+',
  caseSensitive: false,
);
