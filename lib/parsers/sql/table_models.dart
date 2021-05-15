// ignore_for_file: constant_identifier_names
import 'package:petitparser/petitparser.dart';
import 'package:snippet_generator/parsers/sql/data_type_model.dart';
import 'package:snippet_generator/parsers/sql/table_models_templates.dart';
import 'package:snippet_generator/utils/extensions.dart';

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
        : SqlTableKey.primary(
            columns: [
              SqlKeyItem(
                columnName: columns[index].name,
                ascendent: true, // TODO:
              )
            ],
          );
  }

  final List<SqlColumn> columns;
  final List<SqlTableKey> tableKeys;
  final List<SqlForeignKey> foreignKeys;
  final List<Token<String>> errors;
  final Token? token;

  late final templates = SqlTableTemplate(table: this);

  SqlTable({
    required this.name,
    required this.columns,
    required this.tableKeys,
    required this.foreignKeys,
    this.errors = const [],
    this.token,
  });

  @override
  String toString() {
    return """SqlTable{name: $name, columns: $columns, primaryKey: $primaryKey, tableKeys: $tableKeys, foreignKeys: $foreignKeys}""";
  }
}

enum SqlIndexType {
  BTREE,
  HASH,
  FULLTEXT,
  SPATIAL,
}

extension SqlIndexTypeExt on SqlIndexType {
  String toJson() => toString().split('.')[1];
}

class SqlTableKey {
  final String? constraintName;
  final String? indexName;

  final SqlIndexType index;
  final bool unique;
  final bool primary;

  final List<SqlKeyItem> columns;
  final Token? token;

  const SqlTableKey({
    this.constraintName,
    String? indexName,
    required SqlIndexType? index,
    required this.unique,
    required this.primary,
    required this.columns,
    this.token,
  })  : assert(!primary || unique),
        assert(!primary || (indexName == null || indexName == 'PRIMARY')),
        assert(constraintName == null || unique || primary),
        index = index ?? SqlIndexType.BTREE,
        indexName = primary ? 'PRIMARY' : indexName;

  factory SqlTableKey.primary({
    String? constraintName,
    SqlIndexType? index,
    required List<SqlKeyItem> columns,
  }) {
    return SqlTableKey(
      constraintName: constraintName,
      index: index,
      primary: true,
      unique: true,
      columns: columns,
    );
  }

  @override
  String toString() {
    return 'SqlTableKey${toJson()}';
  }

  Map<String, dynamic> toJson() {
    return {
      'constraintName': constraintName,
      'indexName': indexName,
      'index': index.toJson(),
      'unique': unique,
      'primary': primary,
      'columns': columns.map((x) => x.toJson()).toList(),
    };
  }
}

class SqlForeignKey {
  final String? constraintName;
  final String? indexName;
  final List<String> ownColumns;
  final SqlReference reference;

  const SqlForeignKey({
    this.constraintName,
    this.indexName,
    required this.ownColumns,
    required this.reference,
  });

  Map<String, dynamic> toJson() {
    return {
      'constraintName': constraintName,
      'indexName': indexName,
      'ownColumns': ownColumns,
      'reference': reference.toJson(),
    };
  }

  List<Tuple3<SqlForeignKey, String, SqlKeyItem>> colItems() {
    return ownColumns
        .mapIndex(
          (c, ind) => ind >= reference.columns.length
              ? null
              : Tuple3(
                  this,
                  c,
                  reference.columns[ind],
                ),
        )
        .whereType<Tuple3<SqlForeignKey, String, SqlKeyItem>>()
        .toList();
  }

  @override
  String toString() {
    return 'SqlForeignKey${toJson()}';
  }
}

class Tuple3<F, S, L> {
  final F first;
  final S second;
  final L last;

  const Tuple3(this.first, this.second, this.last);
}

class SqlKeyItem {
  final String columnName;
  final bool ascendent;

  const SqlKeyItem({
    required this.columnName,
    required this.ascendent,
  });

  Map<String, dynamic> toJson() {
    return {
      'columnName': columnName,
      'ascendent': ascendent,
    };
  }

  @override
  String toString() {
    return '${toJson()}';
  }
}

enum ReferenceMatchType {
  FULL,
  PARTIAL,
  SIMPLE,
}

extension ReferenceMatchTypeExt on ReferenceMatchType {
  String toJson() => toString().split('.')[1];
}

class SqlReference {
  final String referencedTable;
  final ReferenceMatchType? matchType;
  final ReferenceOption onDelete;
  final ReferenceOption onUpdate;
  final List<SqlKeyItem> columns;

  SqlReference({
    required this.referencedTable,
    required this.matchType,
    ReferenceOption? onDelete,
    ReferenceOption? onUpdate,
    required this.columns,
  })  : onDelete = onDelete ?? ReferenceOption.NO_ACTION,
        onUpdate = onUpdate ?? ReferenceOption.NO_ACTION;

  Map<String, dynamic> toJson() {
    return {
      'referencedTable': referencedTable,
      'matchType': matchType?.toJson(),
      'onDelete': onDelete.toJson(),
      'onUpdate': onUpdate.toJson(),
      'columns': columns.map((x) => x.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'SqlReference${toJson()}';
  }
}

enum ReferenceOption {
  RESTRICT,
  CASCADE,
  SET_NULL,
  NO_ACTION,
  SET_DEFAULT,
}

extension ReferenceOptionExt on ReferenceOption {
  String toJson() => toString().split('.')[1];
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
  final SqlColumnTokens? tokens;

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
    this.tokens,
  })  : assert(generatedValue == null || defaultValue == null),
        assert(generatedValue == null || alwaysGenerated == false);

  @override
  String toString() {
    return 'SqlColumn${toJson()}';
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

class SqlColumnTokens {
  final Token? name;
  final Token? type;
  final Token? autoIncrement;
  final Token? unique;
  final Token? primary;
  final Token? defaultValue;
  final Token? nullable;
  final Token? collation;
  final Token? visible;
  final Token? generatedValue;
  final Token? virtual;
  final Token? alwaysGenerated;

  const SqlColumnTokens({
    required this.name,
    required this.type,
    required this.autoIncrement,
    required this.unique,
    required this.primary,
    required this.defaultValue,
    required this.nullable,
    required this.collation,
    required this.visible,
    required this.generatedValue,
    required this.virtual,
    required this.alwaysGenerated,
  });

  @override
  String toString() {
    return 'SqlColumn${toJson()}';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
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
