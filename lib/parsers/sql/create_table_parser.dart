import 'package:petitparser/petitparser.dart';
import 'package:snippet_generator/parsers/sql/data_type_model.dart';
import 'package:snippet_generator/parsers/sql/data_type_parser.dart';
import 'package:snippet_generator/parsers/sql/table_models.dart';
import 'package:snippet_generator/utils/extensions.dart';

Parser<String> _token(String str) {
  return stringIgnoreCase(str).trim();
}

Parser<T> parens<T>(Parser<T> parser) {
  return (char('(').trim() & parser & char(')').trim()).pick(1).cast();
}

final _symbol = ((char('`') & pattern('^`').star().flatten() & char('`'))
            .trim()
            .pick(1)
            .cast<String>() |
        word().plus().flatten().trim())
    .cast<String>();

final createTableParser = (_token('CREATE') &
        _token('TABLE') &
        _symbol &
        parens(
            _tableItem.separatedBy(char(',').trim(), includeSeparators: false)))
    .map((value) {
  final list = value[3] as List;
  return SqlTable(
    name: value[2] as String,
    columns: list.whereType<SqlColumn>().toList(),
    tableKeys: list.whereType<SqlTableKey>().toList(),
    foreignKeys: list.whereType<SqlForeignKey>().toList(),
  );
});

final _tableItem = _columnDefinition | _constraintDefinition | _indexDefinition;

final _constraintDefinition = ((_token('CONSTRAINT') & _symbol.optional())
            .optional() &
        (((_token('PRIMARY') & _token('KEY') |
                    _token('UNIQUE') &
                        (_token('INDEX') | _token('KEY')).optional() &
                        _symbol.optional()) &
                _indexTypeParser.optional() &
                _keysParser) |
            (_token('FOREIGN') &
                _token('KEY') &
                _symbol.optional() &
                _foreignKeysParser &
                _referenceDefinition) |
            (_token('CHECK') &
                (_token('NOT').optional() & _token('ENFORCED')).optional())))
    .map((value) {
  final constraintName = value[0] == null ? null : value[0][1] as String?;
  final list = value[1] as List;
  final f = list[0];
  if (f is String && f.toUpperCase() == 'FOREIGN') {
    final indexName = list[2] as String?;
    return SqlForeignKey(
      constraintName: constraintName,
      indexName: indexName,
      ownColumns: list[3] as List<String>,
      reference: list[4] as SqlReference,
    );
  } else if (f is List) {
    final primary = (f[0] as String).toUpperCase() == 'PRIMARY';
    return SqlTableKey(
      constraintName: constraintName,
      indexName: primary ? 'PRIMARY' : f[2] as String?,
      index: list[1] as SqlIndexType?,
      primary: primary,
      unique: true,
      columns: list.last as List<SqlKeyItem>,
    );
  } else {
    throw UnimplementedError();
  }
});

final _indexDefinition = (((_token('INDEX') | _token('KEY')) &
                _symbol.optional() &
                _indexTypeParser.optional() |
            (_token('FULLTEXT') | _token('SPATIAL')) &
                (_token('INDEX') | _token('KEY')).optional() &
                _symbol.optional()) &
        _keysParser)
    .map((value) {
  final list = value.first as List;
  final f = (list.first as String).toUpperCase();
  final String? index;
  final String? name;
  final columns = value.last as List<SqlKeyItem>;
  if (f == 'FULLTEXT' || f == 'SPATIAL') {
    index = f;
    name = list[2] as String?;
  } else {
    index = list[2] as String?;
    name = list[1] as String?;
  }

  return SqlTableKey(
    primary: false,
    unique: false,
    index: index == null
        ? null
        : parseEnum(index, SqlIndexType.values, caseSensitive: false),
    columns: columns,
    indexName: name,
  );
});

final _indexTypeParser =
    (_token('USING') & (_token('BTREE') | _token('HASH'))).pick(1).map(
          (value) => parseEnum(
            value as String,
            SqlIndexType.values,
            caseSensitive: false,
          )!,
        );

