import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snippet_generator/database/database_store.dart';
import 'package:snippet_generator/database/models/sql_values.dart';
import 'package:snippet_generator/database/widgets/sql_table_tables.dart';
import 'package:snippet_generator/parsers/sql/table_models.dart';
import 'package:snippet_generator/types/root_store.dart';
import 'package:snippet_generator/types/views/code_generated.dart';
import 'package:snippet_generator/utils/tt.dart';
import 'package:snippet_generator/widgets/horizontal_item_list.dart';
import 'package:snippet_generator/widgets/resizable_scrollable/resizable.dart';

class DatabaseTabView extends HookWidget {
  const DatabaseTabView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final root = useRootStore(context);

    final DatabaseStore store = root.databaseStore;
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Observer(builder: (context) {
            final tab = store.selectedTab;

            return Column(
              children: [
                HorizontalItemList<TextView>(
                  items: TextView.values,
                  onSelected: (v, index) {
                    tab.value = v;
                  },
                  selected: tab.value,
                  buildItem: (e) {
                    const _m = {
                      TextView.import: 'Import Sql',
                      TextView.dartCode: 'Dart Code',
                      TextView.sqlCode: 'Sql Code',
                      TextView.sqlBuilder: 'Sql Builder',
                    };
                    return Text(
                      _m[e]!,
                    );
                  },
                ),
                Expanded(
                  child: IndexedStack(
                    index: tab.value.index,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: LayoutBuilder(
                          builder: (context, box) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Observer(builder: (context) {
                                final list =
                                    store.rawTableDefinition.value.split('\n');
                                final _maxCharacters = list.isEmpty
                                    ? 100
                                    : list
                                        .reduce(
                                          (value, element) =>
                                              value.length > element.length
                                                  ? value
                                                  : element,
                                        )
                                        .length;
                                final _w = _maxCharacters * 8 + 20.0;
                                return SizedBox(
                                  width: box.maxWidth > _w ? box.maxWidth : _w,
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                    style: GoogleFonts.cousine(fontSize: 13),
                                    controller:
                                        store.rawTableDefinition.controller,
                                    expands: true,
                                    maxLines: null,
                                    minLines: null,
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: CodeGenerated(
                          sourceCode: store.selectedTable.value?.templates
                                  .dartClass(store.tables.value) ??
                              'Invalid SQL Code',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Builder(builder: (context) {
                          return CodeGenerated(
                            sourceCode: store.selectedTable.value?.sqlTemplates
                                    .toSql() ??
                                'Invalid SQL Code',
                          );
                        }),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Builder(builder: (context) {
                          final cols = MessageCols('message');
                          final _sqlQuery = Message.selectSql(
                            database: SqlDatabase.mysql,
                            unsafe: true,
                            withRoom: true,
                            limit: const SqlLimit(100, offset: 50),
                            orderBy: [
                              SqlOrderItem(cols.numId, nullsFirst: true),
                            ],
                            where: cols.read
                                .equalTo(4.sql)
                                .or(cols.text.like('%bbb%')),
                          );
                          return CodeGenerated(
                            sourceCode: _sqlQuery.query,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
        Resizable(
          horizontal: ResizeHorizontal.left,
          flex: 5,
          child: Column(
            children: [
              Observer(
                builder: (context) {
                  final tables = store.tables.value;
                  return HorizontalItemList<SqlTable>(
                    items: tables,
                    onSelected: (_, index) {
                      store.selectIndex(index);
                    },
                    selected: store.selectedTable.value,
                    buildItem: (e) => Text(e.name),
                  );
                },
              ),
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Observer(
                    builder: (context) {
                      final parseResult = store.parsedTableDefinition.value;
                      return Text(parseResult.toString());
                    },
                  ),
                ),
              ),
              const SqlTablesView(),
            ],
          ),
        )
      ],
    );
  }
}
