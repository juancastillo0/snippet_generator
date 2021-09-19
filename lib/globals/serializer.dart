import 'package:collection/collection.dart';
import 'package:snippet_generator/globals/models.dart';
import 'package:snippet_generator/globals/props_serializable.dart';

class Serializers {
  const Serializers._();

  static final Map<Type, Serializer<Object?>> _map = {
    int: _SerializerIdentity<int>(),
    double: _SerializerIdentity<double>(),
    num: _SerializerIdentity<num>(),
    String: _SerializerIdentity<String>(),
    bool: _SerializerIdentity<bool>(),
    // ignore: prefer_void_to_null
    Null: _SerializerIdentity<Null>(),
    Map: _MapSerializer<Object?, Object?>(),
  };

  static T fromJson<T>(Object? json, [T Function()? _itemFactory]) {
    if (json is T) {
      return json;
    } else {
      final itemFactory = _itemFactory ?? Globals.getFactory<T>();
      if (itemFactory != null) {
        try {
          final item = itemFactory();
          if (item is SerializableItem && item.trySetFromJson(json)) {
            return item;
          } else {
            throw Error();
          }
        } catch (_) {}
      }
      return Serializers.of<T>()!.fromJson(json);
    }
  }

  static Map<K, V> fromJsonMap<K, V>(Object? json) {
    if (json is Map) {
      return json.map(
        (Object? key, Object? value) => MapEntry(
          Serializers.fromJson<K>(key),
          Serializers.fromJson<V>(value),
        ),
      );
    }
    throw Error();
  }

  static Map<String, Object?> toJsonMap<K, V>(Map<K, V> map) {
    return map.map(
      (key, value) => MapEntry(
        Serializers.toJson<K>(key).toString(),
        Serializers.toJson<V>(value),
      ),
    );
  }

  static List<V> fromJsonList<V>(Iterable json, [V Function()? itemFactory]) {
    return json
        .map((Object? value) => Serializers.fromJson<V>(value, itemFactory))
        .toList();
  }

  static List<Object?> toJsonList<V>(Iterable<V> list) {
    return list.map((value) => Serializers.toJson<V>(value)).toList();
  }

  static Object? toJson<T>(T instance) {
    try {
      final serializer = Serializers.of<T>();
      return serializer!.toJson(instance);
    } catch (_) {
      if (instance is Map) {
        return instance.toJsonMap();
      } else if (instance is List || instance is Set) {
        return (instance as Iterable).toJsonList();
      } else if (instance == null && null is T) {
        return null;
      } else {
        try {
          return (instance as dynamic).toJson();
        } catch (_) {
          return (instance as dynamic).toMap();
        }
      }
    }
  }

  static void add<T>(Serializer<T> serializer) {
    _map[T] = serializer;
  }

  static Serializer<T>? of<T>() {
    final v = _map[T] as Serializer<T>?;
    if (v != null) return v;
    return _map.values.firstWhereOrNull((serde) => serde.isType<T>())
        as Serializer<T>?;
  }

  static List<Serializer<T>> manyOf<T>() {
    final v = _map[T] as Serializer<T>?;
    if (v != null) return [v];
    return _map.values
        .where((serde) => serde.isType<T>())
        .map((s) => s as Serializer<T>)
        .toList();
  }
}

abstract class SerializableGeneric<S> {
  S toJson();
}

abstract class Serializable
    implements SerializableGeneric<Map<String, dynamic>> {
  @override
  Map<String, dynamic> toJson();
}

abstract class Serializer<T> {
  Serializer() {
    // Serializers.add(this);
  }

  T fromJson(Object? json);
  Object? toJson(T instance);

  bool isType<O>() => O is T;
  bool isOtherType<O>() => T is O;
  bool isEqualType<O>() => O == T;
}

class _MapSerializer<K, V> extends Serializer<Map<K, V>> {
  @override
  Map<K, V> fromJson(Object? json) {
    if (json is Map) {
      return json.map(
        (Object? key, Object? value) => MapEntry(
          Serializers.fromJson<K>(key),
          Serializers.fromJson<V>(value),
        ),
      );
    }
    throw Error();
  }

  @override
  Object toJson(Map<K, V> instance) {
    return instance.map(
      (key, value) => MapEntry(
        Serializers.toJson(key),
        Serializers.toJson(value),
      ),
    );
  }
}

class _SerializerIdentity<T> extends Serializer<T> {
  @override
  T fromJson(Object? json) {
    return json as T;
  }

  @override
  Object? toJson(T instance) {
    return instance;
  }
}

class SerializerFuncGeneric<T extends SerializableGeneric<S>, S>
    extends Serializer<T> {
  SerializerFuncGeneric({
    required T Function(S json) fromJson,
  })  : _fromJson = fromJson,
        super();

  final T Function(S json) _fromJson;

  @override
  T fromJson(Object? json) => _fromJson(json as S);
  @override
  S toJson(T instance) => instance.toJson();
}

class SerializerFunc<T extends Serializable> extends Serializer<T> {
  SerializerFunc({
    required T Function(Map<String, dynamic>? json) fromJson,
  })  : _fromJson = fromJson,
        super();

  final T Function(Map<String, dynamic>? json) _fromJson;

  @override
  T fromJson(Object? json) => _fromJson(json as Map<String, dynamic>?);
  @override
  Map<String, dynamic> toJson(T instance) => instance.toJson();
}

extension GenMap<K, V> on Map<K, V> {
  Map<String, Object?> toJsonMap() {
    return Serializers.toJsonMap(this);
  }
}

extension GenIterable<V> on Iterable<V> {
  List<Object?> toJsonList() {
    return Serializers.toJsonList(this);
  }
}
