import 'dart:async';

import 'package:injectable/injectable.dart';

/// Broadcasts the values seen in the `X-Token-Status` response header.
///
/// The request interceptor publishes; the refresher and the auth cubit
/// subscribe. Lives as a singleton to break the construction cycle between
/// the interceptor (which sees responses) and the refresher (which makes
/// requests through the interceptor).
@lazySingleton
class TokenStatusBus {
  final _controller = StreamController<String>.broadcast();

  Stream<String> get stream => _controller.stream;

  void publish(String status) {
    if (!_controller.isClosed) _controller.add(status);
  }

  @disposeMethod
  void dispose() {
    _controller.close();
  }
}

