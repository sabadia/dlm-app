import 'package:dlm_api/dlm_api.dart';

/// How the daemon should treat a link.
enum AddMode {
  /// Let the daemon decide from the link.
  auto,

  /// A file to fetch as it is.
  direct,

  /// A page with media: the yt-dlp tool picks the stream.
  ytdlp,

  /// A page that needs a real browser to find the file.
  browser,
}

/// The checksum algorithms and the length of their hex digest.
const Map<String, int> checksumHexLength = {
  'md5': 32,
  'sha1': 40,
  'sha256': 64,
  'blake3': 64,
};

/// The optional settings of an added download, as typed in the dialog.
class AdvancedDraft {
  /// Creates an empty draft.
  AdvancedDraft();

  /// The page the link was found on.
  String referrer = '';

  /// Extra request headers, one `Name: value` per line.
  String headers = '';

  /// Other places the same file can be fetched from, one link per line.
  String mirrors = '';

  /// The checksum algorithm.
  String algorithm = 'sha256';

  /// The expected digest in hex; empty for no check.
  String digest = '';

  /// How the link is treated.
  AddMode mode = AddMode.auto;

  /// The headers as a map, or null when a line is not `Name: value`.
  Map<String, String>? get parsedHeaders {
    final out = <String, String>{};
    for (final raw in headers.split(RegExp(r'\r?\n'))) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      final at = line.indexOf(':');
      if (at <= 0) return null;
      final name = line.substring(0, at).trim();
      final value = line.substring(at + 1).trim();
      if (name.isEmpty || value.isEmpty) return null;
      out[name] = value;
    }
    return out;
  }

  /// The mirrors, one per non-blank line.
  List<String> get parsedMirrors => [
    for (final line in mirrors.split(RegExp(r'\r?\n')))
      if (line.trim().isNotEmpty) line.trim(),
  ];

  /// Whether the digest is empty or a hex string of the right length.
  bool get digestValid {
    final d = digest.trim();
    if (d.isEmpty) return true;
    return d.length == checksumHexLength[algorithm] &&
        RegExp(r'^[0-9a-fA-F]+$').hasMatch(d);
  }

  /// Whether every field is usable.
  bool get valid => parsedHeaders != null && digestValid;

  /// Whether nothing was set.
  bool get isEmpty =>
      referrer.trim().isEmpty &&
      headers.trim().isEmpty &&
      mirrors.trim().isEmpty &&
      digest.trim().isEmpty &&
      mode == AddMode.auto;

  /// The source of a task for [link] with the draft's headers, referrer,
  /// mirrors and mode.
  SourceInput source(String link) => SourceInput(
    currentUrl: link,
    headers: (parsedHeaders ?? const {}).isEmpty ? null : parsedHeaders,
    mirrors: parsedMirrors.isEmpty ? null : parsedMirrors,
    referrer: referrer.trim().isEmpty ? null : referrer.trim(),
    resolverKind: switch (mode) {
      AddMode.auto => null,
      AddMode.direct => SourceInputResolverKind.direct,
      AddMode.ytdlp => SourceInputResolverKind.ytdlp,
      AddMode.browser => SourceInputResolverKind.browser,
    },
  );

  /// The settings overrides of the task (the checksum), or null when none.
  Settings? get settings => digest.trim().isEmpty
      ? null
      : Settings(
          checksum: Checksum(
            algorithm: algorithm,
            expected: digest.trim().toLowerCase(),
          ),
        );
}
