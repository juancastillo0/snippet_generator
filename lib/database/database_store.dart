import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:mysql1/mysql1.dart';
import 'package:petitparser/petitparser.dart';
import 'package:snippet_generator/globals/async_state_notifer.dart';
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
    // autorun(
    //   (r) {
    //     importTableFromCode();
    //   },
    //   delay: 50,
    // );
    importTableFromCode();

    reaction((r) => tablesSqlText.value, (r) {
      rawTableDefinition.controller.text = tablesSqlText.value;
    });
  }

  final connectionStore = ConnectionStore();

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

  void importTableFromCode() {
    if (parsedTableDefinition.value.isSuccess &&
        rawTableDefinition.text != tablesSqlText.value) {
      tables.value = parsedTableDefinition.value.value;
    }
  }

  Future<void> importCodeFromConnection() async {
    if (connectionStore.connectionState.value.isSuccess) {
      final String tables = await connectionStore.queryTables();
      print('tables $tables');
    } else {
      connectionStore.host.focusNode.requestFocus();
    }
  }

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

  // void replace(Token token, String str) {
  //   String _after = rawTableDefinition.text.substring(token.stop);
  //   if (str.isEmpty) {
  //     _after = _after.replaceFirst(RegExp(r'^\s*,\s*'), '');
  //   }
  //   rawTableDefinition.controller.text =
  //       rawTableDefinition.text.substring(0, token.start) + str + _after;
  // }

  @override
  late final Iterable<SerializableProp> props = [
    rawTableDefinition,
    _selectedIndex,
    tables,
  ];

  void replaceSelectedTable(SqlTable newTable) {
    replaceTable(newTable, _selectedIndex.value);
  }

  void replaceTable(SqlTable newTable, int index) {
    final newTables = [...tables.value];
    newTables[index] = newTable;
    tables.value = newTables;
  }

  void addTable(SqlTable newTable) {
    final newTables = [...tables.value, newTable];
    tables.value = newTables;
    selectIndex(tables.value.length - 1);
  }
}

class ConnectionStore {
  final host = TextNotifier(name: "host");
  final port = TextNotifier(name: "port");
  final user = TextNotifier(name: "user");
  final password = TextNotifier(name: "password");
  final db = TextNotifier(name: "db");

  ConnectionSettings? connectionSettings;
  MySqlConnection? conn;

  AsyncStateNotifier<ConnectionSettings, MySqlConnection, String>
      connectionState = AsyncStateNotifier();

  Future<void> connect() async {
    if (connectionState.value.isLoading) {
      return;
    } else if (connectionState.value.isSuccess) {
      await connectionState.value.maybeMap(
        success: (state) {
          return state.value.close();
        },
        orElse: () => throw Error(),
      );
    }

    try {
      final settings = ConnectionSettings(
        host: host.value,
        port: port.value.isEmpty ? 3306 : int.parse(port.value),
        user: user.value,
        password: password.value,
        db: db.value,
      );
      connectionState.loading(settings);

      final _conn = await MySqlConnection.connect(settings);
      connectionState.success(_conn, request: settings);
    } catch (e) {
      final invalidPort = e is FormatException;
      connectionState.error(
        invalidPort ? "Invalid port" : e.toString(),
      );
      if (invalidPort) {
        port.focusNode.requestFocus();
      }
    }
  }

  Future<String> queryTables() async {
    return connectionState.value.maybeMap(
      success: (state) async {
        final tableNamesStr = await state.value.query("show tables;");
        return tableNamesStr.first.first.toString();
        tableNamesStr;

        final tableNames =
            await state.value.queryMulti("show create table ?;", []);
      },
      orElse: () => '',
    );
  }
}
