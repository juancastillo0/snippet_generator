import 'package:flutter/material.dart';
import 'package:snippet_generator/formatters.dart';
import 'package:snippet_generator/models/type_models.dart';
import 'package:snippet_generator/utils/extensions.dart';
import 'package:snippet_generator/utils/theme.dart';

class EnumTable extends StatelessWidget {
  const EnumTable({Key? key, required this.typeConfig}) : super(key: key);
  final TypeConfig typeConfig;

  @override
  Widget build(BuildContext context) {
    const _contraints = BoxConstraints(minWidth: 100, maxWidth: 200);

    return Card(
      margin: const EdgeInsets.only(top: 10.0, bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18.0),
        child: Column(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 32,
                    columns: <DataColumn>[
                      DataColumn(
                        label: ConstrainedBox(
                          constraints: _contraints,
                          child: const Text('Variant Name'),
                        ),
                      ),
                      const DataColumn(
                        label: Text('Default'),
                      ),
                      const DataColumn(
                        label: Text('Delete'),
                      ),
                    ],
                    rows: typeConfig.classes.map(_makeRow).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 7),
            ElevatedButton.icon(
              onPressed: typeConfig.addVariant,
              style: elevatedStyle(context),
              icon: const Icon(Icons.add),
              label: const Text("Add Variant"),
            )
          ],
        ),
      ),
    );
  }

  DataRow _makeRow(ClassConfig value) {
    return DataRow(
      cells: <DataCell>[
        DataCell(TextField(
          controller: value.nameNotifier.controller,
          inputFormatters: Formatters.variableName,
        )),
        DataCell(Center(
          child: value.typeConfig.defaultEnumKeyNotifier.rebuild(
            (defaultEnumKey) => Radio(
              groupValue: defaultEnumKey,
              value: value.key,
              onChanged: (String? _value) {
                value.typeConfig.defaultEnumKeyNotifier.value = _value;
              },
              toggleable: true,
            ),
          ),
        )),
        DataCell(Center(
          child: IconButton(
            onPressed: () {
              value.typeConfig.classes.remove(value);
            },
            icon: const Icon(Icons.delete),
          ),
        )),
      ],
    );
  }
}
