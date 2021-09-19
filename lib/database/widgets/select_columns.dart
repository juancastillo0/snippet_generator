import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snippet_generator/database/models/parsers/table_models.dart';
import 'package:snippet_generator/fields/button_select_field.dart';
import 'package:snippet_generator/globals/option.dart';
import 'package:snippet_generator/utils/extensions.dart';
import 'package:snippet_generator/widgets/globals.dart';
import 'package:stack_portal/stack_portal.dart';

class SelectReferenceColumnsField extends HookWidget {
  final List<SqlTable> tables;
  final void Function(SqlReference) onChange;
  final SqlReference value;

  const SelectReferenceColumnsField({
    required this.tables,
    required this.onChange,
    required this.value,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tableIndex = useState(0);

    useEffect(() {
      if (tables.length <= tableIndex.value) {
        tableIndex.value = 0;
      }
    }, [tables]);

    final selectedTable = tables[tableIndex.value];

    return SizedBox(
      width: 270,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0, left: 4, bottom: 10),
            child: CustomDropdownField<SqlTable>(
              options: tables,
              asString: (t) => t.name,
              onChange: (t) {
                tableIndex.value = tables.indexOf(t);
              },
              selected: selectedTable,
            ),
          ),
          SelectColumnsField(
            onChange: (columns) {
              onChange(value.copyWith(
                columns: columns,
                referencedTable: selectedTable.name,
              ));
            },
            selectedTable: selectedTable,
            value: selectedTable.name == value.referencedTable
                ? value.columns
                : const [],
          ),
        ],
      ),
    );
  }
}

class SelectColumnsField extends HookWidget {
  const SelectColumnsField({
    Key? key,
    required this.value,
    required this.selectedTable,
    required this.onChange,
  }) : super(key: key);

  final List<SqlKeyItem> value;
  final SqlTable selectedTable;
  final void Function(List<SqlKeyItem>) onChange;

  @override
  Widget build(BuildContext context) {
    final listState = useState<List<Tuple3<int, String, SqlKeyItem?>>>([]);

    final _scrollController = useScrollController();

    useEffect(() {
      listState.value.sort((a, b) {
        final ap = a.last != null ? 2 : 0;
        final bp = b.last != null ? 2 : 0;
        return bp - ap;
      });
    }, [listState.value]);

    useEffect(() {
      final _m = Map.fromEntries(
        value.map((e) => MapEntry(e.columnName, e)),
      );
      int index = 0;
      final newList = <Tuple3<int, String, SqlKeyItem?>>[
        ...value.map((e) => Tuple3(
              index++,
              e.columnName,
              e,
            )),
        ...selectedTable.columns
            .map(
              (e) => _m.containsKey(e.name)
                  ? null
                  : Tuple3<int, String, SqlKeyItem?>(
                      index++,
                      e.name,
                      null,
                    ),
            )
            .whereType<Tuple3<int, String, SqlKeyItem?>>()
      ];
      listState.value = newList;
    }, [value, selectedTable.columns]);

    final list = listState.value;
    void rebuild() {
      listState.value = [...list];
    }

    return SizedBox(
      width: 270,
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(child: Text('Column')),
              Text('Include'),
              SizedBox(
                width: 32,
                child: Center(child: Text('Asc')),
              ),
              SizedBox(width: 10),
            ],
          ),
          SizedBox(
            height: 250,
            child: Scrollbar(
              isAlwaysShown: true,
              controller: _scrollController,
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.only(right: 10),
                children: [
                  ...list.mapIndex(
                    (col, colIndex) {
                      return Row(
                        key: ValueKey(col.first),
                        children: [
                          if (col.last != null)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  key: Key('t$colIndex'),
                                  onPressed: colIndex != 0
                                      ? () {
                                          list[colIndex] = list[colIndex - 1];
                                          list[colIndex - 1] = col;
                                          rebuild();
                                        }
                                      : null,
                                  style: TextButton.styleFrom(
                                      minimumSize: Size.zero),
                                  child: const Icon(
                                    Icons.arrow_drop_up,
                                    size: 15,
                                    // color: colIndex != 0
                                    //     ? Colors.black
                                    //     : Colors.black12,
                                  ),
                                ),
                                TextButton(
                                  key: Key('b$colIndex'),
                                  onPressed: colIndex != list.length - 1
                                      ? () {
                                          list[colIndex] = list[colIndex + 1];
                                          list[colIndex + 1] = col;
                                          rebuild();
                                        }
                                      : null,
                                  style: TextButton.styleFrom(
                                      minimumSize: Size.zero),
                                  child: const Icon(
                                    Icons.arrow_drop_down,
                                    size: 15,
                                    // color: colIndex != list.length - 1
                                    //     ? Colors.black
                                    //     : Colors.black12,
                                  ),
                                )
                              ],
                            ),
                          if (col.last != null) const SizedBox(width: 5),
                          Expanded(child: Text(col.second)),
                          Checkbox(
                            value: col.last != null,
                            onChanged: (v) {
                              if (col.last != null) {
                                list[colIndex] =
                                    col.copyWith(last: const None());
                              } else {
                                list[colIndex] = col.copyWith(
                                  last: Some(SqlKeyItem(
                                    columnName: col.second,
                                    ascendent: true,
                                  )),
                                );
                              }
                              rebuild();
                            },
                          ),
                          const SizedBox(width: 8),
                          Checkbox(
                            value: col.last?.ascendent ?? false,
                            onChanged: col.last != null
                                ? (asc) {
                                    list[colIndex] = col.copyWith(
                                      last: Some(SqlKeyItem(
                                        columnName: col.second,
                                        ascendent: asc!,
                                      )),
                                    );
                                    rebuild();
                                  }
                                : null,
                          ),
                        ],
                      );
                    },
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          DialogRowButton(
            onSave: () {
              onChange(
                list.map((e) => e.last).whereType<SqlKeyItem>().toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class DialogRowButton extends StatelessWidget {
  const DialogRowButton({
    Key? key,
    required this.onSave,
  }) : super(key: key);

  final void Function() onSave;

  @override
  Widget build(BuildContext context) {
    final notifier = Inherited.maybeOf<PortalNotifier>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (notifier != null)
          OutlinedButton(
            onPressed: notifier.hide,
            child: const Text('Close'),
          )
        else
          const SizedBox(),
        OutlinedButton(
          onPressed: onSave,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
