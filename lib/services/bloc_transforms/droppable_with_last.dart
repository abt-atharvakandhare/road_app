import 'dart:async';

import 'package:bloc/bloc.dart';

/// Process one event, drop subsequent events, then process the last event
EventTransformer<Event> droppableWithLast<Event>({bool restartOnDifferentEventType = false}) {
  return (events, mapper) {
    return events.transform(_DroppableWithLastStreamTransformer(mapper, restartOnDifferentEventType));
  };
}

class _DroppableWithLastStreamTransformer<T> extends StreamTransformerBase<T, T> {
  _DroppableWithLastStreamTransformer(this.mapper, this.restartOnDifferentEventType);

  bool restartOnDifferentEventType;
  final EventMapper<T> mapper;

  late StreamSubscription<T> subscription;
  StreamSubscription<T>? mappedSubscription;

  T? currentData;
  T? lastRetained;

  StreamController<T>? controller;

  @override
  Stream<T> bind(Stream<T> stream) {
    controller = StreamController<T>(
      onCancel: () async {
        await mappedSubscription?.cancel();
        return subscription.cancel();
      },
      sync: true,
    );

    subscription = stream.listen(
      _processStreamData,
      onError: controller?.addError,
      onDone: () {
        mappedSubscription ?? controller?.close();
      },
    );

    return controller!.stream;
  }

  void _processStreamData(T data) {
    if (mappedSubscription != null) {
      if (restartOnDifferentEventType) {
        if (currentData != null && currentData.runtimeType != data.runtimeType) {
          mappedSubscription?.cancel();
          mappedSubscription = null;
          lastRetained = null;
          currentData = null;
          _processStreamData(data);
          return;
        }
      }

      lastRetained = data;
      return;
    }

    final Stream<T> mappedStream = mapper(data);
    currentData = data;

    mappedSubscription = mappedStream.listen(
      (data) {
        controller?.add(data);
      },
      onError: (err) {
        controller?.addError(err);
      },
      onDone: () {
        final lastCopy = lastRetained;
        lastRetained = null;
        mappedSubscription = null;
        currentData = null;
        if (lastCopy != null) {
          _processStreamData(lastCopy);
        }
      },
    );
  }
}
