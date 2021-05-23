import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:petitparser/petitparser.dart';
import 'package:snippet_generator/globals/flutter/highlighted_text_controller.dart';
import 'package:snippet_generator/globals/props_serializable.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';
import 'package:snippet_generator/parsers/sql/create_table_parser.dart';
import 'package:snippet_generator/parsers/sql/table_models.dart';

const _initialRawSqlTable = """
CREATE TABLE `message` (
  `num_id` bigint NOT NULL AUTO_INCREMENT,
  `code_message` varchar(64) NOT NULL,
  `user_code` varbinary(64) NOT NULL,
  `room_code` varchar(64) NOT NULL,
  `room_code_section` INT NOT NULL,
  `text` mediumtext NOT NULL,
  `sender_name` TEXT(255) NULL,
  `type_message_code` varchar(64) NOT NULL,
  `read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`num_id`, `code_message`),
  CONSTRAINT `fk_messages_room` FOREIGN KEY (`room_code`, `room_code_section`) REFERENCES `room` (`code_room`, `section`),
  CONSTRAINT `fk_messages_user_code` FOREIGN KEY (`user_code`) REFERENCES `user` (`code_user`),
  CONSTRAINT `fk_messages_types_messages` FOREIGN KEY (`type_message_code`) REFERENCES `type_message` (`code_type`)
);

CREATE TABLE `user` (
`code_user` varbinary(64) NOT NULL,
`created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE `room` (
`code_room` varchar(64) NOT NULL,
`section` INT NOT NULL,
`created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE `type_message` (
`code_type` varchar(64) NOT NULL,
`created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
);
""";

enum TextView { import, dartCode, sqlCode, sqlBuilder }

class DatabaseStore with PropsSerializable {
  @override
  final String name;

  DatabaseStore({required this.name}) {
    autorun(
      (r) {
        if (parsedTableDefinition.value.isSuccess &&
            rawTableDefinition.text != tablesSqlText.value) {
          tables.value = parsedTableDefinition.value.value;
        }
      },
      delay: 50,
    );
  }

  late final rawTableDefinition = TextNotifier(
    controller: HighlightedTextController(
      errorsFn: _errors,
      text: _initialRawSqlTable,
    ),
    name: 'rawTableDefinition',
  );

  late final Computed<Result<List<SqlTable>>> parsedTableDefinition = Computed(
    () => createTableListParser.parse(rawTableDefinition.text),
  );

  final tables = AppNotifier<List<SqlTable>>([], name: 'tables');

  late final Computed<String> tablesSqlText = Computed(
    () => tables.value.map((e) => e.sqlTemplates.toSql()).join('\n'),
  );

  final _selectedIndex = AppNotifier(0, name: 'selectedIndex');
  late final Computed<SqlTable?> selectedTable = Computed(
    () => _selectedIndex.value < tables.value.length
        ? tables.value[_selectedIndex.value]
        : null,
  );

  void selectIndex(int index) {
    _selectedIndex.value = index;
  }

  final selectedTab = AppNotifier(TextView.import);

  List<TextRange> _errors() {
    return parsedTableDefinition.value.isSuccess
        ? parsedTableDefinition.value.value
            .expand((t) =>
                t.errors.map((e) => TextRange(start: e.start, end: e.stop)))
            .toList()
        : [];
  }

  void replace(Token token, String str) {
    String _after = rawTableDefinition.text.substring(token.stop);
    if (str.isEmpty) {
      _after = _after.replaceFirst(RegExp(r'^\s*,\s*'), '');
    }
    rawTableDefinition.controller.text =
        rawTableDefinition.text.substring(0, token.start) + str + _after;
  }

  @override
  late final Iterable<SerializableProp> props = [
    rawTableDefinition,
    _selectedIndex,
    tables,
  ];

  void replaceTable(SqlTable newTable, int index) {
    final newTables = [...tables.value];
    newTables[index] = newTable;
    tables.value = newTables;
    rawTableDefinition.controller.text = tablesSqlText.value;
  }
}
