import 'dart:io';

/// The `server.address` the user saved in the daemon's configuration file, or
/// null when there is none.
///
/// The app starts its daemon on a free port of its own choosing, and a command
/// line flag outranks the configuration file: if the app passed that flag
/// whatever the file says, an address saved under Manage, Daemon would be
/// ignored at every start. So the flag is only passed when the file has no
/// address.
String? configuredServerAddress(String home) {
  final file = File(
    '$home${Platform.pathSeparator}config'
    '${Platform.pathSeparator}config.yaml',
  );
  try {
    if (!file.existsSync()) return null;
    return serverAddressIn(file.readAsStringSync());
  } on FileSystemException {
    return null;
  }
}

/// The `address` under the top-level `server:` key of a configuration file's
/// [text]. The daemon writes plain two-level YAML, so no YAML parser is needed.
String? serverAddressIn(String text) {
  var inServer = false;
  for (final raw in text.split(RegExp(r'\r?\n'))) {
    if (raw.trim().isEmpty || raw.trimLeft().startsWith('#')) continue;
    final indented = raw.startsWith(' ') || raw.startsWith('\t');
    if (!indented) {
      inServer = RegExp(r'^server\s*:\s*(#.*)?$').hasMatch(raw);
      continue;
    }
    if (!inServer) continue;
    final match = RegExp(r'^\s+address\s*:\s*(.*?)\s*$').firstMatch(raw);
    if (match == null) continue;
    var value = match.group(1)!;
    final comment = value.indexOf(' #');
    if (comment >= 0) value = value.substring(0, comment).trim();
    if (value.length >= 2 &&
        (value.startsWith("'") && value.endsWith("'") ||
            value.startsWith('"') && value.endsWith('"'))) {
      value = value.substring(1, value.length - 1);
    }
    return value.isEmpty ? null : value;
  }
  return null;
}
