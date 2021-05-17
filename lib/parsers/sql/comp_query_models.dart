import 'package:snippet_generator/parsers/sql/bool_query_models.dart';
import 'package:snippet_generator/parsers/sql/sql_values.dart';

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
  String toSql() {
    return '(${value.toSql()} IS ${negated ? "NOT " : ""}NULL)';
  }
}

class SqlCompBinary<T extends SqlValue<T>> extends SqlBoolValue {
  final SqlValue<T> left;
  final SqlValue<T> right;
  final BinaryCompOperator op;

  const SqlCompBinary(this.left, this.op, this.right);

  @override
  String toSql() {
    return '(${left.toSql()} ${op.toSql()} ${right.toSql()})';
  }
}

class SqlIn<T extends SqlValue<T>> extends SqlBoolValue {
  final SqlValue<T> value;
  final List<SqlValue<T>> list;

  const SqlIn(this.value, this.list);

  @override
  String toSql() {
    return '(${value.toSql()} IN (${list.map((e) => e.toSql()).join(",")}))';
  }
}
