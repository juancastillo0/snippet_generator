enum SqlDatabase {
  mysql,
  postgres,
}

abstract class TransactionContext implements TableConnection {
  Never rollback();
}

class SqlQuery {
  final String query;
  final List<String> params;

  const SqlQuery(this.query, this.params);
}

abstract class TableConnection {
  SqlDatabase get database;

  Future<SqlQueryResult> query(
    String sqlQuery, [
    List<Object?>? values,
  ]);

  Future<Object?> transaction(
    Future<void> Function(TransactionContext context) transactionFn,
  );
}

abstract class SqlQueryResult implements Iterable<List<Object?>> {
  int? get affectedRows;
}
