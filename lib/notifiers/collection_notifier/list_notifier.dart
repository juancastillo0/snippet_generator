import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:mobx/mobx.dart';
import 'package:snippet_generator/notifiers/collection_notifier/collection_notifier.dart';
import 'package:snippet_generator/globals/serializer.dart';
import 'package:snippet_generator/notifiers/nested_notifier.dart';

enum ListEventEnum { change, insert, remove, many, recreate }

@immutable
abstract class ListEvent<E> implements Event<ListEvent<E>> {
  const ListEvent._();

  const factory ListEvent.change(
    int index, {
    required E oldValue,
    required E newValue,
  }) = ChangeListEvent._;
  const factory ListEvent.insert(int index, E value) = InsertListEvent._;
  const factory ListEvent.remove(int index, E value) = RemoveListEvent._;
  const factory ListEvent.many(List<ListEvent<E>> events) = ManyListEvent._;
  const factory ListEvent.recreate({
    required List<E> newList,
    required List<E> oldList,
  }) = RecreateListEvent._;

  ListEventEnum get typeId {
    final ListEvent<E> v = this;
    if (v is ChangeListEvent<E>) {
      return ListEventEnum.change;
    } else if (v is InsertListEvent<E>) {
      return ListEventEnum.insert;
    } else if (v is RemoveListEvent<E>) {
      return ListEventEnum.remove;
    } else if (v is ManyListEvent<E>) {
      return ListEventEnum.many;
    } else if (v is RecreateListEvent<E>) {
      return ListEventEnum.recreate;
    }
    throw Error();
  }

  bool isType(ListEventEnum type) => type == typeId;

  T when<T>({
    required T Function(ChangeListEvent<E>) change,
    required T Function(InsertListEvent<E>) insert,
    required T Function(RemoveListEvent<E>) remove,
    required T Function(ManyListEvent<E>) many,
    required T Function(RecreateListEvent<E>) recreate,
  }) {
    final ListEvent<E> v = this;
    if (v is ChangeListEvent<E>) return change(v);
    if (v is InsertListEvent<E>) return insert(v);
    if (v is RemoveListEvent<E>) return remove(v);
    if (v is ManyListEvent<E>) return many(v);
    if (v is RecreateListEvent<E>) return recreate(v);
    throw "";
  }
}

class ChangeListEvent<E> extends ListEvent<E> {
  const ChangeListEvent._(
    this.index, {
    required this.oldValue,
    required this.newValue,
  }) : super._();
  final int index;
  final E oldValue;
  final E newValue;

  @override
  ListEvent<E> revert() {
    return ListEvent.change(index, newValue: oldValue, oldValue: newValue);
  }
}

class InsertListEvent<E> extends ListEvent<E> {
  const InsertListEvent._(this.index, this.value) : super._();
  final int index;
  final E value;

  @override
  ListEvent<E> revert() {
    return ListEvent<E>.remove(index, value);
  }
}

class RemoveListEvent<E> extends ListEvent<E> {
  const RemoveListEvent._(this.index, this.value) : super._();
  final int index;
  final E value;

  @override
  ListEvent<E> revert() {
    return ListEvent<E>.insert(index, value);
  }
}

class ManyListEvent<E> extends ListEvent<E> {
  const ManyListEvent._(this.events) : super._();
  final List<ListEvent<E>> events;

  @override
  ListEvent<E> revert() {
    return ListEvent<E>.many(
      events.reversed.map((e) => e.revert()).toList(),
    );
  }
}

class RecreateListEvent<E> extends ListEvent<E> {
  const RecreateListEvent._({required this.oldList, required this.newList})
      : super._();
  final List<E> newList;
  final List<E> oldList;

  @override
  ListEvent<E> revert() {
    return ListEvent<E>.recreate(
      oldList: newList,
      newList: oldList,
    );
  }
}

class ListNotifier<E> extends EventConsumer<ListEvent<E>> implements List<E> {
  ListNotifier(
    List<E> inner, {
    int? maxHistoryLength,
    NestedNotifier? parent,
    String? propKey,
    this.itemFactory,
  })  : _inner = ObservableList.of(inner),
        super(
          maxHistoryLength: maxHistoryLength,
          parent: parent,
          propKey: propKey,
        );

  ObservableList<E> _inner;
  final E Function()? itemFactory;

  @override
  dynamic toJson() {
    return Serializers.toJsonList(_inner);
  }

