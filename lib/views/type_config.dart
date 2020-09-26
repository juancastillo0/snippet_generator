import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snippet_generator/views/class_properties.dart';
import 'package:snippet_generator/formatters.dart';
import 'package:snippet_generator/models/type_models.dart';
import 'package:snippet_generator/models/models.dart';
import 'package:snippet_generator/widgets.dart';

class TypeConfigTitleView extends HookWidget {
  const TypeConfigTitleView({
    Key key,
    this.typeConfig,
  }) : super(key: key);
  final TypeConfig typeConfig;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RowTextField(
              label: "Type Name",
              controller: typeConfig.nameNotifier,
              inputFormatters: Formatters.variableName,
            ),
            Wrap(
              alignment: WrapAlignment.center,
              children: {
                "Data Value": typeConfig.isDataValueNotifier,
                "Listenable": typeConfig.isListenableNotifier,
                "Serializable": typeConfig.isSerializableNotifier,
                "Sum Type": typeConfig.isSumTypeNotifier,
                "Enum": typeConfig.isEnumNotifier,
              }
                  .entries
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(right: 5.0, left: 5.0),
                      child: RowBoolField(
                        label: e.key,
                        notifier: e.value,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class TypeConfigView extends StatelessWidget {
  const TypeConfigView({
    Key key,
    @required this.typeConfig,
  }) : super(key: key);

  final TypeConfig typeConfig;

  @override
  Widget build(BuildContext context) {
    final variantListListenable =
        Listenable.merge([typeConfig.classes, typeConfig.hasVariants]);

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          TypeConfigTitleView(typeConfig: typeConfig),
          const SizedBox(height: 15),
          variantListListenable.rebuild(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: (typeConfig.hasVariants.value
                      ? typeConfig.classes.value
                      : typeConfig.classes.value.take(1))
                  .map(
                    (e) => typeConfig.isEnum
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RowTextField(
                                controller: e.nameNotifier,
                                label: "Variant",
                              ),
                              IconButton(
                                onPressed: () {
                                  typeConfig.classes.remove(e);
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            ],
                          )
                        : ClassPropertiesTable(data: e),
                  )
                  .toList(),
            ),
          ),
          typeConfig.hasVariants.rebuild(
            (hasVariants) => hasVariants
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: RaisedButton.icon(
                      onPressed: () =>
                          typeConfig.classes.add(ClassConfig(typeConfig)),
                      icon: const Icon(Icons.add),
                      label: typeConfig.isEnum
                          ? const Text("Add Variant")
                          : const Text("Add Class"),
                    ),
                  )
                : const SizedBox(),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
