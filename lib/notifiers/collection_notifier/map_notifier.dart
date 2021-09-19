import 'package:meta/meta.dart';
import 'package:mobx/mobx.dart';

import 'package:snippet_generator/globals/serializer.dart';
import 'package:snippet_generator/notifiers/collection_notifier/collection_notifier.dart';
import 'package:snippet_generator/notifiers/nested_notifier.dart';

@immutable
abstract class MapEvent<K, V> implements Event<MapEvent<K, V>> {
  const MapEvent._();

  const factory MapEvent.change({
    required K key,
    required V oldValue,
    required V newValue,
  }) = MapChangeEvent<K, V>._;
  const factory MapEvent.insert({
    required K key,
    required V value,
  }) = MapInsertEvent<K, V>._;
  const factory MapEvent.remove({
    required K key,
    required V value,
  }) = MapRemoveEvent._;
  const factory MapEvent.many({
    required List<MapEvent<K, V>> events,
  }) = MapManyEvent._;

  const factory MapEvent.replace({
    required Map<K, V> oldMap,
    required Map<K, V> newMap,
  }) = MapReplaceEvent._;

  T when<T>({
    required T Function(MapChangeEvent<K, V> value) change,
    required T Function(MapInsertEvent<K, V> value) insert,
    required T Function(MapRemoveEvent<K, V> value) remove,
    required T Function(MapManyEvent<K, V> value) many,
    required T Function(MapReplaceEvent<K, V> value) replace,
  }) {
    final MapEvent<K, V> v = this;
    if (v is MapChangeEvent<K, V>) return change(v);
    if (v is MapInsertEvent<K, V>) return insert(v);
    if (v is MapRemoveEvent<K, V>) return remove(v);
    if (v is MapManyEvent<K, V>) return many(v);
    if (v is MapReplaceEvent<K, V>) return replace(v);
    throw '';
  }

  static MapEvent<K, V>? fromJson<K, V>(Map<String, Object?> map) {
    switch (map['runtimeType'] as String?) {
      case 'Change':
        return MapChangeEvent.fromJson(map);
      case 'Insert':
        return MapInsertEvent.fromJson(map);
      case 'Remove':
        return MapRemoveEvent.fromJson(map);
      case 'Many':
        return MapManyEvent.fromJson(map);
      case 'Replace':
        return MapReplaceEvent.fromJson(map);
      default:
        return null;
    }
  }
}

class MapChangeEvent<K, V> extends MapEvent<K, V> {
  final K key;
  final V oldValue;
  final V newValue;

  const MapChangeEvent._({
    required this.key,
    required this.oldValue,
    required this.newValue,
  }) : super._();

  static MapChangeEvent<K, V> fromJson<K, V>(Map<String, Object?> map) {
    return MapChangeEvent<K, V>._(
      key: Serializers.fromJson<K>(map['key']),
      oldValue: Serializers.fromJson<V>(map['oldValue']),
      newValue: Serializers.fromJson<V>(map['newValue']),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'key': Serializers.toJson(key),
      'oldValue': Serializers.toJson(oldValue),
      'newValue': Serializers.toJson(newValue),
    };
  }

  @override
  MapEvent<K, V> revert() {
    return MapEvent<K, V>.change(
        key: key, oldValue: newValue, newValue: oldValue);
  }
}

class MapInsertEvent<K, V> extends MapEvent<K, V> {
  final K key;
  final V value;

  const MapInsertEvent._({
    required this.key,
    required this.value,
  }) : super._();

  static MapInsertEvent<K, V> fromJson<K, V>(Map<String, Object?> map) {
    return MapInsertEvent<K, V>._(
      key: Serializers.fromJson<K>(map['key']),
      value: Serializers.fromJson<V>(map['key']),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'key': Serializers.toJson(key),
      'value': Serializers.toJson(value),
    };
  }

  @override
  MapEvent<K, V> revert() {
    return MapEvent<K, V>.remove(key: key, value: value);
  }
}

class MapRemoveEvent<K, V> extends MapEvent<K, V> {
  final K key;
  final V value;

  const MapRemoveEvent._({
    required this.key,
    required this.value,
  }) : super._();

  static MapRemoveEvent<K, V> fromJson<K, V>(Map<String, Object?> map) {
    return MapRemoveEvent._(
      key: Serializers.fromJson<K>(map['key']),
      value: Serializers.fromJson<V>(map['key']),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'key': Serializers.toJson(key),
      'value': Serializers.toJson(value),
    };
  }

  @override
  MapEvent<K, V> revert() {
    return MapEvent<K, V>.insert(key: key, value: value);
  }
}

class MapManyEvent<K, V> extends MapEvent<K, V> {
  final List<MapEvent<K, V>> events;

  const MapManyEvent._({
    required this.events,
  }) : super._();

  static MapManyEvent<K, V> fromJson<K, V>(Map<String, Object?> map) {
    return MapManyEvent._(
      events:
          Serializers.fromJsonList<MapEvent<K, V>>(map['events']! as Iterable),
    );
  }

  Map<String, Object?> toJson() {
    // TODO:
    return {
      'events': events,
    };
  }

  @override
  MapEvent<K, V> revert() {
    return MapEvent<K, V>.many(
      events: events.map((e) => e.revert()).toList().reversed.toList(),
    );
  }
}

class MapReplaceEvent<K, V> extends MapEvent<K, V> {
  final Map<K, V> oldMap;
  final Map<K, V> newMap;

  const MapReplaceEvent._({
    required this.oldMap,
    required this.newMap,
  }) : super._();

