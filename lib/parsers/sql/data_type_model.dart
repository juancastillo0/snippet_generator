// ignore_for_file: constant_identifier_names
import 'package:snippet_generator/utils/extensions.dart';

abstract class SqlType {
  const SqlType._();

  const factory SqlType.date({
    required SqlDateVariant type,
    required int? fractionalSeconds,
  }) = _Date;
  const factory SqlType.string({
    required bool variableSize,
    required bool binary,
    required int size,
    required String? characterSet,
  }) = _String;
  const factory SqlType.enumeration({
    required List<String> variants,
    required bool allowMultipleValues,
    required String? characterSet,
  }) = _Enumeration;
  const factory SqlType.integer({
    required int bits,
    required bool unsigned,
    required bool zerofill,
  }) = _Integer;
  const factory SqlType.decimal({
    required int digitsTotal,
    required int digitsDecimal,
    required bool unsigned,
    required bool zerofill,
    required SqlDecimalType type,
  }) = _Decimal;
  const factory SqlType.json() = _Json;

  _T when<_T>({
    required _T Function(SqlDateVariant type, int? fractionalSeconds) date,
    required _T Function(
            bool variableSize, bool binary, int size, String? characterSet)
        string,
    required _T Function(List<String> variants, bool allowMultipleValues,
            String? characterSet)
        enumeration,
    required _T Function(int bits, bool unsigned, bool zerofill) integer,
    required _T Function(int digitsTotal, int digitsDecimal, bool unsigned,
            bool zerofill, SqlDecimalType type)
        decimal,
    required _T Function() json,
  }) {
    final v = this;
    if (v is _Date) {
      return date(v.type, v.fractionalSeconds);
    } else if (v is _String) {
      return string(v.variableSize, v.binary, v.size, v.characterSet);
    } else if (v is _Enumeration) {
      return enumeration(v.variants, v.allowMultipleValues, v.characterSet);
    } else if (v is _Integer) {
      return integer(v.bits, v.unsigned, v.zerofill);
    } else if (v is _Decimal) {
      return decimal(
          v.digitsTotal, v.digitsDecimal, v.unsigned, v.zerofill, v.type);
    } else if (v is _Json) {
      return json();
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(SqlDateVariant type, int? fractionalSeconds)? date,
    _T Function(bool variableSize, bool binary, int size, String? characterSet)?
        string,
    _T Function(List<String> variants, bool allowMultipleValues,
            String? characterSet)?
        enumeration,
    _T Function(int bits, bool unsigned, bool zerofill)? integer,
    _T Function(int digitsTotal, int digitsDecimal, bool unsigned,
            bool zerofill, SqlDecimalType type)?
        decimal,
    _T Function()? json,
  }) {
    final v = this;
    if (v is _Date) {
      return date != null ? date(v.type, v.fractionalSeconds) : orElse.call();
    } else if (v is _String) {
      return string != null
          ? string(v.variableSize, v.binary, v.size, v.characterSet)
          : orElse.call();
    } else if (v is _Enumeration) {
      return enumeration != null
          ? enumeration(v.variants, v.allowMultipleValues, v.characterSet)
          : orElse.call();
    } else if (v is _Integer) {
      return integer != null
          ? integer(v.bits, v.unsigned, v.zerofill)
          : orElse.call();
    } else if (v is _Decimal) {
      return decimal != null
          ? decimal(
              v.digitsTotal, v.digitsDecimal, v.unsigned, v.zerofill, v.type)
          : orElse.call();
    } else if (v is _Json) {
      return json != null ? json() : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(_Date value) date,
    required _T Function(_String value) string,
    required _T Function(_Enumeration value) enumeration,
    required _T Function(_Integer value) integer,
    required _T Function(_Decimal value) decimal,
    required _T Function(_Json value) json,
  }) {
    final v = this;
    if (v is _Date) {
      return date(v);
    } else if (v is _String) {
      return string(v);
    } else if (v is _Enumeration) {
      return enumeration(v);
    } else if (v is _Integer) {
      return integer(v);
    } else if (v is _Decimal) {
      return decimal(v);
    } else if (v is _Json) {
      return json(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(_Date value)? date,
    _T Function(_String value)? string,
    _T Function(_Enumeration value)? enumeration,
    _T Function(_Integer value)? integer,
    _T Function(_Decimal value)? decimal,
    _T Function(_Json value)? json,
  }) {
    final v = this;
    if (v is _Date) {
      return date != null ? date(v) : orElse.call();
    } else if (v is _String) {
      return string != null ? string(v) : orElse.call();
    } else if (v is _Enumeration) {
      return enumeration != null ? enumeration(v) : orElse.call();
    } else if (v is _Integer) {
      return integer != null ? integer(v) : orElse.call();
    } else if (v is _Decimal) {
      return decimal != null ? decimal(v) : orElse.call();
    } else if (v is _Json) {
      return json != null ? json(v) : orElse.call();
    }
    throw Exception();
  }

  bool get isDate => this is _Date;
  bool get isString => this is _String;
  bool get isEnumeration => this is _Enumeration;
  bool get isInteger => this is _Integer;
  bool get isDecimal => this is _Decimal;
  bool get isJson => this is _Json;

  TypeSqlType get typeEnum;

  static SqlType fromJson(Map<String, dynamic> map) {
    switch (map["runtimeType"] as String) {
      case "date":
        return _Date.fromJson(map);
      case "string":
        return _String.fromJson(map);
      case "enumeration":
        return _Enumeration.fromJson(map);
      case "integer":
        return _Integer.fromJson(map);
      case "decimal":
        return _Decimal.fromJson(map);
      case "json":
        return _Json.fromJson(map);
      default:
        throw Exception(
            'Invalid discriminator for SqlType.fromJson ${map["runtimeType"]}. Input map: $map');
    }
  }

  Map<String, dynamic> toJson();
}

enum TypeSqlType {
  date,
  string,
  enumeration,
  integer,
  decimal,
  json,
}

TypeSqlType? parseTypeSqlType(String rawString, {bool caseSensitive = true}) {
  final _rawString = caseSensitive ? rawString : rawString.toLowerCase();
  for (final variant in TypeSqlType.values) {
    final variantString = caseSensitive
        ? variant.toEnumString()
        : variant.toEnumString().toLowerCase();
    if (_rawString == variantString) {
      return variant;
    }
  }
  return null;
}

extension TypeSqlTypeExtension on TypeSqlType {
  String toEnumString() => toString().split(".")[1];
  String enumType() => toString().split(".")[0];

