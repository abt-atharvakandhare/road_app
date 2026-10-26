import 'dart:async';

import 'package:injectable/injectable.dart';

/// Events fired as the user's session moves through its lifecycle.
/// `AuthCubit` listens on this bus to keep its in-memory token in sync and
/// to surface the "session ending" notice. The refresher and the renewer
/// publish to it.
sealed class AuthLifecycleEvent {
  const AuthLifecycleEvent();
}

class TokenRotated extends AuthLifecycleEvent {
  final String token;
  const TokenRotated(this.token);
}

class SessionEnding extends AuthLifecycleEvent {
  const SessionEnding();
}

class SessionRenewed extends AuthLifecycleEvent {
  final String token;
  const SessionRenewed(this.token);
}

/// A reactive 401 could not be recovered (renewal rejected, cancelled, or no
/// renewal token). Published by the network interceptor; `AuthCubit` logs out
/// in response. [expired] is true for age-out codes, driving the
/// "session expired" notice on the login screen.
class SessionRevoked extends AuthLifecycleEvent {
  final bool expired;
  const SessionRevoked({required this.expired});
}

@lazySingleton
class AuthLifecycleBus {
  final _controller = StreamController<AuthLifecycleEvent>.broadcast();

  Stream<AuthLifecycleEvent> get stream => _controller.stream;

  void publish(AuthLifecycleEvent event) {
    if (!_controller.isClosed) _controller.add(event);
  }

  @disposeMethod
  void dispose() {
    _controller.close();
  }
}
