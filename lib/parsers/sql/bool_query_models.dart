abstract class SqlWhereModel {
  const SqlWhereModel();

  const factory SqlWhereModel.rawSql(String sql) = SqlWhereRaw;

  SqlWhereModel and(SqlWhereModel other) =>
      _SqBoolOp(BoolOperand.and, [this, other]);

  SqlWhereModel or(SqlWhereModel other) =>
      _SqBoolOp(BoolOperand.or, [this, other]);

  SqlWhereModel neg() => _SqlNegOp(this);

  String toSql();
}

// BETWEEN
// EXISTS
// LIKE

class SqlWhereRaw extends SqlWhereModel {
  final String rawSql;

  const SqlWhereRaw(this.rawSql);

  @override
  String toSql() => rawSql;
}

enum BoolOperand {
  and,
  or,
}

class _SqBoolOp extends SqlWhereModel {
  final List<SqlWhereModel> operands;
  final BoolOperand op;

  const _SqBoolOp(this.op, this.operands);

  @override
  SqlWhereModel and(SqlWhereModel other) {
    if (op == BoolOperand.and) {
      operands.add(other);
      return this;
    } else {
      return super.and(other);
    }
  }

  @override
  SqlWhereModel or(SqlWhereModel other) {
    if (op == BoolOperand.or) {
      operands.add(other);
      return this;
    } else {
      return super.or(other);
    }
  }

  @override
  String toSql() {
    return '(' +
        operands
            .map((e) => e.toSql())
            .join(op == BoolOperand.or ? ' OR ' : ' AND ') +
        ')';
  }
}

class _SqlNegOp extends SqlWhereModel {
  final SqlWhereModel inner;

  const _SqlNegOp(this.inner);

  @override
  SqlWhereModel neg() {
    return inner;
  }

  @override
  String toSql() {
    return '(NOT ${inner.toSql()})';
  }
}
