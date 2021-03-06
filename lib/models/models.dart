import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class Globals {
  static final Map<Type, Object> _map = {};
  static final Map<Type, Object Function()> _factoryMap = {};
  static final _refs = <String, Object>{};
  static final _nested = <String, List<Object>>{};

  static void add<T extends Object>(T value) {
    _map[T] = value;
  }

  static void addFactory<T extends Object>(T Function() value) {
    _factoryMap[T] = value;
  }

  static void addRef(String key, Object value) {
    _refs[key] = value;
  }

  static void addNested(String key, Object value) {
    List<Object>? l = _nested[key];
    if (l == null) {
      l = [];
      _nested[key] = l;
    }
    l.add(value);
  }

  static List<Object>? popNested(String key) {
    final l = _nested.remove(key);
    return l;
  }

  static T get<T>() {
    return _map[T] as T;
  }

  static T Function()? getFactory<T>() {
    return _factoryMap[T] as T Function()?;
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
