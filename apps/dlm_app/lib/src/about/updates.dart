import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../prefs/pref_providers.dart';
import 'diagnostics_providers.dart';

/// One published build.
class ReleaseInfo {
  /// Creates a release.
  const ReleaseInfo({
    required this.tag,
    required this.page,
    required this.prerelease,
  });

  /// Reads a GitHub release object. Null when it has no tag.
  static ReleaseInfo? fromJson(Map<Object?, Object?> json) {
    final tag = json['tag_name'];
    if (tag is! String || tag.isEmpty) return null;
    final page = json['html_url'];
    return ReleaseInfo(
      tag: tag,
      page: page is String ? page : '',
      prerelease: json['prerelease'] == true,
    );
  }

  /// The tag, such as `v1.2.0`.
  final String tag;

  /// The release page.
  final String page;

  /// Whether GitHub marks it as a prerelease.
  final bool prerelease;
}

/// The newest release newer than [current], or null when nothing qualifies.
///
/// Stable ignores prereleases. The list is taken in order, newest first, which
/// is how the GitHub releases API returns it.
ReleaseInfo? chooseUpdate(
  List<ReleaseInfo> releases, {
  required bool beta,
  required String current,
}) {
  for (final release in releases) {
    if (!beta && release.prerelease) continue;
    if (isNewerVersion(release.tag, current)) return release;
  }
  return null;
}

/// Whether [remote] is a higher version than [current]. A leading `v` is
/// ignored. Build metadata after `+` is ignored.
bool isNewerVersion(String remote, String current) {
  final a = _numbers(remote);
  final b = _numbers(current);
  final count = a.length > b.length ? a.length : b.length;
  for (var i = 0; i < count; i++) {
    final left = i < a.length ? a[i] : 0;
    final right = i < b.length ? b[i] : 0;
    if (left != right) return left > right;
  }
  return false;
}

List<int> _numbers(String version) {
  final core = version
      .replaceFirst(RegExp('^v'), '')
      .split('+')
      .first
      .split('-')
      .first;
  return [for (final part in core.split('.')) int.tryParse(part) ?? 0];
}

/// Reads the published releases. Tests substitute their own.
final releaseSourceProvider = Provider<Future<List<ReleaseInfo>> Function()>(
  (ref) => fetchGitHubReleases,
);

/// The releases of `sabadia/dlm-app` on GitHub.
Future<List<ReleaseInfo>> fetchGitHubReleases() async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(
      Uri.parse('https://api.github.com/repos/sabadia/dlm-app/releases'),
    );
    request.headers.set(HttpHeaders.userAgentHeader, 'dlm-app');
    request.headers.set(
      HttpHeaders.acceptHeader,
      'application/vnd.github+json',
    );
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode != 200) {
      throw HttpException('releases ${response.statusCode}');
    }
    final json = jsonDecode(body);
    if (json is! List<Object?>) throw const FormatException('releases');
    return [
      for (final item in json)
        if (item is Map<Object?, Object?>)
          if (ReleaseInfo.fromJson(item) case final release?) release,
    ];
  } finally {
    client.close(force: true);
  }
}

/// The update channel and the check. Linux can open the release page. The
/// other systems install through their updater once packaging exists.
class UpdateSection extends ConsumerStatefulWidget {
  /// Creates the section.
  const UpdateSection({super.key});

  @override
  ConsumerState<UpdateSection> createState() => _UpdateSectionState();
}

class _UpdateSectionState extends ConsumerState<UpdateSection> {
  var _busy = false;
  var _checked = false;
  var _failed = false;
  ReleaseInfo? _offer;

  Future<void> _check() async {
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      final releases = await ref.read(releaseSourceProvider)();
      if (!mounted) return;
      final beta = ref.read(updateChannelProvider) == UpdateChannel.beta;
      setState(() {
        _offer = chooseUpdate(releases, beta: beta, current: appVersion);
        _checked = true;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _offer = null;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final channel = ref.watch(updateChannelProvider);
    final message = _failed
        ? l.ab_check_failed
        : _offer != null
        ? l.ab_available(_offer!.tag)
        : _checked
        ? l.ab_up_to_date
        : null;
    return DlmFormGroup(
      title: l.ab_updates,
      children: [
        DlmFormRow(
          label: l.ab_channel,
          control: SizedBox(
            width: 220,
            child: DlmDropdown<UpdateChannel>(
              semanticLabel: l.ab_channel,
              value: channel,
              choices: [
                DlmChoice(
                  value: UpdateChannel.stable,
                  label: l.ab_channel_stable,
                ),
                DlmChoice(value: UpdateChannel.beta, label: l.ab_channel_beta),
              ],
              onChanged: (value) => unawaited(
                ref.read(updateChannelProvider.notifier).set(value),
              ),
            ),
          ),
        ),
        DlmFormRow(
          label: l.ab_check,
          description: message,
          control: DlmButton(
            label: _busy ? l.ab_checking : l.ab_check,
            onPressed: _busy ? null : () => unawaited(_check()),
          ),
        ),
        if (_offer != null && Platform.isLinux && _offer!.page.isNotEmpty)
          DlmFormRow(
            label: l.ab_open_release,
            control: DlmButton(
              label: l.ab_open_release,
              onPressed: () => unawaited(openReleasePage(_offer!.page)),
            ),
          ),
      ],
    );
  }
}

/// Opens a release page. Linux uses this; the other systems install through
/// their updater once packaging exists.
Future<void> openReleasePage(String url) async {
  if (Platform.isMacOS) {
    await Process.run('open', [url]);
  } else if (Platform.isWindows) {
    await Process.run('cmd', ['/c', 'start', '', url]);
  } else {
    await Process.run('xdg-open', [url]);
  }
}
