import 'package:meta/meta.dart';
import 'package:snippet_generator/collection_notifier/collection_notifier.dart';
import 'package:snippet_generator/models/serializer.dart';
import 'package:snippet_generator/notifiers/nested_notifier.dart';

enum SetEventManyType { insert, remove }

abstract class SetEvent<V> implements Event<SetEvent<V>> {
  const SetEvent._();

  factory SetEvent.insert({
    required V value,
  }) = InsertSetEvent;
  factory SetEvent.manyTyped({
    required List<V> values,
    required SetEventManyType type,
  }) = ManyTypedSetEvent;
  factory SetEvent.remove({
    required V value,
  }) = RemoveSetEvent;
  factory SetEvent.many({
    required List<SetEvent<V>> events,
  }) = ManySetEvent;

  T when<T>({
    required T Function(V value) insert,
    required T Function(List<V> values, SetEventManyType type) manyTyped,
    required T Function(V value) remove,
    required T Function(List<SetEvent<V>> events) many,
  }) {
    final SetEvent<V> v = this;
    if (v is InsertSetEvent<V>) return insert(v.value);
    if (v is ManyTypedSetEvent<V>) return manyTyped(v.values, v.type);
    if (v is RemoveSetEvent<V>) return remove(v.value);
    if (v is ManySetEvent<V>) return many(v.events);
    throw "";
  }

  T? maybeWhen<T>({
    T Function()? orElse,
    T Function(V value)? insert,
    T Function(List<V> values, SetEventManyType type)? manyTyped,
    T Function(V value)? remove,
    T Function(List<SetEvent<V>> events)? many,
  }) {
    final SetEvent<V> v = this;
    if (v is InsertSetEvent<V>) {
      return insert != null ? insert(v.value) : orElse?.call();
    } else if (v is ManyTypedSetEvent<V>) {
      return manyTyped != null ? manyTyped(v.values, v.type) : orElse?.call();
    } else if (v is RemoveSetEvent<V>) {
      return remove != null ? remove(v.value) : orElse?.call();
    } else if (v is ManySetEvent<V>) {
      return many != null ? many(v.events) : orElse?.call();
    }
    throw "";
  }

  T map<T>({
    required T Function(InsertSetEvent<V> value) insert,
    required T Function(ManyTypedSetEvent<V> value) manyTyped,
    required T Function(RemoveSetEvent<V> value) remove,
    required T Function(ManySetEvent<V> value) many,
  }) {
    final SetEvent<V> v = this;
    if (v is InsertSetEvent<V>) return insert(v);
    if (v is ManyTypedSetEvent<V>) return manyTyped(v);
    if (v is RemoveSetEvent<V>) return remove(v);
    if (v is ManySetEvent<V>) return many(v);
    throw "";
  }

  T? maybeMap<T>({
    T Function()? orElse,
    T Function(InsertSetEvent<V> value)? insert,
    T Function(ManyTypedSetEvent<V> value)? manyTyped,
    T Function(RemoveSetEvent<V> value)? remove,
    T Function(ManySetEvent<V> value)? many,
  }) {
    final SetEvent<V> v = this;
    if (v is InsertSetEvent<V>) {
      return insert != null ? insert(v) : orElse?.call();
    } else if (v is ManyTypedSetEvent<V>) {
      return manyTyped != null ? manyTyped(v) : orElse?.call();
    } else if (v is RemoveSetEvent<V>) {
      return remove != null ? remove(v) : orElse?.call();
    } else if (v is ManySetEvent<V>) {
      return many != null ? many(v) : orElse?.call();
    }
    throw "";
  }

  static SetEvent? fromJson(Map<String, dynamic> map) {
    switch (map["runtimeType"] as String?) {
      case 'InsertSetEvent':
        return InsertSetEvent.fromJson(map);
      case 'ChangeSetEvent':
        return ManyTypedSetEvent.fromJson(map);
      case 'RemoveSetEvent':
        return RemoveSetEvent.fromJson(map);
      case 'ManySetEvent':
        return ManySetEvent.fromJson(map);
      default:
        return null;
    }
  }
}

class InsertSetEvent<V> extends SetEvent<V> {
  final V value;

  const InsertSetEvent({
    required this.value,
  }) : super._();