final _foreignKeysParser = parens(
    _symbol.separatedBy<String>(char(',').trim(), includeSeparators: false));

final _keysParser = parens(
        (_symbol & (_token('ASC') | _token('DESC')).optional())
            .separatedBy(char(',').trim(), includeSeparators: false))
    .map((value) {
  return value.map((e) {
    final l = e as List;
    final order = l[1] as String?;
    return SqlKeyItem(
      columnName: l[0] as String,
      ascendent: order == null || order.toUpperCase() == 'ASC',
    );
  }).toList();
});

final _referenceDefinition = (_token('REFERENCES') &
        _symbol &
        _keysParser &
        (_token('MATCH') &
                (_token('FULL') | _token('PARTIAL') | _token('SIMPLE')))
            .optional() &
        (_token('ON') &
                (_token('DELETE') | _token('UPDATE')) &
                referenceOptionParser)
            .optional())
    .map((value) {
  final tableName = value[1] as String;
  final match = value[3] is List ? value[3][1] as String : null;
  return SqlReference(
    referencedTable: tableName,
    matchType: match == null
        ? null
        : parseEnum(match, ReferenceMatchType.values, caseSensitive: false),
    columns: value[2] as List<SqlKeyItem>,
    onDelete: null,
    onUpdate: null,
  );
});

final referenceOptionParser = (_token('RESTRICT') |
        _token('CASCADE') |
        _token('SET') & _token('NULL') |
        _token('NO') & _token('ACTION') |
        _token('SET') & _token('DEFAULT'))
    .map((value) {
  final String _str;
  if (value is List) {
    _str = value.join('_');
  } else {
    _str = value as String;
  }
  return parseEnum(_str, ReferenceOption.values, caseSensitive: false)!;
});

final _columnDefinition = (_symbol &
        sqlDataTypeParser &
        ((_token('NOT').optional() & _token('NULL')).optional() &
                (_token('DEFAULT') & _sqlLiteral.trim()).optional() &
                (_token('VISIBLE') | _token('INVISIBLE')).optional() &
                _token('AUTO_INCREMENT').optional() &
                (_token('UNIQUE') & _token('KEY').optional()).optional() &
                (_token('PRIMARY').optional() & _token('KEY')).optional() &
                collateParser.optional() |
            collateParser.optional() &
                (_token('GENERATED') & _token('ALWAYS')).optional() &
                _token('AS') &
                _sqlLiteral.trim() &
                (_token('VIRTUAL') | _token('STORED')).optional() &
                (_token('NOT').optional() & _token('NULL')).optional() &
                (_token('VISIBLE') | _token('INVISIBLE')).optional() &
                (_token('UNIQUE') & _token('KEY').optional()).optional() &
                (_token('PRIMARY').optional() & _token('KEY')).optional()))
    .map((value) {
  final name = value[0] as String;
  final type = value[1] as SqlType;

  final opts = value[2] as List;

  if (opts[2] != 'AS') {
    return SqlColumn(
      name: name,
      type: type,
      nullable: opts[0] == null || opts[0][0] == null,
      defaultValue: opts[1] == null ? null : opts[1][1] as String,
      visible:
          opts[2] == null || (opts[2] as String).toUpperCase() == 'VISIBLE',
      autoIncrement: opts[3] != null,
      unique: opts[4] != null,
      primary: opts[5] != null,
      collation: opts[6] as String?,
    );
  } else {
    return SqlColumn(
      name: name,
      type: type,
    );
  }
});

final _sqlLiteral = (sqlStringLiteral |
        _token('NULL') |
        digit().plus().flatten() |
        _token('CURRENT_TIMESTAMP'))
    .cast<String>();
final sqlStringLiteral =
    (char("'") & pattern("^'").star().flatten() & char("'"))
        .pick(1)
        .cast<String>();

final collateParser =
    (_token('COLLATE') & word().plus().flatten().trim()).pick(1).cast<String>();
