import 'package:dlm_api/dlm_api.dart';

/// A category being added or edited, as typed.
class CategoryDraft {
  /// Creates a draft; [from] fills it from an existing category.
  CategoryDraft({Category? from})
    : name = from?.name ?? '',
      dir = from?.dir ?? '',
      extensions = (from?.extensions ?? const []).join(', '),
      mimeTypes = (from?.mimeTypes ?? const []).join('\n');

  /// The category's name.
  String name;

  /// The folder files of the category are sorted into.
  String dir;

  /// File extensions, separated by commas, spaces or lines (`mkv, mp4`).
  String extensions;

  /// MIME types, one per line (`video/*`).
  String mimeTypes;

  /// The extensions as the daemon wants them: lower case, no dot, no repeats.
  List<String> get parsedExtensions {
    final out = <String>[];
    for (final raw in extensions.split(RegExp(r'[\s,;]+'))) {
      final e = raw.trim().replaceFirst(RegExp(r'^\.+'), '').toLowerCase();
      if (e.isNotEmpty && !out.contains(e)) out.add(e);
    }
    return out;
  }

  /// The MIME types, one per non-blank line.
  List<String> get parsedMimeTypes {
    final out = <String>[];
    for (final raw in mimeTypes.split(RegExp(r'[\r\n,;]+'))) {
      final m = raw.trim().toLowerCase();
      if (m.isNotEmpty && !out.contains(m)) out.add(m);
    }
    return out;
  }

  /// Whether every extension is letters and digits.
  bool get extensionsValid =>
      parsedExtensions.every((e) => RegExp(r'^[a-z0-9_+-]+$').hasMatch(e));

  /// Whether every MIME type looks like `type/subtype` (or `type/*`).
  bool get mimeTypesValid => parsedMimeTypes.every(
    (m) => RegExp(r'^[a-z0-9.+-]+/([a-z0-9.+-]+|\*)$').hasMatch(m),
  );

  /// Whether the name and folder are filled.
  bool get namedAndPlaced => name.trim().isNotEmpty && dir.trim().isNotEmpty;

  /// Whether the draft can be saved.
  bool get valid =>
      namedAndPlaced &&
      extensionsValid &&
      mimeTypesValid &&
      (parsedExtensions.isNotEmpty || parsedMimeTypes.isNotEmpty);

  /// The body of a new category.
  CreateCategoryBody toCreate() => CreateCategoryBody(
    name: name.trim(),
    dir: dir.trim(),
    extensions: parsedExtensions,
    mimeTypes: parsedMimeTypes,
  );

  /// The body that turns [old] into the draft; only what changed is sent.
  UpdateCategoryBody toUpdate(Category old) => UpdateCategoryBody(
    name: name.trim() == old.name ? null : name.trim(),
    dir: dir.trim() == old.dir ? null : dir.trim(),
    extensions: _same(parsedExtensions, old.extensions)
        ? null
        : parsedExtensions,
    mimeTypes: _same(parsedMimeTypes, old.mimeTypes) ? null : parsedMimeTypes,
  );

  static bool _same(List<String> a, List<String>? b) {
    final other = b ?? const [];
    return a.length == other.length && a.every(other.contains);
  }
}
