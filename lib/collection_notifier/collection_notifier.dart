
import 'package:meta/meta.dart';

@immutable
abstract class Event {}

abstract class EventConsumer<V extends Event> {
  EventConsumer({
    int maxHistoryLength,
  }) : history = EventHistory(maxHistoryLength: maxHistoryLength);

  final EventHistory<V> history;

  void apply(V e) {
    history.add(e);
    _consume(e);
  }

  @protected
  void _consume(V e);
}

class EventHistory<V extends Event> {
  EventHistory({
    int maxHistoryLength,
  }) : maxHistoryLength = maxHistoryLength ?? 25;

  final int maxHistoryLength;
  final List<V> history = const [];
  int _index = 0;

  void revert() {
    if (_index == 0) {
    } else {
      _index -= 1;
    }
  }

  void forward() {
    if (_index == history.length - 1) {
    } else {
      _index += 1;
    }
  }

  void add(V event) {
    history.add(event);
  }

  @override
  bool operator ==(Object other) {
    if (other is EventHistory) {
      return other._index == _index && other.history == history;
    } else {
      return false;
    }
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;
}