  @override
  bool trySetFromJson(Object? json) {
    try {
      this._inner = ObservableList.of(
        Serializers.fromJsonList(json as Iterable, itemFactory),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  @protected
  void consume(ListEvent<E> e) {
    runInAction(() {
      e.when(
        change: (c) {
          _inner[c.index] = c.newValue;
        },
        insert: (c) {
          _inner.insert(c.index, c.value);
        },
        remove: (c) {
          _inner.removeAt(c.index);
        },
        many: (c) {
          c.events.forEach(consume);
        },
        recreate: (c) {
          _inner = ObservableList.of(c.newList);
        },
      );
    });
  }

  ListNotifier<E> clone() {
    final value = ListNotifier([..._inner]);
    value.setClonedHistory(history);
    return value;
  }

  @override
  ListNotifier<E> operator +(List<E> other) {
    final value = clone();
    value.addAll(other);
    return value;
  }

  @override
  set length(int newLength) {
    // TODO:
    _inner.length = newLength;
  }

  @override
  E operator [](int index) {
    return _inner[index];
  }

  //
  // INSERT SINGLE

  @override
  void add(E value) {
    apply(ListEvent.insert(length, value));
  }

  @override
  void insert(int index, E element) {
    apply(ListEvent.insert(index, element));
  }

  //
  // INSERT MANY

  @override
  void addAll(Iterable<E> iterable) {
    int offset = length;
    final events = iterable.map((v) {
      return ListEvent.insert(offset++, v);
    }).toList();
    apply(ListEvent.many(events));
  }

  @override
  void insertAll(int index, Iterable<E> iterable) {
    validateIndex(index, lengthInclusive: true);

    int offset = index;
    final events = iterable.map((v) {
      return ListEvent.insert(offset++, v);
    }).toList();
    apply(ListEvent.many(events));
  }

  //
  // REMOVE SINGLE

  @override
  bool remove(Object? value) {
    if (value is E) {
      final index = _inner.indexOf(value);
      if (index != -1) {
        apply(ListEvent.remove(index, value));
        return true;
      }
    }
    return false;
  }

  @override
  E removeAt(int index) {
    validateIndex(index, lengthInclusive: false);

    final value = _inner[index];
    apply(ListEvent.remove(index, value));
    return value;
  }

  @override
  E removeLast() {
    return removeAt(_inner.length - 1);
  }

  //
  // REMOVE MANY

  @override
  void clear() {
    if (length != 0) {
      apply(ListEvent.recreate(newList: const [], oldList: _inner));
    }
  }

  @override
  void removeRange(int start, int end) {
    validateRange(start, end);

    final events = Iterable<int>.generate(end - start, (index) => index + start)
        .map((offset) => ListEvent.remove(offset, _inner[offset]))
        .toList();
    apply(ListEvent.many(events));
  }

  @override
  void removeWhere(bool Function(E element) test) {
    int index = 0;
    final events = map((e) {
      ListEvent<E>? event;
      if (test(e)) {
        event = ListEvent.remove(index, e);
      } else {
        event = null;
      }
      index++;
      return event;
    }).where((event) => event != null).toList();
    apply(ListEvent.many(events.cast()));
  }

  @override
  void retainWhere(bool Function(E element) test) {
    removeWhere((e) => !test(e));
  }

  //
  // CHANGE SINGLE

  @override
  void operator []=(int index, E value) {
    apply(ListEvent.change(index, oldValue: _inner[index], newValue: value));
  }

  @override
  set first(E value) {
    this[0] = value;
  }

  @override
  set last(E value) {
    this[length - 1] = value;
  }

  //
  // CHANGE MANY

  @override
  void replaceRange(int start, int end, Iterable<E> replacement) {
    validateRange(start, end);

    int offset = start;
    final events = <ListEvent<E>>[];
    for (final e in replacement) {
      if (offset >= end) {
        break;
      }

      events.add(ListEvent.change(offset, oldValue: this[offset], newValue: e));
      offset++;
    }
    apply(ListEvent.many(events));
  }

  @override
  void fillRange(int start, int end, [E? fillValue]) {
    validateRange(start, end);

    final events = Iterable<int>.generate(end - start).map((index) {
      final E oldValue = this[index];
      return ListEvent.change(
        index + start,
        oldValue: oldValue,
        newValue: fillValue,
      );
    }).toList();
    apply(ListEvent.many(events.cast()));
  }

  @override
  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) {
    validateRange(start, end);
    // TODO: implement setRange
  }

  @override
  void setAll(int index, Iterable<E> iterable) {
    validateIndex(index, lengthInclusive: true);

    int offset = index;
    final events = iterable.map((v) {
      final E oldValue = this[offset];
      return ListEvent.change(offset++, oldValue: oldValue, newValue: v);
    }).toList();
    apply(ListEvent.many(events));
  }

  //
  // REORDER

  @override
  void shuffle([Random? random]) {
    if (length > 1) {
      final newList = [..._inner];
      newList.shuffle(random);
      apply(ListEvent.recreate(newList: newList, oldList: _inner));
    }
  }

  @override
  void sort([int Function(E a, E b)? compare]) {
    if (length > 1) {
      final newList = [..._inner];
      newList.sort(compare);
      apply(ListEvent.recreate(newList: newList, oldList: _inner));
    }
  }

  //
  // HELPERS

  /// 0 <= start <= end <= length
  void validateRange(int start, int end) {
    if (0 > start || start > end || end > length) {
      throw "0 <= start <= end <= length";
    }
  }

  /// lengthInclusive: 0 <= index <= length
  /// !lengthInclusive: 0 <= index < length
  void validateIndex(int index, {required bool lengthInclusive}) {
    if (0 > index || (lengthInclusive ? index > length : index >= length)) {
      throw lengthInclusive ? "0 <= index <= length" : "0 <= index < length";
    }
  }

  //
  //
  // OVERRIDES

  @override
  bool any(bool Function(E element) test) => _inner.any(test);

  @override
  Map<int, E> asMap() => _inner.asMap();

  @override
  List<R> cast<R>() => _inner.cast();

  @override
  bool contains(Object? element) => _inner.contains(element);

  @override
  E elementAt(int index) => _inner.elementAt(index);

  @override
  bool every(bool Function(E element) test) => _inner.every(test);

  @override
  Iterable<T> expand<T>(Iterable<T> Function(E element) f) => _inner.expand(f);

  @override
  E firstWhere(bool Function(E element) test, {E Function()? orElse}) =>
      _inner.firstWhere(test, orElse: orElse);

  @override
  T fold<T>(T initialValue, T Function(T previousValue, E element) combine) =>
      _inner.fold(initialValue, combine);

  @override
  Iterable<E> followedBy(Iterable<E> other) => _inner.followedBy(other);

  @override
  void forEach(void Function(E element) f) => _inner.forEach(f);

  @override
  Iterable<E> getRange(int start, int end) => _inner.getRange(start, end);

  @override
  int indexOf(E element, [int start = 0]) => _inner.indexOf(element, start);

  @override
  int indexWhere(bool Function(E element) test, [int start = 0]) =>
      _inner.indexWhere(test, start);

  @override
  bool get isEmpty => _inner.isEmpty;

  @override
  bool get isNotEmpty => _inner.isNotEmpty;

  @override
  Iterator<E> get iterator => _inner.iterator;

  @override
  String join([String separator = ""]) => _inner.join(separator);

  @override
  int lastIndexOf(E element, [int? start]) =>
      _inner.lastIndexOf(element, start);

  @override
  int lastIndexWhere(bool Function(E element) test, [int? start]) =>
      _inner.lastIndexWhere(test, start);

  @override
  E lastWhere(bool Function(E element) test, {E Function()? orElse}) =>
      _inner.lastWhere(test, orElse: orElse);

  @override
  Iterable<T> map<T>(T Function(E e) f) => _inner.map(f);

  @override
  E reduce(E Function(E value, E element) combine) => _inner.reduce(combine);

  @override
  Iterable<E> get reversed => _inner.reversed;

  @override
  E get single => _inner.single;

  @override
  E singleWhere(bool Function(E element) test, {E Function()? orElse}) =>
      _inner.singleWhere(test, orElse: orElse);

  @override
  Iterable<E> skip(int count) => _inner.skip(count);

  @override
  Iterable<E> skipWhile(bool Function(E value) test) => _inner.skipWhile(test);

  @override
  List<E> sublist(int start, [int? end]) => _inner.sublist(start, end);

  @override
  Iterable<E> take(int count) => _inner.take(count);

  @override
  Iterable<E> takeWhile(bool Function(E value) test) => _inner.takeWhile(test);

  @override
  List<E> toList({bool growable = true}) => _inner.toList(growable: growable);

  @override
  Set<E> toSet() => _inner.toSet();

  @override
  Iterable<E> where(bool Function(E element) test) => _inner.where(test);

  @override
  Iterable<T> whereType<T>() => _inner.whereType<T>();

  @override
  E get first => _inner.first;

  @override
  E get last => _inner.last;

  @override
  int get length => _inner.length;
}
