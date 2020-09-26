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
                          controller: data.nameNotifier,
                          label: "Class Name",
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: RowBoolField(
                            label: "Private",
                            notifier: data.isPrivateNotifier,
                          ),
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
                    (properties) => DataTable(
                      columnSpacing: 32,
                      columns: const <DataColumn>[
                        DataColumn(
                          label: Text('Field Name'),
                        ),
                        DataColumn(
                          label: Text('Type'),
                        ),
                        DataColumn(
                          label: Text('Required'),
                        ),
                        DataColumn(
                          label: Text('Positional'),
                        ),
                        DataColumn(
                          label: Text('More'),
                        ),
                      ],
                      rows: properties.map(_makeRow).toList(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            RaisedButton.icon(
              onPressed: () => data.properties.add(PropertyField()),
              icon: const Icon(Icons.add),
              label: const Text("Add Field"),
            )
          ],
        ),
      ),
    );
  }

  DataRow _makeRow(PropertyField property) {
    const _contraints = BoxConstraints(minWidth: 100, maxWidth: 200);
    return DataRow(
      cells: <DataCell>[
        DataCell(ConstrainedBox(
          constraints: _contraints,
          child: TextField(
            controller: property.name,
            inputFormatters: Formatters.variableName,
          ),
        )),
        DataCell(ConstrainedBox(
          constraints: _contraints,
          child: AnimatedBuilder(
            animation: property.type,
            builder: (context, _) => DropdownButton<String>(
              isExpanded: true,
              value: "____",
              onTap: () {
                Future.delayed(
                  Duration.zero,
                  () => property.typeFocusNode.requestFocus(),
                );
              },
              items: [
                DropdownMenuItem<String>(
                  key: const Key("____"),
                  value: "____",
                  child: TextField(
                    controller: property.type,
                    focusNode: property.typeFocusNode,
                  ),
                ),
                ...supportedJsonTypes
                    .where((e) =>
                        // e
                        //     .toLowerCase()
                        //     .contains(property.type.text.toLowerCase()) &&
                        property.type.text != e)
                    .map((e) => DropdownMenuItem<String>(
                          value: e,
                          onTap: () => property.type.text = e,
                          key: Key(e),
                          child: Text(e),
                        ))
              ],
              onChanged: (v) {},
            ),
          ),
        )),
        DataCell(
          Center(
            child: property.isRequired.rebuild(
              (isRequired) => Checkbox(
                value: isRequired,
                onChanged: property.isRequired.set,
              ),
            ),
          ),
        ),
        DataCell(
          Center(
            child: property.isPositional.rebuild(
              (isPositional) => Checkbox(
                value: isPositional,
                onChanged: property.isPositional.set,
              ),
            ),
          ),
        ),
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


