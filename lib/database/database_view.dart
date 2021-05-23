import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snippet_generator/database/database_store.dart';
import 'package:snippet_generator/database/models/sql_values.dart';
import 'package:snippet_generator/database/sql_type_field.dart';
import 'package:snippet_generator/fields/button_select_field.dart';
import 'package:snippet_generator/globals/hook_observer.dart';
import 'package:snippet_generator/globals/option.dart';
import 'package:snippet_generator/parsers/sql/table_models.dart';
import 'package:snippet_generator/types/root_store.dart';
import 'package:snippet_generator/types/views/code_generated.dart';
import 'package:snippet_generator/utils/extensions.dart';
import 'package:snippet_generator/utils/formatters.dart';
import 'package:snippet_generator/utils/tt.dart';
import 'package:snippet_generator/widgets/custom_portal_entry.dart';
import 'package:snippet_generator/widgets/horizontal_item_list.dart';

double get _columnSpacing => 14;
double get _dataRowHeight => 26;
double get _headingRowHeight => 32;
double get _horizontalMargin => 14;
BoxDecoration get _decoration => const BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Colors.transparent, width: 14),
      ),
    );

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
                            sourceCode: _sqlQuery,
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
        Expanded(
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
              const _TableWrapper(
                title: 'Columns',
                valueToAdd: SqlColumn.defaultColumn,
                child: ColumnsTable(),
              ),
              const _TableWrapper(
                title: 'Foreign Keys',
                valueToAdd: SqlForeignKey.defaultForeignKey,
                child: ForeignKeysTable(),
              ),
              const _TableWrapper(
                title: 'Indexes',
                valueToAdd: SqlTableKey.defaultTableKey,
                child: IndexesTable(),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _TableWrapper extends HookWidget {
  const _TableWrapper({
    Key? key,
    required this.title,
    required this.child,
    required this.valueToAdd,
  }) : super(key: key);

  final String title;
  final Widget child;
  final Object valueToAdd;

  @override
  Widget build(BuildContext context) {
    final store = useRootStore(context).databaseStore;
    final _verticalScroll = useScrollController();
    final _horizontalScroll = useScrollController();
    final showTable = useState(true);

    final topWidget = Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          IconButton(
            splashRadius: 24,
            onPressed: () {
              showTable.value = !showTable.value;
            },
            icon: Icon(
              showTable.value
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
            ),
          )
        ],
      ),
    );
    if (!showTable.value) {
      return topWidget;
    }
    return Flexible(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          topWidget,
          Expanded(
            child: Scrollbar(
              controller: _verticalScroll,
              child: SingleChildScrollView(
                controller: _verticalScroll,
                child: Scrollbar(
                  controller: _horizontalScroll,
                  child: SingleChildScrollView(
                    controller: _horizontalScroll,
                    scrollDirection: Axis.horizontal,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(right: 12, top: 4),
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: store.selectedTable.value == null
                  ? null
                  : () {
                      final selectedTable = store.selectedTable.value!;
                      final SqlTable newTable;
                      final toAdd = valueToAdd;
                      if (toAdd is SqlColumn) {
                        newTable = selectedTable.copyWith(
                            columns: [...selectedTable.columns, toAdd]);
                      } else if (toAdd is SqlTableKey) {
                        newTable = selectedTable.copyWith(
                            tableKeys: [...selectedTable.tableKeys, toAdd]);
                      } else if (toAdd is SqlForeignKey) {
                        newTable = selectedTable.copyWith(
                            foreignKeys: [...selectedTable.foreignKeys, toAdd]);
                      } else {
                        throw Error();
                      }
                      store.replaceSelectedTable(newTable);
                    },
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          )
        ],
      ),
    );
  }
}

class ColumnsTable extends HookObserverWidget {
  const ColumnsTable({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final root = useRootStore(context);
    final DatabaseStore store = root.databaseStore;
    final selectedTable = store.selectedTable.value;

    Widget typeWidget(SqlColumn col) {
      final type = col.type;
      return CustomPortalEntry(
        portal: SqlTypeField(
          value: type,
          onChange: (newValue) {
            final newCol = col.copyWith(type: newValue);
            final newTable = selectedTable!.replaceColumn(
              newCol,
              selectedTable.columns.indexOf(col),
            );
            store.replaceTable(
              newTable,
              store.tables.value.indexOf(selectedTable),
            );
          },
        ),
        child: Text(type.toSql()),
      );
    }

    final List<DataRow> rows;

    if (selectedTable == null) {
      rows = const [];
    } else {
      rows = selectedTable.columns.mapIndex(
        (e, colIndex) {
          final pk = selectedTable.primaryKey;
          return DataRow(
            cells: [
              DataCell(TextFormField(
                key: const Key("name"),
                initialValue: e.name,
                inputFormatters: [Formatters.noWhitespaces],
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    final newTable = selectedTable.replaceColumn(
                      e.copyWith(name: value),
                      colIndex,
                    );
                    store.replaceSelectedTable(newTable);
                  }
                },
              )),
              DataCell(typeWidget(e)),
              DataCell(
                Checkbox(
                  value: e.nullable,
                  onChanged: (value) {
                    final newTable = selectedTable.replaceColumn(
                      e.copyWith(nullable: !e.nullable),
                      colIndex,
                    );
                    store.replaceSelectedTable(newTable);
                  },
                ),
              ),
              DataCell(SelectableText(
                  e.defaultValue ?? (e.nullable ? 'NULL' : ''),
                  maxLines: 1)),
              DataCell(
                Builder(builder: (context) {
                  final _index = selectedTable.tableKeys.indexWhere((k) =>
                      k.columns.length == 1 &&
                      k.columns.first.columnName == e.name &&
                      k.unique);
                  return Checkbox(
                    value: _index != -1,
                    onChanged: (value) {
                      final newTableKeys = [...selectedTable.tableKeys];
                      if (_index != -1) {
                        newTableKeys.removeAt(_index);
                      } else {
                        newTableKeys.add(SqlTableKey(
                          primary: false,
                          unique: true,
                          indexType: null,
                          columns: [
                            SqlKeyItem(
                              columnName: e.name,
                              ascendent: true,
                            )
                          ],
                        ));
                      }
                      final newTable = selectedTable.copyWith(
                        tableKeys: newTableKeys,
                      );
                      store.replaceSelectedTable(newTable);
                    },
                  );
                }),
              ),
              DataCell(
                Builder(builder: (context) {
                  final list = selectedTable.foreignKeys
                      .expand((k) => k.colItems())
                      .toList();
                  final _index = list.indexWhere((k) => k.second == e.name);
                  final found = _index == -1 ? null : list[_index];
                  final reference = found?.first.reference;
                  final keyItem = found?.last;
                  return SelectableText(
                      reference != null && keyItem != null
                          ? '${reference.referencedTable}'
                              '(${keyItem.columnName}${keyItem.ascendent ? "" : " DESC"})'
                          : '',
                      maxLines: 1);
                }),
              ),
              DataCell(
                SelectableText(
                  pk != null &&
                          pk.columns.any(
                            (col) => col.columnName == e.name,
                          )
                      ? 'YES'
                      : 'NO',
                  maxLines: 1,
                ),
              ),
              DataCell(
                SmallIconButton(
                  onPressed: () {
                    final newTable =
                        selectedTable.replaceColumn(null, colIndex);
                    store.replaceSelectedTable(newTable);
                  },
                  child: const Icon(Icons.delete),
                ),
              ),
            ],
          );
        },
      ).toList();
    }
    return DataTable(
      columnSpacing: _columnSpacing,
      dataRowHeight: _dataRowHeight,
      headingRowHeight: _headingRowHeight,
      horizontalMargin: _horizontalMargin,
      decoration: _decoration,
      columns: const [
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Type')),
        DataColumn(label: Text('Null')),
        DataColumn(label: Text('Default')),
        DataColumn(label: Text('Unique')),
        DataColumn(label: Text('Reference')),
        DataColumn(label: Text('Primary')),
        DataColumn(label: Text('Delete')),
      ],
      rows: rows,
    );
  }
}

