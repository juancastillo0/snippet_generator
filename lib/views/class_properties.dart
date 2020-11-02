import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:reorderables/reorderables.dart';
import 'package:snippet_generator/formatters.dart';
import 'package:snippet_generator/models/models.dart';
import 'package:snippet_generator/models/root_store.dart';
import 'package:snippet_generator/models/type_models.dart';
import 'package:snippet_generator/widgets.dart';
import 'package:super_tooltip/super_tooltip.dart';

class ClassPropertiesTable extends StatelessWidget {
  const ClassPropertiesTable({Key key, @required this.data}) : super(key: key);
  final ClassConfig data;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => RootStore.of(context).selectClass(data),
      child: Card(
        margin: const EdgeInsets.only(top: 10.0, bottom: 8.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18.0),
          child: Column(
            children: [
              data.typeConfig.isSumTypeNotifier.rebuild(
                (isSumType) => isSumType
                    ? Row(
                        children: [
                          RowTextField(
                            controller: data.nameNotifier.controller,
                            label: "Class Name",
                          ),
                          const Spacer(),
                          RaisedButton.icon(
                            onPressed: () =>
                                data.typeConfig.classes.remove(data),
                            icon: const Icon(Icons.delete),
                            label: const Text("Remove Class"),
                          )
                        ],
                      )
                    : const SizedBox(),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                // const BoxConstraints(maxHeight: 300, maxWidth: 520),
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: data.properties.rebuild(
                      () {
                        const columnSizes = <double>[200.0, 200, 40, 40, 40];
                        const _contraints =
                            BoxConstraints(minWidth: 100, maxWidth: 200);
                        return DataTable(
                          columnSpacing: 20,
                          columns: <DataColumn>[
                            DataColumn(
                              label: ConstrainedBox(
                                constraints: _contraints,
                                child: const Text('Field Name'),
                              ),
                            ),
                            DataColumn(
                              label: ConstrainedBox(
                                constraints: _contraints,
                                child: const Text('Type'),
                              ),
                            ),
                            const DataColumn(
                              tooltip: "Required",
                              label: Text('Req.'),
                            ),
                            const DataColumn(
                              tooltip: 'Positional',
                              label: Text('Pos.'),
                            ),
                            const DataColumn(
                              label: Text('More'),
                            ),
                          ],
                          // onReorder: (index1, index2) {
                          //   data.properties.syncTransaction(() {
                          //     final temp = data.properties[index1];
                          //     data.properties[index1] = data.properties[index2];
                          //     data.properties[index2] = temp;
                          //   });
                          // },
                          rows: data.properties
                              .map(
                                // (p) => ReorderableTableRow(
                                //   key: Key(p.key),
                                //   children: _makeRowChildren(p).zip<Widget, double>(
                                //     columnSizes,
                                //     (w, size) {
                                //       print(size);
                                //       return SizedBox(
                                //         width: size,
                                //         child: w,
                                //       );
                                //     },
                                //   ).toList(),
                                // ),
                                (p) => DataRow(
                                  cells: _makeRowChildren(p)
                                      .map((e) => DataCell(e))
                                      .toList(),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 7),
              RaisedButton.icon(
                onPressed: data.addProperty,
                icon: const Icon(Icons.add),
                label: const Text("Add Field"),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _makeRowChildren(PropertyField property) {
    final typeNotifier = property.typeNotifier;
    return [
      TextField(
        controller: property.nameNotifier.controller,
        inputFormatters: Formatters.variableName,
      ),
      AnimatedBuilder(
        animation: Listenable.merge(
          [typeNotifier.textNotifier, typeNotifier.focusNode],
        ),
        builder: (context, _) {
          final options = supportedJsonTypes
              .where((e) =>
                  e.toLowerCase().contains(property.type.toLowerCase()) &&
                  property.type != e)
              .toList();
          return PortalEntry(
            visible:
                typeNotifier.focusNode.hasPrimaryFocus && options.isNotEmpty,
            portalAnchor: Alignment.topCenter,
            childAnchor: Alignment.bottomCenter,
            portal: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              width: 100,
              margin: const EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 2,
                    spreadRadius: 1,
                    offset: Offset(0, 1.5),
                    color: Colors.black12,
                  )
                ],
              ),
              child: ListView(
                itemExtent: 32,
                shrinkWrap: true,
                children: [
                  ...options.map(
                    (e) => FlatButton(
                      onPressed: () {
                        typeNotifier.controller.value = TextEditingValue(
                          text: e,
                          selection: TextSelection.collapsed(
                            offset: e.length,
                          ),
                        );
                      },
                      key: Key(e),
                      child: Text(e),
                    ),
                  )
                ],
              ),
            ),
            child: TextField(
              controller: typeNotifier.controller,
              focusNode: typeNotifier.focusNode,
            ),
          );
        },
      ),
      Center(
        child: property.isRequiredNotifier.rebuild(
          (isRequired) => Checkbox(
            value: isRequired,
            onChanged: property.isRequiredNotifier.set,
          ),
        ),
      ),
      Center(
        child: property.isPositionalNotifier.rebuild(
          (isPositional) => Checkbox(
            value: isPositional,
            onChanged: property.isPositionalNotifier.set,
          ),
        ),
      ),
      Builder(
        builder: (context) {
          return IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              SuperTooltip tooltip;
              tooltip = SuperTooltip(
                popupDirection: TooltipDirection.up,
                arrowLength: 10,
                borderColor: Colors.black12,
                borderWidth: 1,
                hasShadow: false,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RaisedButton.icon(
                      onPressed: () {
                        tooltip.close();
                        data.properties.remove(property);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text("Remove Field"),
                    ),
                  ],
                ),
              );

              tooltip.show(context);
            },
          );
        },
      ),
    ];
  }
}

extension IndexedMap<T> on Iterable<T> {
  Iterable<V> mapIndex<V>(V Function(T, int) f) {
    int i = 0;
    return this.map((v) => f(v, i++));
  }

  Iterable<O> zip<O, V>(Iterable<V> it, O Function(T, V) f) sync* {
    final iterator = it.iterator;
    for (final v in this) {
      if (iterator.moveNext()) {
        yield f(v, iterator.current);
      } else {
        break;
      }
    }
  }
}
