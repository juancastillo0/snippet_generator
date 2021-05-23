// ignore_for_file: constant_identifier_names
import 'package:petitparser/petitparser.dart';

import 'package:snippet_generator/database/models/table_models_dart_templates.dart';
import 'package:snippet_generator/database/models/table_models_sql_templates.dart';
import 'package:snippet_generator/globals/option.dart';
import 'package:snippet_generator/parsers/sql/data_type_model.dart';
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

  late final templates = SqlTableDartTemplate(table: this);
  late final sqlTemplates = SqlTableSqlTemplate(table: this);

  SqlTable({
    required this.name,
    required this.columns,
    required this.tableKeys,
    required this.foreignKeys,
    this.errors = const [],
    this.token,
  });

  SqlTable replaceColumn(SqlColumn? col, int index) {
    final _columns = [...columns];
    if (col == null) {
      _columns.removeAt(index);
    } else {
      _columns[index] = col;
    }
    return copyWith(columns: _columns);
  }

  SqlTable replaceTableKey(SqlTableKey? key, int index) {
    final _tableKeys = [...tableKeys];
    if (key == null) {
      _tableKeys.removeAt(index);
    } else {
      _tableKeys[index] = key;
    }
    return copyWith(tableKeys: _tableKeys);
  }

  SqlTable replaceForeignKey(SqlForeignKey? key, int index) {
    final _foreignKeys = [...foreignKeys];
    if (key == null) {
      _foreignKeys.removeAt(index);
    } else {
      _foreignKeys[index] = key;
    }
    return copyWith(foreignKeys: _foreignKeys);
  }

  @override
  String toString() {
    return """SqlTable{name: $name, columns: $columns, primaryKey: $primaryKey, tableKeys: $tableKeys, foreignKeys: $foreignKeys}""";
  }

  SqlTable copyWith({
    String? name,
    List<SqlColumn>? columns,
    List<SqlTableKey>? tableKeys,
    List<SqlForeignKey>? foreignKeys,
    List<Token<String>>? errors,
    Option<Token>? token,
  }) {
    return SqlTable(
      name: name ?? this.name,
      columns: columns ?? this.columns,
      tableKeys: tableKeys ?? this.tableKeys,
      foreignKeys: foreignKeys ?? this.foreignKeys,
      errors: errors ?? this.errors,
      token: token != null ? token.valueOrNull : this.token,
    );
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

  bool get canBeUnique =>
      this == SqlIndexType.BTREE || this == SqlIndexType.HASH;
}

class SqlTableKey {
  final String? constraintName;
  final String? indexName;

  final SqlIndexType indexType;
  final bool _unique;
  bool get unique => indexType.canBeUnique && _unique;
  final bool primary;

  final List<SqlKeyItem> columns;
  final Token? token;

  const SqlTableKey({
    this.constraintName,
    String? indexName,
    required SqlIndexType? indexType,
    required bool unique,
    required this.primary,
    required this.columns,
    this.token,
  })  : assert(!primary || unique),
        assert(!primary || (indexName == null || indexName == 'PRIMARY')),
        assert(constraintName == null || unique || primary),
        _unique = unique,
        indexType = indexType ?? SqlIndexType.BTREE,
        indexName = primary ? 'PRIMARY' : indexName;

  factory SqlTableKey.primary({
    String? constraintName,
    SqlIndexType? index,
    required List<SqlKeyItem> columns,
  }) {
    return SqlTableKey(
      constraintName: constraintName,
      indexType: index,
      primary: true,
      unique: true,
      columns: columns,
    );
  }

  static const defaultTableKey = SqlTableKey(
    columns: [],
    primary: false,
    unique: false,
    indexType: SqlIndexType.BTREE,
  );

  @override
  String toString() {
    return 'SqlTableKey${toJson()}';
  }

  Map<String, dynamic> toJson() {
    return {
      'constraintName': constraintName,
      'indexName': indexName,
      'index': indexType.toJson(),
      'unique': unique,
      'primary': primary,
      'columns': columns.map((x) => x.toJson()).toList(),
    };
  }

