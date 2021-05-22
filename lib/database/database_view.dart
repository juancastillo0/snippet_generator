import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snippet_generator/database/database_store.dart';
import 'package:snippet_generator/database/models/sql_values.dart';
import 'package:snippet_generator/fields/base_fields.dart';
import 'package:snippet_generator/fields/button_select_field.dart';
import 'package:snippet_generator/globals/hook_observer.dart';
import 'package:snippet_generator/parsers/sql/data_type_model.dart';
import 'package:snippet_generator/parsers/sql/table_models.dart';
import 'package:snippet_generator/types/root_store.dart';
import 'package:snippet_generator/types/views/code_generated.dart';
import 'package:snippet_generator/utils/formatters.dart';
import 'package:snippet_generator/utils/tt.dart';
import 'package:snippet_generator/widgets/horizontal_item_list.dart';

double get _columnSpacing => 14;
double get _dataRowHeight => 26;
double get _headingRowHeight => 32;
double get _horizontalMargin => 14;
BoxDecoration get _decoration => const BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Colors.transparent, width: 10),
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
                                  .dartClass(store.tablesOrEmpty) ??
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
                  final parseResult = store.tablesOrEmpty;
                  return HorizontalItemList<SqlTable>(
                    items: parseResult,
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
                child: ColumnsTable(),
              ),
              const _TableWrapper(
                title: 'Foreign Keys',
                child: ForeignKeysTable(),
              ),
              const _TableWrapper(
                title: 'Indexes',
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
  }) : super(key: key);

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
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

    Widget typeWidget(SqlType type) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 100,
            child: CustomDropdownField<TypeSqlType>(
              selected: type.typeEnum,
              asString: (v) => v.toString().split('.')[1],
              onChange: (v) {},
              options: TypeSqlType.values,
              padding: const EdgeInsets.only(),
            ),
          ),
          ...type.map(
            date: (date) sync* {
              yield SizedBox(
                width: 100,
                child: CustomDropdownField<SqlDateVariant>(
                  selected: date.type,
                  asString: (v) => v.toString().split('.')[1],
                  onChange: (v) {},
                  options: SqlDateVariant.values,
                  padding: const EdgeInsets.only(),
                ),
              );
              yield SizedBox(
                width: 80,
                child: IntInput(
                  label: 'fractionalSeconds',
                  onChanged: (fractionalSeconds) {},
                  value: date.fractionalSeconds,
                ),
              );
            },
            string: (date) sync* {},
            enumeration: (date) sync* {},
            integer: (date) sync* {},
            decimal: (date) sync* {},
            json: (date) sync* {},
          )
        ],
      );
    }

    final List<DataRow> rows;

    if (selectedTable == null) {
      rows = const [];
    } else {
      rows = selectedTable.columns.map(
        (e) {
          final pk = selectedTable.primaryKey;
          return DataRow(
            cells: [
              DataCell(TextFormField(
                key: const Key("name"),
                initialValue: e.name,
                inputFormatters: [Formatters.noWhitespaces],
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    store.replace(e.tokens!.name!, '`$value`');
                  }
                },
              )),
              DataCell(typeWidget(e.type)),
              DataCell(
                Checkbox(
                  value: e.nullable,
                  onChanged: (value) {
                    final token = e.tokens!.nullable!;
                    final str = value == true ? 'NULL' : 'NOT NULL';

                    store.replace(token, str);
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
                      final str = value == true ? 'UNIQUE (`${e.name}`)' : '';
                      final tableKey = selectedTable.tableKeys[_index];

                      store.replace(tableKey.token!, str);
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
                    maxLines: 1),
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
        DataColumn(label: Text('Nullable')),
        DataColumn(label: Text('Default')),
        DataColumn(label: Text('Unique')),
        DataColumn(label: Text('Reference')),
        DataColumn(label: Text('In Primary')),
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
        DataColumn(label: Text('Match')),
        DataColumn(label: Text('On Delete')),
        DataColumn(label: Text('On Update')),
      ],
      rows: selectedTable == null
          ? []
          : selectedTable.foreignKeys
              .map(
                (e) => DataRow(
                  cells: [
                    DataCell(
                        SelectableText(e.constraintName ?? '', maxLines: 1)),
                    DataCell(SelectableText(e.indexName ?? '', maxLines: 1)),
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
                    DataCell(SelectableText(
                        e.reference.matchType?.toJson() ?? '',
                        maxLines: 1)),
                    DataCell(SelectableText(e.reference.onDelete.toJson(),
                        maxLines: 1)),
                    DataCell(SelectableText(e.reference.onUpdate.toJson(),
                        maxLines: 1)),
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
      ],
      rows: selectedTable == null
          ? []
          : selectedTable.tableKeys
              .map(
                (e) => DataRow(
                  cells: [
                    DataCell(
                        SelectableText(e.constraintName ?? '', maxLines: 1)),
                    DataCell(SelectableText(e.indexName ?? '', maxLines: 1)),
                    DataCell(SelectableText(
                        e.columns
                            .map((e) =>
                                '${e.columnName}${e.ascendent ? "" : " DESC"}')
                            .join(' , '),
                        maxLines: 1)),
                    DataCell(SelectableText(e.indexType.toJson(), maxLines: 1)),
                    DataCell(
                        SelectableText(e.unique ? 'YES' : 'NO', maxLines: 1)),
                  ],
                ),
              )
              .toList(),
    );
  }
}
