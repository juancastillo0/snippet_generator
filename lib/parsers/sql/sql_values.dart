import 'package:snippet_generator/parsers/sql/bool_query_models.dart';
import 'package:snippet_generator/parsers/sql/comp_query_models.dart';

abstract class SqlValue<T extends SqlValue<T>> {
  const SqlValue();

  const factory SqlValue.raw(String raw) = SqlRawValue;
  const factory SqlValue.rawFn(String Function() raw) = SqlRawFuncValue;
  const factory SqlValue.caseWhen(
    List<MapEntry<SqlBoolValue, T>> conditions, {
    T? elseValue,
  }) = SqlCaseValue;
  static SqlDateValue dateTime(DateTime value) => SqlDateValue.dateTime(value);
  static SqlDateValue date(DateTime value) => SqlDateValue.date(value);
  static SqlDateValue time(DateTime value) => SqlDateValue.time(value);
  static SqlDateValue year(DateTime value) => SqlDateValue.year(value);
  static SqlBinaryValue binary(List<int> value) => SqlBinaryValue(value);
  static SqlStringValue string(String value) => SqlStringValue(value);
  static SqlIntValue integer(int value) => SqlIntValue(value);
  static SqlDoubleValue decimal(double value) => SqlDoubleValue(value);
  static SqlJsonValue json(String value) => SqlJsonValue(value);

  // ignore: prefer_void_to_null
  static const nullValue = SqlNullValue();
  static const currentTimestamp =
      SqlValue<SqlDateValue>.raw('CURRENT_TIMESTAMP()');
  static const currentDate = SqlValue<SqlDateValue>.raw('CURRENT_DATE()');
  static const currentTime = SqlValue<SqlDateValue>.raw('CURRENT_TIME()');

  String toSql();

  SqlBoolValue inList(List<SqlValue<T>> list) => SqlIn(this, list);

  SqlBoolValue equalTo(SqlValue<T> other) =>
      SqlCompBinary(this, BinaryCompOperator.eq, other);
  SqlBoolValue differentFrom(SqlValue<T> other) =>
      SqlCompBinary(this, BinaryCompOperator.different, other);
  SqlBoolValue moreThan(SqlValue<T> other) =>
      SqlCompBinary(this, BinaryCompOperator.more, other);
  SqlBoolValue lessThan(SqlValue<T> other) =>
      SqlCompBinary(this, BinaryCompOperator.less, other);
  SqlBoolValue lessOrEqualTo(SqlValue<T> other) =>
      SqlCompBinary(this, BinaryCompOperator.lessEq, other);
  SqlBoolValue moreOrEqualTo(SqlValue<T> other) =>
      SqlCompBinary(this, BinaryCompOperator.moreEq, other);

  SqlBoolValue isNotNull() => SqlNullComp(this, negated: true);
  SqlBoolValue isNull() => SqlNullComp(this, negated: false);
}

class SqlCaseValue<T extends SqlValue<T>> extends SqlValue<T> {
  final List<MapEntry<SqlBoolValue, T>> conditions;
  final T? elseValue;

  const SqlCaseValue(this.conditions, {this.elseValue});

  @override
  String toSql() {
    return """
CASE
${conditions.map((e) => 'WHEN ${e.key.toSql()} THEN ${e.value.toSql()}')}
ELSE ${elseValue == null ? 'NULL' : elseValue!.toSql()}
END
""";
  }
}

class SqlRawValue<T extends SqlValue<T>> extends SqlValue<T> {
  final String raw;
  const SqlRawValue(this.raw);

  @override
  String toSql() {
    return raw;
  }
}

class SqlRawFuncValue<T extends SqlValue<T>> extends SqlValue<T> {
  final String Function() rawFn;
  const SqlRawFuncValue(this.rawFn);

  @override
  String toSql() {
    return rawFn();
  }
}

class SqlNullValue extends SqlValue<SqlNullValue> {
  const SqlNullValue();

  @override
  String toSql() => 'NULL';
}

class SqlStringValue extends SqlValue<SqlStringValue> {
  final String value;
  const SqlStringValue(this.value);

  @override
  String toSql() => "'$value'";
}

abstract class SqlNumValue extends SqlValue<SqlNumValue> {
  const SqlNumValue();
}

