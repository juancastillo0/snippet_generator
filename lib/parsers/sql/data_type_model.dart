// ignore_for_file: constant_identifier_names
import 'dart:math';

import 'package:snippet_generator/globals/option.dart';
import 'package:snippet_generator/utils/extensions.dart';

abstract class SqlType {
  const SqlType._();

  const factory SqlType.date({
    required SqlDateVariant type,
    required int? fractionalSeconds,
  }) = SqlTypeDate;
  const factory SqlType.string({
    required bool variableSize,
    required bool binary,
    required int size,
    required String? characterSet,
  }) = SqlTypeString;
  const factory SqlType.enumeration({
    required List<String> variants,
    required bool allowMultipleValues,
    required String? characterSet,
  }) = SqlTypeEnumeration;
  const factory SqlType.integer({
    required int bytes,
    required bool unsigned,
    required bool zerofill,
  }) = SqlTypeInteger;
  const factory SqlType.decimal({
    required int digitsTotal,
    required int digitsDecimal,
    required bool unsigned,
    required bool zerofill,
    required SqlDecimalType type,
  }) = SqlTypeDecimal;
  const factory SqlType.json() = SqlTypeJson;

  static const sqlIntegerBytes = {
    'TINY': 1,
    'SMALL': 2,
    'MEDIUM': 3,
    '': 4,
    'BIG': 8,
  };

  static const sqlIntegerBytesRev = {
    1: 'TINY',
    2: 'SMALL',
    3: 'MEDIUM',
    4: '',
    8: 'BIG',
  };

  static final sqlStringSizeRev = {
    pow(2, 8) - 1: 'TINY',
    pow(2, 16) - 1: '',
    pow(2, 24) - 1: 'MEDIUM',
    pow(2, 32) - 1: 'LONG',
  };

  static const defaultSqlTypes = {
    TypeSqlType.date: SqlType.date(
      type: SqlDateVariant.DATETIME,
      fractionalSeconds: 0,
    ),
    TypeSqlType.decimal: SqlType.decimal(
      type: SqlDecimalType.DOUBLE,
      unsigned: false,
      zerofill: false,
      digitsTotal: SqlTypeDecimal.defaultDigitsTotalNotFixed,
      digitsDecimal: SqlTypeDecimal.defaultDigitsDecimalDouble,
    ),
    TypeSqlType.json: SqlType.json(),
    TypeSqlType.integer: SqlType.integer(
      bytes: 4,
      unsigned: false,
      zerofill: false,
    ),
    TypeSqlType.enumeration: SqlType.enumeration(
      allowMultipleValues: false,
      variants: [''],
      characterSet: null,
    ),
    TypeSqlType.string: SqlType.string(
      binary: false,
      size: 255,
      characterSet: null,
      variableSize: true,
    ),
  };

  String toSql() {
    return this.map(
      date: (date) {
        return '${date.type.toEnumString()}${date.fractionalSeconds == null ? "" : "(${date.fractionalSeconds})"}';
      },
      string: (string) {
        if (string.variableSize) {
          if (sqlStringSizeRev.containsKey(string.size)) {
            final prefix = sqlStringSizeRev[string.size]!;
            return '$prefix${string.binary ? "BLOB" : "TEXT"}';
          } else {
            return '${string.binary ? "VARBINARY" : "VARCHAR"}(${string.size})';
          }
        } else {
          return '${string.binary ? "BINARY" : "CHAR"}(${string.size})';
        }
      },
      enumeration: (enumeration) {
        return '${enumeration.allowMultipleValues ? "SET" : "ENUM"} (${enumeration.variants.map((e) => "'$e'").join(",")})';
      },
      integer: (integer) {
        return '${sqlIntegerBytesRev[integer.bytes]!}INT${integer.unsigned ? " UNSIGNED" : ""}${integer.zerofill ? " ZEROFILL" : ""}';
      },
      decimal: (decimal) {
        final reper = decimal.type.toEnumString();
        final String _digits;
        if (decimal.type == SqlDecimalType.FIXED ||
            !decimal.hasDefaultNumDigits()) {
          _digits = '(${decimal.digitsTotal},${decimal.digitsDecimal})';
        } else {
          _digits = '';
        }
        return '$reper$_digits${decimal.unsigned ? " UNSIGNED" : ""}${decimal.zerofill ? " ZEROFILL" : ""}';
      },
      json: (json) {
        return 'JSON';
      },
    );
  }

