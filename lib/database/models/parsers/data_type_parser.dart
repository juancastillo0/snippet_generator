import 'dart:math';

import 'package:petitparser/petitparser.dart';
import 'package:snippet_generator/parsers/parsers.dart';
import 'package:snippet_generator/utils/extensions.dart';

import 'create_table_parser.dart';
import 'data_type_model.dart';

Parser<String> _token(String str) {
  return stringIgnoreCase(str).trim();
}

final sqlDataTypeParser = (_numericTypeParser |
        _dateTypeParser |
        _stringTypeParser |
        _token('JSON').map<SqlType>((value) => const SqlType.json()))
    .cast<SqlType>();

final _numericTypeParser = ((((stringIgnoreCase('TINY') |
                        stringIgnoreCase('SMALL') |
                        stringIgnoreCase('MEDIUM') |
                        stringIgnoreCase('BIG'))
                    .optional() &
                stringIgnoreCase('INT') &
                parens(unsignedIntParser).optional()) |
            ((_token('DOUBLE') & _token('PRECISION').optional()).pick(0) |
                    _token('REAL') |
                    _token('FLOAT') |
                    _token('DEC') |
                    _token('NUMERIC') |
                    _token('FIXED') |
                    _token('DECIMAL')) &
                parens(unsignedIntParser &
                        (char(',').trim() & unsignedIntParser).optional())
                    .optional()) &
        _token('UNSIGNED').optional() &
        _token('ZEROFILL').optional())
    .map((value) {
  final Object? props = value[0];
  final unsigned = value[value.length - 2] != null;
  final zerofill = value[value.length - 1] != null;

  if (props is List && props[1] is String) {
    final variant = (props[0] as String? ?? '').toUpperCase();

    return SqlType.integer(
      bytes: SqlType.sqlIntegerBytes[variant]!,
      unsigned: unsigned,
      zerofill: zerofill,
    );
  } else {
    final key = ((props is List ? props[0] : props) as String).toUpperCase();
    final fixed = const [
      'DEC',
      'NUMERIC',
      'FIXED',
      'DECIMAL',
    ].contains(key);
    final float = 'FLOAT' == key;

    final digits = (props is List ? props[1] as List? : null) ??
        <Object?>[
          null,
          [null, null]
        ];

    return SqlType.decimal(
      type: fixed
          ? SqlDecimalType.FIXED
          : (float ? SqlDecimalType.FLOAT : SqlDecimalType.DOUBLE),
      digitsTotal: digits[0] as int? ??
          (fixed
              ? SqlTypeDecimal.defaultDigitsTotalFixed
              : SqlTypeDecimal.defaultDigitsTotalNotFixed),
      digitsDecimal: (digits[1]! as List)[1] as int? ??
          (fixed
              ? SqlTypeDecimal.defaultDigitsDecimalFixed
              : float
                  ? SqlTypeDecimal.defaultDigitsDecimalFloat
                  : SqlTypeDecimal.defaultDigitsDecimalDouble),
      unsigned: unsigned,
      zerofill: zerofill,
    );
  }
});

final _dateTypeParser =
    ((_token('TIMESTAMP') | _token('TIME') | _token('DATETIME')) &
                parens(pattern('0-6')).optional() |
            _token('DATE') |
            _token('YEAR'))
        .map((Object? value) {
  final String rawType;
  final int? fractionalSeconds;
  if (value is List) {
    rawType = value[0] as String;
    fractionalSeconds = value[1] == null ? null : int.parse(value[1] as String);
  } else {
    rawType = value as String;
    fractionalSeconds = null;
  }
  final type = parseEnum(rawType, SqlDateVariant.values, caseSensitive: false)!;

  return SqlType.date(type: type, fractionalSeconds: fractionalSeconds);
});

final _stringTypeParser = (((_token('CHAR') |
                    _token('BINARY') |
                    _token('BLOB') |
                    _token('TEXT')) &
                parens(unsignedIntParser).optional() |
            (_token('VARCHAR') | _token('VARBINARY')) &
                parens<int>(unsignedIntParser) |
            _token('TINYTEXT') |
            _token('MEDIUMTEXT') |
            _token('LONGTEXT') |
            _token('TINYBLOB') |
            _token('MEDIUMBLOB') |
            _token('LONGBLOB') |
            (_token('ENUM') | _token('SET')) &
                parens<List<String>>(sqlStringLiteral.separatedBy<String>(
                    char(',').trim(),
                    includeSeparators: false))) &
        (_token('CHARACTER') & _token('SET') & word().plus().flatten().trim())
            .optional() &
        collateParser.optional())
    .map((value) {
  final Object? props = value[0];
  final characterSet =
      value[1] == null ? null : (value[1] as List)[2] as String;
  final collation = value[2] as String?;

  final String key;
  final int? size;
  if (props is List) {
    key = props[0] as String;
    final Object? _p = props[1];
    if (_p is List) {
      return SqlType.enumeration(
        variants: _p.cast(),
        allowMultipleValues: key.toUpperCase() == 'SET',
        characterSet: characterSet,
      );
    } else {
      size = _p as int?;
    }
  } else {
    key = props as String;
    size = null;
  }

  const _m = {
    'TINY': 8,
    '': 16,
    'MEDIUM': 24,
    'LONG': 32,
  };
  final _keyUpper = key.toUpperCase();

  return SqlType.string(
    variableSize: !const ['CHAR', 'BINARY'].contains(_keyUpper),
    binary: _keyUpper.contains(RegExp('BLOB|BINARY')),
    size: size ??
        (pow(2, _m[_keyUpper.replaceAll(RegExp('BLOB|TEXT'), '')] ?? 1) - 1)
            .toInt(),
    characterSet: characterSet,
  );
});
