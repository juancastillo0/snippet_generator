// ignore_for_file: missing_whitespace_between_adjacent_strings
import '../parsers/table_models.dart';

class SqlTableSqlTemplate {
  final SqlTable table;

  const SqlTableSqlTemplate({required this.table});

  String toSql() {
    return """
CREATE TABLE ${table.name} (
${table.columns.map(colToSql).join(',\n')}${_primaryKey()}${table.foreignKeys.map(_foreignKey).join()}${table.tableKeys.map(_tableKeys).join()}
);
""";
  }

  String colToSql(SqlColumn col) {
    return '${col.name} ${col.type.toSql()} ${col.nullable ? "NULL" : "NOT NULL"}'
        '${col.defaultValue == null ? "" : " DEFAULT ${col.defaultValue}"}${!col.visible ? " INVISIBLE" : ""}'
        '${col.autoIncrement ? " AUTO_INCREMENT" : ""}${col.unique ? " UNIQUE" : ""}${col.primary ? " PRIMARY KEY" : ""}';
  }

  String _primaryKey() {
    final key = table.primaryKey;
    if (key == null) {
      return '';
    }
    return ',\n${_constraintName(key.constraintName)}PRIMARY KEY USING ${key.indexType.toJson()} '
        '${_colsRef(key.columns)}';
  }

  String _foreignKey(SqlForeignKey key) {
    return ',\n${_constraintName(key.constraintName)}FOREIGN KEY ${_indexName(key.indexName)}'
            '(${key.ownColumns.join(",")}) REFERENCES ${key.reference.referencedTable} ${_colsRef(key.reference.columns)}'
        // '${key.reference.matchType == null ? "" : " MATCH ${key.reference.matchType!.toJson}"}'
        ;
  }

  String _constraintName(String? name) {
    if (name == null) {
      return '';
    }
    return 'CONSTRAINT $name ';
  }

  String _indexName(String? name) {
    if (name == null) {
      return '';
    }
    return '$name ';
  }

  String _tableKeys(SqlTableKey key) {
    if (key.primary) {
      return '';
    }
    switch (key.indexType) {
      case SqlIndexType.FULLTEXT:
      case SqlIndexType.SPATIAL:
        return ',\n${key.indexType.toJson()} ${_indexName(key.indexName)}${_colsRef(key.columns)}';
      case SqlIndexType.HASH:
      case SqlIndexType.BTREE:
        if (key.unique) {
          return ',\n${_constraintName(key.constraintName)}UNIQUE ${_indexName(key.indexName)}USING ${key.indexType.toJson()} ${_colsRef(key.columns)}';
        }
        return ',\nINDEX ${_indexName(key.indexName)}USING ${key.indexType.toJson()} ${_colsRef(key.columns)}';
    }
  }

  String _colsRef(List<SqlKeyItem> columns) {
    return '(${columns.map((e) => "${e.columnName}${e.ascendent ? '' : ' DESC'}").join(",")})';
  }
}
