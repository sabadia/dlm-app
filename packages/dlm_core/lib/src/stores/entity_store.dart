/// Stops listening when called.
typedef Disposer = void Function();

/// The normalised cache of one kind of entity: every entity exists once, by id,
/// and anything that shows it listens to that id only. A change to one task
/// wakes the row of that task and nothing else.
class EntityStore<T> {
  final _items = <String, T>{};
  final _byId = <String, Set<void Function()>>{};
  final _any = <void Function()>{};

  /// The entity [id], or null.
  T? operator [](String id) => _items[id];

  /// How many entities are cached.
  int get length => _items.length;

  /// The ids of the cached entities (unordered).
  Iterable<String> get ids => _items.keys;

  /// Whether [id] is cached.
  bool contains(String id) => _items.containsKey(id);

  /// Stores [value] under [id] and wakes its listeners.
  void put(String id, T value) {
    _items[id] = value;
    _notify(id);
  }

  /// Stores many entities; each listener is woken once at the end.
  void putAll(Iterable<MapEntry<String, T>> entries) {
    final changed = <String>[];
    for (final e in entries) {
      _items[e.key] = e.value;
      changed.add(e.key);
    }
    changed.forEach(_notify);
  }

  /// Removes [id]; returns what was stored.
  T? remove(String id) {
    final old = _items.remove(id);
    if (old != null) _notify(id);
    return old;
  }

  /// Forgets everything (after a reset the state is fetched again).
  void clear() {
    final all = _items.keys.toList();
    _items.clear();
    all.forEach(_notify);
  }

  /// Calls [listener] when [id] changes.
  Disposer listen(String id, void Function() listener) {
    final set = _byId.putIfAbsent(id, () => {})..add(listener);
    return () {
      set.remove(listener);
      if (set.isEmpty) _byId.remove(id);
    };
  }

  /// Calls [listener] when any entity changes.
  Disposer listenAll(void Function() listener) {
    _any.add(listener);
    return () => _any.remove(listener);
  }

  void _notify(String id) {
    final targeted = _byId[id];
    if (targeted != null) {
      for (final l in List.of(targeted)) {
        l();
      }
    }
    for (final l in List.of(_any)) {
      l();
    }
  }
}
