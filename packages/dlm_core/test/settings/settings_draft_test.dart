import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:test/test.dart';

SettingsSnapshot global({
  Settings stored = const Settings(),
  Settings defaults = const Settings(
    maxConnections: 8,
    speedLimit: 0,
    retry: RetrySettings(maxAttempts: 5),
  ),
}) => SettingsSnapshot.global(
  GlobalSettings(settings: stored, defaults: defaults),
);

void main() {
  group('merge patch', () {
    test('merges objects, replaces values and removes nulls', () {
      final out = applyMergePatch(
        {
          'a': 1,
          'b': {'c': 2, 'd': 3},
          'e': 4,
        },
        {
          'a': 9,
          'b': {'c': null, 'x': 5},
          'e': null,
        },
      );
      expect(out, {
        'a': 9,
        'b': {'d': 3, 'x': 5},
      });
    });

    test('jsonAt follows dotted paths and tolerates gaps', () {
      final json = {
        'retry': {'maxAttempts': 3},
      };
      expect(jsonAt(json, 'retry.maxAttempts'), 3);
      expect(jsonAt(json, 'retry.nothing'), isNull);
      expect(jsonAt(json, 'torrent.seedRatio'), isNull);
    });
  });

  group('snapshot', () {
    test('global: stored values over the defaults, with their source', () {
      final s = global(stored: const Settings(maxConnections: 16));
      expect(s.overrides, {'maxConnections': 16});
      expect(s.effective['maxConnections'], 16);
      expect(s.effective['speedLimit'], 0);
      expect(s.sources['maxConnections'], SettingLevel.global);
      expect(s.sources['speedLimit'], SettingLevel.defaults);
      expect(s.sources['retry.maxAttempts'], SettingLevel.defaults);
    });
  });

  group('draft', () {
    test('untouched, it is clean and shows what applies', () {
      final d = SettingsDraft(
        global(stored: const Settings(maxConnections: 16)),
      );
      expect(d.isDirty, isFalse);
      expect(d.patch, isEmpty);
      expect(d.valueOf('maxConnections'), 16);
      expect(d.valueOf('speedLimit'), 0);
      expect(d.isOverridden('maxConnections'), isTrue);
      expect(d.isOverridden('speedLimit'), isFalse);
      expect(d.levelOf('maxConnections'), SettingLevel.global);
      expect(d.levelOf('speedLimit'), SettingLevel.defaults);
    });

    test('an edit is a merge patch, nested like the settings', () {
      final d = SettingsDraft(global())
        ..set('maxConnections', 4)
        ..set('retry.maxAttempts', 9);
      expect(d.isDirty, isTrue);
      expect(d.patch, {
        'maxConnections': 4,
        'retry': {'maxAttempts': 9},
      });
      expect(d.valueOf('maxConnections'), 4);
      expect(d.isOverridden('retry.maxAttempts'), isTrue);
      expect(d.levelOf('retry.maxAttempts'), SettingLevel.global);
    });

    test('setting the stored value again is no change', () {
      final d =
          SettingsDraft(global(stored: const Settings(maxConnections: 16)))
            ..set('maxConnections', 4)
            ..set('maxConnections', 16);
      expect(d.isDirty, isFalse);
    });

    test('reset removes an override and shows the value below', () {
      final d = SettingsDraft(
        global(stored: const Settings(maxConnections: 16)),
      )..reset('maxConnections');
      expect(d.patch, {'maxConnections': null});
      expect(d.isOverridden('maxConnections'), isFalse);
      expect(d.valueOf('maxConnections'), 8, reason: 'the default');
      expect(d.levelOf('maxConnections'), SettingLevel.defaults);
    });

    test('resetting a field that has no override changes nothing', () {
      final d = SettingsDraft(global())
        ..set('maxConnections', 4)
        ..reset('maxConnections');
      expect(d.isDirty, isFalse);
    });

    test('the result is the overrides after saving', () {
      final d =
          SettingsDraft(
              global(
                stored: const Settings(maxConnections: 16, speedLimit: 100),
              ),
            )
            ..set('speedLimit', 500)
            ..reset('maxConnections')
            ..set('retry.maxAttempts', 2);
      expect(d.result, {
        'speedLimit': 500,
        'retry': {'maxAttempts': 2},
      });
    });

    test('revert drops edits and errors', () {
      final d = SettingsDraft(global())
        ..set('maxConnections', 4)
        ..applyProblem(
          const ApiProblem(
            status: 422,
            code: 'settings.invalid',
            errors: [
              ProblemDetail(
                message: 'too big',
                location: 'body.maxConnections',
              ),
            ],
          ),
        )
        ..revert();
      expect(d.isDirty, isFalse);
      expect(d.hasErrors, isFalse);
    });

    test('422 locations become field errors until the field is edited', () {
      final d = SettingsDraft(global())
        ..set('maxConnections', 999)
        ..set('retry.maxAttempts', 0)
        ..applyProblem(
          const ApiProblem(
            status: 422,
            code: 'settings.invalid',
            errors: [
              ProblemDetail(
                message: 'must be at most 64',
                location: 'body.maxConnections',
              ),
              ProblemDetail(
                message: 'must be at least 1',
                location: 'body.settings.retry.maxAttempts',
              ),
              ProblemDetail(message: 'odd', location: 'body.mystery'),
            ],
          ),
        );
      expect(d.errorsOf('maxConnections'), ['must be at most 64']);
      expect(d.errorsOf('retry.maxAttempts'), ['must be at least 1']);
      expect(d.unmatchedErrors({'maxConnections', 'retry.maxAttempts'}), [
        'odd',
      ]);
      d.set('maxConnections', 4);
      expect(d.errorsOf('maxConnections'), isEmpty);
      expect(d.errorsOf('retry.maxAttempts'), isNotEmpty);
    });
  });

  group('rebasing', () {
    test('edits survive a new snapshot; one that now equals it drops out', () {
      final draft = SettingsDraft(global())
        ..set('maxConnections', 12)
        ..set('speedLimit', 500);
      final next = global(stored: const Settings(speedLimit: 500));
      final rebased = draft.rebasedOn(next);
      expect(rebased.snapshot, same(next));
      expect(rebased.valueOf('maxConnections'), 12);
      // Somebody saved the same value elsewhere: nothing left to save.
      expect(rebased.patch, {'maxConnections': 12});
      expect(rebased.isDirty, isTrue);
    });
  });
}
