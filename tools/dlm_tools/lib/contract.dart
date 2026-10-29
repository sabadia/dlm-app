/// What changed between the OpenAPI document the app was built on and a newer
/// one, from the app's point of view.
class ContractReport {
  /// Creates a report.
  const ContractReport({
    required this.removed,
    required this.changed,
    required this.added,
  });

  /// Operations the app knows that the new document no longer has.
  final List<String> removed;

  /// Operations that still exist but lost a response code or a request field
  /// the app may rely on.
  final List<String> changed;

  /// Operations only the new document has (the app does not use them yet).
  final List<String> added;

  /// Whether the app may stop working against the new daemon.
  bool get breaking => removed.isNotEmpty || changed.isNotEmpty;
}

const _methods = {'get', 'put', 'post', 'delete', 'patch', 'head', 'options'};

Map<String, Map<String, Object?>> _operations(Map<String, Object?> doc) {
  final out = <String, Map<String, Object?>>{};
  final paths = doc['paths'];
  if (paths is! Map<String, Object?>) return out;
  for (final p in paths.entries) {
    final item = p.value;
    if (item is! Map<String, Object?>) continue;
    for (final m in item.entries) {
      if (_methods.contains(m.key) && m.value is Map<String, Object?>) {
        out['${m.key.toUpperCase()} ${p.key}'] =
            m.value! as Map<String, Object?>;
      }
    }
  }
  return out;
}

Set<String> _responseCodes(Map<String, Object?> op) {
  final r = op['responses'];
  return r is Map<String, Object?> ? r.keys.toSet() : {};
}

Set<String> _requiredFields(Object? doc, Map<String, Object?> op) {
  final body = op['requestBody'];
  if (body is! Map<String, Object?>) return {};
  final content = body['content'];
  if (content is! Map<String, Object?>) return {};
  for (final media in content.values) {
    if (media is Map<String, Object?>) {
      final schema = media['schema'];
      if (schema is Map<String, Object?>) {
        final req = schema['required'];
        if (req is List<Object?>) return {for (final r in req) '$r'};
      }
    }
  }
  return {};
}

/// Compares [pinned] (what the app was generated from) with [latest].
///
/// A removed operation, a response code that disappeared (the app handles it),
/// or a new *required* request field is breaking; a new operation is not.
ContractReport compareContracts(
  Map<String, Object?> pinned,
  Map<String, Object?> latest,
) {
  final before = _operations(pinned);
  final after = _operations(latest);
  final removed = <String>[];
  final changed = <String>[];
  for (final e in before.entries) {
    final next = after[e.key];
    if (next == null) {
      removed.add(e.key);
      continue;
    }
    final lostCodes = _responseCodes(e.value).difference(_responseCodes(next));
    if (lostCodes.isNotEmpty) {
      changed.add('${e.key}: responses ${lostCodes.toList()..sort()} are gone');
    }
    final newRequired = _requiredFields(
      latest,
      next,
    ).difference(_requiredFields(pinned, e.value));
    if (newRequired.isNotEmpty) {
      changed.add(
        '${e.key}: new required request fields ${newRequired.toList()..sort()}',
      );
    }
  }
  final added = [
    for (final k in after.keys)
      if (!before.containsKey(k)) k,
  ];
  return ContractReport(
    removed: removed..sort(),
    changed: changed..sort(),
    added: added..sort(),
  );
}