  SqlTableKey copyWith({
    Option<String>? constraintName,
    Option<String>? indexName,
    SqlIndexType? indexType,
    bool? unique,
    bool? primary,
    List<SqlKeyItem>? columns,
    Option<Token>? token,
  }) {
    return SqlTableKey(
      constraintName: constraintName != null
          ? constraintName.valueOrNull
          : this.constraintName,
      indexName: indexName != null ? indexName.valueOrNull : this.indexName,
      indexType: indexType ?? this.indexType,
      unique: unique ?? this._unique,
      primary: primary ?? this.primary,
      columns: columns ?? this.columns,
      token: token != null ? token.valueOrNull : this.token,
    );
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

  static const defaultForeignKey = SqlForeignKey(
    ownColumns: [],
    reference: SqlReference.defaultReference,
  );

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

  SqlForeignKey copyWith({
    Option<String>? constraintName,
    Option<String>? indexName,
    List<String>? ownColumns,
    SqlReference? reference,
  }) {
    return SqlForeignKey(
      constraintName: constraintName != null
          ? constraintName.valueOrNull
          : this.constraintName,
      indexName: indexName != null ? indexName.valueOrNull : this.indexName,
      ownColumns: ownColumns ?? this.ownColumns,
      reference: reference ?? this.reference,
    );
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
  final List<SqlKeyItem> columns;

  /// https://dev.mysql.com/doc/refman/8.0/en/constraint-foreign-key.html
  /// https://www.postgresql.org/docs/9.1/sql-createtable.html
  final ReferenceMatchType matchType;
  final ReferenceOption onDelete;
  final ReferenceOption onUpdate;

  const SqlReference({
    required this.referencedTable,
    required this.columns,
    ReferenceOption? onDelete,
    ReferenceOption? onUpdate,
    ReferenceMatchType? matchType,
  })  : onDelete = onDelete ?? ReferenceOption.NO_ACTION,
        onUpdate = onUpdate ?? ReferenceOption.NO_ACTION,
        matchType = matchType ?? ReferenceMatchType.SIMPLE;

  static const defaultReference = SqlReference(
    columns: [],
    referencedTable: '',
  );

  Map<String, dynamic> toJson() {
    return {
      'referencedTable': referencedTable,
      'matchType': matchType.toJson(),
      'onDelete': onDelete.toJson(),
      'onUpdate': onUpdate.toJson(),
      'columns': columns.map((x) => x.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'SqlReference${toJson()}';
  }

  SqlReference copyWith({
    String? referencedTable,
    ReferenceMatchType? matchType,
    ReferenceOption? onDelete,
    ReferenceOption? onUpdate,
    List<SqlKeyItem>? columns,
  }) {
    return SqlReference(
      referencedTable: referencedTable ?? this.referencedTable,
      matchType: matchType ?? this.matchType,
      onDelete: onDelete ?? this.onDelete,
      onUpdate: onUpdate ?? this.onUpdate,
      columns: columns ?? this.columns,
    );
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

  static const defaultColumn = SqlColumn(
    name: '',
    type: SqlType.integer(
      bytes: 4,
      unsigned: false,
      zerofill: false,
    ),
  );

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

  SqlColumn copyWith({
    String? name,
    SqlType? type,
    bool? autoIncrement,
    bool? unique,
    bool? primary,
    Option<String>? defaultValue,
    bool? nullable,
    Option<String>? collation,
    bool? visible,
    Option<String>? generatedValue,
    bool? virtual,
    bool? alwaysGenerated,
    Option<SqlColumnTokens>? tokens,
  }) {
    return SqlColumn(
      name: name ?? this.name,
      type: type ?? this.type,
      autoIncrement: autoIncrement ?? this.autoIncrement,
      unique: unique ?? this.unique,
      primary: primary ?? this.primary,
      defaultValue:
          defaultValue != null ? defaultValue.valueOrNull : this.defaultValue,
      nullable: nullable ?? this.nullable,
      collation: collation != null ? collation.valueOrNull : this.collation,
      visible: visible ?? this.visible,
      generatedValue: generatedValue != null
          ? generatedValue.valueOrNull
          : this.generatedValue,
      virtual: virtual ?? this.virtual,
      alwaysGenerated: alwaysGenerated ?? this.alwaysGenerated,
      tokens: tokens != null ? tokens.valueOrNull : this.tokens,
    );
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
