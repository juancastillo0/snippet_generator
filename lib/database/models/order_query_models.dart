import 'package:snippet_generator/database/models/sql_values.dart';

class SqlOrderItem {
  final SqlValue value;
  final bool desc;
  final bool nullsFirst;

  const SqlOrderItem(this.value, {this.desc = false, this.nullsFirst = false});

  String toSql() {
    return '${nullsFirst && !desc ? "${value.toSql()} IS NOT NULL," : ""}${value.toSql()} ${desc ? "DESC" : "ASC"}';
  }
}

class SqlJoin {
  final SqlValue<SqlBoolValue>? condition;
  final bool isInner;

  const SqlJoin({this.condition, required this.isInner});
  const SqlJoin.inner({this.condition}) : this.isInner = true;
  const SqlJoin.left({this.condition}) : this.isInner = false;
}

class SqlLimit {
  final int? offset;
  final int rowCount;

  const SqlLimit(this.rowCount, {this.offset});
}
