import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

extension GlobalPaintBoundsExt on BuildContext {
  Rect? get globalPaintBounds {
    final renderObject = findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject!.paintBounds != null) {
      return renderObject.paintBounds
          .shift(Offset(translation.x, translation.y));
    } else {
      return null;
    }
  }
}

extension ContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;

  MediaQueryData get mq => MediaQuery.of(this);

  Size get size => mq.size;
}

extension IndexedMap<T> on Iterable<T> {
  Iterable<V> mapIndex<V>(V Function(T, int) f) {
    int i = 0;
    return this.map((v) => f(v, i++));
  }

  Iterable<ItemIndex<T>> indexed() {
    int i = 0;
    return this.map((v) => ItemIndex(i++, v));
  }

  Iterable<O> zip<O, V>(Iterable<V> it, O Function(T, V) f) sync* {
    final iterator = it.iterator;
    for (final v in this) {
      if (iterator.moveNext()) {
        yield f(v, iterator.current);
      } else {
        break;
      }
    }
  }
}

class ItemIndex<T> {
  final int index;
  final T item;

  const ItemIndex(this.index, this.item);
}

T? parseEnum<T>(String rawString, List<T> enumValues,
    {bool caseSensitive = true}) {
  final _rawStringComp = caseSensitive ? rawString : rawString.toLowerCase();
  for (final value in enumValues) {
    final str =
        caseSensitive ? value.toString() : value.toString().toLowerCase();
    if (str == _rawStringComp || str.split('.')[1] == _rawStringComp) {
      return value;
    }
  }
  return null;
}

extension ValueListenableBuilderExtension<T> on ValueListenable<T> {
  Widget rebuild(Widget Function(T value) fn, {Key? key}) {
    return ValueListenableBuilder<T>(
      key: key,
      valueListenable: this,
      builder: (context, v, _) {
        return fn(v);
      },
    );
  }
}

extension ListenableBuilder on Listenable {
  Widget rebuild(Widget Function() fn) {
    return AnimatedBuilder(
      animation: this,
      builder: (context, _) {
        return fn();
      },
    );
  }
}

extension ValueNotifierSetter<T> on ValueNotifier<T> {
  void set(T newValue) {
    this.value = newValue;
  }
}

extension MapSetter<K, T> on Map<K, T> {
  void set(K key, T newValue) {
    this[key] = newValue;
  }

  T? get(K key) {
    return this[key];
  }
}

extension CasingString on String {
  String firstToLowerCase() =>
      length > 0 ? substring(0, 1).toLowerCase() + substring(1) : this;
  String firstToUpperCase() =>
      length > 0 ? substring(0, 1).toUpperCase() + substring(1) : this;
  String asVariableName({bool dart = true}) {
    String value = replaceFirst('_', '').firstToLowerCase();
    const _reserved = {'null', 'true', 'false', 'default', 'enum'};
    const _reservedChar = {
      '"': 'doubleQuote',
      r'\\': 'escape',
      r'\n': 'newLine',
      '"""': 'tripleDoubleQuote',
      r'\\"""': 'escapedTripleDoubleQuote',
    };
    if (dart && _reserved.contains(value)) {
      value += '_';
    } else if (_reservedChar.containsKey(value)) {
      value = _reservedChar[value]!;
    }
    return value;
  }

  String snakeToCamel({bool firstUpperCase = false}) {
    int lastIndex = 0;
    int index = 0;

    final buffer = StringBuffer();

    void _add() {
      if (index <= lastIndex) {
        return;
      }
      final _toAdd = this.substring(lastIndex, index);
      buffer.write(lastIndex != 0 || firstUpperCase
          ? _toAdd.firstToUpperCase()
          : _toAdd);
    }

    for (final codeUnit in this.codeUnits) {
      final char = String.fromCharCode(codeUnit);
      if (char == '_') {
        _add();
        lastIndex = index + 1;
      }
      index += 1;
    }
    _add();

    return buffer.toString();
  }
}

const dynamic importExtensions = null;
