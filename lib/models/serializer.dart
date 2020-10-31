import 'package:meta/meta.dart';

class Serializers {
  const Serializers._();

  static final _map = <Type, Serializer<dynamic>>{
    int: _SerializerIdentity<int>(),
    double: _SerializerIdentity<double>(),
    num: _SerializerIdentity<num>(),
    String: _SerializerIdentity<String>(),
    bool: _SerializerIdentity<bool>(),
    Map: _MapSerializer(),
  };

  static T fromJson<T>(dynamic json) {
    if (json is T) {
      return json;
    } else {
      return Serializers.of<T>().fromJson(json);
    }
  }

  static Map<K, V> fromJsonMap<K, V>(dynamic json) {
    if (json is Map) {
      return json.map(
        (key, value) => MapEntry(
          Serializers.fromJson<K>(key),
          Serializers.fromJson<V>(value),
        ),
      );
    }
    throw "";
  }

  static List<V> fromJsonList<V>(dynamic json) {
    if (json is List) {
      return json.map((value) => Serializers.fromJson<V>(value)).toList();
    }
    throw "";
  }

  static dynamic toJson<T>(T instance) {
    try {
      return Serializers.of<T>().toJson(instance);
    } catch (_) {
      return (instance as dynamic).toJson();
    }
  }

  static void add<T>(Serializer<T> serializer) {
    _map[T] = serializer;
  }

  static Serializer<T> of<T>() {
    return _map[T] as Serializer<T>;
  }
}

abstract class SerializableGeneric<T, S> {
  S toJson();
}

abstract class Serializable<T>
    implements SerializableGeneric<T, Map<String, dynamic>> {
  @override
  Map<String, dynamic> toJson();
}

abstract class Serializer<T> {
  Serializer() {
    Serializers.add(this);
  }

  T fromJson(dynamic json);
  dynamic toJson(T instance);
}

class _MapSerializer<K, V> implements Serializer<Map<K, V>> {
  @override
  Map<K, V> fromJson(dynamic json) {
    if (json is Map) {
      return json.map(
        (key, value) => MapEntry(
          Serializers.fromJson<K>(key),
          Serializers.fromJson<V>(value),
        ),
      );
    }
    throw "";
  }

  @override
  dynamic toJson(Map<K, V> instance) {
    return instance.map(
      (key, value) => MapEntry(
        Serializers.toJson(key),
        Serializers.toJson(value),
      ),
    );
  }
}

class _SerializerIdentity<T> implements Serializer<T> {
  @override
  T fromJson(dynamic json) {
    return json as T;
  }

  @override
  dynamic toJson(T instance) {
    return instance;
  }
}

class SerializerFuncGeneric<T extends SerializableGeneric<T, S>, S>
    extends Serializer<T> {
  SerializerFuncGeneric({
    @required T Function(S json) fromJson,
  })  : _fromJson = fromJson,
        super();

  final T Function(S json) _fromJson;

  @override
  T fromJson(dynamic json) => _fromJson(json as S);
  @override
  S toJson(T instance) => instance.toJson();
}

class SerializerFunc<T extends Serializable<T>> extends Serializer<T> {
  SerializerFunc({
    @required T Function(Map<String, dynamic> json) fromJson,
  })  : _fromJson = fromJson,
        super();

  final T Function(Map<String, dynamic> json) _fromJson;

  @override
  T fromJson(dynamic json) => _fromJson(json as Map<String, dynamic>);
  @override
  Map<String, dynamic> toJson(T instance) => instance.toJson();
}
