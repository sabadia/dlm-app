import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<AppLocalizations> english() =>
      AppLocalizations.delegate.load(const Locale('en'));

  test('fills parameters into the message', () async {
    final l = await english();
    expect(
      problemMessage(l, 'task.duplicate', {'status': 'queued'}),
      'This file is already in your downloads (queued).',
    );
    expect(
      problemMessage(l, 'task.invalid_state', {
        'operation': 'restart',
        'status': 'queued',
      }),
      contains('restart'),
    );
    expect(
      problemMessage(l, 'origin.failed', {'code': 'http_503'}),
      contains('http_503'),
    );
  });

  test('a code this build does not know has no message', () async {
    expect(problemMessage(await english(), 'future.thing', {}), isNull);
  });

  test('missing parameters do not crash', () async {
    expect(problemMessage(await english(), 'task.duplicate', {}), isNotEmpty);
  });
}
