/// A named combination of list settings the user can come back to: which
/// downloads, the search text, the sort and the engine filter.
class SavedView {
  /// Creates a view.
  const SavedView({
    required this.name,
    required this.filter,
    this.text = '',
    this.sort = 'position',
    this.descending = false,
    this.engine,
  });

  /// Decodes a view from the preferences file; null when unusable.
  static SavedView? fromJson(Object? raw) {
    if (raw is! Map<String, Object?>) return null;
    final name = raw['name'];
    final filter = raw['filter'];
    if (name is! String || name.isEmpty || filter is! String) return null;
    return SavedView(
      name: name,
      filter: filter,
      text: raw['text'] is String ? raw['text']! as String : '',
      sort: raw['sort'] is String ? raw['sort']! as String : 'position',
      descending: raw['descending'] == true,
      engine: raw['engine'] is String ? raw['engine']! as String : null,
    );
  }

  /// What the user calls it.
  final String name;

  /// The downloads filter (`all`, `active`, ...).
  final String filter;

  /// The search text.
  final String text;

  /// The sort key (`position`, `name`, `size`, `created`, `completed`).
  final String sort;

  /// Whether the sort runs from the largest to the smallest.
  final bool descending;

  /// Only downloads of this engine.
  final String? engine;

  /// The form stored in the preferences file.
  Map<String, Object?> toJson() => {
    'name': name,
    'filter': filter,
    'text': text,
    'sort': sort,
    'descending': descending,
    'engine': engine,
  };
}
