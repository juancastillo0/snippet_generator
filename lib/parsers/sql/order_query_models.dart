import 'package:snippet_generator/parsers/sql/sql_values.dart';

class OrderQueryItem<T> {
  final SqlValue<T> value;
  final bool desc;

  OrderQueryItem(this.value, {this.desc = false});
}
