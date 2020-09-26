import 'package:meta/meta.dart';

abstract class MapEvent<K, V> {
  const MapEvent._();

  factory MapEvent.change({
    @required K key,
    @required V oldValue,
    @required V newValue,
  }) = _Change<K, V>._;
  factory MapEvent.insert({
    @required K key,
    @required V value,
  }) = _Insert<K, V>._;
  factory MapEvent.remove({
    @required K key,
    @required V value,
  }) = _Remove._;
  factory MapEvent.many({
    @required List<MapEvent<K, V>> events,
  }) = _Many._;

  T when<T>({
    @required T Function(_Change<K, V> value) change,
    @required T Function(_Insert<K, V> value) insert,
    @required T Function(_Remove<K, V> value) remove,
    @required T Function(_Many<K, V> value) many,
  }) {
    final v = this;
    if (v is _Change<K, V>) return change(v);
    if (v is _Insert<K, V>) return insert(v);
    if (v is _Remove<K, V>) return remove(v);
    if (v is _Many<K, V>) return many(v);
    throw "";
  }

  static MapEvent fromJson(Map<String, dynamic> map) {
    switch (map["runtimeType"] as String) {
      case 'Change':
        return _Change.fromJson(map);
      case 'Insert':
        return _Insert.fromJson(map);
      case 'Remove':
        return _Remove.fromJson(map);
      case 'Many':
        return _Many.fromJson(map);
      default:
        return null;
    }
  }
}

class _Change<K, V> extends MapEvent<K, V> {
  final K key;
  final V oldValue;
  final V newValue;

  const _Change._({
    @required this.key,
    @required this.oldValue,
    @required this.newValue,
  }) : super._();

  static _Change<K, V> fromJson<K, V>(Map<String, dynamic> map) {
    return _Change<K, V>._(
      key: map['key'] as K,
      oldValue: map['oldValue'] as V,
      newValue: map['newValue'] as V,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'oldValue': oldValue,
      'newValue': newValue,
    };
  }
}

class _Insert<K, V> extends MapEvent<K, V> {
  final K key;
  final V value;

  const _Insert._({
    @required this.key,
    @required this.value,
  }) : super._();

  static _Insert<K, V> fromJson<K, V>(Map<String, dynamic> map) {
    return _Insert<K, V>._(
      key: map['key'] as K,
      value: map['value'] as V,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
    };
  }
}

class _Remove<K, V> extends MapEvent<K, V> {
  final K key;
  final V value;

  const _Remove._({
    @required this.key,
    @required this.value,
  }) : super._();

  static _Remove<K, V> fromJson<K, V>(Map<String, dynamic> map) {
    return _Remove._(
      key: map['key'] as K,
      value: map['value'] as V,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
    };
  }
}

class _Many<K, V> extends MapEvent<K, V> {
  final List<MapEvent<K, V>> events;

  const _Many._({
    @required this.events,
  }) : super._();

  static _Many<K, V> fromJson<K, V>(Map<String, dynamic> map) {
    return _Many._(
      events: map['events'] as List<MapEvent<K, V>>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'events': events,
    };
  }
}

class MapNotifier<K, V> implements Map<K, V> {
  final Map<K, V> _inner = {};

  //
  // INSERT SINGLE

  @override
  V putIfAbsent(K key, V Function() ifAbsent) {
    final v = _inner.putIfAbsent(key, ifAbsent);
    if (v != null){
      
    }
    return v;
  }

  //
  // CHANGE SINGLE

  @override
  void operator []=(K key, V value) {
    // TODO: implement []=
  }

  @override
  V update(K key, V Function(V value) update, {V Function() ifAbsent}) {
    // TODO: implement update
    throw UnimplementedError();
  }

  //
  // CHANGE MANY

  @override
  void updateAll(V Function(K key, V value) update) {
    // TODO: implement updateAll
  }

  //
  // INSERT MANY

  @override
  void addAll(Map<K, V> other) {
    // TODO: implement addAll
  }

  @override
  void addEntries(Iterable<MapEntry<K, V>> newEntries) {
    // TODO: implement addEntries
  }

  //
  // REMOVE SINGLE

  @override
  V remove(Object key) {
    // TODO: implement remove
    throw UnimplementedError();
  }

  //
  // REMOVE MANY

  @override
  void removeWhere(bool Function(K key, V value) predicate) {
    // TODO: implement removeWhere
  }

  @override
  void clear() {
    // TODO: implement clear
  }

  //
  //
  // OVERRIDES

  @override
  V operator [](Object key) {
    return _inner[key];
  }

  @override
  Map<RK, RV> cast<RK, RV>() {
    return _inner.cast<RK, RV>();
  }

  @override
  bool containsKey(Object key) {
    return _inner.containsKey(key);
  }

  @override
  bool containsValue(Object value) {
    return _inner.containsValue(value);
  }

  @override
  Iterable<MapEntry<K, V>> get entries => _inner.entries;

  @override
  void forEach(void Function(K key, V value) f) {
    _inner.forEach(f);
  }

  @override
  bool get isEmpty => _inner.isEmpty;

  @override
  bool get isNotEmpty => _inner.isNotEmpty;

  @override
  Iterable<K> get keys => _inner.keys;

  @override
  int get length => _inner.length;

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K key, V value) f) {
    return _inner.map(f);
  }

  @override
  Iterable<V> get values => _inner.values;
}
