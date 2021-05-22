import 'package:snippet_generator/database/models/sql_values.dart';

abstract class SqlBoolValue extends SqlValue<SqlBoolValue> {
  const SqlBoolValue();

  const factory SqlBoolValue.rawSql(String sql) = SqlWhereRaw;
  static const SqlValue<SqlBoolValue> trueValue = SqlWhereRaw('TRUE');
  static const SqlValue<SqlBoolValue> falseValue = SqlWhereRaw('FALSE');
}

extension SqlBoolValueExt on SqlValue<SqlBoolValue> {
  SqlValue<SqlBoolValue> and(SqlValue<SqlBoolValue> other) =>
      _SqBoolOp(BoolOperator.and, [this, other]);

  SqlValue<SqlBoolValue> or(SqlValue<SqlBoolValue> other) =>
      _SqBoolOp(BoolOperator.or, [this, other]);

  SqlValue<SqlBoolValue> neg() => _SqlNegOp(this);
}

// BETWEEN
// EXISTS

class SqlWhereRaw extends SqlBoolValue {
  final String rawSql;

  const SqlWhereRaw(this.rawSql);

  @override
  String toSql() => rawSql;
}

enum BoolOperator {
  and,
  or,
}

class _SqBoolOp extends SqlBoolValue {
  final List<SqlValue<SqlBoolValue>> operands;
  final BoolOperator op;

  const _SqBoolOp(this.op, this.operands);

  // @override
  // SqlBoolValue and(SqlBoolValue other) {
  //   if (op == BoolOperator.and) {
  //     return _SqBoolOp(op, [...operands, other]);
  //   } else {
  //     return super.and(other);
  //   }
  // }

  // @override
  // SqlBoolValue or(SqlBoolValue other) {
  //   if (op == BoolOperator.or) {
  //     return _SqBoolOp(op, [...operands, other]);
  //   } else {
  //     return super.or(other);
  //   }
  // }

  @override
  String toSql() {
    return '(' +
        operands
            .map((e) => e.toSql())
            .join(op == BoolOperator.or ? ' OR ' : ' AND ') +
        ')';
  }
}

class _SqlNegOp extends SqlBoolValue {
  final SqlValue<SqlBoolValue> inner;

  const _SqlNegOp(this.inner);

  // @override
  // SqlBoolValue neg() {
  //   return inner;
  // }

  @override
  String toSql() {
    return '(NOT ${inner.toSql()})';
  }
}
