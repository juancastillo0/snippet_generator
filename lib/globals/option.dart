abstract class Option<T> {
  const Option._();

  const factory Option.some(
    T value,
  ) = Some;
  const factory Option.none() = None;

  T? get valueOrNull => when(some: (some) => some, none: () => null);

  _T when<_T>({
    required _T Function(T value) some,
    required _T Function() none,
  }) {
    final v = this;
    if (v is Some<T>) {
      return some(v.value);
    } else if (v is None<T>) {
      return none();
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(T value)? some,
    _T Function()? none,
  }) {
    final v = this;
    if (v is Some<T>) {
      return some != null ? some(v.value) : orElse.call();
    } else if (v is None<T>) {
      return none != null ? none() : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(Some<T> value) some,
    required _T Function(None<T> value) none,
  }) {
    final v = this;
    if (v is Some<T>) {
      return some(v);
    } else if (v is None<T>) {
      return none(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(Some<T> value)? some,
    _T Function(None<T> value)? none,
  }) {
    final v = this;
    if (v is Some<T>) {
      return some != null ? some(v) : orElse.call();
    } else if (v is None<T>) {
      return none != null ? none(v) : orElse.call();
    }
    throw Exception();
  }

  bool get isSome => this is Some;
  bool get isNone => this is None;

  TypeOption get typeEnum;

  Option<_T> mapGenericT<_T>(_T Function(T) mapper) {
    return map(
      some: (v) => Option.some(mapper(v.value)),
      none: (v) => const Option.none(),
    );
  }
}

enum TypeOption {
  some,
  none,
}

TypeOption? parseTypeOption(String rawString, {bool caseSensitive = true}) {
  final _rawString = caseSensitive ? rawString : rawString.toLowerCase();
  for (final variant in TypeOption.values) {
    final variantString = caseSensitive
        ? variant.toEnumString()
        : variant.toEnumString().toLowerCase();
    if (_rawString == variantString) {
      return variant;
    }
  }
  return null;
}

extension TypeOptionExtension on TypeOption {
  String toEnumString() => toString().split('.')[1];
  String enumType() => toString().split('.')[0];

  bool get isSome => this == TypeOption.some;
  bool get isNone => this == TypeOption.none;

  _T when<_T>({
    required _T Function() some,
    required _T Function() none,
  }) {
    switch (this) {
      case TypeOption.some:
        return some();
      case TypeOption.none:
        return none();
    }
  }

  _T maybeWhen<_T>({
    _T Function()? some,
    _T Function()? none,
    required _T Function() orElse,
  }) {
    _T Function()? c;
    switch (this) {
      case TypeOption.some:
        c = some;
        break;
      case TypeOption.none:
        c = none;
        break;
    }
    return (c ?? orElse).call();
  }
}

class Some<T> extends Option<T> {
  final T value;

  const Some(
    this.value,
  ) : super._();

  @override
  TypeOption get typeEnum => TypeOption.some;
}

class None<T> extends Option<T> {
  const None() : super._();

  @override
  TypeOption get typeEnum => TypeOption.none;
}
