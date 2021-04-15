abstract class InitialSize {
  const InitialSize._();

  const factory InitialSize.flex(
    int value,
  ) = _Flex;
  const factory InitialSize.size(
    double value,
  ) = _Size;

  _T when<_T>({
    required _T Function(int value) flex,
    required _T Function(double value) size,
  }) {
    final v = this;
    if (v is _Flex) {
      return flex(v.value);
    } else if (v is _Size) {
      return size(v.value);
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(int value)? flex,
    _T Function(double value)? size,
  }) {
    final v = this;
    if (v is _Flex) {
      return flex != null ? flex(v.value) : orElse.call();
    } else if (v is _Size) {
      return size != null ? size(v.value) : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(_Flex value) flex,
    required _T Function(_Size value) size,
  }) {
    final v = this;
    if (v is _Flex) {
      return flex(v);
    } else if (v is _Size) {
      return size(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(_Flex value)? flex,
    _T Function(_Size value)? size,
  }) {
    final v = this;
    if (v is _Flex) {
      return flex != null ? flex(v) : orElse.call();
    } else if (v is _Size) {
      return size != null ? size(v) : orElse.call();
    }
    throw Exception();
  }

  bool get isFlex => this is _Flex;
  bool get isSize => this is _Size;
}

class _Flex extends InitialSize {
  final int value;

  const _Flex(
    this.value,
  ) : super._();

  _Flex copyWith({
    int? value,
  }) {
    return _Flex(
      value ?? this.value,
    );
  }

  @override
  bool operator ==(dynamic other) {
    if (other is _Flex) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;
}

class _Size extends InitialSize {
  final double value;

  const _Size(
    this.value,
  ) : super._();

  _Size copyWith({
    double? value,
  }) {
    return _Size(
      value ?? this.value,
    );
  }

  @override
  bool operator ==(dynamic other) {
    if (other is _Size) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;
}
