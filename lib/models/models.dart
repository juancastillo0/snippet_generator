import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class Globals {
  static final _map = <Type, Object>{};
  static final _refs = <String, Object>{};
  static final _nested = <String, List<Object>>{};

  static void add<T>(T value) {
    _map[T] = value;
  }

  static void addRef(String key, Object value) {
    _refs[key] = value;
  }

  static void addNested(String key, Object value) {
    List<Object> l = _nested[key];
    if (l == null) {
      l = [];
      _nested[key] = l;
    }
    l.add(value);
  }

  static List<Object> popNested(String key) {
    final l = _nested.remove(key);
    return l;
  }

  static T get<T>() {
    return _map[T] as T;
  }
}

abstract class Disposable {
  final Set<void Function()> _callbacks = {};

  void onDispose(void Function() callback) {
    _callbacks.add(callback);
  }

  @mustCallSuper
  void dispose() {
    for (final callback in _callbacks) {
      callback();
    }
  }
}
