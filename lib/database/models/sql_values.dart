import 'package:snippet_generator/database/models/bool_query_models.dart';
import 'package:snippet_generator/database/models/collect_query_models.dart';
import 'package:snippet_generator/database/models/comp_query_models.dart';
import 'package:snippet_generator/database/models/connection_models.dart';

export 'package:snippet_generator/database/models/bool_query_models.dart';
export 'package:snippet_generator/database/models/collect_query_models.dart';
export 'package:snippet_generator/database/models/comp_query_models.dart';
export 'package:snippet_generator/database/models/connection_models.dart';
export 'package:snippet_generator/database/models/order_query_models.dart';

class SqlContext {
  final SqlDatabase database;
  final List<String> variables = [];
  final bool unsafe;

  SqlContext({required this.database, this.unsafe = false});

  String addString(String value) {
    if (unsafe) {
      return "'$value'";
    }
    variables.add("'$value'");
    return database == SqlDatabase.mysql ? '?' : '\$${variables.length}';
  }
}

abstract class SqlGenerator {
  String toSql(SqlContext ctx);
}

abstract class SqlValue<T extends SqlValue<T>> implements SqlGenerator {
  const SqlValue();

  const factory SqlValue.raw(String raw) = SqlRawValue;
  const factory SqlValue.rawFn(String Function(SqlContext ctx) raw) =
      SqlRawFuncValue;
  const factory SqlValue.coalesce(List<SqlValue<T>> values) = SqlCoalesceValue;
  const factory SqlValue.caseWhen(
    List<MapEntry<SqlBoolValue, T>> conditions, {
    T? elseValue,
  }) = SqlCaseValue;
  const factory SqlValue.greatest(List<SqlValue<T>> values,
      {required bool nullWithAnyNull}) = SqlAggCompValue.greatest;
  const factory SqlValue.least(List<SqlValue<T>> values,
      {required bool nullWithAnyNull}) = SqlAggCompValue.least;
  const factory SqlValue.nullValue() = SqlNullValue;

  static SqlDateValue dateTime(DateTime value) => SqlDateValue.dateTime(value);
  static SqlDateValue date(DateTime value) => SqlDateValue.date(value);
  static SqlDateValue time(DateTime value) => SqlDateValue.time(value);
  static SqlDateValue year(DateTime value) => SqlDateValue.year(value);
  static SqlBinaryValue binary(List<int> value) => SqlBinaryValue(value);
  static SqlStringValue string(String value) => SqlStringValue(value);
  static SqlIntValue integer(int value) => SqlIntValue(value);
  static SqlDoubleValue decimal(double value) => SqlDoubleValue(value);
  static SqlJsonValue json(String value) => SqlJsonValue(value);

  static const currentTimestamp =
      SqlValue<SqlDateValue>.raw('CURRENT_TIMESTAMP()');
  static const currentDate = SqlValue<SqlDateValue>.raw('CURRENT_DATE()');
  static const currentTime = SqlValue<SqlDateValue>.raw('CURRENT_TIME()');

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
  SqlValue<T> ifNull(SqlValue<T> value) => SqlCoalesceValue([this, value]);
}

class SqlRawValue<T extends SqlValue<T>> extends SqlValue<T> {
  final String raw;
  const SqlRawValue(this.raw);

  @override
  String toSql(SqlContext ctx) {
    return raw;
  }
}

class SqlRawFuncValue<T extends SqlValue<T>> extends SqlValue<T> {
  final String Function(SqlContext ctx) rawFn;
  const SqlRawFuncValue(this.rawFn);

  @override
  String toSql(SqlContext ctx) {
    return rawFn(ctx);
  }
}

class SqlNullValue<T extends SqlValue<T>> extends SqlValue<T> {
  const SqlNullValue();

  @override
  String toSql(SqlContext ctx) => 'NULL';
}

class SqlStringValue extends SqlValue<SqlStringValue> {
  final String value;
  const SqlStringValue(this.value);

  @override
  String toSql(SqlContext ctx) {
    return ctx.addString(value);
  }
}

extension SqlStringValueExt on SqlValue<SqlStringValue> {
  SqlValue<SqlBoolValue> like(String pattern) {
    return SqlBoolLikeValue(this, pattern);
  }
}

class SqlBoolLikeValue extends SqlBoolValue {
  final SqlValue<SqlStringValue> value;
  final String pattern;
  const SqlBoolLikeValue(this.value, this.pattern);

  @override
  String toSql(SqlContext ctx) {
    return "(${value.toSql(ctx)} LIKE ${ctx.addString(pattern)})";
  }
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
  String toSql(SqlContext ctx) {
    return '(${left.toSql(ctx)} ${operation.toSql()} ${right.toSql(ctx)})';
  }
}

class SqlIntValue extends SqlNumValue {
  final int value;
  const SqlIntValue(this.value);

  @override
  String toSql(SqlContext ctx) => value.toString();
}

class SqlDoubleValue extends SqlNumValue {
  final double value;
  const SqlDoubleValue(this.value);

  @override
  String toSql(SqlContext ctx) => value.toString();
}

class SqlJsonValue extends SqlValue<SqlJsonValue> {
  final String value;
  const SqlJsonValue(this.value);

  @override
  String toSql(SqlContext ctx) => ctx.addString(value);
}

extension SqlJsonValueExt on SqlValue<SqlJsonValue> {
  SqlValue<SqlJsonValue> extract(String path) {
    return SqlValue.rawFn((ctx) => '${toSql(ctx)}->>$path');
  }
}

enum SqlDateType {
  dateTime,
  date,
  time,
  year,
}

class SqlDateValue extends SqlValue<SqlDateValue> {
  final DateTime value;
  final SqlDateType variant;
  const SqlDateValue(this.value, this.variant);

  const SqlDateValue.dateTime(this.value) : variant = SqlDateType.dateTime;
  const SqlDateValue.date(this.value) : variant = SqlDateType.date;
  const SqlDateValue.time(this.value) : variant = SqlDateType.time;
  const SqlDateValue.year(this.value) : variant = SqlDateType.year;

  @override
  String toSql(SqlContext ctx) {
    switch (variant) {
      case SqlDateType.dateTime:
        return "'${value.toString()}'";
      case SqlDateType.date:
        return "'${value.toString().split(' ')[0]}'";
      case SqlDateType.time:
        return "'${value.toString().split(' ')[1]}'";
      case SqlDateType.year:
        return value.year.toString();
    }
  }
}

class SqlBinaryValue extends SqlValue<SqlBinaryValue> {
  final List<int> value;
  const SqlBinaryValue(this.value);

  @override
  String toSql(SqlContext ctx) {
    // TODO:
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
