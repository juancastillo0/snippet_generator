import 'package:snippet_generator/parsers/sql/data_type_model.dart';

class SqlTable {
  final String name;
  SqlTableKey? get primaryKey {
    final _index = tableKeys.indexWhere((col) => col.primary);
    if (_index != -1) {
      return tableKeys[_index];
    }

    final index = columns.indexWhere((col) => col.primary);
    return index == -1
        ? null
        : SqlTableKey.primary(columns: [columns[index].name]);
  }

  final List<SqlColumn> columns;
  final List<SqlTableKey> tableKeys;
  final List<SqlForeignKey> foreignKeys;

  const SqlTable({
    required this.name,
    required this.columns,
    required this.tableKeys,
    required this.foreignKeys,
  });

  @override
  String toString() {
    return """SqlTable(name: $name, columns: $columns, tableKeys: $tableKeys, foreignKeys: $foreignKeys)""";
  }
}

class SqlTableKey {
  final String? name;

  final bool indexed;
  final bool unique;
  final bool primary;

  final List<String> columns;

  const SqlTableKey({
    this.name,
    required this.indexed,
    required this.unique,
    required this.primary,
    required this.columns,
  }) : assert(!primary || (indexed && unique));

  factory SqlTableKey.primary({
    String? name,
    required List<String> columns,
  }) {
    return SqlTableKey(
      name: name,
      indexed: true,
      primary: true,
      unique: true,
      columns: columns,
    );
  }
}

class SqlForeignKey {
  final String? name;
  final List<String> ownColumns;
  final String referencedTable;
  final List<String> referencedColumns;

  const SqlForeignKey({
    this.name,
    required this.ownColumns,
    required this.referencedTable,
    required this.referencedColumns,
  });
}

class SqlColumn {
  final String name;
  final SqlType type;
  final bool autoIncrement;
  final bool unique;
  final bool primary;
  final String? defaultValue;
  final bool nullable;
  final String? collation;
  final bool visible;
  final String? generatedValue;
  final bool virtual;
  final bool alwaysGenerated;

  const SqlColumn({
    required this.name,
    required this.type,
    this.autoIncrement = false,
    this.unique = false,
    this.primary = false,
    this.defaultValue,
    this.nullable = true,
    this.collation,
    this.visible = true,
    this.generatedValue,
    this.virtual = false,
    this.alwaysGenerated = false,
  })  : assert(generatedValue == null || defaultValue == null),
        assert(generatedValue == null || alwaysGenerated == false);

  @override
  String toString() {
    return toJson().toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.toJson(),
      'autoIncrement': autoIncrement,
      'unique': unique,
      'primary': primary,
      'defaultValue': defaultValue,
      'nullable': nullable,
      'collation': collation,
      'visible': visible,
      'generatedValue': generatedValue,
      'virtual': virtual,
      'alwaysGenerated': alwaysGenerated,
    };
  }
}
