import 'dart:convert';
import 'dart:ffi' show Abi;
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// A daemon build installed by the app, beside the one that ships with it.
class InstalledEngine {
  /// Creates the record.
  const InstalledEngine({required this.version, required this.path});

  /// The version without the leading `v`, such as `0.7.4`.
  final String version;

  /// The executable.
  final String path;
}

/// A published daemon release.
class EngineRelease {
  /// Creates the release.
  const EngineRelease({required this.tag, required this.page});

  /// The tag, such as `v0.7.4`.
  final String tag;

  /// The release page.
  final String page;

  /// The version without the leading `v`.
  String get version => tag.replaceFirst(RegExp('^v'), '');
}

/// Why a daemon update failed, in words for the person.
class EngineUpdateException implements Exception {
  /// Creates the error.
  const EngineUpdateException(this.message);

  /// What went wrong.
  final String message;

  @override
  String toString() => message;
}

/// -1, 0 or 1 by the numeric parts of two versions (`v` and anything after a
/// `-` or `+` are ignored). Daemon releases are plain `x.y.z`.
int compareVersions(String a, String b) {
  List<int> parts(String v) => [
    for (final p
        in v
            .replaceFirst(RegExp('^v'), '')
            .split(RegExp('[-+]'))
            .first
            .split('.'))
      int.tryParse(p) ?? 0,
  ];
  final x = parts(a);
  final y = parts(b);
  for (var i = 0; i < (x.length > y.length ? x.length : y.length); i++) {
    final l = i < x.length ? x[i] : 0;
    final r = i < y.length ? y[i] : 0;
    if (l != r) return l < r ? -1 : 1;
  }
  return 0;
}

/// Fetches a URL and returns the body; behind a function so tests do not use
/// the network.
typedef EngineFetch = Future<List<int>> Function(Uri url);

Future<List<int>> _download(Uri url) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(url);
    request.headers.set(HttpHeaders.userAgentHeader, 'dlm-app');
    final response = await request.close();
    if (response.statusCode != 200) {
      throw HttpException('${response.statusCode}', uri: url);
    }
    final out = BytesBuilder(copy: false);
    await for (final chunk in response) {
      out.add(chunk);
    }
    return out.takeBytes();
  } finally {
    client.close(force: true);
  }
}

/// Daemon builds the app downloaded itself: it lets a new server release be
/// used without a new app. They live in one directory per version below
/// [root]; the newest of them and the one bundled with the app is run.
class DaemonEngines {
  /// Creates the store below [root]. The other arguments exist for tests.
  DaemonEngines(
    this.root, {
    EngineFetch? fetch,
    String? operatingSystem,
    String? architecture,
    this.repository = 'sabadia/dlm-server',
    this.keep = 2,
  }) : _fetch = fetch ?? _download,
       _os = operatingSystem ?? _detectOs(),
       _arch = architecture ?? _detectArch();

  /// The directory the versions are in.
  final String root;

  /// The GitHub repository the releases come from.
  final String repository;

  /// How many installed versions are kept; older ones are removed.
  final int keep;

  final EngineFetch _fetch;
  final String _os;
  final String _arch;

  static String _detectOs() => switch (Platform.operatingSystem) {
    'macos' => 'darwin',
    final other => other,
  };

  static String _detectArch() {
    final abi = Abi.current().toString();
    return abi.endsWith('arm64') || abi.endsWith('arm64_ios')
        ? 'arm64'
        : 'amd64';
  }

  String get _exe => _os == 'windows' ? 'dlm.exe' : 'dlm';

  /// The versions installed, newest first.
  List<InstalledEngine> installed() {
    final dir = Directory(root);
    if (!dir.existsSync()) return const [];
    final found = <InstalledEngine>[];
    for (final entry in dir.listSync(followLinks: false)) {
      if (entry is! Directory) continue;
      final name = entry.uri.pathSegments.where((s) => s.isNotEmpty).last;
      if (!RegExp(r'^\d+\.\d+\.\d+$').hasMatch(name)) continue;
      final path = '${entry.path}${Platform.pathSeparator}$_exe';
      if (File(path).existsSync()) {
        found.add(InstalledEngine(version: name, path: path));
      }
    }
    found.sort((a, b) => compareVersions(b.version, a.version));
    return found;
  }

