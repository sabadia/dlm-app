import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'every problem code and app failure the core can present has a text',
    () async {
      final l = await AppLocalizations.delegate.load(const Locale('en'));
      final missing = [
        for (final key in {...knownProblemCodes, ...appFailureKeys})
          if (problemMessage(l, key, const {}) == null) key,
      ];
      expect(
        missing,
        isEmpty,
        reason: 'add them to packages/dlm_l10n/lib/l10n/app_en.arb',
      );
    },
  );

  test('a presented failure resolves to a localised message', () async {
    final l = await AppLocalizations.delegate.load(const Locale('en'));
    final p = presentFailure(
      const ApiProblem(status: 404, code: 'task.not_found'),
    )!;
    expect(problemMessage(l, p.messageKey, p.params), contains('download'));
  });
}
