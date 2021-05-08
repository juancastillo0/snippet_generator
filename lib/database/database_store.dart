import 'package:mobx/mobx.dart';
import 'package:petitparser/petitparser.dart';
import 'package:snippet_generator/globals/props_serializable.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';
import 'package:snippet_generator/parsers/sql/create_table_parser.dart';

class DatabaseStore with PropsSerializable {
  @override
  final String name;

  DatabaseStore({required this.name});

  final rawTableDefinition = TextNotifier();

  late final Computed<Result<List<Object?>>> parsedTableDefinition = Computed(
    () => createTableParser.parse(rawTableDefinition.text),
  );

  @override
  late final Iterable<SerializableProp> props = [rawTableDefinition];
}