  bool get isDate => this == TypeSqlType.date;
  bool get isString => this == TypeSqlType.string;
  bool get isEnumeration => this == TypeSqlType.enumeration;
  bool get isInteger => this == TypeSqlType.integer;
  bool get isDecimal => this == TypeSqlType.decimal;
  bool get isJson => this == TypeSqlType.json;

  _T when<_T>({
    required _T Function() date,
    required _T Function() string,
    required _T Function() enumeration,
    required _T Function() integer,
    required _T Function() decimal,
    required _T Function() json,
  }) {
    switch (this) {
      case TypeSqlType.date:
        return date();
      case TypeSqlType.string:
        return string();
      case TypeSqlType.enumeration:
        return enumeration();
      case TypeSqlType.integer:
        return integer();
      case TypeSqlType.decimal:
        return decimal();
      case TypeSqlType.json:
        return json();
    }
  }

  _T maybeWhen<_T>({
    _T Function()? date,
    _T Function()? string,
    _T Function()? enumeration,
    _T Function()? integer,
    _T Function()? decimal,
    _T Function()? json,
    required _T Function() orElse,
  }) {
    _T Function()? c;
    switch (this) {
      case TypeSqlType.date:
        c = date;
        break;
      case TypeSqlType.string:
        c = string;
        break;
      case TypeSqlType.enumeration:
        c = enumeration;
        break;
      case TypeSqlType.integer:
        c = integer;
        break;
      case TypeSqlType.decimal:
        c = decimal;
        break;
      case TypeSqlType.json:
        c = json;
        break;
    }
    return (c ?? orElse).call();
  }
}

class _Date extends SqlType {
  final SqlDateVariant type;
  final int? fractionalSeconds;

  const _Date({
    required this.type,
    required this.fractionalSeconds,
  }) : super._();

  @override
  TypeSqlType get typeEnum => TypeSqlType.date;

