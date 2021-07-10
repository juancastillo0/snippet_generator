import 'package:petitparser/petitparser.dart';

class Table {
  final String name;
  final bool isTemporary;
  final List<Column> columns;

  const Table({
    required this.name,
    required this.isTemporary,
    required this.columns,
  });
}

final table = (stringIgnoreCase('CREATE').trim() &
        (stringIgnoreCase('TEMPORARY') | stringIgnoreCase('TEMP'))
            .trim()
            .optional() &
        stringIgnoreCase('TABLE').trim() &
        identifier.trim() &
        string('(').trim() &
        column
            .trim()
            .separatedBy(string(',').trim(),
                includeSeparators: false, optionalSeparatorAtEnd: false)
            .trim() &
        string(')').trim() &
        string(';').trim())
    .trim();

final identifier = (letter() & (letter() | digit()).star()).flatten().trim();

class Column {
  final String name;
  final ColumnType? type;
  final List<Constraint> constraints;

  const Column({
    required this.name,
    required this.type,
    required this.constraints,
  });
}

final column = (identifier.trim() &
        columnType.trim().optional() &
        constraint.trim().star())
    .trim();

enum ColumnType {
  text,
  numeric,
  integer,
  real,
  blob,
}

final columnType = ((stringIgnoreCase('TEXT') |
        stringIgnoreCase('NUMERIC') |
        stringIgnoreCase('INTEGER') |
        stringIgnoreCase('REAL') |
        stringIgnoreCase('BLOB')))
    .trim();

class Constraint {
  final String name;
  final ConstraintValue value;

  const Constraint({
    required this.name,
    required this.value,
  });
}

class ConstraintValue {}

final constraint = (stringIgnoreCase('CONSTRAINT').trim() &
        identifier.trim() &
        ((stringIgnoreCase('PRIMARY').trim() &
                        stringIgnoreCase('KEY').trim() &
                        (stringIgnoreCase('ASC') | stringIgnoreCase('DESC'))
                            .trim()
                            .optional() &
                        conflictClause.trim())
                    .trim() |
                (stringIgnoreCase('NOT').trim() &
                        stringIgnoreCase('NULL').trim() &
                        conflictClause.trim())
                    .trim() |
                (stringIgnoreCase('UNIQUE').trim() & conflictClause.trim())
                    .trim() |
                stringIgnoreCase('CHECK').trim() |
                string('DEFAULT').trim() |
                foreignKey.trim())
            .trim())
    .trim();

enum ConflictClause {
  rollback,
  abort,
  fail,
  ignore,
  replace,
}

final conflictClause = (stringIgnoreCase('ON').trim() &
        stringIgnoreCase('CONFLICT').trim() &
        (stringIgnoreCase('ROLLBACK').trim() |
                stringIgnoreCase('ABORT').trim() |
                stringIgnoreCase('FAIL').trim() |
                stringIgnoreCase('IGNORE').trim() |
                stringIgnoreCase('REPLACE').trim())
            .trim())
    .trim()
    .optional();

class ForeignKey {
  final String tableName;
  final List<String> columnNames;
  final List<ChangeClause> changeClauses;

  const ForeignKey({
    required this.tableName,
    required this.columnNames,
    required this.changeClauses,
  });
}

enum ChangeClauseType {
  update,
  delete,
}

enum ChangeClauseValue {
  setNull,
  setDefault,
  cascade,
  restrict,
  noAction,
}

class ChangeClause {
  final ChangeClauseType type;
  final ChangeClauseValue value;

  const ChangeClause({
    required this.type,
    required this.value,
  });
}

final foreignKey = (stringIgnoreCase('REFERENCES').trim() &
        identifier.trim() &
        stringIgnoreCase('(').trim() &
        identifier
            .trim()
            .separatedBy(string(',').trim(),
                includeSeparators: false, optionalSeparatorAtEnd: true)
            .trim() &
        stringIgnoreCase(')').trim() &
        foreignKeyChangeClause.trim().repeat(0, 2))
    .trim();

final foreignKeyChangeClause = (stringIgnoreCase('ON').trim() &
        (stringIgnoreCase('DELETE').trim() | stringIgnoreCase('UPDATE').trim())
            .trim() &
        ((stringIgnoreCase('SET').trim() & stringIgnoreCase('NULL').trim())
                    .trim() |
                (stringIgnoreCase('SET').trim() &
                        stringIgnoreCase('DEFAULT').trim())
                    .trim() |
                stringIgnoreCase('CASCADE').trim() |
                stringIgnoreCase('RESTRICT').trim() |
                (stringIgnoreCase('NO').trim() &
                        stringIgnoreCase('ACTION').trim())
                    .trim())
            .trim())
    .trim();