class ForeignKeysTable extends HookObserverWidget {
  const ForeignKeysTable({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = useRootStore(context).databaseStore;
    final selectedTable = store.selectedTable.value;

    return DataTable(
      columnSpacing: _columnSpacing,
      dataRowHeight: _dataRowHeight,
      headingRowHeight: _headingRowHeight,
      horizontalMargin: _horizontalMargin,
      decoration: _decoration,
      columns: const [
        DataColumn(label: Text('Constraint')),
        DataColumn(label: Text('Index')),
        DataColumn(label: Text('Columns')),
        DataColumn(label: Text('Reference')),
        // DataColumn(label: Text('Match')),
        DataColumn(label: Text('On Delete')),
        DataColumn(label: Text('On Update')),
        DataColumn(label: Text('Delete')),
      ],
      rows: selectedTable == null
          ? []
          : selectedTable.foreignKeys
              .mapIndex(
                (e, keyIndex) => DataRow(
                  cells: [
                    DataCell(TextFormField(
                      initialValue: e.constraintName,
                      inputFormatters: [Formatters.noWhitespaces],
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          final newTable = selectedTable.replaceForeignKey(
                            e.copyWith(constraintName: Some(value)),
                            keyIndex,
                          );
                          store.replaceSelectedTable(newTable);
                        }
                      },
                    )),
                    DataCell(TextFormField(
                      initialValue: e.indexName,
                      inputFormatters: [Formatters.noWhitespaces],
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          final newTable = selectedTable.replaceForeignKey(
                            e.copyWith(indexName: Some(value)),
                            keyIndex,
                          );
                          store.replaceSelectedTable(newTable);
                        }
                      },
                    )),
                    DataCell(
                        SelectableText(e.ownColumns.join(' , '), maxLines: 1)),
                    DataCell(
                      SelectableText(
                          e.reference.referencedTable +
                              '(' +
                              e.reference.columns
                                  .map((e) =>
                                      '${e.columnName}${e.ascendent ? "" : " DESC"}')
                                  .join(' , ') +
                              ')',
                          maxLines: 1),
                    ),
                    // DataCell(CustomDropdownField<ReferenceMatchType?>(
                    //   selected: e.reference.matchType,
                    //   asString: (v) => v?.toJson() ?? '-',
                    //   onChange: (v) {
                    //     final newTable = selectedTable.replaceForeignKey(
                    //       e.copyWith(
                    //         reference: e.reference.copyWith(
                    //           matchType: Some(v!),
                    //         ),
                    //       ),
                    //       keyIndex,
                    //     );
                    //     store.replaceSelectedTable(newTable);
                    //   },
                    //   padding: const EdgeInsets.only(left: 4),
                    //   options: ReferenceMatchType.values,
                    // )),
                    DataCell(CustomDropdownField<ReferenceOption>(
                      selected: e.reference.onDelete,
                      asString: (v) => v.toJson(),
                      onChange: (v) {
                        final newTable = selectedTable.replaceForeignKey(
                          e.copyWith(
                            reference: e.reference.copyWith(
                              onDelete: v,
                            ),
                          ),
                          keyIndex,
                        );
                        store.replaceSelectedTable(newTable);
                      },
                      padding: const EdgeInsets.only(left: 4),
                      options: ReferenceOption.values,
                    )),
                    DataCell(CustomDropdownField<ReferenceOption>(
                      selected: e.reference.onUpdate,
                      asString: (v) => v.toJson(),
                      onChange: (v) {
                        final newTable = selectedTable.replaceForeignKey(
                          e.copyWith(
                            reference: e.reference.copyWith(
                              onUpdate: v,
                            ),
                          ),
                          keyIndex,
                        );
                        store.replaceSelectedTable(newTable);
                      },
                      padding: const EdgeInsets.only(left: 4),
                      options: ReferenceOption.values,
                    )),
                    DataCell(
                      SmallIconButton(
                        onPressed: () {
                          final newTable =
                              selectedTable.replaceForeignKey(null, keyIndex);
                          store.replaceSelectedTable(newTable);
                        },
                        child: const Icon(Icons.delete),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
    );
  }
}

class IndexesTable extends HookObserverWidget {
  const IndexesTable({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = useRootStore(context).databaseStore;
    final selectedTable = store.selectedTable.value;

    return DataTable(
      columnSpacing: _columnSpacing,
      dataRowHeight: _dataRowHeight,
      headingRowHeight: _headingRowHeight,
      horizontalMargin: _horizontalMargin,
      decoration: _decoration,
      columns: const [
        DataColumn(label: Text('Constraint')),
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Columns')),
        DataColumn(label: Text('Type')),
        DataColumn(label: Text('Unique')),
        DataColumn(label: Text('Delete')),
      ],
      rows: selectedTable == null
          ? []
          : selectedTable.tableKeys
              .mapIndex(
                (e, keyIndex) => DataRow(
                  cells: [
                    DataCell(TextFormField(
                      initialValue: e.constraintName,
                      inputFormatters: [Formatters.noWhitespaces],
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          final newTable = selectedTable.replaceTableKey(
                            e.copyWith(constraintName: Some(value)),
                            keyIndex,
                          );
                          store.replaceSelectedTable(newTable);
                        }
                      },
                    )),
                    DataCell(e.primary
                        ? SelectableText(e.indexName ?? '', maxLines: 1)
                        : TextFormField(
                            initialValue: e.indexName,
                            inputFormatters: [Formatters.noWhitespaces],
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                final newTable = selectedTable.replaceTableKey(
                                  e.copyWith(indexName: Some(value)),
                                  keyIndex,
                                );
                                store.replaceSelectedTable(newTable);
                              }
                            },
                          )),
                    DataCell(SelectableText(
                        e.columns
                            .map((e) =>
                                '${e.columnName}${e.ascendent ? "" : " DESC"}')
                            .join(' , '),
                        maxLines: 1)),
                    DataCell(CustomDropdownField<SqlIndexType>(
                      selected: e.indexType,
                      asString: (v) => v.toJson(),
                      onChange: (v) {
                        final newTable = selectedTable.replaceTableKey(
                          e.copyWith(indexType: v),
                          keyIndex,
                        );
                        store.replaceSelectedTable(newTable);
                      },
                      padding: const EdgeInsets.only(left: 4),
                      options: e.primary
                          ? const [SqlIndexType.HASH, SqlIndexType.BTREE]
                          : SqlIndexType.values,
                    )),
                    DataCell(
                      Checkbox(
                        value: e.indexType.canBeUnique && e.unique,
                        onChanged: !e.indexType.canBeUnique || e.primary
                            ? null
                            : (v) {
                                final newTable = selectedTable.replaceTableKey(
                                  e.copyWith(unique: !e.unique),
                                  keyIndex,
                                );
                                store.replaceSelectedTable(newTable);
                              },
                      ),
                    ),
                    DataCell(
                      SmallIconButton(
                        onPressed: () {
                          final newTable =
                              selectedTable.replaceTableKey(null, keyIndex);
                          store.replaceSelectedTable(newTable);
                        },
                        child: const Icon(Icons.delete),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
    );
  }
}

class SmallIconButton extends StatelessWidget {
  final bool center;
  final void Function()? onPressed;
  final Widget child;

  const SmallIconButton({
    Key? key,
    this.center = true,
    required this.child,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _button = IconButton(
      icon: child,
      constraints: const BoxConstraints(),
      alignment: Alignment.center,
      padding: EdgeInsets.zero,
      splashRadius: 22,
      iconSize: 18,
      onPressed: onPressed,
    );

    return Center(
      child: _button,
    );
  }
}
