import 'package:snippet_generator/database/models/sql_values.dart';

class SqlAggCompValue<T extends SqlValue<T>> extends SqlValue<T> {
  final List<SqlValue<T>> values;
  final bool greatest;
  final bool nullWithAnyNull;

  const SqlAggCompValue(
    this.values, {
    required this.greatest,
    required this.nullWithAnyNull,
  });

  const SqlAggCompValue.greatest(this.values, {required this.nullWithAnyNull})
      : greatest = true;

  const SqlAggCompValue.least(this.values, {required this.nullWithAnyNull})
      : greatest = false;

  @override
  String toSql() {
    const isMysql = true;
    final _func = greatest ? 'GREATEST' : 'LEAST';

    if (isMysql && nullWithAnyNull || !isMysql && !nullWithAnyNull) {
      return "$_func(${values.map((e) => e.toSql()).join(',')})";
    } else if (isMysql && !nullWithAnyNull) {
      final _coalesced = SqlValue.coalesce(values);

      final _d = SqlIfValue<T>(
        _coalesced.isNull(),
        whenTrue: const SqlValue.nullValue(),
        whenFalse: SqlValue.raw(
          "$_func(${values.map((e) => e.ifNull(_coalesced).toSql()).join(',')})",
        ),
      );

      return _d.toSql();
    } else if (!isMysql && nullWithAnyNull) {
      const SqlValue<SqlNumValue> _null = SqlNullValue();
      const SqlValue<SqlNumValue> _val = SqlIntValue(1);

      final _coalesced = SqlValue<SqlNumValue>.coalesce([
        ...values.map((v) => SqlIfValue(
              v.isNull(),
              whenTrue: _val,
              whenFalse: _null,
            ))
      ]);

      final _d = SqlIfValue<T>(
        _coalesced.isNotNull(),
        whenTrue: const SqlValue.nullValue(),
        whenFalse: SqlValue.raw(
          "($_func(${values.map((e) => e.toSql()).join(',')}))",
        ),
      );

      return _d.toSql();
    } else {
      throw FallThroughError();
    }
  }
}

class SqlCoalesceValue<T extends SqlValue<T>> extends SqlValue<T> {
  final List<SqlValue<T>> values;

  const SqlCoalesceValue(this.values);

  @override
  String toSql() {
    return "COALESCE(${values.map((e) => e.toSql()).join(',')})";
  }
}

class SqlIfValue<T extends SqlValue<T>> extends SqlValue<T> {
  final SqlBoolValue conditions;
  final SqlValue<T> whenTrue;
  final SqlValue<T> whenFalse;

  const SqlIfValue(
    this.conditions, {
    required this.whenTrue,
    required this.whenFalse,
  });

  @override
  String toSql() {
    return """
CASE
WHEN ${conditions.toSql()} THEN ${whenTrue.toSql()}
ELSE ${whenFalse.toSql()}
END
""";
  }
}

class SqlCaseValue<T extends SqlValue<T>> extends SqlValue<T> {
  final List<MapEntry<SqlBoolValue, SqlValue<T>>> conditions;
  final SqlValue<T>? elseValue;

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
