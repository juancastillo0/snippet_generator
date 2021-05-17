import 'package:snippet_generator/parsers/sql/bool_query_models.dart';
import 'package:snippet_generator/parsers/sql/comp_query_models.dart';

abstract class SqlValue<T> {
  const SqlValue();

  const factory SqlValue.raw(String raw) = SqlRawValue;
  static SqlValue<DateTime> dateTime(DateTime value) =>
      SqlDateValue.dateTime(value);
  static SqlValue<DateTime> date(DateTime value) => SqlDateValue.date(value);
  static SqlValue<DateTime> time(DateTime value) => SqlDateValue.time(value);
  static SqlValue<DateTime> year(DateTime value) => SqlDateValue.year(value);
  static SqlValue<List<int>> binary(List<int> value) => SqlBinaryValue(value);
  static SqlValue<String> string(String value) => SqlStringValue(value);
  static SqlValue<int> integer(int value) => SqlIntValue(value);
  static SqlValue<double> decimal(double value) => SqlDoubleValue(value);
  static SqlValue<String> json(String value) => SqlJsonValue(value);

  // ignore: prefer_void_to_null
  static const nullValue = SqlValue<Null>.raw('NULL');
  static const currentTimestamp = SqlValue<DateTime>.raw('CURRENT_TIMESTAMP()');
  static const currentDate = SqlValue<DateTime>.raw('CURRENT_DATE()');
  static const currentTime = SqlValue<DateTime>.raw('CURRENT_TIME()');

  String toSql();

  SqlIn<T> inList(List<SqlValue<T>> list) => SqlIn(this, list);

  SqlWhereModel different(SqlValue<T> other) =>
      SqlCompBinary(this, BinaryCompOperator.different, other);
  SqlWhereModel more(SqlValue<T> other) =>
      SqlCompBinary(this, BinaryCompOperator.more, other);
  SqlWhereModel less(SqlValue<T> other) =>
      SqlCompBinary(this, BinaryCompOperator.less, other);
  SqlWhereModel lessEq(SqlValue<T> other) =>
      SqlCompBinary(this, BinaryCompOperator.lessEq, other);
  SqlWhereModel moreEq(SqlValue<T> other) =>
      SqlCompBinary(this, BinaryCompOperator.moreEq, other);

  SqlWhereModel isNotNull() => SqlNullComp(this, negated: true);
  SqlWhereModel isNull() => SqlNullComp(this, negated: false);
}

class SqlRawValue<T> extends SqlValue<T> {
  final String raw;
  const SqlRawValue(this.raw);

  @override
  String toSql() {
    return raw;
  }
}

// class SqlDartValue<T> extends SqlValue<T> {
//   final T value;
//   SqlDartValue._(this.value)
//   : assert(T == String ||
//         T == int ||
//         T == num ||
//         T == double ||
//         T == DateTime ||
//         T == List ||
//         T == Map ||
//         T == Null)
//   ;

//   @override
//   String toSql() {
//     return value == null ? 'NULL' : value.toString();
//   }
// }

// class SqlListValue<T> {
//   final List<SqlValue<T>> list;
//   const SqlListValue(this.list);

//   String toSql() {
//     return '()';
//   }
// }

class SqlStringValue extends SqlValue<String> {
  final String value;
  const SqlStringValue(this.value);

  @override
  String toSql() => "'$value'";
}

class SqlIntValue extends SqlValue<int> {
  final int value;
  const SqlIntValue(this.value);

  @override
  String toSql() => value.toString();
}

class SqlDoubleValue extends SqlValue<double> {
  final double value;
  const SqlDoubleValue(this.value);

  @override
  String toSql() => value.toString();
}

class SqlJsonValue extends SqlValue<String> {
  final String value;
  const SqlJsonValue(this.value);

  @override
  String toSql() => "'$value'";
}

enum SqlDateVariant {
  dateTime,
  date,
  time,
  year,
}

class SqlDateValue extends SqlValue<DateTime> {
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
        return "'${value.year.toString()}'";
    }
  }
}

class SqlBinaryValue extends SqlValue<List<int>> {
  final List<int> value;
  const SqlBinaryValue(this.value);

  @override
  String toSql() {
    return value.toString();
  }
}