  _T when<_T>({
    required _T Function(SqlDateVariant type, int? fractionalSeconds) date,
    required _T Function(
            bool variableSize, bool binary, int size, String? characterSet)
        string,
    required _T Function(List<String> variants, bool allowMultipleValues,
            String? characterSet)
        enumeration,
    required _T Function(int bytes, bool unsigned, bool zerofill) integer,
    required _T Function(int digitsTotal, int digitsDecimal, bool unsigned,
            bool zerofill, SqlDecimalType type)
        decimal,
    required _T Function() json,
  }) {
    final v = this;
    if (v is SqlTypeDate) {
      return date(v.type, v.fractionalSeconds);
    } else if (v is SqlTypeString) {
      return string(v.variableSize, v.binary, v.size, v.characterSet);
    } else if (v is SqlTypeEnumeration) {
      return enumeration(v.variants, v.allowMultipleValues, v.characterSet);
    } else if (v is SqlTypeInteger) {
      return integer(v.bytes, v.unsigned, v.zerofill);
    } else if (v is SqlTypeDecimal) {
      return decimal(
          v.digitsTotal, v.digitsDecimal, v.unsigned, v.zerofill, v.type);
    } else if (v is SqlTypeJson) {
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
    _T Function(int bytes, bool unsigned, bool zerofill)? integer,
    _T Function(int digitsTotal, int digitsDecimal, bool unsigned,
            bool zerofill, SqlDecimalType type)?
        decimal,
    _T Function()? json,
  }) {
    final v = this;
    if (v is SqlTypeDate) {
      return date != null ? date(v.type, v.fractionalSeconds) : orElse.call();
    } else if (v is SqlTypeString) {
      return string != null
          ? string(v.variableSize, v.binary, v.size, v.characterSet)
          : orElse.call();
    } else if (v is SqlTypeEnumeration) {
      return enumeration != null
          ? enumeration(v.variants, v.allowMultipleValues, v.characterSet)
          : orElse.call();
    } else if (v is SqlTypeInteger) {
      return integer != null
          ? integer(v.bytes, v.unsigned, v.zerofill)
          : orElse.call();
    } else if (v is SqlTypeDecimal) {
      return decimal != null
          ? decimal(
              v.digitsTotal, v.digitsDecimal, v.unsigned, v.zerofill, v.type)
          : orElse.call();
    } else if (v is SqlTypeJson) {
      return json != null ? json() : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(SqlTypeDate value) date,
    required _T Function(SqlTypeString value) string,
    required _T Function(SqlTypeEnumeration value) enumeration,
    required _T Function(SqlTypeInteger value) integer,
    required _T Function(SqlTypeDecimal value) decimal,
    required _T Function(SqlTypeJson value) json,
  }) {
    final v = this;
    if (v is SqlTypeDate) {
      return date(v);
    } else if (v is SqlTypeString) {
      return string(v);
    } else if (v is SqlTypeEnumeration) {
      return enumeration(v);
    } else if (v is SqlTypeInteger) {
      return integer(v);
    } else if (v is SqlTypeDecimal) {
      return decimal(v);
    } else if (v is SqlTypeJson) {
      return json(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(SqlTypeDate value)? date,
    _T Function(SqlTypeString value)? string,
    _T Function(SqlTypeEnumeration value)? enumeration,
    _T Function(SqlTypeInteger value)? integer,
    _T Function(SqlTypeDecimal value)? decimal,
    _T Function(SqlTypeJson value)? json,
  }) {
    final v = this;
    if (v is SqlTypeDate) {
      return date != null ? date(v) : orElse.call();
    } else if (v is SqlTypeString) {
      return string != null ? string(v) : orElse.call();
    } else if (v is SqlTypeEnumeration) {
      return enumeration != null ? enumeration(v) : orElse.call();
    } else if (v is SqlTypeInteger) {
      return integer != null ? integer(v) : orElse.call();
    } else if (v is SqlTypeDecimal) {
      return decimal != null ? decimal(v) : orElse.call();
    } else if (v is SqlTypeJson) {
      return json != null ? json(v) : orElse.call();
    }
    throw Exception();
  }

  bool get isDate => this is SqlTypeDate;
  bool get isString => this is SqlTypeString;
  bool get isEnumeration => this is SqlTypeEnumeration;
  bool get isInteger => this is SqlTypeInteger;
  bool get isDecimal => this is SqlTypeDecimal;
  bool get isJson => this is SqlTypeJson;

  TypeSqlType get typeEnum;

  static SqlType fromJson(Map<String, dynamic> map) {
    switch (map['runtimeType'] as String) {
      case 'date':
        return SqlTypeDate.fromJson(map);
      case 'string':
        return SqlTypeString.fromJson(map);
      case 'enumeration':
        return SqlTypeEnumeration.fromJson(map);
      case 'integer':
        return SqlTypeInteger.fromJson(map);
      case 'decimal':
        return SqlTypeDecimal.fromJson(map);
      case 'json':
        return SqlTypeJson.fromJson(map);
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
  String toEnumString() => toString().split('.')[1];
  String enumType() => toString().split('.')[0];

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

class SqlTypeDate extends SqlType {
  final SqlDateVariant type;
  final int? fractionalSeconds;

  const SqlTypeDate({
    required this.type,
    required this.fractionalSeconds,
  }) : super._();

  @override
  TypeSqlType get typeEnum => TypeSqlType.date;

  static SqlTypeDate fromJson(Map<String, dynamic> map) {
    return SqlTypeDate(
      type: parseEnum(
        map['type'] as String,
        SqlDateVariant.values,
        caseSensitive: false,
      )!,
      fractionalSeconds: map['fractionalSeconds'] as int,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'runtimeType': 'date',
      'type': type.toEnumString(),
      'fractionalSeconds': fractionalSeconds,
    };
  }

  SqlTypeDate copyWith({
    SqlDateVariant? type,
    Option<int>? fractionalSeconds,
  }) {
    return SqlTypeDate(
      type: type ?? this.type,
      fractionalSeconds: fractionalSeconds != null
          ? fractionalSeconds.valueOrNull
          : this.fractionalSeconds,
    );
  }
}

class SqlTypeString extends SqlType {
  final bool variableSize;
  final bool binary;
  final int size;
  final String? characterSet;

  const SqlTypeString({
    required this.variableSize,
    required this.binary,
    required this.size,
    required this.characterSet,
  }) : super._();

  @override
  TypeSqlType get typeEnum => TypeSqlType.string;

  static SqlTypeString fromJson(Map<String, dynamic> map) {
    return SqlTypeString(
      variableSize: map['variableSize'] as bool,
      binary: map['binary'] as bool,
      size: map['size'] as int,
      characterSet: map['characterSet'] as String,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'runtimeType': 'string',
      'variableSize': variableSize,
      'binary': binary,
      'size': size,
      'characterSet': characterSet,
    };
  }

  SqlTypeString copyWith({
    bool? variableSize,
    bool? binary,
    int? size,
    Option<String>? characterSet,
  }) {
    return SqlTypeString(
      variableSize: variableSize ?? this.variableSize,
      binary: binary ?? this.binary,
      size: size ?? this.size,
      characterSet:
          characterSet != null ? characterSet.valueOrNull : this.characterSet,
    );
  }
}

class SqlTypeEnumeration extends SqlType {
  final List<String> variants;
  final bool allowMultipleValues;
  final String? characterSet;

  const SqlTypeEnumeration({
    required this.variants,
    required this.allowMultipleValues,
    required this.characterSet,
  }) : super._();

  @override
  TypeSqlType get typeEnum => TypeSqlType.enumeration;

  static SqlTypeEnumeration fromJson(Map<String, dynamic> map) {
    return SqlTypeEnumeration(
      variants:
          (map['variants'] as List).map((Object? e) => e! as String).toList(),
      allowMultipleValues: map['allowMultipleValues'] as bool,
      characterSet: map['characterSet'] as String,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'runtimeType': 'enumeration',
      'variants': variants.map((e) => e).toList(),
      'allowMultipleValues': allowMultipleValues,
      'characterSet': characterSet,
    };
  }

  SqlTypeEnumeration copyWith({
    List<String>? variants,
    bool? allowMultipleValues,
    Option<String>? characterSet,
  }) {
    return SqlTypeEnumeration(
      variants: variants ?? this.variants,
      allowMultipleValues: allowMultipleValues ?? this.allowMultipleValues,
      characterSet:
          characterSet != null ? characterSet.valueOrNull : this.characterSet,
    );
  }
}

class SqlTypeInteger extends SqlType {
  final int bytes;
  final bool unsigned;
  final bool zerofill;

  const SqlTypeInteger({
    required this.bytes,
    required this.unsigned,
    required this.zerofill,
  }) : super._();

  @override
  TypeSqlType get typeEnum => TypeSqlType.integer;

  static SqlTypeInteger fromJson(Map<String, dynamic> map) {
    return SqlTypeInteger(
      bytes: map['bytes'] as int,
      unsigned: map['unsigned'] as bool,
      zerofill: map['zerofill'] as bool,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'runtimeType': 'integer',
      'bytes': bytes,
      'unsigned': unsigned,
      'zerofill': zerofill,
    };
  }

  SqlTypeInteger copyWith({
    int? bytes,
    bool? unsigned,
    bool? zerofill,
  }) {
    return SqlTypeInteger(
      bytes: bytes ?? this.bytes,
      unsigned: unsigned ?? this.unsigned,
      zerofill: zerofill ?? this.zerofill,
    );
  }
}

class SqlTypeDecimal extends SqlType {
  /// total number of digits (precision)
  final int digitsTotal;

  /// number of digits after the decimal point (scale)
  final int digitsDecimal;
  final bool unsigned;
  final bool zerofill;
  final SqlDecimalType type;

  static const defaultDigitsTotalFixed = 10;
  static const defaultDigitsTotalNotFixed = 65;
  static const defaultDigitsDecimalFixed = 0;
  static const defaultDigitsDecimalDouble = 15;
  static const defaultDigitsDecimalFloat = 7;

  const SqlTypeDecimal({
    required this.digitsTotal,
    required this.digitsDecimal,
    required this.unsigned,
    required this.zerofill,
    required this.type,
  }) : super._();

  @override
  TypeSqlType get typeEnum => TypeSqlType.decimal;

  static SqlTypeDecimal fromJson(Map<String, dynamic> map) {
    return SqlTypeDecimal(
      digitsTotal: map['digitsTotal'] as int,
      digitsDecimal: map['digitsDecimal'] as int,
      unsigned: map['unsigned'] as bool,
      zerofill: map['zerofill'] as bool,
      type: parseEnum(map['type'] as String, SqlDecimalType.values,
          caseSensitive: false)!,
    );
  }

  bool hasDefaultNumDigits() {
    return (type == SqlDecimalType.FIXED &&
            digitsTotal == SqlTypeDecimal.defaultDigitsTotalFixed &&
            digitsDecimal == SqlTypeDecimal.defaultDigitsDecimalFixed) ||
        (type == SqlDecimalType.DOUBLE &&
            digitsTotal == SqlTypeDecimal.defaultDigitsTotalNotFixed &&
            digitsDecimal == SqlTypeDecimal.defaultDigitsDecimalDouble) ||
        (type == SqlDecimalType.FLOAT &&
            digitsTotal == SqlTypeDecimal.defaultDigitsTotalNotFixed &&
            digitsDecimal == SqlTypeDecimal.defaultDigitsDecimalFloat);
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'runtimeType': 'decimal',
      'digitsTotal': digitsTotal,
      'digitsDecimal': digitsDecimal,
      'unsigned': unsigned,
      'zerofill': zerofill,
      'type': type.toEnumString(),
    };
  }

  SqlTypeDecimal copyWithDefaults() {
    return SqlTypeDecimal(
      digitsTotal: type == SqlDecimalType.FIXED
          ? defaultDigitsTotalFixed
          : defaultDigitsTotalNotFixed,
      digitsDecimal: type == SqlDecimalType.FIXED
          ? defaultDigitsDecimalFixed
          : type == SqlDecimalType.FLOAT
              ? defaultDigitsDecimalFloat
              : defaultDigitsDecimalDouble,
      unsigned: unsigned,
      zerofill: zerofill,
      type: type,
    );
  }

  SqlTypeDecimal copyWith({
    int? digitsTotal,
    int? digitsDecimal,
    bool? unsigned,
    bool? zerofill,
    SqlDecimalType? type,
  }) {
    return SqlTypeDecimal(
      digitsTotal: digitsTotal ?? this.digitsTotal,
      digitsDecimal: digitsDecimal ?? this.digitsDecimal,
      unsigned: unsigned ?? this.unsigned,
      zerofill: zerofill ?? this.zerofill,
      type: type ?? this.type,
    );
  }
}

class SqlTypeJson extends SqlType {
  const SqlTypeJson() : super._();

  @override
  TypeSqlType get typeEnum => TypeSqlType.json;

  static SqlTypeJson fromJson(Map<String, dynamic> map) {
    return const SqlTypeJson();
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'runtimeType': 'json',
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
