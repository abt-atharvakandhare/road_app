import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// RFC 6238 TOTP, fixed to the parameters the API verifies against
/// (`mfa-totp.ts`: SHA-1, 6 digits, 30s step, ±1 step tolerance). Pure Dart
/// on top of `crypto`, which the app already depends on, so the e2e suite
/// needs no extra package to answer an authenticator-app challenge.
const totpStepSeconds = 30;

/// Current 6-digit code for [base32Secret] (the secret shown at enrolment,
/// spaces/dashes/case ignored, padding optional).
String totpCode(String base32Secret, {DateTime? at}) {
  final now = at ?? DateTime.now().toUtc();
  final counter = now.millisecondsSinceEpoch ~/ 1000 ~/ totpStepSeconds;
  return _hotp(_base32Decode(base32Secret), counter);
}

/// Seconds left before the current 30s window rolls over. The API tolerates
/// ±1 step, but a code typed right at the boundary still races the keyboard
/// and the network, so callers wait out a nearly-expired window first.
int totpSecondsRemaining({DateTime? at}) {
  final now = at ?? DateTime.now().toUtc();
  return totpStepSeconds - (now.millisecondsSinceEpoch ~/ 1000) % totpStepSeconds;
}

String _hotp(List<int> key, int counter) {
  final message = ByteData(8)..setUint64(0, counter, Endian.big);
  final digest = Hmac(sha1, key).convert(message.buffer.asUint8List()).bytes;
  final offset = digest[digest.length - 1] & 0x0f;
  final binary = ((digest[offset] & 0x7f) << 24) |
      ((digest[offset + 1] & 0xff) << 16) |
      ((digest[offset + 2] & 0xff) << 8) |
      (digest[offset + 3] & 0xff);
  return (binary % 1000000).toString().padLeft(6, '0');
}

const _base32Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

List<int> _base32Decode(String input) {
  final cleaned = input.toUpperCase().replaceAll(RegExp('[^A-Z2-7]'), '');
  final bytes = <int>[];
  var buffer = 0;
  var bits = 0;
  for (final char in cleaned.split('')) {
    buffer = (buffer << 5) | _base32Alphabet.indexOf(char);
    bits += 5;
    if (bits >= 8) {
      bits -= 8;
      bytes.add((buffer >> bits) & 0xff);
      buffer &= (1 << bits) - 1;
    }
  }
  if (bytes.isEmpty) {
    throw ArgumentError('TEST_TOTP_SECRET is not a base32 secret');
  }
  return bytes;
}
