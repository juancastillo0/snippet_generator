import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:snippet_generator/utils/extensions.dart';
import 'package:snippet_generator/formatters.dart';
import 'package:snippet_generator/models/models.dart';
import 'package:snippet_generator/models/rebuilder.dart';
import 'package:snippet_generator/models/root_store.dart';
import 'package:snippet_generator/models/type_models.dart';
import 'package:snippet_generator/widgets.dart';
import 'package:super_tooltip/super_tooltip.dart';

class ClassPropertiesTable extends HookWidget {
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
                key: const Key("header"),
              ),
              ConstrainedBox(
                key: const Key("table"),
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: data.properties.rebuild(
                      () {
                        const columnSizes = <double>[200.0, 200, 40, 40, 40];
                        const _contraints = BoxConstraints(minWidth: 150);
                        return Rebuilder(
                          builder: (_) => DataTable(
                            showCheckboxColumn: false,
                            columnSpacing: 20,
                            columns: <DataColumn>[
                              if (data.isReordering)
                                const DataColumn(
                                  label: Text('Order'),
                                ),
                              const DataColumn(
                                label: SizedBox(
                                  width: 110,
                                  child: Text('Field Name'),
                                ),
                              ),
                              const DataColumn(
                                label: SizedBox(
                                  width: 150,
                                  child: Text('Type'),
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
                            rows: data.properties
                                .map(
                                  (p) => DataRow(
                                    key: ValueKey(p.key),
                                    selected: p.isSelected,
                                    onSelectChanged: p.isSelectedNotifier.set,
                                    cells: _makeRowChildren(p)
                                        .map((e) => DataCell(e))
                                        .toList(),
                                  ),
                                )
                                .toList(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 9),
              Row(
                key: const Key("footer"),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RowBoolField(
                    notifier: data.isReorderingNotifier,
                    label: "Reorder",
                  ),
                  RaisedButton.icon(
                    onPressed: data.addProperty,
                    icon: const Icon(Icons.add),
                    label: const Text("Add Field"),
                  ),
                  const SizedBox(width: 100),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _makeRowChildren(PropertyField property) {
    final typeNotifier = property.typeNotifier;
    final index = data.properties.indexOf(property);
    return [
      if (data.isReordering)
        Center(
          key: const Key("reorder"),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: index != 0
                    ? () {
                        data.properties.syncTransaction(() {
                          data.properties[index] = data.properties[index - 1];
                          data.properties[index - 1] = property;
                        });
                      }
                    : null,
                child: Icon(
                  Icons.arrow_drop_up,
                  size: 20,
                  color: index != 0 ? Colors.black : Colors.black12,
                ),
              ),
              InkWell(
                onTap: index != data.properties.length - 1
                    ? () {
                        data.properties.syncTransaction(() {
                          data.properties[index] = data.properties[index + 1];
                          data.properties[index + 1] = property;
                        });
                      }
                    : null,
                child: Icon(
                  Icons.arrow_drop_down,
                  size: 20,
                  color: index != data.properties.length - 1
                      ? Colors.black
                      : Colors.black12,
                ),
              )
            ],
          ),
        ),
      TextField(
        key: const Key("name"),
        controller: property.nameNotifier.controller,
        inputFormatters: Formatters.variableName,
      ),
      AnimatedBuilder(
        key: const Key("type"),
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
        key: const Key("required"),
        child: property.isRequiredNotifier.rebuild(
          (isRequired) => Checkbox(
            value: isRequired,
            onChanged: property.isRequiredNotifier.set,
          ),
        ),
      ),
      Center(
        key: const Key("positional"),
        child: property.isPositionalNotifier.rebuild(
          (isPositional) => Checkbox(
            value: isPositional,
            onChanged: property.isPositionalNotifier.set,
          ),
        ),
      ),
      Builder(
        key: const Key("more"),
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
