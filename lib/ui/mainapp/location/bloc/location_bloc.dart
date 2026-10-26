import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/user_location/user_location.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/location/initial_location_native.dart';
import 'package:road_mobile/ui/mainapp/debug_controls/cubit/debug_controls_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:geolocator/geolocator.dart';

part 'location_event.dart';
part 'location_state.dart';
part 'location_bloc.freezed.dart';

typedef CrashRecorder = Future<void> Function(Object exception, StackTrace? stack, {String? reason});

@lazySingleton
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc(SharedPreferences prefs)
    : this._(prefs, FGBGEvents.instance.stream, FirebaseCrashlytics.instance.recordError);

  @visibleForTesting
  LocationBloc.forTesting(
    SharedPreferences prefs, {
    required Stream<FGBGType> fgbgStream,
    required CrashRecorder recordError,
  }) : this._(prefs, fgbgStream, recordError);

  LocationBloc._(this._sharedpreferences, this._fgbgStream, this._recordError) : super(const LocationState.initial()) {
    on<LocationEvent>(_eventHandler);

    if (getIt<DebugControlsRepo>().areDebugControlsEnabled) {
      double? lat = _sharedpreferences.getDouble(_debugLatitudeKey);
      double? long = _sharedpreferences.getDouble(_debugLongitudeKey);
      double? accuracy = _sharedpreferences.getDouble(_debugAccuracyKey);

      if (lat != null && long != null && accuracy != null) {
        _debugLocation = UserLocation(latitude: lat, longitude: long, accuracy: accuracy);
      }
    }

    _fgbgSubscription = _fgbgStream.listen((event) {
      if (event == FGBGType.foreground) {
        add(const LocationEvent.checkServiceStatus());
      }
    });

    _serviceStatusStream = Geolocator.getServiceStatusStream().listen((event) {
      add(const LocationEvent.checkServiceStatus());
    });

    add(const LocationEvent.checkServiceStatus());
  }

  static const _debugLatitudeKey = 'debug_latitude';
  static const _debugLongitudeKey = 'debug_longitude';
  static const _debugAccuracyKey = 'debug_accuracy';

  final SharedPreferences _sharedpreferences;
  final Stream<FGBGType> _fgbgStream;
  final CrashRecorder _recordError;
  StreamSubscription<Position>? _locationSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusStream;
  StreamSubscription<FGBGType>? _fgbgSubscription;
  UserLocation? _debugLocation;
  bool _isRequestingPermission = false;

  // Previous fix, kept so we can derive speed/heading from the movement delta
  // when the fix itself reports an invalid value (see fromGeoLocationData).
  Position? _lastPositionForSpeed;

  // Derived speeds below this (km/h) are treated as stationary GPS jitter and ignored.
  static const double _derivedSpeedFloorKmh = 3.0;

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _serviceStatusStream?.cancel();
    _serviceStatusStream = null;
    _fgbgSubscription?.cancel();
    _fgbgSubscription = null;
    return super.close();
  }

  EventHandler<LocationEvent, LocationState> get _eventHandler =>
      (event, emit) => switch (event) {
        CheckServiceStatus() => _onCheckServiceStatus(emit),
        RequestPermission() => _onRequestPermission(emit),
        StartUpdates() => _onStartUpdates(emit),
        StopUpdates() => _onStopUpdates(emit),
        LocationReceived(:final locationData) => _onLocationReceived(locationData, emit),
        UseDebugLocation(:final userLocation) => _onUseDebugLocation(userLocation, emit),
      };

  void _onCheckServiceStatus(Emitter<LocationState> emit) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      emit(const LocationState.serviceDisabled());
      return;
    }

    final permission = await Geolocator.checkPermission();

    switch (permission) {
      case LocationPermission.denied:
        if (_isRequestingPermission) return;
        _isRequestingPermission = true;
        try {
          final requested = await Geolocator.requestPermission();
          if (requested == LocationPermission.denied || requested == LocationPermission.deniedForever) {
            emit(const LocationState.shouldDirectToSettings());
          } else {
            emit(const LocationState.permissionGranted());
            add(const LocationEvent.startUpdates());
          }
        } catch (_) {
          // No UI to show the system dialog (headless Android Auto engine has
          // no activity). Report denied; the car screen's native permission
          // prompt triggers a re-check on grant.
          emit(const LocationState.shouldDirectToSettings());
        } finally {
          _isRequestingPermission = false;
        }
        break;
      case LocationPermission.deniedForever:
        emit(const LocationState.shouldDirectToSettings());
        break;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        emit(const LocationState.permissionGranted());
        add(const LocationEvent.startUpdates());
        break;
      case LocationPermission.unableToDetermine:
        emit(const LocationState.shouldDirectToSettings());
        break;
    }
  }

  void _onRequestPermission(Emitter<LocationState> emit) async {
    if (_isRequestingPermission) return;
    _isRequestingPermission = true;
    try {
      await Geolocator.requestPermission();
    } catch (_) {
      // No activity to host the dialog (headless engine) — the follow-up
      // checkServiceStatus below reports the still-denied state.
    } finally {
      _isRequestingPermission = false;
    }
    add(const LocationEvent.checkServiceStatus());
  }

  void _onStartUpdates(Emitter<LocationState> emit) async {
    if (_debugLocation != null) {
      emit(LocationState.locationProvided(userLocation: _debugLocation!));
      return;
    }

    if (_locationSubscription != null) return;

    _subscribeToPositionStream(const LocationSettings());

    // Seed state ASAP instead of waiting for the position stream's first emission.
    // iOS: getLastKnownPosition is always null (Core Location has no equivalent)
    // and geolocator's getCurrentPosition can stall (e.g. simulator with a
    // single-shot simulated location), so we go straight to CLLocationManager
    // via a native channel — the same path the Google Maps SDK uses for the
    // blue dot. No geolocator fallback on iOS by design.
    if (Platform.isIOS) {
      final native = await InitialLocationNative.getCurrentLocation();
      if (native != null) {
        add(LocationEvent.locationReceived(native));
      }
      return;
    }

    // Android: getLastKnownPosition usually returns instantly. If it doesn't
    // (fresh boot, cleared cache) fall through to a low-accuracy one-shot
    // getCurrentPosition. The continuous stream is the authoritative feed.
    final lastKnownPosition = await Geolocator.getLastKnownPosition();
    if (lastKnownPosition != null) {
      add(LocationEvent.locationReceived(fromGeoLocationData(lastKnownPosition)));
      return;
    }

    try {
      final currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      );
      add(LocationEvent.locationReceived(fromGeoLocationData(currentPosition)));
    } catch (_) {
      // Stream is primary — ignore timeouts/permission errors here.
    }
  }

  void _subscribeToPositionStream(LocationSettings settings) {
    _locationSubscription = Geolocator.getPositionStream(locationSettings: settings).listen(
      (position) {
        final userLocation = fromGeoLocationData(position);
        add(LocationEvent.locationReceived(userLocation));
        // log('LocationBloc: Location received - Lat: ${userLocation.latitude}, Lng: ${userLocation.longitude}');
      },
      onError: (error, stackTrace) {
        _locationSubscription?.cancel();
        _locationSubscription = null;

        // On Android 12+, denying precise location (while granting approximate) can surface
        // as LocationServiceDisabledException. Retry with low accuracy to use approximate location.
        if (error is LocationServiceDisabledException && settings.accuracy != LocationAccuracy.low) {
          _subscribeToPositionStream(const LocationSettings(accuracy: LocationAccuracy.low));
          return;
        }
        // iOS service-disabled / permission-denied surfaces as a PositionUpdateException
        // carrying the kCLErrorDomain identifier in its message rather than a typed
        // PermissionDeniedException or LocationServiceDisabledException.
        final isPermissionDenied =
            error is PermissionDeniedException ||
            (error is PositionUpdateException && (error.message?.contains('kCLErrorDomain') ?? false));

        if (isPermissionDenied || error is LocationServiceDisabledException) {
          // Re-run permission logic so the UI reflects the denied/disabled state.
          add(const LocationEvent.checkServiceStatus());
          return;
        }
        _recordError(error, stackTrace, reason: 'Geolocator position stream error');
      },
    );
  }

  void _onLocationReceived(UserLocation value, Emitter<LocationState> emit) {
    // Convert the event to a state
    emit(LocationState.locationProvided(userLocation: value));
  }

  void _onStopUpdates(Emitter<LocationState> emit) {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  void _onUseDebugLocation(UserLocation? value, Emitter<LocationState> emit) async {
    assert(getIt<DebugControlsRepo>().areDebugControlsEnabled);

    _debugLocation = value;

    if (value != null) {
      emit(LocationState.locationProvided(userLocation: value));

      _sharedpreferences.setDouble(_debugLatitudeKey, value.latitude);
      _sharedpreferences.setDouble(_debugLongitudeKey, value.longitude);
      _sharedpreferences.setDouble(_debugAccuracyKey, value.accuracy);
    } else {
      _sharedpreferences.remove(_debugLatitudeKey);
      _sharedpreferences.remove(_debugLongitudeKey);
      _sharedpreferences.remove(_debugAccuracyKey);

      // Drop the stale pre-debug fix so the first real position after leaving debug
      // mode starts a fresh baseline instead of deriving speed across the debug gap.
      _lastPositionForSpeed = null;

      add(const LocationEvent.checkServiceStatus());
    }
  }

  UserLocation fromGeoLocationData(Position position) {
    if (_debugLocation != null) {
      return _debugLocation!;
    }

    // Prefer the speed/heading the fix provides; derive them from the movement since
    // the previous fix when they're unusable, so speed-gated features (highway mode)
    // still work. Two cases need the speed fallback:
    //   - speed < 0: the fix reports "unknown" (can happen on-device).
    //   - speed == 0 while clearly moving: simulated fixes from `simctl location start`
    //     report a bogus zero speed even though their coordinates advance each second.
    final last = _lastPositionForSpeed;

    double speedKmh = position.speed > 0 ? position.speed * 3.6 : 0.0;
    double? heading = position.heading >= 0 ? position.heading : null;

    if (last != null) {
      final meters = Geolocator.distanceBetween(
        last.latitude,
        last.longitude,
        position.latitude,
        position.longitude,
      );
      final seconds = position.timestamp.difference(last.timestamp).inMilliseconds / 1000.0;

      if (seconds > 0) {
        if (position.speed <= 0) {
          final derivedKmh = (meters / seconds) * 3.6;
          // Floor it so GPS jitter on a stationary device doesn't read as movement.
          if (derivedKmh >= _derivedSpeedFloorKmh) {
            speedKmh = derivedKmh;
          }
        }
        // Only trust a derived heading once we've actually moved — a near-stationary
        // delta produces a meaningless bearing.
        if (position.heading < 0 && meters >= 1.0) {
          final bearing = Geolocator.bearingBetween(
            last.latitude,
            last.longitude,
            position.latitude,
            position.longitude,
          );
          heading = (bearing + 360) % 360; // bearingBetween returns -180..180
        }
      }
    }

    _lastPositionForSpeed = position;

    return UserLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      speed: speedKmh,
      heading: heading,
    );
  }
}
