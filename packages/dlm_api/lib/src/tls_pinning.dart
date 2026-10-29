import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// The pin of a certificate: `sha256:` and the lower-case hex SHA-256 of its
/// DER encoding. This is also what the daemon publishes as `tlsFingerprint`.
String fingerprintOf(List<int> der) => 'sha256:${sha256.convert(der)}';

/// Formats a pin for people: `D5:2E:B8:…` in upper case.
String displayFingerprint(String pin) {
  final hex = pin.startsWith('sha256:') ? pin.substring(7) : pin;
  final upper = hex.toUpperCase();
  return [
    for (var i = 0; i + 1 < upper.length; i += 2) upper.substring(i, i + 2),
  ].join(':');
}

/// An HTTP adapter that trusts exactly one certificate, identified by [pin],
/// whatever its issuer or validity: the usual trust in certificate authorities
/// is switched off, so a certificate that merely looks valid is refused.
HttpClientAdapter pinnedAdapter(String pin) {
  return IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient(context: SecurityContext())
        // With no trusted roots every certificate reaches this callback.
        ..badCertificateCallback = (cert, host, port) =>
            fingerprintOf(cert.der) == pin;
      return client;
    },
  );
}

/// The certificate a server presents: what a first connection shows the user
/// to confirm (trust on first use).
class PresentedCertificate {
  /// Creates the value.
  const PresentedCertificate({
    required this.pin,
    required this.subject,
    required this.issuer,
    required this.validUntil,
  });

  /// The pin to store when the user trusts it.
  final String pin;

  /// Certificate subject.
  final String subject;

  /// Certificate issuer (equal to [subject] when self-signed).
  final String issuer;

  /// Expiry.
  final DateTime validUntil;

  /// Whether the certificate vouches for itself.
  bool get selfSigned => subject == issuer;
}

/// Connects to [host]:[port] without trusting anything and returns the
/// certificate the server presents. Nothing is sent to the server.
Future<PresentedCertificate> fetchCertificate(
  String host,
  int port, {
  Duration timeout = const Duration(seconds: 8),
}) async {
  final socket = await SecureSocket.connect(
    host,
    port,
    context: SecurityContext(),
    onBadCertificate: (_) => true,
    timeout: timeout,
  );
  try {
    final cert = socket.peerCertificate;
    if (cert == null) {
      throw const HandshakeException('the server presented no certificate');
    }
    return PresentedCertificate(
      pin: fingerprintOf(cert.der),
      subject: cert.subject,
      issuer: cert.issuer,
      validUntil: cert.endValidity,
    );
  } finally {
    await socket.close();
    socket.destroy();
  }
}
