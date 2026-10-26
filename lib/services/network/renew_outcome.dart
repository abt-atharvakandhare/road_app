/// Result of an attempted silent session renewal ([AuthSessionRenewer.tryRenew]).
///
/// Lives in its own file so both the renewer and the network interceptor can
/// depend on it without an import cycle (the interceptor calls the renewer via
/// a registered callback that returns this).
enum RenewOutcome {
  /// New session in place; the new user token is stored. The rotated renewal
  /// token is normally stored too — but if persisting it failed after the
  /// network renewal succeeded, the session is still live and this is still
  /// [renewed], with the presence flag cleared so we don't retry a consumed
  /// token.
  renewed,

  /// No renewal token to try (either never stored or biometrics unavailable).
  notAvailable,

  /// User cancelled or biometric verification failed.
  userCancelled,

  /// Device/token revoked server-side or renewal token rejected. Storage
  /// has been cleared appropriately; caller should fall through to login.
  rejected,

  /// Renewal couldn't complete for a transient reason (no connectivity,
  /// timeout, 5xx). The renewal token is still valid server-side and has been
  /// kept — callers should NOT log the user out over a network blip; a later
  /// request will retry.
  transientError,
}
