import 'dart:async';

/// Coalesces concurrent calls into a single in-flight future.
///
/// While an action is running, additional [run] calls return the *same*
/// future rather than starting a new one. Once it completes (success or
/// error), the next [run] starts fresh. Used wherever a side-effecting async
/// operation must not overlap with itself — token refresh, session renewal,
/// post-401 recovery.
class SingleFlight<T> {
  Future<T>? _inFlight;

  Future<T> run(Future<T> Function() action) {
    final existing = _inFlight;
    if (existing != null) return existing;
    final future = action().whenComplete(() => _inFlight = null);
    _inFlight = future;
    return future;
  }
}
