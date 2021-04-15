import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:snippet_generator/types/json_type.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';
import 'package:snippet_generator/notifiers/computed_notifier.dart';
import 'package:snippet_generator/utils/extensions.dart';
import 'package:snippet_generator/utils/formatters.dart';
import 'package:snippet_generator/notifiers/rebuilder.dart';
import 'package:snippet_generator/types/root_store.dart';
import 'package:snippet_generator/types/type_models.dart';
import 'package:snippet_generator/utils/theme.dart';
import 'package:snippet_generator/widgets/context_menu_portal.dart';
import 'package:snippet_generator/widgets/row_fields.dart';

class ClassPropertiesTable extends HookWidget {
  const ClassPropertiesTable({Key? key, required this.data}) : super(key: key);
  final ClassConfig data;

  @override
  Widget build(BuildContext context) {
    final hasProperties = useComputed(
      () => data.properties.isNotEmpty,
      [data.properties],
    );
    const padding = 10.0;

    return GestureDetector(
      onTap: () => RootStore.of(context).selectClass(data),
      child: Card(
        margin: const EdgeInsets.only(top: 10.0, bottom: padding),
        child: Padding(
          padding: const EdgeInsets.only(
              bottom: padding, left: padding, right: padding),
          child: Column(
            children: [
              data.typeConfig.isSumTypeNotifier.rebuild(
                (isSumType) => isSumType
                    ? Padding(
                        padding: const EdgeInsets.only(top: padding),
                        child: Row(
                          children: [
                            RowTextField(
                              controller: data.nameNotifier.controller,
                              label: "Class Name",
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  data.typeConfig.classes.remove(data),
                              style: elevatedStyle(context),
                              icon: const Icon(Icons.delete),
                              label: const Text("Remove Class"),
                            )
                          ],
                        ),
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
                        if (data.properties.isEmpty) {
                          return const SizedBox();
                        }
                        // const columnSizes = <double>[200.0, 200, 40, 40, 40];
                        // const _contraints = BoxConstraints(minWidth: 150);
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
                                    onSelectChanged: (value) {
                                      assert(value != null);
                                      p.isSelectedNotifier.value = value!;
                                    },
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
                  if (hasProperties)
                    RowBoolField(
                      notifier: data.isReorderingNotifier,
                      label: "Reorder",
                    )
                  else
                    const SizedBox(width: 100),
                  ElevatedButton.icon(
                    onPressed: data.addProperty,
                    style: elevatedStyle(context),
                    icon: const Icon(Icons.add),
                    label: const Text("Add Field"),
                  ),
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: RawImportField(data: data),
                            );
                          },
                        );
                      },
                      child: const Text("Import Raw"),
                    ),
                  ),
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
                key: Key("t$index"),
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
                key: Key("b$index"),
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
          return MenuPortalEntry<String>(
            options: options
                .map(
                  (e) => TextButton(
                    onPressed: () {
                      typeNotifier.controller.value = TextEditingValue(
                        text: e,
                        selection: TextSelection.collapsed(
                          offset: e.length,
                        ),
                      );
                    },
                    style: menuStyle(context),
                    key: Key(e),
                    child: Text(e),
                  ),
                )
                .toList(),
            isVisible: typeNotifier.focusNode.hasPrimaryFocus,
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
            onChanged: (value) {
              assert(value != null);
              property.isRequiredNotifier.value = value!;
            },
          ),
        ),
      ),
      Center(
        key: const Key("positional"),
        child: property.isPositionalNotifier.rebuild(
          (isPositional) => Checkbox(
            value: isPositional,
            onChanged: (value) {
              assert(value != null);
              property.isPositionalNotifier.value = value!;
            },
          ),
        ),
      ),
      Builder(
        key: const Key("more"),
        builder: (context) {
          return _MoreOptions(
            data: data,
            property: property,
          );
        },
      ),
    ];
  }
}

class RawImportField extends StatelessWidget {
  const RawImportField({
    Key? key,
    required this.data,
  }) : super(key: key);

  final ClassConfig data;

  @override
  Widget build(BuildContext context) {
    final allRequired = AppNotifier(true);
    void close() {
      Navigator.of(context).pop();
    }

    return Container(
      height: 400,
      width: 600,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Raw Import", style: context.textTheme.headline5),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: close,
              )
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    autofocus: true,
                    controller: data.rawImport.controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      helperText:
                          "Line or coma separated field descriptions, e.g:"
                          "\n• String name\n• req int count,\n• isAvailable : bool",
                    ),
                    expands: true,
                    minLines: null,
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: Observer(
                    builder: (context) {
                      final listResult = data.parsedRawImport.value;

                      if (listResult.isSuccess) {
                        final atLeastOneRequired =
                            listResult.value.any((f) => f.isRequired);
                        return Column(
                          children: [
                            Text("Fields", style: context.textTheme.headline6),
                            const SizedBox(height: 5),
                            Expanded(
                              child: ListView(
                                children: [
                                  ...listResult.value.map(
                                    (e) => SelectableText(
                                      "${e.type} ${e.name} ${e.isRequired}",
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (!atLeastOneRequired)
                                  RowBoolField(
                                    notifier: allRequired,
                                    label: "All Required",
                                  )
                                else
                                  const SizedBox(),
                                ElevatedButton(
                                  onPressed: () {
                                    for (final rawField in listResult.value) {
                                      final prop = data.addProperty();
                                      prop.nameNotifier.value = rawField.name;
                                      prop.typeNotifier.value = rawField.type;
                                      prop.isRequiredNotifier.value =
                                          atLeastOneRequired
                                              ? rawField.isRequired
                                              : allRequired.value;
                                    }
                                    close();
                                  },
                                  child: const Text("Import"),
                                ),
                              ],
                            )
                          ],
                        );
                      } else {
                        return Center(
                          child: Text(
                            "Wrong input\n" + listResult.toString(),
                          ),
                        );
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreOptions extends HookWidget {
  final ClassConfig data;
  final PropertyField property;

  const _MoreOptions({
    Key? key,
    required this.data,
    required this.property,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final showMenu = useState(false);
    return MenuPortalEntry(
      options: [
        TextButton.icon(
          onPressed: () {
            showMenu.value = false;
            data.properties.remove(property);
          },
          style: menuStyle(context),
          icon: const Icon(Icons.delete),
          label: const Text("Remove Field"),
        )
      ],
      width: 170,
      isVisible: showMenu.value,
      onClose: () {
        showMenu.value = false;
      },
      child: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () {
          showMenu.value = true;
        },
      ),
    );
  }
}