  static InsertSetEvent<V> fromJson<V>(Map<String, dynamic> map) {
    return InsertSetEvent(
      value: Serializers.fromJson<V>(map['value']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "runtimeType": "InsertSetEvent",
      'value': Serializers.toJson(value),
    };
  }

  @override
  SetEvent<V> revert() {
    return SetEvent.remove(value: value);
  }
}

class ManyTypedSetEvent<V> extends SetEvent<V> {
  final List<V> values;
  final SetEventManyType type;

  const ManyTypedSetEvent({
    required this.values,
    required this.type,
  }) : super._();

  static ManyTypedSetEvent<V> fromJson<V>(Map<String, dynamic> map) {
    return ManyTypedSetEvent<V>(
      values: Serializers.fromJsonList<V>(map['values'] as Iterable),
      type: map['type'] == SetEventManyType.insert.toString().split(".")[1]
          ? SetEventManyType.insert
          : SetEventManyType.remove,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "runtimeType": "ManyTypedSetEvent",
      'value': Serializers.toJson(values),
      'type': type.toString().split(".")[1],
    };
  }

  @override
  SetEvent<V> revert() {
    return SetEvent.manyTyped(
      values: values,
      type: type == SetEventManyType.remove
          ? SetEventManyType.insert
          : SetEventManyType.remove,
    );
  }
}

class RemoveSetEvent<V> extends SetEvent<V> {
  final V value;

  const RemoveSetEvent({
    required this.value,
  }) : super._();

  static RemoveSetEvent<V> fromJson<V>(Map<String, dynamic> map) {
    return RemoveSetEvent(
      value: Serializers.fromJson<V>(map['value']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "runtimeType": "RemoveSetEvent",
      'value': Serializers.toJson(value),
    };
  }

  @override
  SetEvent<V> revert() {
    return SetEvent.insert(value: value);
  }
}

class ManySetEvent<V> extends SetEvent<V> {
  final List<SetEvent<V>> events;

  const ManySetEvent({
    required this.events,
  }) : super._();

  static ManySetEvent<V> fromJson<V>(Map<String, dynamic> map) {
    return ManySetEvent(
      events: Serializers.fromJsonList<SetEvent<V>>(map["events"] as Iterable),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "runtimeType": "ManySetEvent",
      'events': events.map((e) => e).toList(),
    };
  }

  @override
  SetEvent<V> revert() {
    return SetEvent.many(
      events: events.map((e) => e.revert()).toList().reversed.toList(),
    );
  }
}

class SetNotifier<V> extends EventConsumer<SetEvent<V>> implements Set<V> {
  SetNotifier({
    Set<V>? inner,
    NestedNotifier? parent,
    String? propKey,
    int? maxHistoryLength,
  })  : _inner = inner ?? <V>{},
        super(
          maxHistoryLength: maxHistoryLength,
          parent: parent,
          propKey: propKey,
        );

  Set<V> _inner;

  @override
  dynamic toJson() {
    return Serializers.toJsonList(_inner);
  }

  @override
  void fromJson(dynamic json) {
    this._inner = Serializers.fromJsonList<V>(json as Iterable).toSet();
  }

  @override
  @protected
  void consume(SetEvent<V> e) {
    e.when(
      insert: (value) {
        _inner.add(value);
      },
      manyTyped: (values, type) {
        switch (type) {
          case SetEventManyType.insert:
            _inner.addAll(values);
            return;
          case SetEventManyType.remove:
            _inner.removeAll(values);
            return;
        }
      },
      remove: (value) {
        _inner.remove(value);
      },
      many: (events) {
        events.forEach(consume);
      },
    );
  }

  //
  // ADD SINGLE

  @override
  bool add(V value) {
    final isInSet = _inner.contains(value);
    if (!isInSet) {
      apply(SetEvent.insert(value: value));
    }
    return !isInSet;
  }

  //
  // ADD MANY

  @override
  void addAll(Iterable<V> elements) {
    final values = elements
        .map((e) {
          final isInSet = _inner.contains(e);
          if (!isInSet) {
            return e;
          } else {
            return null;
          }
        })
        .where((e) => e != null)
        .toList();
    if (values.isNotEmpty) {
      apply(SetEvent.manyTyped(
          values: values.cast(), type: SetEventManyType.insert));
    }
  }

  //
  // REMOVE SINGLE

  @override
  bool remove(Object? value) {
    final isInSet = _inner.contains(value);
    if (isInSet) {
      apply(SetEvent.remove(value: value as V));
    }
    return isInSet;
  }

