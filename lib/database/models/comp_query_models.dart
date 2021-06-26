import 'package:snippet_generator/database/models/bool_query_models.dart';
import 'package:snippet_generator/database/models/sql_values.dart';

enum BinaryCompOperator {
  eq,
  different,
  more,
  less,
  lessEq,
  moreEq,
}

extension ToSqlBinaryComp on BinaryCompOperator {
  String toSql() {
    switch (this) {
      case BinaryCompOperator.more:
        return '>';
      case BinaryCompOperator.moreEq:
        return '>=';
      case BinaryCompOperator.less:
        return '<';
      case BinaryCompOperator.lessEq:
        return '<=';
      case BinaryCompOperator.eq:
        return '=';
      case BinaryCompOperator.different:
        return '<>';
    }
  }
}

class SqlNullComp<T extends SqlValue<T>> extends SqlBoolValue {
  final SqlValue<T> value;
  final bool negated;

  const SqlNullComp(this.value, {required this.negated});

  @override
  String toSql(SqlContext ctx) {
    return '(${value.toSql(ctx)} IS ${negated ? "NOT " : ""}NULL)';
  }
}

class SqlCompBinary<T extends SqlValue<T>> extends SqlBoolValue {
  final SqlValue<T> left;
  final SqlValue<T> right;
  final BinaryCompOperator op;

  const SqlCompBinary(this.left, this.op, this.right);

  @override
  String toSql(SqlContext ctx) {
    return '(${left.toSql(ctx)} ${op.toSql()} ${right.toSql(ctx)})';
  }
}

class SqlIn<T extends SqlValue<T>> extends SqlBoolValue {
  final SqlValue<T> value;
  final List<SqlValue<T>> list;

  const SqlIn(this.value, this.list);

  @override
  String toSql(SqlContext ctx) {
    return '(${value.toSql(ctx)} '
        'IN (${list.map((e) => e.toSql(ctx)).join(",")}))';
  }
}
