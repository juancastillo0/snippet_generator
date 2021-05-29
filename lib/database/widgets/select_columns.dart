import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snippet_generator/globals/option.dart';
import 'package:snippet_generator/parsers/sql/table_models.dart';
import 'package:snippet_generator/utils/extensions.dart';

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
    }, [value]);

    final list = listState.value;
    void rebuild() {
      listState.value = [...list];
    }

    final color = Theme.of(context).colorScheme;
    print(color);

    return Container(
      height: 350,
      width: 270,
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        children: [
          const Text('Columns'),
          Row(
            children: [
              const Expanded(child: Text("Column")),
              const Text('Include'),
              const SizedBox(
                width: 32,
                child: Center(child: Text('Asc')),
              ),
            ],
          ),
          Expanded(
            child: ListView(
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
                                key: Key("t$colIndex"),
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
                                key: Key("b$colIndex"),
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
                              list[colIndex] = col.copyWith(last: const None());
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
          Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.only(top: 15),
            child: OutlinedButton(
              onPressed: () {
                onChange(
                  list.map((e) => e.last).whereType<SqlKeyItem>().toList(),
                );
              },
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
