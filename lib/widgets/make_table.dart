import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snippet_generator/utils/extensions.dart';

class MakeTableRow {
  final List<Widget> columns;

  const MakeTableRow({required this.columns});
}

class MakeTableCol {
  final double? minWidth;
  final double? maxWidth;
  final String name;

  const MakeTableCol({this.minWidth, this.maxWidth, required this.name});

  TableColumnWidth columnWidth(
    TableColumnWidth def, {
    double? defaultMinWidth,
    double? defaultMaxWidth,
  }) {
    TableColumnWidth width = def;
    if (minWidth != null) {
      width = MaxColumnWidth(width, FixedColumnWidth(minWidth!));
    } else if (defaultMinWidth != null) {
      width = MaxColumnWidth(width, FixedColumnWidth(defaultMinWidth));
    }
    if (maxWidth != null) {
      width = MinColumnWidth(width, FixedColumnWidth(maxWidth!));
    } else if (defaultMaxWidth != null) {
      width = MinColumnWidth(width, FixedColumnWidth(defaultMaxWidth));
    }
    return width;
  }
}

class MakeTable extends HookWidget {
  final List<MakeTableCol> columns;
  final List<MakeTableRow> rows;
  final bool simple;
  final double? minColumnWidth;
  final double? maxColumnWidth;
  final DataTableParams? params;
  final bool sticky;

  const MakeTable({
    Key? key,
    required this.columns,
    required this.rows,
    this.simple = true,
    this.minColumnWidth,
    this.maxColumnWidth,
    this.params,
    this.sticky = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // if (simple) {
    return SimpleTable(
      columns: columns,
      minColumnWidth: minColumnWidth,
      maxColumnWidth: maxColumnWidth,
      rows: rows,
    );
    // }
    // else if (sticky) {
    //   return StickyHeadersTable(
    //     rowsLength: rows.length,
    //     columnsLength: columns.length,
    //     rowsTitleBuilder: (index) => const SizedBox(),
    //     columnsTitleBuilder: (index) => Text(columns[index].name),
    //     contentCellBuilder: (col, row) =>
    //         SizedBox(width: 100, child: rows[row].columns[col]),
    //     // cellDimensions: CellDimensions.,
    //   );
    // }
    // return DataTable2(
    //   columnSpacing: params?.columnSpacing,
    //   dataRowHeight: params?.dataRowHeight,
    //   headingRowHeight: params?.headingRowHeight,
    //   horizontalMargin: params?.horizontalMargin,
    //   decoration: params?.decoration,
    //   columns: [
    //     ...columns.map(
    //       (e) => DataColumn(
    //         label: Text(e.name),
    //       ),
    //     )
    //   ],
    //   rows: [
    //     ...rows.map(
    //       (e) => DataRow(
    //         cells: [
    //           ...e.columns.map(
    //             (e) => DataCell(e),
    //           ),
    //         ],
    //       ),
    //     )
    //   ],
    // );
  }
}

class SimpleTable extends HookWidget {
  const SimpleTable({
    Key? key,
    required this.columns,
    required this.minColumnWidth,
    required this.maxColumnWidth,
    required this.rows,
    this.rowHeight = 28,
    this.expandToMaxWidth = true,
  }) : super(key: key);

  final List<MakeTableCol> columns;
  final double? minColumnWidth;
  final double? maxColumnWidth;
  final double rowHeight;
  final List<MakeTableRow> rows;
  final bool expandToMaxWidth;