extension SqlNumValueExt on SqlValue<SqlNumValue> {
  SqlNumOpValue plus(SqlValue<SqlNumValue> other) =>
      SqlNumOpValue(this, NumOperation.plus, other);
  SqlNumOpValue minus(SqlValue<SqlNumValue> other) =>
      SqlNumOpValue(this, NumOperation.minus, other);
  SqlNumOpValue times(SqlValue<SqlNumValue> other) =>
      SqlNumOpValue(this, NumOperation.times, other);
  SqlNumOpValue divided(SqlValue<SqlNumValue> other) =>
      SqlNumOpValue(this, NumOperation.divided, other);
  SqlNumOpValue modulo(SqlValue<SqlNumValue> other) =>
      SqlNumOpValue(this, NumOperation.modulo, other);
}

enum NumOperation {
  plus,
  minus,
  times,
  divided,
  modulo,
}

extension NumOperationExt on NumOperation {
  String toSql() {
    switch (this) {
      case NumOperation.plus:
        return '+';
      case NumOperation.minus:
        return '-';
      case NumOperation.times:
        return '*';
      case NumOperation.divided:
        return '/';
      case NumOperation.modulo:
        return '%';
    }
  }
}

class SqlNumOpValue extends SqlNumValue {
  final SqlValue<SqlNumValue> left;
  final NumOperation operation;
  final SqlValue<SqlNumValue> right;
  const SqlNumOpValue(this.left, this.operation, this.right);

  @override
  String toSql() {
    return '(${left.toSql()} ${operation.toSql()} ${right.toSql()})';
  }
}

class SqlIntValue extends SqlNumValue {
  final int value;
  const SqlIntValue(this.value);

  @override
  String toSql() => value.toString();
}

class SqlDoubleValue extends SqlNumValue {
  final double value;
  const SqlDoubleValue(this.value);

  @override
  String toSql() => value.toString();
}

class SqlJsonValue extends SqlValue<SqlJsonValue> {
  final String value;
  const SqlJsonValue(this.value);

  @override
  String toSql() => "'$value'";
}

extension SqlJsonValueExt on SqlValue<SqlJsonValue> {
  SqlValue<SqlJsonValue> extract(String path) {
    return SqlValue.rawFn(() => '${toSql()}->>$path');
  }
}

enum SqlDateVariant {
  dateTime,
  date,
  time,
  year,
}

class SqlDateValue extends SqlValue<SqlDateValue> {
  final DateTime value;
  final SqlDateVariant variant;
  const SqlDateValue(this.value, this.variant);

  const SqlDateValue.dateTime(this.value) : variant = SqlDateVariant.dateTime;
  const SqlDateValue.date(this.value) : variant = SqlDateVariant.date;
  const SqlDateValue.time(this.value) : variant = SqlDateVariant.time;
  const SqlDateValue.year(this.value) : variant = SqlDateVariant.year;

  @override
  String toSql() {
    switch (variant) {
      case SqlDateVariant.dateTime:
        return "'${value.toString()}'";
      case SqlDateVariant.date:
        return "'${value.toString().split(' ')[0]}'";
      case SqlDateVariant.time:
        return "'${value.toString().split(' ')[1]}'";
      case SqlDateVariant.year:
        return value.year.toString();
    }
  }
}

class SqlBinaryValue extends SqlValue<SqlBinaryValue> {
  final List<int> value;
  const SqlBinaryValue(this.value);

  @override
  String toSql() {
    return value.toString();
  }
}

extension IntSql on int {
  SqlIntValue get sql => SqlIntValue(this);
}

extension DoubleSql on double {
  SqlDoubleValue get sql => SqlDoubleValue(this);
}

extension NumSql on num {
  SqlNumValue get sql =>
      this is int ? SqlIntValue(this as int) : SqlDoubleValue(this as double);
}

extension StringSql on String {
  SqlStringValue get sql => SqlStringValue(this);
}

extension BinarySql on List<int> {
  SqlBinaryValue get sql => SqlBinaryValue(this);
}

extension DateTimeSql on DateTime {
  SqlDateValue get sqlDateTime => SqlValue.dateTime(this);
  SqlDateValue get sqlDate => SqlValue.date(this);
  SqlDateValue get sqlTime => SqlValue.time(this);
  SqlDateValue get sqlYear => SqlValue.year(this);
}
