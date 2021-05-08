import 'package:petitparser/petitparser.dart';

Parser<String> _token(String str) {
  return stringIgnoreCase(str).trim();
}

Parser<T> parens<T>(Parser<T> parser) {
  return (char('(').trim() & parser & char(')').trim()).pick(1).cast();
}

final _symbol = (char('`') & pattern('^`').star().flatten() & char('`'))
        .trim()
        .pick(1)
        .cast<String>() |
    word().plus().flatten().trim();

final createTableParser = _token('CREATE') &
    _token('TABLE') &
    _symbol &
    parens(_tableItem.separatedBy(char(',').trim()));

final _tableItem = _columnDefinition | _constraintDefinition | _indexDefinition;

final _constraintDefinition =
    (_token('CONSTRAINT') & _symbol.optional()).optional() &
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
                (_token('NOT').optional() & _token('ENFORCED')).optional()));

final _indexDefinition = ((_token('INDEX') | _token('KEY')) &
            _symbol.optional() &
            _indexTypeParser.optional() |
        (_token('FULLTEXT') | _token('SPATIAL')) &
            (_token('INDEX') | _token('KEY')).optional() &
            _symbol.optional()) &
    _keysParser;

final _indexTypeParser = _token('USING') & (_token('BTREE') | _token('HASH'));

final _foreignKeysParser = parens(_symbol.separatedBy(char(',').trim()));

final _keysParser = parens(
    (_symbol & (_token('ASC') | _token('DESC')).optional())
        .separatedBy(char(',').trim()));

final _referenceDefinition = _token('REFERENCES') &
    _symbol &
    _keysParser &
    (_token('MATCH') & (_token('FULL') | _token('PARTIAL') | _token('SIMPLE')))
        .optional() &
    (_token('ON') &
            (_token('DELETE') | _token('UPDATE')) &
            referenceOptionParser)
        .optional();

final referenceOptionParser = _token('RESTRICT') |
    _token('CASCADE') |
    _token('SET') & _token('NULL') |
    _token('NO') & _token('ACTION') |
    _token('SET') & _token('DEFAULT');

final _columnDefinition = _symbol &
    _typeParser &
    _collate.optional() &
    (_token('NOT').optional() & _token('NULL')).optional() &
    (_token('DEFAULT') & _sqlLiteral.trim()).optional() &
    (_token('VISIBLE') | _token('INVISIBLE')).optional() &
    _token('AUTO_INCREMENT').optional() &
    (_token('UNIQUE') & _token('KEY').optional()).optional() &
    (_token('PRIMARY').optional() & _token('KEY')).optional();

final _sqlLiteral = _stringLiteral |
    _token('NULL') |
    digit().plus().flatten() |
    _token('CURRENT_TIMESTAMP');
final _stringLiteral = (char("'") & pattern("^'").star().flatten() & char("'"))
    .pick(1)
    .cast<String>();

final _typeParser =
    _numericTypeParser | _dateTypeParser | _stringTypeParser | _token('JSON');

final _numericTypeParser = (((stringIgnoreCase('TINY') |
                    stringIgnoreCase('SMALL') |
                    stringIgnoreCase('MEDIUM') |
                    stringIgnoreCase('BIG'))
                .optional() &
            stringIgnoreCase('INT') &
            parens(pattern('1-9') & pattern('0-9').star().flatten())
                .optional()) |
        (_token('DOUBLE') & _token('PRECISION').optional() |
                _token('FLOAT') |
                _token('DECIMAL')) &
            parens(pattern('1-9') &
                pattern('0-9').star().flatten() &
                (char(',').trim() &
                        pattern('1-9') &
                        pattern('0-9').star().flatten())
                    .optional())) &
    _token('UNSIGNED').optional() &
    _token('ZEROFILL').optional();

final _dateTypeParser =
    (_token('TIMESTAMP') | _token('TIME') | _token('DATETIME')) &
            parens(pattern('0-6')).optional() |
        _token('DATE') |
        _token('YEAR');

final _stringTypeParser =
    ((_token('CHAR') | _token('BINARY') | _token('BLOB') | _token('TEXT')) &
                parens(pattern('0-9').plus().flatten()).optional() |
            (_token('VARCHAR') | _token('VARBINARY')) &
                parens(pattern('0-9').plus().flatten()) |
            _token('TINYTEXT') |
            _token('MEDIUMTEXT') |
            _token('LONGTEXT') |
            _token('TINYBLOB') |
            _token('MEDIUMBLOB') |
            _token('LONGBLOB') |
            (_token('ENUM') | _token('SET')) &
                parens(_stringLiteral.separatedBy(char(',').trim()))) &
        (_token('CHARACTER') & _token('SET') & word().plus().flatten().trim())
            .optional() &
        _collate.optional();

final _collate = _token('COLLATE') & word().plus().flatten().trim();
