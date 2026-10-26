import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';

/// Why a platform passkey ceremony failed, reduced to the outcomes the UI
/// branches on (spec §5.1b).
enum PasskeyErrorType {
  /// The user dismissed the OS sheet (or it timed out). Surface nothing —
  /// leave a retry affordance and never re-run the ceremony automatically.
  cancelled,

  /// The device holds no passkey usable for this challenge. The backend
  /// offering `passkey` only means the *account* has one somewhere — steer
  /// to another factor, a recovery code, or a dead-end message.
  noCredential,

  /// Registration refused because a credential in `excludeCredentials`
  /// already lives on this device.
  excludedCredentialExists,

  /// The ceremony could not run for an integrity reason (domain association
  /// missing, malformed options, unexpected authenticator failure).
  securityError,

  /// This device cannot do passkeys at all (OS too old, no credential
  /// provider, no Google account where one is required).
  unsupported,
}

/// A failed platform passkey ceremony, typed for UI branching. [message]
/// carries the underlying platform detail for logs only — never show it.
class PasskeyException implements Exception {
  const PasskeyException(this.type, [this.message]);

  final PasskeyErrorType type;
  final String? message;

  @override
  String toString() => 'PasskeyException(${type.name}${message == null ? '' : ': $message'})';
}

/// Drives the platform WebAuthn ceremonies (create/get) for every passkey
/// surface. The seam is JSON-verbatim: options from the backend go in as the
/// raw map, the authenticator response comes back as the raw map the backend
/// expects — WebAuthn shapes are never modelled in the app.
///
/// This is the only place allowed to import the `passkeys` (Corbado) package,
/// so it can be swapped for custom platform channels without touching any
/// caller.
@lazySingleton
class PasskeyService {
  PasskeyService() : _authenticator = PasskeyAuthenticator();

  @visibleForTesting
  PasskeyService.withAuthenticator(this._authenticator);

  final PasskeyAuthenticator _authenticator;

  Future<bool>? _supported;

  /// Whether this device can run passkey ceremonies. Device-static, so the
  /// first answer is cached. iOS is unconditionally true (passkeys exist from
  /// iOS 16; our floor is 16.2). Android asks the platform, which requires
  /// API 28+ and a working Credential Manager / Play services provider.
  Future<bool> isSupported() => _supported ??= _checkSupport();

  Future<bool> _checkSupport() async {
    if (Platform.isIOS) {
      return true;
    }
    if (Platform.isAndroid) {
      try {
        final availability = await _authenticator.getAvailability().android();
        return availability.hasPasskeySupport;
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  /// Runs the registration ceremony for the given WebAuthn creation options
  /// (passed verbatim from the backend). Returns the attestation response as
  /// the raw JSON map the backend's `response` field expects.
  Future<Map<String, dynamic>> create(Map<String, dynamic> optionsJson) async {
    final RegisterRequestType request;
    try {
      request = RegisterRequestType.fromJson(optionsJson);
    } catch (e, stackTrace) {
      // Malformed options JSON (FormatException or a type error deep in the
      // parser) — the ceremony can't be attempted.
      Error.throwWithStackTrace(
          PasskeyException(PasskeyErrorType.securityError, e.toString()), stackTrace);
    }
    try {
      final response = await _authenticator.register(request);
      return response.toJson();
    } on AuthenticatorException catch (e, stackTrace) {
      Error.throwWithStackTrace(_mapException(e), stackTrace);
    }
  }

  /// Runs the authentication ceremony for the given WebAuthn request options
  /// (passed verbatim from the backend). Returns the assertion response as
  /// the raw JSON map the backend's `response` field expects.
  Future<Map<String, dynamic>> get(Map<String, dynamic> optionsJson) async {
    return _authenticate(optionsJson, mediation: MediationType.Optional);
  }

  /// Whether this platform can park a conditional (autofill-assisted)
  /// ceremony. iOS only — Android's Credential Manager has no equivalent
  /// surface in the plugin.
  bool get supportsConditionalUi => Platform.isIOS;

  /// Runs the authentication ceremony in *conditional* mediation: no modal
  /// sheet — the request parks until the user picks the passkey suggestion
  /// the OS offers over a focused username/email field. Resolves like [get];
  /// a cancellation (via [cancelCeremony], or any modal ceremony starting,
  /// which supersedes a parked one) surfaces as the silent cancelled type.
  Future<Map<String, dynamic>> getConditional(Map<String, dynamic> optionsJson) async {
    return _authenticate(optionsJson, mediation: MediationType.Conditional);
  }

  /// Cancels any parked or in-flight ceremony. Safe when none is running.
  Future<void> cancelCeremony() => _authenticator.cancelCurrentAuthenticatorOperation();

  Future<Map<String, dynamic>> _authenticate(Map<String, dynamic> optionsJson,
      {required MediationType mediation}) async {
    final AuthenticateRequestType request;
    try {
      request = AuthenticateRequestType.fromJson(optionsJson, mediation: mediation);
    } catch (e, stackTrace) {
      // Malformed options JSON (FormatException or a type error deep in the
      // parser) — the ceremony can't be attempted.
      Error.throwWithStackTrace(
          PasskeyException(PasskeyErrorType.securityError, e.toString()), stackTrace);
    }
    try {
      final response = await _authenticator.authenticate(request);
      return response.toJson();
    } on AuthenticatorException catch (e, stackTrace) {
      Error.throwWithStackTrace(_mapException(e), stackTrace);
    }
  }

  PasskeyException _mapException(AuthenticatorException e) {
    final type = switch (e) {
      PasskeyAuthCancelledException() => PasskeyErrorType.cancelled,
      // A timed-out sheet is behaviourally a dismissal: silent, retryable.
      TimeoutException() => PasskeyErrorType.cancelled,
      NoCredentialsAvailableException() => PasskeyErrorType.noCredential,
      ExcludeCredentialsCanNotBeRegisteredException() => PasskeyErrorType.excludedCredentialExists,
      DeviceNotSupportedException() => PasskeyErrorType.unsupported,
      PasskeyUnsupportedException() => PasskeyErrorType.unsupported,
      MissingGoogleSignInException() => PasskeyErrorType.unsupported,
      SyncAccountNotAvailableException() => PasskeyErrorType.unsupported,
      NoCreateOptionException() => PasskeyErrorType.unsupported,
      RestoreCredentialUnsupportedException() => PasskeyErrorType.unsupported,
      DomainNotAssociatedException() => PasskeyErrorType.securityError,
      MalformedBase64Url() => PasskeyErrorType.securityError,
      UnhandledAuthenticatorException() => PasskeyErrorType.securityError,
    };
    return PasskeyException(type, e.toString());
  }
}
