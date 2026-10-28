/// A licence family recognised in a package's licence file.
enum LicenseKind {
  /// Apache License 2.0.
  apache2,

  /// MIT.
  mit,

  /// BSD 2- or 3-clause.
  bsd,

  /// Mozilla Public License 2.0.
  mpl2,

  /// ISC.
  isc,

  /// Public domain dedications (Unlicense, CC0).
  publicDomain,

  /// GPL, LGPL, AGPL: not allowed in this project.
  copyleft,

  /// Not recognised: needs a human decision (tools/license_allowlist.yaml).
  unknown;

  /// Whether the licence is compatible with this Apache-2.0 project.
  bool get allowed => this != copyleft && this != unknown;
}

/// Classifies the text of a licence file.
LicenseKind classifyLicense(String text) {
  final t = text.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  if (t.contains('gnu affero general public license') ||
      t.contains('gnu lesser general public license') ||
      t.contains('gnu general public license')) {
    return LicenseKind.copyleft;
  }
  if (t.contains('apache license') && t.contains('version 2.0')) {
    return LicenseKind.apache2;
  }
  if (t.contains('mozilla public license') && t.contains('2.0')) {
    return LicenseKind.mpl2;
  }
  if (t.contains('permission is hereby granted, free of charge')) {
    return LicenseKind.mit;
  }
  if (t.contains('redistribution and use in source and binary forms')) {
    return LicenseKind.bsd;
  }
  if (t.contains('permission to use, copy, modify, and/or distribute')) {
    return LicenseKind.isc;
  }
  if (t.contains(
        'this is free and unencumbered software released into the '
        'public domain',
      ) ||
      t.contains('cc0 1.0 universal')) {
    return LicenseKind.publicDomain;
  }
  return LicenseKind.unknown;
}
