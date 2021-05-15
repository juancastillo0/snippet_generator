import 'package:dart_style/dart_style.dart';
import 'package:snippet_generator/parsers/sql/data_type_model.dart';
import 'package:snippet_generator/parsers/sql/table_models.dart';
import 'package:snippet_generator/utils/extensions.dart';

class SqlTableTemplate {
  final SqlTable table;

  final _formatter = DartFormatter();

  SqlTableTemplate({required this.table});

  String dartClass(List<SqlTable> allTables) {
    final mapAllTables = allTables.fold<Map<String, SqlTable>>(
        {}, (value, element) => value..set(element.name, element));

    String sourceCode = """
import 'dart:convert';

abstract class TransactionContext implements TableConnection {
  Never rollback();
}

abstract class TableConnection {
  Future<SqlQueryResult> query(String sqlQuery, [List<Object?>? values,]);

  Future<Object?> transaction(Future<void> Function(TransactionContext context) transactionFn,);
}

abstract class SqlQueryResult implements Iterable<List<Object?>> {
  int? get affectedRows;
}


class $className{
  ${table.columns.map((e) => 'final ${_dartType(e.type, nullable: e.nullable)} ${e.name.snakeToCamel()};').join()}

  ${table.foreignKeys.map((e) => 'final List<${e.reference.className}>? ref${e.reference.className};').join()}

  final Map<String, Object?> additionalInfo;

  const $className({
    ${table.columns.map((e) => '${e.nullable ? "" : "required "}this.${e.name.snakeToCamel()},').join()}
    ${table.foreignKeys.map((e) => 'this.ref${e.reference.className},').join()}
    this.additionalInfo = const {},
  });

  factory $className.fromJson(dynamic json) {
    final Map map;
    if (json is Map) {
      map = json;
    } else if (json is String) {
      map = jsonDecode(json) as Map;
    } else if (json is $className) {
      return json;
    } else {
      throw Error();
    }

    return $className(
      ${table.columns.map((e) => '${e.name.snakeToCamel()}:map["${e.name.snakeToCamel()}"] as ${_dartType(e.type, nullable: e.nullable)},').join()}
      ${table.foreignKeys.map((e) => "ref${e.reference.className}: ${joinFromJsonList(e, 'map["ref${e.reference.className}"]')},").join()}
    );
  }

  String insertShallowSql() {
    return \"""
INSERT INTO ${table.name}(${table.columns.map((e) => e.name).join(',')})
VALUES (${table.columns.map((e) => '\$${e.name.snakeToCamel()}').join(',')});
\""";
  }

  Future<SqlQueryResult> insertShallow(TableConnection conn) {
    final sqlQuery = insertShallowSql();
    return conn.query(sqlQuery);
  }

  static String selectSql(${_joinParams()}) {
    return \"""
SELECT ${table.columns.map((e) => e.name).join(',')}
${_joinSelects(mapAllTables)}
FROM ${table.name}
${table.foreignKeys.map((e) => '\${with${e.reference.className} ? "JOIN ${e.reference.referencedTable} ON '
            '${e.colItems().map((c) => '${table.name}.${c.second}=${e.reference.referencedTable}.${c.last.columnName}').join(" AND ")}" : ""}')}
GROUP BY ${table.primaryKey?.columns.map((e) => e.columnName).join(',')}
;
\""";
  }

  static Future<List<$className>> select(TableConnection conn,${_joinParams()}) async {
    final query = $className.selectSql(${table.foreignKeys.map((e) => "with${e.reference.className}: with${e.reference.className},").join()});

    final result = await conn.query(query);
    int _refIndex = ${table.columns.length};

    return result.map((r) {
      return $className(
        ${table.columns.mapIndex((e, i) => '${e.name.snakeToCamel()}:r[$i] as ${_dartType(e.type, nullable: e.nullable)},').join()}
        ${table.foreignKeys.map((e) => 'ref${e.reference.className}: with${e.reference.className} ? ${joinFromJsonList(e, "r[_refIndex++]")} : null,').join()}
      );
    }).toList();
  }
}
""";
    try {
      sourceCode = _formatter.format(sourceCode);
    } catch (_) {}
    return sourceCode;
  }

  String joinFromJsonList(SqlForeignKey key, String varName) {
    final _tableClass = key.reference.className;
    return '($varName as List?)?.map((_v) => $_tableClass.fromJson(_v)).toList()';
  }

  String get className => table.name.snakeToCamel(firstUpperCase: true);

  String _joinParams() {
    if (table.foreignKeys.isEmpty) {
      return '';
    }
    return '{${table.foreignKeys.map((e) => "bool with${e.reference.className} = false,").join()}}';
  }

  String _joinSelects(Map<String, SqlTable> mapTables) {
    if (table.foreignKeys.isEmpty) {
      return '';
    }

    String? _mm(SqlTable? e) =>
        e?.columns.map((c) => "'${c.name.snakeToCamel()}',${e.name}.${c.name}").join(',');

    String _map(SqlForeignKey e) =>
        '\${with${e.reference.className} ? ",JSON_ARRAYAGG(JSON_OBJECT(${_mm(mapTables.get(e.reference.referencedTable))})) ref${e.reference.className}":""}';
    return table.foreignKeys.map(_map).join('\n');
  }

  String _dartType(SqlType type, {required bool nullable}) {
    return type.map(
          date: (date) => date.type == SqlDateVariant.YEAR ? 'int' : 'DateTime',
          string: (string) => string.binary ? 'List<int>' : 'String',
          enumeration: (enumeration) => 'String',
          integer: (integer) => 'int',
          decimal: (decimal) => 'double',
          json: (json) => 'Object',
        ) +
        (nullable ? '?' : '');
  }
}

extension _SqlReferenceExt on SqlReference {
  String get className =>
      this.referencedTable.snakeToCamel(firstUpperCase: true);
}