  /// The installed build to run instead of the bundled one: the newest, when
  /// it is newer than [bundled] (empty or null when the app bundles none).
  InstalledEngine? preferred({String? bundled}) {
    final all = installed();
    if (all.isEmpty) return null;
    final best = all.first;
    if (bundled == null || bundled.isEmpty) return best;
    return compareVersions(best.version, bundled) > 0 ? best : null;
  }

  /// The latest published release, or null when it cannot be read.
  Future<EngineRelease> latest() async {
    try {
      final body = await _fetch(
        Uri.parse('https://api.github.com/repos/$repository/releases/latest'),
      );
      final json = jsonDecode(utf8.decode(body));
      if (json is Map<String, Object?> && json['tag_name'] is String) {
        final page = json['html_url'];
        return EngineRelease(
          tag: json['tag_name']! as String,
          page: page is String ? page : '',
        );
      }
    } on Object catch (e) {
      throw EngineUpdateException('could not read the latest release: $e');
    }
    throw const EngineUpdateException('the latest release has no tag');
  }

  /// Downloads [release] for this machine, checks it against the release's
  /// checksums and installs it. Returns the installed build.
  Future<InstalledEngine> install(EngineRelease release) async {
    final version = release.version;
    final ext = _os == 'windows' ? 'zip' : 'tar.gz';
    final asset = 'dlm_${version}_${_os}_$_arch.$ext';
    final base =
        'https://github.com/$repository/releases/download/${release.tag}';
    final List<int> archive;
    final String sums;
    try {
      archive = await _fetch(Uri.parse('$base/$asset'));
      sums = utf8.decode(
        await _fetch(Uri.parse('$base/dlm_${version}_checksums.txt')),
      );
    } on Object catch (e) {
      throw EngineUpdateException('could not download ${release.tag}: $e');
    }
    final expected = RegExp(
      '^([0-9a-f]{64})\\s+\\*?${RegExp.escape(asset)}\$',
      multiLine: true,
    ).firstMatch(sums)?.group(1);
    if (expected == null) {
      throw EngineUpdateException('${release.tag} has no checksum for $asset');
    }
    if (sha256.convert(archive).toString() != expected) {
      throw EngineUpdateException(
        '$asset does not match its checksum; it was not installed',
      );
    }

    final target = Directory('$root${Platform.pathSeparator}$version');
    final work = Directory(
      '$root${Platform.pathSeparator}.installing-$version',
    );
    try {
      if (work.existsSync()) work.deleteSync(recursive: true);
      work.createSync(recursive: true);
      final file = File('${work.path}${Platform.pathSeparator}$asset')
        ..writeAsBytesSync(archive);
      // tar reads both formats (Windows 10 and later ships bsdtar).
      final result = await Process.run('tar', [
        '-xf',
        file.path,
        '-C',
        work.path,
      ]);
      if (result.exitCode != 0) {
        throw EngineUpdateException(
          'could not unpack $asset: ${result.stderr}',
        );
      }
      file.deleteSync();
      final binary = work
          .listSync(recursive: true, followLinks: false)
          .whereType<File>()
          .where((f) => f.uri.pathSegments.last == _exe)
          .firstOrNull;
      if (binary == null) throw EngineUpdateException('$asset has no $_exe');
      if (_os != 'windows') await Process.run('chmod', ['+x', binary.path]);
      if (target.existsSync()) target.deleteSync(recursive: true);
      Directory(binary.parent.path).renameSync(target.path);
    } finally {
      if (work.existsSync()) work.deleteSync(recursive: true);
    }
    _prune();
    return InstalledEngine(
      version: version,
      path: '${target.path}${Platform.pathSeparator}$_exe',
    );
  }

  void _prune() {
    final all = installed();
    for (final old in all.skip(keep)) {
      try {
        Directory(File(old.path).parent.path).deleteSync(recursive: true);
      } on FileSystemException {
        // In use (Windows) or not ours to remove; the next update tries again.
      }
    }
  }
}
