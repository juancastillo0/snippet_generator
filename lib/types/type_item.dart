import 'package:snippet_generator/types/type_models.dart';

abstract class TypeItem implements Clonable<TypeItem> {
  final DateTime createdAt;
  TypeItem._() : createdAt = DateTime.now();

  @override
  TypeItem clone() {
    return this.when(
      classI: (c) => TypeItem.classI(c.clone()),
      typeI: (t) => TypeItem.typeI(t.clone()),
      propertyI: (p) => TypeItem.propertyI(p.clone()),
      propertyListI: (p) =>
          TypeItem.propertyListI(p.map((e) => e.clone()).toList()),
    );
  }

  ClassConfig? parentClass() {
    return this.when(
      classI: (c) => c,
      typeI: (t) => null,
      propertyI: (p) => p.classConfig,
      propertyListI: (p) => p.first.classConfig,
    );
  }

  TypeConfig parentType() {
    return this.when(
      classI: (c) => c.typeConfig,
      typeI: (t) => t,
      propertyI: (p) => p.classConfig!.typeConfig,
      propertyListI: (p) => p.first.classConfig!.typeConfig,
    );
  }

  factory TypeItem.classI(
    ClassConfig value,
  ) = _ClassI;
  factory TypeItem.typeI(
    TypeConfig value,
  ) = _TypeI;
  factory TypeItem.propertyI(
    PropertyField value,
  ) = _PropertyI;
  factory TypeItem.propertyListI(
    List<PropertyField> value,
  ) = _PropertyListI;

  T when<T>({
    required T Function(ClassConfig value) classI,
    required T Function(TypeConfig value) typeI,
    required T Function(PropertyField value) propertyI,
    required T Function(List<PropertyField> value) propertyListI,
  }) {
    final TypeItem v = this;
    if (v is _ClassI) return classI(v.value);
    if (v is _TypeI) return typeI(v.value);
    if (v is _PropertyI) return propertyI(v.value);
    if (v is _PropertyListI) return propertyListI(v.value);
    throw '';
  }

  T? maybeWhen<T>({
    T Function()? orElse,
    T Function(ClassConfig value)? classI,
    T Function(TypeConfig value)? typeI,
    T Function(PropertyField value)? propertyI,
    T Function(List<PropertyField> value)? propertyListI,
  }) {
    final TypeItem v = this;
    if (v is _ClassI) {
      return classI != null ? classI(v.value) : orElse?.call();
    } else if (v is _TypeI) {
      return typeI != null ? typeI(v.value) : orElse?.call();
    } else if (v is _PropertyI) {
      return propertyI != null ? propertyI(v.value) : orElse?.call();
    } else if (v is _PropertyListI) {
      return propertyListI != null ? propertyListI(v.value) : orElse?.call();
    }
    throw '';
  }

  T map<T>({
    required T Function(_ClassI value) classI,
    required T Function(_TypeI value) typeI,
    required T Function(_PropertyI value) propertyI,
    required T Function(_PropertyListI value) propertyListI,
  }) {
    final TypeItem v = this;
    if (v is _ClassI) return classI(v);
    if (v is _TypeI) return typeI(v);
    if (v is _PropertyI) return propertyI(v);
    if (v is _PropertyListI) return propertyListI(v);
    throw '';
  }

  T? maybeMap<T>({
    T Function()? orElse,
    T Function(_ClassI value)? classI,
    T Function(_TypeI value)? typeI,
    T Function(_PropertyI value)? propertyI,
    T Function(_PropertyListI value)? propertyListI,
  }) {
    final TypeItem v = this;
    if (v is _ClassI) {
      return classI != null ? classI(v) : orElse?.call();
    } else if (v is _TypeI) {
      return typeI != null ? typeI(v) : orElse?.call();
    } else if (v is _PropertyI) {
      return propertyI != null ? propertyI(v) : orElse?.call();
    } else if (v is _PropertyListI) {
      return propertyListI != null ? propertyListI(v) : orElse?.call();
    }
    throw '';
  }

  static TypeItem? fromJson(Map<String, Object?> map) {
    switch (map['runtimeType'] as String?) {
      case '_ClassI':
        return _ClassI.fromJson(map);
      case '_TypeI':
        return _TypeI.fromJson(map);
      case '_PropertyI':
        return _PropertyI.fromJson(map);
      case '_PropertyListI':
        return _PropertyListI.fromJson(map);
      default:
        return null;
    }
  }

  Map<String, dynamic> toJson();
}

class _ClassI extends TypeItem {
  final ClassConfig value;

  _ClassI(
    this.value,
  ) : super._();

  static _ClassI fromJson(Map<String, dynamic> map) {
    return _ClassI(
      ClassConfig.fromJson(map['value'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'runtimeType': '_ClassI',
      'value': value.toJson(),
    };
  }
}

class _TypeI extends TypeItem {
  final TypeConfig value;

  _TypeI(
    this.value,
  ) : super._();

  static _TypeI fromJson(Map<String, Object?> map) {
    return _TypeI(
      TypeConfig.fromJson(map['value'] as Map<String, Object?>),
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'runtimeType': '_TypeI',
      'value': value.toJson(),
    };
  }
}

class _PropertyI extends TypeItem {
  final PropertyField value;

  _PropertyI(
    this.value,
  ) : super._();

  static _PropertyI fromJson(Map<String, Object?> map) {
    return _PropertyI(
      PropertyField.fromJson(map['value'] as Map<String, Object?>),
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'runtimeType': '_PropertyI',
      'value': value.toJson(),
    };
  }
}

class _PropertyListI extends TypeItem {
  final List<PropertyField> value;

  _PropertyListI(
    this.value,
  ) : super._();

  static _PropertyListI fromJson(Map<String, Object?> map) {
    return _PropertyListI(
      (map['value']! as List)
          .map(
              (Object? e) => PropertyField.fromJson(e! as Map<String, Object?>))
          .toList(),
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'runtimeType': '_PropertyListI',
      'value': value.map((e) => e.toJson()).toList(),
    };
  }
}
