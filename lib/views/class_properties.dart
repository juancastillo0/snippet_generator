import 'package:flutter/material.dart';
import 'package:snippet_generator/formatters.dart';
import 'package:snippet_generator/models/models.dart';
import 'package:snippet_generator/models/type_models.dart';
import 'package:snippet_generator/widgets.dart';
import 'package:super_tooltip/super_tooltip.dart';

class ClassPropertiesTable extends StatelessWidget {
  const ClassPropertiesTable({Key key, @required this.data}) : super(key: key);
  final ClassConfig data;

  @override
  Widget build(BuildContext context) {
    return Card(
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
                          onPressed: () => data.typeConfig.classes.remove(data),
                          icon: const Icon(Icons.delete),
                          label: const Text("Remove Class"),
                        )
                      ],
                    )
                  : const SizedBox(),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: data.properties.rebuild(
                    () {
                      const _contraints =
                          BoxConstraints(minWidth: 100, maxWidth: 200);
                      return DataTable(
                        columnSpacing: 32,
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
                            label: Text('Required'),
                          ),
                          const DataColumn(
                            label: Text('Positional'),
                          ),
                          const DataColumn(
                            label: Text('More'),
                          ),
                        ],
                        rows: data.properties.map(_makeRow).toList(),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 7),
            RaisedButton.icon(
              onPressed: () => data.properties.add(PropertyField(data)),
              icon: const Icon(Icons.add),
              label: const Text("Add Field"),
            )
          ],
        ),
      ),
    );
  }

  DataRow _makeRow(PropertyField property) {
    final typeNotifier = property.typeNotifier;
    return DataRow(
      cells: <DataCell>[
        DataCell(TextField(
          controller: property.nameNotifier.controller,
          inputFormatters: Formatters.variableName,
        )),
        DataCell(AnimatedBuilder(
          animation: typeNotifier.textNotifier,
          builder: (context, _) => DropdownButton<String>(
            isExpanded: true,
            value: "____",
            onTap: () {
              Future.delayed(
                Duration.zero,
                () => typeNotifier.focusNode.requestFocus(),
              );
            },
            items: [
              DropdownMenuItem<String>(
                key: const Key("____"),
                value: "____",
                child: TextField(
                  controller: typeNotifier.controller,
                  focusNode: typeNotifier.focusNode,
                ),
              ),
              ...supportedJsonTypes
                  .where((e) =>
                      // e
                      //     .toLowerCase()
                      //     .contains(property.type.text.toLowerCase()) &&
                      property.type != e)
                  .map((e) => DropdownMenuItem<String>(
                        value: e,
                        onTap: () => typeNotifier.controller.text = e,
                        key: Key(e),
                        child: Text(e),
                      ))
            ],
            onChanged: (v) {},
          ),
        )),
        DataCell(Center(
          child: property.isRequiredNotifier.rebuild(
            (isRequired) => Checkbox(
              value: isRequired,
              onChanged: property.isRequiredNotifier.set,
            ),
          ),
        )),
        DataCell(Center(
          child: property.isPositionalNotifier.rebuild(
            (isPositional) => Checkbox(
              value: isPositional,
              onChanged: property.isPositionalNotifier.set,
            ),
          ),
        )),
        DataCell(
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
        ),
      ],
    );
  }
}
