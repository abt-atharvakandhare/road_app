import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'app_links_state.dart';
part 'app_links_cubit.freezed.dart';

@lazySingleton
class AppLinksCubit extends Cubit<AppLinksState> {
  AppLinksCubit() : super(AppLinksState.idle()) {
    _setupLinksHandler();
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }

  StreamSubscription? _sub;
  final _appLinks = AppLinks();

  void _setupLinksHandler() async {
    try {
      final initialLink = await _appLinks.getInitialLink();
      log('App link: initial link: $initialLink');

      if (initialLink != null) {
        _processAppLink(initialLink);
        return;
      }
    } catch (err) {
      log('got error during getIntitialLink: $err');
    }

    _sub = _appLinks.uriLinkStream.listen((Uri? uri) {
      log('App link: received link uri: $uri');
      if (uri != null) {
        _processAppLink(uri);
      }
    }, onError: (Object err) {
      log('App link: error: $err');
    });
  }

  void _processAppLink(Uri uri) {
    // iOS Live Activity widgetURL: `<flavor-scheme>://charging`. The whole link
    // is `scheme + host` with no path segments, so check it before the
    // 3-segment validation that follows.
    if (uri.host.toLowerCase() == 'charging') {
      emit(const AppLinksState.showCharging());
      return;
    }

    if (uri.pathSegments.length < 3) {
      log('Invalid app link: $uri');
      return;
    }

    final provider = uri.pathSegments[0];
    final action = uri.pathSegments[1].toLowerCase();
    final id = uri.pathSegments[2];

    log('App link: $provider, $action, $id');

    switch (action) {
      case 'charge':
        emit(AppLinksState.showChargingStation(id));
        break;
      default:
        log('Unhandled app link action: $action');
        break;
    }
  }

  /// Requests the UI open the charging status screen. Used by the FCM tap
  /// handler and the iOS Live Activity tap bridge — they have no URI to feed
  /// through `_processAppLink`, just the intent.
  void requestOpenCharging() {
    emit(const AppLinksState.showCharging());
  }

  /// Requests the UI open the wallet's Sessions list and refresh it. Fired
  /// when the user taps a `charging.session.ended` push — by that point the
  /// charging status screen has no live data to show, so the sessions list
  /// (which gains a new just-ended entry) is the useful destination.
  void requestOpenSessions() {
    emit(const AppLinksState.showSessions());
  }

  void linkHandled() {
    emit(AppLinksState.idle());
  }
}