  static _Date fromJson(Map<String, dynamic> map) {
    return _Date(
      type: parseEnum(
        map['type'] as String,
        SqlDateVariant.values,
        caseSensitive: false,
      )!,
      fractionalSeconds: map['fractionalSeconds'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "runtimeType": "date",
      "type": type.toEnumString(),
      "fractionalSeconds": fractionalSeconds,
    };
  }
}

class _String extends SqlType {
  final bool variableSize;
  final bool binary;
  final int size;
  final String? characterSet;

  const _String({
    required this.variableSize,
    required this.binary,
    required this.size,
    required this.characterSet,
  }) : super._();

  @override
  TypeSqlType get typeEnum => TypeSqlType.string;

  static _String fromJson(Map<String, dynamic> map) {
    return _String(
      variableSize: map['variableSize'] as bool,
      binary: map['binary'] as bool,
      size: map['size'] as int,
      characterSet: map['characterSet'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "runtimeType": "string",
      "variableSize": variableSize,
      "binary": binary,
      "size": size,
      "characterSet": characterSet,
    };
  }
}

class _Enumeration extends SqlType {
  final List<String> variants;
  final bool allowMultipleValues;
  final String? characterSet;

  const _Enumeration({
    required this.variants,
    required this.allowMultipleValues,
    required this.characterSet,
  }) : super._();

  @override
  TypeSqlType get typeEnum => TypeSqlType.enumeration;

  static _Enumeration fromJson(Map<String, dynamic> map) {
    return _Enumeration(
      variants: (map['variants'] as List).map((e) => e as String).toList(),
      allowMultipleValues: map['allowMultipleValues'] as bool,
      characterSet: map['characterSet'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "runtimeType": "enumeration",
      "variants": variants.map((e) => e).toList(),
      "allowMultipleValues": allowMultipleValues,
      "characterSet": characterSet,
    };
  }
}

class _Integer extends SqlType {
  final int bits;
  final bool unsigned;
  final bool zerofill;

  const _Integer({
    required this.bits,
    required this.unsigned,
    required this.zerofill,
  }) : super._();

  @override
  TypeSqlType get typeEnum => TypeSqlType.integer;

  static _Integer fromJson(Map<String, dynamic> map) {
    return _Integer(
      bits: map['bits'] as int,
      unsigned: map['unsigned'] as bool,
      zerofill: map['zerofill'] as bool,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "runtimeType": "integer",
      "bits": bits,
      "unsigned": unsigned,
      "zerofill": zerofill,
    };
  }
}

class _Decimal extends SqlType {
  final int digitsTotal;
  final int digitsDecimal;
  final bool unsigned;
  final bool zerofill;
  final SqlDecimalType type;

  const _Decimal({
    required this.digitsTotal,
    required this.digitsDecimal,
    required this.unsigned,
    required this.zerofill,
    required this.type,
  }) : super._();

  @override
  TypeSqlType get typeEnum => TypeSqlType.decimal;

  static _Decimal fromJson(Map<String, dynamic> map) {
    return _Decimal(
      digitsTotal: map['digitsTotal'] as int,
      digitsDecimal: map['digitsDecimal'] as int,
      unsigned: map['unsigned'] as bool,
      zerofill: map['zerofill'] as bool,
      type: parseEnum(map['type'] as String, SqlDecimalType.values,
          caseSensitive: false)!,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "runtimeType": "decimal",
      "digitsTotal": digitsTotal,
      "digitsDecimal": digitsDecimal,
      "unsigned": unsigned,
      "zerofill": zerofill,
      "type": type.toEnumString(),
    };
  }
}

class _Json extends SqlType {
  const _Json() : super._();

  @override
  TypeSqlType get typeEnum => TypeSqlType.json;

  static _Json fromJson(Map<String, dynamic> map) {
    return const _Json();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "runtimeType": "json",
    };
  }
}

enum SqlDateVariant {
  TIMESTAMP,
  TIME,
  DATETIME,
  DATE,
  YEAR,
}

extension SqlDateVariantExt on SqlDateVariant {
  String toEnumString() => toString().split('.')[1];
}

enum SqlDecimalType {
  FIXED,
  FLOAT,
  DOUBLE,
}

extension SqlDecimalTypeExt on SqlDecimalType {
  String toEnumString() => toString().split('.')[1];
}