  static MapReplaceEvent<K, V> fromJson<K, V>(Map<String, Object?> map) {
    return MapReplaceEvent._(
      oldMap: Serializers.fromJsonMap<K, V>(map['oldMap']),
      newMap: Serializers.fromJsonMap<K, V>(map['newMap']),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'oldMap': Serializers.toJson(oldMap),
      'newMap': Serializers.toJson(newMap),
    };
  }

  @override
  MapEvent<K, V> revert() {
    return MapEvent<K, V>.replace(oldMap: newMap, newMap: oldMap);
  }
}

Map<K, V> _defaultMapCreator<K, V>() {
  return <K, V>{};
}

class MapNotifier<K, V> extends EventConsumer<MapEvent<K, V>>
    implements Map<K, V> {
  final Map<K, V> Function() _mapCreator;
  late ObservableMap<K, V> _inner;

  MapNotifier({
    int? maxHistoryLength,
    Map<K, V> Function()? mapCreator,
    NestedNotifier? parent,
    String? propKey,
  })  : _mapCreator = mapCreator ?? _defaultMapCreator,
        super(
          maxHistoryLength: maxHistoryLength,
          parent: parent,
          propKey: propKey,
        ) {
    _inner = ObservableMap.of(_mapCreator());
  }

  @override
  dynamic toJson() {
    return Serializers.toJsonMap(_inner);
  }

  @override
  bool trySetFromJson(Object? json) {
    try {
      this._inner = ObservableMap.of(Serializers.fromJsonMap(json));
      return true;
    } catch (_) {
      return false;
    }
  }

  @protected
  @override
  void consume(MapEvent<K, V> e) {
    e.when(change: (e) {
      _inner[e.key] = e.newValue;
    }, insert: (e) {
      _inner[e.key] = e.value;
    }, remove: (e) {
      _inner.remove(e.key);
    }, many: (e) {
      e.events.forEach(consume);
    }, replace: (e) {
      _inner = ObservableMap.of(e.newMap);
    });
  }

  MapEvent<K, V> _updateOrInsertEvent(K key, V value) {
    if (containsKey(key)) {
      return MapEvent.change(
          key: key, newValue: value, oldValue: this[key] as V);
    } else {
      return MapEvent.insert(key: key, value: value);
    }
  }

  //
  // INSERT SINGLE

  @override
  V putIfAbsent(K key, V Function() ifAbsent) {
    V? value;
    if (containsKey(key)) {
      value = _inner[key];
    } else {
      value = ifAbsent();
      apply(MapEvent.insert(key: key, value: value!));
    }
    return value!;
  }

  //
  // CHANGE SINGLE

  @override
  void operator []=(K key, V value) {
    apply(_updateOrInsertEvent(key, value));
  }

  @override
  V update(K key, V Function(V value) update, {V Function()? ifAbsent}) {
    V value;
    if (containsKey(key)) {
      final V oldValue = this[key]!;
      value = update(oldValue);
      apply(MapEvent.change(key: key, newValue: value, oldValue: oldValue));
    } else {
      value = ifAbsent!();
      apply(MapEvent.insert(key: key, value: value));
    }
    return value;
  }

  //
  // CHANGE MANY

  @override
  void updateAll(V Function(K key, V value) update) {
    if (isNotEmpty) {
      final newMap = _mapCreator();
      newMap.addEntries(
        _inner.entries.map((e) => MapEntry(e.key, update(e.key, e.value))),
      );

      apply(MapEvent.replace(oldMap: _inner, newMap: newMap));
    }
  }

  //
  // INSERT MANY

  @override
  void addAll(Map<K, V> other) {
    addEntries(other.entries);
  }

  @override
  void addEntries(Iterable<MapEntry<K, V>> newEntries) {
    final events =
        newEntries.map((e) => _updateOrInsertEvent(e.key, e.value)).toList();
    if (events.isNotEmpty) {
      apply(MapEvent.many(events: events));
    }
  }

  //
  // REMOVE SINGLE

  @override
  V? remove(Object? key) {
    V? value;
    if (containsKey(key)) {
      value = _inner[key as K];
      apply(MapEvent.remove(key: key, value: value as V));
    }
    return value;
  }

  //
  // REMOVE MANY

  @override
  void removeWhere(bool Function(K key, V value) predicate) {
    final events = entries
        .where((e) => predicate(e.key, e.value))
        .map((e) => MapEvent.remove(key: e.key, value: e.value))
        .toList();
    if (events.isNotEmpty) {
      apply(MapEvent.many(events: events));
    }
  }

  @override
  void clear() {
    if (isNotEmpty) {
      // ignore: prefer_const_literals_to_create_immutables
      apply(MapEvent.replace(oldMap: _inner, newMap: _mapCreator()));
    }
  }

  //
  //
  // OVERRIDES

  @override
  V? operator [](Object? key) => _inner[key as K];

  @override
  Map<RK, RV> cast<RK, RV>() => _inner.cast<RK, RV>();

  @override
  bool containsKey(Object? key) => _inner.containsKey(key);

  @override
  bool containsValue(Object? value) => _inner.containsValue(value);

  @override
  Iterable<MapEntry<K, V>> get entries => _inner.entries;

  @override
  void forEach(void Function(K key, V value) f) => _inner.forEach(f);

  @override
  bool get isEmpty => _inner.isEmpty;

  @override
  bool get isNotEmpty => _inner.isNotEmpty;

  @override
  Iterable<K> get keys => _inner.keys;

  @override
  int get length => _inner.length;

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K key, V value) f) =>
      _inner.map(f);

  @override
  Iterable<V> get values => _inner.values;
}
