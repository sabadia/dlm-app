import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:riverpod/misc.dart' show ProviderException;
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

/// A list over an in-memory "daemon".
class Fake extends ResourceList<String> {
  static List<String> remote = [];
  static Object? failNext;

  @override
  Future<List<String>> fetch(DlmApi api) async => List.of(remote);

  Future<void> add(String v) => mutate((api) async {
    if (failNext != null) {
      final e = failNext!;
      failNext = null;
      // ignore: only_throw_errors
      throw e;
    }
    remote.add(v);
  }, optimistic: (l) => [...l, v]);

  Future<void> removeItem(String v) => mutate(
    (api) async {
      if (failNext != null) {
        final e = failNext!;
        failNext = null;
        // ignore: only_throw_errors
        throw e;
      }
      remote.remove(v);
    },
    optimistic: (l) => [
      for (final x in l)
        if (x != v) x,
    ],
  );
}

/// A list that the daemon announces as changed elsewhere.
class Announced extends Fake {
  @override
  ResourceChangedDataKind get kind => ResourceChangedDataKind.category;
}

final fakeProvider = AsyncNotifierProvider<Fake, List<String>>(Fake.new);
final announcedProvider = AsyncNotifierProvider<Announced, List<String>>(
  Announced.new,
);

void main() {
  late ProviderContainer container;
  setUp(() {
    Fake.remote = ['a', 'b'];
    Fake.failNext = null;
    final api = DlmApi(const DlmEndpoint(baseUrl: 'http://127.0.0.1:1'));
    addTearDown(() => api.close(force: true));
    container = ProviderContainer.test(
      overrides: [apiProvider.overrideWithValue(api)],
      retry: dlmRetry,
    );
  });

  test('loads, then shows what the daemon stored after a change', () async {
    expect(await container.read(fakeProvider.future), ['a', 'b']);
    await container.read(fakeProvider.notifier).add('c');
    expect(container.read(fakeProvider).requireValue, ['a', 'b', 'c']);
  });

  test('the list changes before the daemon answers', () async {
    await container.read(fakeProvider.future);
    final gate = Completer<void>();
    final seen = <List<String>>[];
    container.listen(fakeProvider, (_, n) => seen.add(n.requireValue));
    // The "daemon" is slow: the optimistic list is visible meanwhile.
    final pending = container
        .read(fakeProvider.notifier)
        .mutate<void>((api) => gate.future, optimistic: (l) => [...l, 'x']);
    expect(container.read(fakeProvider).requireValue, ['a', 'b', 'x']);
    gate.complete();
    await pending;
    expect(seen.first, ['a', 'b', 'x']);
    expect(container.read(fakeProvider).requireValue, [
      'a',
      'b',
    ], reason: 'then the real list');
  });

  test('a refused change is rolled back and rethrown', () async {
    await container.read(fakeProvider.future);
    Fake.failNext = const ApiProblem(status: 409, code: 'category.in_use');
    await expectLater(
      container.read(fakeProvider.notifier).removeItem('a'),
      throwsA(isA<ApiProblem>()),
    );
    expect(container.read(fakeProvider).requireValue, ['a', 'b']);
  });

  test('a load failure is the state of the provider', () async {
    final api = DlmApi(const DlmEndpoint(baseUrl: 'http://127.0.0.1:1'));
    addTearDown(() => api.close(force: true));
    final c = ProviderContainer.test(
      overrides: [apiProvider.overrideWithValue(api)],
      retry: (_, _) => null,
    );
    final plugins = c.listen(pluginsProvider, (_, _) {});
    await expectLater(
      c.read(pluginsProvider.future),
      throwsA(
        predicate<Object>(
          (e) =>
              e is ApiConnectionFailure ||
              (e is ProviderException && e.exception is ApiConnectionFailure),
          'is (or wraps) an ApiConnectionFailure',
        ),
      ),
    );
    expect(plugins.read().hasError, isTrue);
  });

  test(
    'a change made elsewhere is read when the daemon announces it',
    () async {
      expect(await container.read(announcedProvider.future), ['a', 'b']);
      Fake.remote = ['a', 'b', 'c'];
      // Another kind of resource does not matter to this list.
      container
          .read(taskStoreProvider)
          .apply(
            StreamEvent.fromJson({
              'id': 1,
              'type': 'resource.changed',
              'time': '2026-10-30T10:00:00Z',
              'data': {'kind': 'webhook', 'op': 'created', 'id': 'w'},
            }),
          );
      await Future<void>.delayed(Duration.zero);
      expect(container.read(announcedProvider).value, ['a', 'b']);
      container
          .read(taskStoreProvider)
          .apply(
            StreamEvent.fromJson({
              'id': 2,
              'type': 'resource.changed',
              'time': '2026-10-30T10:00:01Z',
              'data': {'kind': 'category', 'op': 'created', 'id': 'c'},
            }),
          );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(container.read(announcedProvider).value, ['a', 'b', 'c']);
    },
  );
}
