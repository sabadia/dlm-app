/// Where a daemon runs.
enum ProfileKind {
  /// The daemon the app starts and manages on this machine.
  local,

  /// A daemon somewhere else, reached over the network.
  remote,
}

/// How the app reaches one daemon. Contains nothing secret: the token lives in
/// the [TokenVault](token_vault.dart).
class ConnectionProfile {
  /// Creates a profile.
  const ConnectionProfile({
    required this.id,
    required this.name,
    required this.kind,
    this.url,
    this.tlsPin,
  });

  /// The profile of the managed daemon.
  const ConnectionProfile.local({this.name = 'This computer'})
    : id = localId,
      kind = ProfileKind.local,
      url = null,
      tlsPin = null;

  /// Decodes a stored profile; throws [FormatException] when it is malformed.
  factory ConnectionProfile.fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final name = json['name'];
    final kind = json['kind'];
    if (id is! String || id.isEmpty || name is! String || kind is! String) {
      throw const FormatException('a profile needs id, name and kind');
    }
    final parsed = ProfileKind.values.where((k) => k.name == kind);
    if (parsed.isEmpty) throw FormatException('unknown profile kind $kind');
    final url = json['url'];
    final pin = json['tlsPin'];
    return ConnectionProfile(
      id: id,
      name: name,
      kind: parsed.single,
      url: url is String ? url : null,
      tlsPin: pin is String ? pin : null,
    );
  }

  /// The id of the one local profile.
  static const localId = 'local';

  /// Stable identifier (also the key of its token).
  final String id;

  /// Name shown to people.
  final String name;

  /// Local or remote.
  final ProfileKind kind;

  /// Base URL of a remote daemon (`https://nas.lan:17171`).
  final String? url;

  /// Pinned certificate of a remote daemon (`sha256:…`), set once the user
  /// has trusted it.
  final String? tlsPin;

  /// Whether this is the managed daemon.
  bool get isLocal => kind == ProfileKind.local;

  /// A copy with the given fields replaced.
  ConnectionProfile copyWith({String? name, String? url, String? tlsPin}) {
    return ConnectionProfile(
      id: id,
      name: name ?? this.name,
      kind: kind,
      url: url ?? this.url,
      tlsPin: tlsPin ?? this.tlsPin,
    );
  }

  /// The stored form.
  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'kind': kind.name,
    if (url != null) 'url': url,
    if (tlsPin != null) 'tlsPin': tlsPin,
  };

  @override
  bool operator ==(Object other) =>
      other is ConnectionProfile &&
      other.id == id &&
      other.name == name &&
      other.kind == kind &&
      other.url == url &&
      other.tlsPin == tlsPin;

  @override
  int get hashCode => Object.hash(id, name, kind, url, tlsPin);

  @override
  String toString() => 'ConnectionProfile($id, $name, ${kind.name}, $url)';
}