  //
  // REMOVE MANY

  @override
  void removeAll(Iterable<Object?> elements) {
    final values = elements
        .map((e) {
          final isInSet = _inner.contains(e);
          if (isInSet) {
            return e as V?;
          } else {
            return null;
          }
        })
        .where((e) => e != null)
        .toList();
    if (values.isNotEmpty) {
      apply(SetEvent.manyTyped(
          values: values.cast(), type: SetEventManyType.insert));
    }
  }

  @override
  void removeWhere(bool Function(V element) test) {
    final values = _inner
        .map((e) {
          if (test(e)) {
            return e;
          } else {
            return null;
          }
        })
        .where((e) => e != null)
        .toList();
    if (values.isNotEmpty) {
      apply(SetEvent.manyTyped(
          values: values.cast(), type: SetEventManyType.remove));
    }
  }

  @override
  void retainAll(Iterable<Object?> elements) {
    final newSet = elements.where((e) => _inner.contains(e)).toSet();
    if (newSet.length != _inner.length) {}
  }

  @override
  void retainWhere(bool Function(V element) test) {
    removeWhere((e) => !test(e));
  }

  @override
  void clear() {
    if (length != 0) {
      apply(
        SetEvent.manyTyped(
          values: _inner.toList(),
          type: SetEventManyType.remove,
        ),
      );
    }
  }

  //
  // OVERRIDES

  @override
  Set<V> difference(Set<Object?> other) => _inner.difference(other);

  @override
  Set<V> union(Set<V> other) => _inner.union(other);

  @override
  Set<V> intersection(Set<Object?> other) => _inner.intersection(other);

  @override
  V get single => _inner.single;

  @override
  V singleWhere(bool Function(V element) test, {V Function()? orElse}) =>
      _inner.singleWhere(test, orElse: orElse);

  @override
  Iterable<V> skip(int count) => _inner.skip(count);

  @override
  Iterable<V> skipWhile(bool Function(V value) test) => _inner.skipWhile(test);

  @override
  Iterable<V> take(int count) => _inner.take(count);

  @override
  Iterable<V> takeWhile(bool Function(V value) test) => _inner.takeWhile(test);

  @override
  List<V> toList({bool growable = true}) => _inner.toList(growable: growable);

  @override
  Set<V> toSet() => _inner.toSet();

  @override
  Iterable<V> where(bool Function(V element) test) => _inner.where(test);

  @override
  Iterable<T> whereType<T>() => _inner.whereType<T>();

  @override
  bool any(bool Function(V element) test) => _inner.any(test);

  @override
  Set<R> cast<R>() => _inner.cast<R>();

  @override
  bool contains(Object? value) => _inner.contains(value);

  @override
  bool containsAll(Iterable<Object?> other) => _inner.containsAll(other);

  @override
  V elementAt(int index) => _inner.elementAt(index);

  @override
  bool every(bool Function(V element) test) => _inner.every(test);

  @override
  Iterable<T> expand<T>(Iterable<T> Function(V element) f) => _inner.expand(f);

  @override
  V get first => _inner.first;

  @override
  V firstWhere(bool Function(V element) test, {V Function()? orElse}) =>
      _inner.firstWhere(test, orElse: orElse);

  @override
  T fold<T>(T initialValue, T Function(T previousValue, V element) combine) =>
      _inner.fold<T>(initialValue, combine);

  @override
  Iterable<V> followedBy(Iterable<V> other) => _inner.followedBy(other);

  @override
  void forEach(void Function(V element) f) => _inner.forEach(f);

  @override
  bool get isEmpty => _inner.isEmpty;

  @override
  bool get isNotEmpty => _inner.isNotEmpty;

  @override
  Iterator<V> get iterator => _inner.iterator;

  @override
  String join([String separator = ""]) => _inner.join(separator);

  @override
  V get last => _inner.last;

  @override
  V lastWhere(bool Function(V element) test, {V Function()? orElse}) =>
      _inner.lastWhere(test, orElse: orElse);

  @override
  int get length => _inner.length;

  @override
  V? lookup(Object? object) => _inner.lookup(object);

  @override
  Iterable<T> map<T>(T Function(V e) f) => _inner.map(f);

  @override
  V reduce(V Function(V value, V element) combine) => _inner.reduce(combine);
}
