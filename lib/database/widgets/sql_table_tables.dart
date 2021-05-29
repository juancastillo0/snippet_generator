import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snippet_generator/database/database_store.dart';
import 'package:snippet_generator/database/widgets/sql_type_field.dart';
import 'package:snippet_generator/database/widgets/select_columns.dart';
import 'package:snippet_generator/fields/button_select_field.dart';
import 'package:snippet_generator/globals/hook_observer.dart';
import 'package:snippet_generator/globals/option.dart';
import 'package:snippet_generator/parsers/sql/table_models.dart';
import 'package:snippet_generator/types/root_store.dart';
import 'package:snippet_generator/utils/extensions.dart';
import 'package:snippet_generator/utils/formatters.dart';
import 'package:snippet_generator/widgets/custom_overlay.dart';
import 'package:snippet_generator/widgets/custom_portal_entry.dart';
import 'package:snippet_generator/widgets/small_icon_button.dart';

double get _columnSpacing => 14;
double get _dataRowHeight => 26;
double get _headingRowHeight => 32;
double get _horizontalMargin => 14;
BoxDecoration get _decoration => const BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Colors.transparent, width: 14),
      ),
    );

class SqlTablesView extends StatelessWidget {
  const SqlTablesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 6,
      child: Column(
        children: const [
          _TableWrapper(
            title: 'Columns',
            valueToAdd: SqlColumn.defaultColumn,
            child: ColumnsTable(),
          ),
          _TableWrapper(
            title: 'Foreign Keys',
            valueToAdd: SqlForeignKey.defaultForeignKey,
            child: ForeignKeysTable(),
          ),
          _TableWrapper(
            title: 'Indexes',
            valueToAdd: SqlTableKey.defaultTableKey,
            child: IndexesTable(),
          ),
        ],
      ),
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
                    value: e.unique || _index != -1,
                    onChanged: _index != -1 &&
                            selectedTable.tableKeys[_index].primary
                        ? null
                        : (value) {
                            if (e.unique) {
                              final newTable = selectedTable.replaceColumn(
                                e.copyWith(unique: false),
                                colIndex,
                              );
                              store.replaceSelectedTable(newTable);
                              return;
                            }
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
                Checkbox(
                  value: pk != null &&
                      pk.columns.any(
                        (col) => col.columnName == e.name,
                      ),
                  onChanged: (value) {
                    final _index = selectedTable.tableKeys
                        .indexWhere((col) => col.primary);
                    final SqlTable newTable;
                    if (_index != -1) {
                      final key = selectedTable.tableKeys[_index];
                      final _colIndex = key.columns
                          .map((c) => c.columnName)
                          .toList()
                          .indexWhere((n) => n == e.name);
                      newTable = selectedTable.replaceTableKey(
                        key.copyWith(
                          columns: _colIndex == -1
                              ? [
                                  ...key.columns,
                                  SqlKeyItem(
                                    ascendent: true,
                                    columnName: e.name,
                                  )
                                ]
                              : [
                                  ...key.columns
                                      .where((col) => col.columnName != e.name),
                                ],
                        ),
                        _index,
                      );
                    } else if (value == true) {
                      final _pk = pk ?? SqlTableKey.primary(columns: []);
                      final tableKey = _pk.copyWith(columns: [
                        ..._pk.columns,
                        SqlKeyItem(
                          ascendent: true,
                          columnName: e.name,
                        ),
                      ]);
                      newTable = selectedTable.copyWith(
                          tableKeys: [...selectedTable.tableKeys, tableKey]);
                    } else {
                      final tableKey = pk!.copyWith(columns: [
                        ...pk.columns.where((c) => c.columnName != e.name),
                      ]);
                      newTable = selectedTable.copyWith(
                          tableKeys: [...selectedTable.tableKeys, tableKey]);
                    }
                    store.replaceSelectedTable(newTable);
                  },
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
                    DataCell(CustomOverlayButton(
                      portalBuilder: (p) => Card(
                        child: SelectColumnsField(
                          value: e.columns,
                          selectedTable: selectedTable,
                          onChange: (v) {
                            final newTable = selectedTable.replaceTableKey(
                              e.copyWith(columns: v),
                              keyIndex,
                            );
                            store.replaceSelectedTable(newTable);
                            p.hide();
                          },
                        ),
                      ),
                      child: Text(
                        e.columns
                            .map((e) =>
                                '${e.columnName}${e.ascendent ? "" : " DESC"}')
                            .join(' , '),
                        maxLines: 1,
                      ),
                    )),
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
                        child: CustomOverlayButton(
                          portalBuilder: (p) => Container(
                            height: 100,
                            width: 150,
                            color: Colors.red,
                          ),
                          child: const Icon(Icons.delete),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
    );
  }
}