  @override
  Widget build(BuildContext context) {
    final verticalScroll = useScrollController();
    final horizontalScroll = useScrollController();
    final innerColumnWidths = useState(<int, double>{});
    innerColumnWidths.value.removeWhere((key, value) => key >= columns.length);

    return LayoutBuilder(builder: (context, box) {
      final totalWidth = innerColumnWidths.value.values
          .fold<double>(0.0, (value, element) => value + element);
      final toAdd =
          expandToMaxWidth && totalWidth > 0 && totalWidth < box.maxWidth
              ? ((box.maxWidth - totalWidth) / columns.length)
              : 0;
      // FixedColumnWidth, FlexColumnWidth, FractionColumnWidth, IntrinsicColumnWidth, MinColumnWidth

      bool hasChanged = false;

      Widget wrapFirstCell(ItemIndex<Widget> item) {
        final index = item.index;
        return Builder(builder: (context) {
          if (toAdd == 0) {
            SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
              final curr = context.globalPaintBounds!.width.roundToDouble();
              hasChanged = hasChanged || innerColumnWidths.value[index] != curr;
              innerColumnWidths.value[index] = curr;
              if (index == columns.length - 1 && hasChanged) {
                innerColumnWidths.value = {...innerColumnWidths.value};
              }
            });
          }
          return item.item;
        });
      }

      final contentTable = Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: Map.fromEntries(
          columns.mapIndex(
            (e, index) {
              final innerWidth = innerColumnWidths.value[index];
              final _w = e.columnWidth(
                const IntrinsicColumnWidth(),
                defaultMinWidth: minColumnWidth,
                defaultMaxWidth: maxColumnWidth,
              );
              return MapEntry(
                index,
                toAdd != 0
                    ? MaxColumnWidth(
                        FixedColumnWidth(innerWidth! + toAdd),
                        _w,
                      )
                    : _w,
              );
            },
          ),
        ),
        children: [
          ...rows.mapIndex(
            (e, index) {
              final cols = index == 0
                  ? e.columns.indexed().map(wrapFirstCell).toList()
                  : e.columns;
              return TableRow(
                children: cols
                    .map(
                      (e) => SizedBox(
                        height: rowHeight,
                        child: e,
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      );

      final headerTable = Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: innerColumnWidths.value.length >= columns.length
            ? innerColumnWidths.value.map(
                (key, value) => MapEntry(key, FixedColumnWidth(value + toAdd)),
              )
            : null,
        children: [
          TableRow(
            decoration: const BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(color: Colors.black26),
              ),
            ),
            children: columns
                .map(
                  (e) => Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    alignment: Alignment.center,
                    child: Text(
                      e.name,
                      style: context.textTheme.subtitle2!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      );

      return Scrollbar(
        controller: horizontalScroll,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: horizontalScroll,
          child: Column(
            children: [
              headerTable,
              Expanded(
                child: Scrollbar(
                  controller: verticalScroll,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SingleChildScrollView(
                      controller: verticalScroll,
                      child: contentTable,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class Ref<T> {
  final T value;

  const Ref(this.value);
}

class DataTableParams {
  final double? columnSpacing;
  final double? dataRowHeight;
  final double? headingRowHeight;
  final double? horizontalMargin;
  final Decoration? decoration;

  const DataTableParams({
    this.columnSpacing,
    this.dataRowHeight,
    this.headingRowHeight,
    this.horizontalMargin,
    this.decoration,
  });

  DataTableParams copyWith({
    Ref<double?>? columnSpacing,
    Ref<double?>? dataRowHeight,
    Ref<double?>? headingRowHeight,
    Ref<double?>? horizontalMargin,
    Ref<Decoration?>? decoration,
  }) {
    return DataTableParams(
      columnSpacing:
          columnSpacing != null ? columnSpacing.value : this.columnSpacing,
      dataRowHeight:
          dataRowHeight != null ? dataRowHeight.value : this.dataRowHeight,
      headingRowHeight: headingRowHeight != null
          ? headingRowHeight.value
          : this.headingRowHeight,
      horizontalMargin: horizontalMargin != null
          ? horizontalMargin.value
          : this.horizontalMargin,
      decoration: decoration != null ? decoration.value : this.decoration,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is DataTableParams) {
      return this.columnSpacing == other.columnSpacing &&
          this.dataRowHeight == other.dataRowHeight &&
          this.headingRowHeight == other.headingRowHeight &&
          this.horizontalMargin == other.horizontalMargin &&
          this.decoration == other.decoration;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(
        columnSpacing,
        dataRowHeight,
        headingRowHeight,
        horizontalMargin,
        decoration,
      );
}
