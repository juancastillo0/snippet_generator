import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

@immutable
abstract class Event<E extends Event<E>> {
  E revert();
}

@immutable
class EventData<V extends Event<V>> {
  const EventData(this.event, this.type);
  final V event;
  final EventType type;
}

abstract class EventConsumer<E extends Event<E>> extends ChangeNotifier {
  EventConsumer({
    int maxHistoryLength,
  }) : _history = EventHistory(maxHistoryLength: maxHistoryLength);

  EventHistory<E> _history;
  EventHistory<E> get history => _history;
  bool get canUndo => _history.canUndo;
  bool get canRedo => _history.canRedo;

  Stream<EventData<E>> get events => _eventStreamController.stream;
  final _eventStreamController = StreamController<EventData<E>>.broadcast();

  List<EventData<E>> _transactionEvents;

  void syncTransaction(void Function() execute) {
    if (_transactionEvents != null) {
      // Already in transaction
      execute();
      return;
    }

    _transactionEvents = [];
    execute();
    if (_transactionEvents.isNotEmpty) {
      notifyListeners();
      for (final event in _transactionEvents) {
        _eventStreamController.add(event);
      }
    }
    _transactionEvents = null;
  }

  void apply(E e) {
    _history = _history.push(e);
    _callConsume(e, EventType.apply);
  }

  void undo() {
    assert(canUndo);
    if (canUndo) {
      final e = _history.current;
      _history = _history.undo();
      _callConsume(e.revert(), EventType.undo);
    }
  }

  void redo() {
    assert(canRedo);
    if (canRedo) {
      final e = _history.next;
      _history = _history.redo();
      _callConsume(e, EventType.redo);
    }
  }

  void _callConsume(E event, EventType type) {
    consume(event);

    final data = EventData(event, type);
    if (_transactionEvents != null) {
      _transactionEvents.add(data);
    } else {
      notifyListeners();
      _eventStreamController.add(data);
    }
  }

  @protected
  void consume(E e);

  void setClonedHistory(EventHistory<E> h) {
    _history = h.clone();
  }

  @override
  bool operator ==(Object other) {
    if (other is EventConsumer<E>) {
      return other._history == _history;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => _history.hashCode;

  @override
  void dispose() {
    _eventStreamController.close();
    super.dispose();
  }
}

@immutable
class EventHistory<V extends Event<V>> {
  EventHistory({
    int maxHistoryLength,
    ListQueue<V> events,
    int position,
  })  : assert(maxHistoryLength == null || maxHistoryLength >= 0),
        assert(position == null || position >= -1),
        assert(events == null || position == null || position < events.length),
        maxHistoryLength = maxHistoryLength ?? 15,
        events = events ?? ListQueue<V>(),
        position = position ?? -1;

  final int maxHistoryLength;
  final ListQueue<V> events;
  final int position;

  V get current => position == -1 ? null : events.elementAt(position);
  V get next => canRedo ? events.elementAt(position + 1) : null;
  bool get canUndo => position >= 0;
  bool get canRedo => position < events.length - 1;

  EventHistory<V> undo() {
    assert(canUndo);
    return copyWith(position: position - 1);
  }

  EventHistory<V> redo() {
    assert(canRedo);
    return copyWith(position: position + 1);
  }

  EventHistory<V> push(V event) {
    if (maxHistoryLength == 0) {
      return this;
    }
    if (canRedo) {
      if (events.elementAt(position + 1) == event) {
        return redo();
      } else {
        for (final _
            in Iterable<int>.generate(events.length - (position + 1))) {
          events.removeLast();
        }
      }
    }

    if (events.length == maxHistoryLength) {
      events.removeFirst();
      events.addLast(event);
      return copyWith(position: position);
    } else {
      events.addLast(event);
      return copyWith(position: position + 1);
    }
  }

  EventHistory<V> clone() {
    return copyWith(events: ListQueue<V>.from(events));
  }

  EventHistory<V> copyWith({
    int maxHistoryLength,
    ListQueue<V> events,
    int position,
  }) {
    return EventHistory<V>(
      events: events ?? this.events,
      position: position ?? this.position,
      maxHistoryLength: maxHistoryLength ?? this.maxHistoryLength,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is EventHistory<V>) {
      return other.position == position &&
          other.events == events &&
          other.maxHistoryLength == maxHistoryLength;
    } else {
      return false;
    }
  }

  @override
  int get hashCode =>
      position.hashCode + events.hashCode + maxHistoryLength.hashCode;
}

enum EventType {
  apply,
  undo,
  redo,
}

EventType parseEventType(String rawString, {EventType defaultValue}) {
  for (final variant in EventType.values) {
    if (rawString == variant.toEnumString()) {
      return variant;
    }
  }
  return defaultValue;
}

extension EventTypeExtension on EventType {
  String toEnumString() => toString().split(".")[1];
  String enumType() => toString().split(".")[0];

  bool get isApply => this == EventType.apply;
  bool get isUndo => this == EventType.undo;
  bool get isRedo => this == EventType.redo;

  T when<T>({
    @required T Function() apply,
    @required T Function() undo,
    @required T Function() redo,
  }) {
    switch (this) {
      case EventType.apply:
        return apply();
      case EventType.undo:
        return undo();
      case EventType.redo:
        return redo();
    }
    throw "";
  }

  T maybeWhen<T>({
    T Function() apply,
    T Function() undo,
    T Function() redo,
    T Function() orElse,
  }) {
    T Function() c;
    switch (this) {
      case EventType.apply:
        c = apply;
        break;
      case EventType.undo:
        c = undo;
        break;
      case EventType.redo:
        c = redo;
        break;
    }
    return (c ?? orElse)?.call();
  }
}
