import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snippet_generator/models/root_store.dart';
import 'package:snippet_generator/views/class_properties.dart';
import 'package:snippet_generator/formatters.dart';
import 'package:snippet_generator/models/type_models.dart';
import 'package:snippet_generator/models/models.dart';
import 'package:snippet_generator/views/enum_config.dart';
import 'package:snippet_generator/widgets.dart';
import 'package:snippet_generator/collection_notifier/list_notifier.dart';

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
            const SizedBox(height: 5),
            Wrap(
              alignment: WrapAlignment.center,
              children: typeConfig.allSettings.entries
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

class TypeConfigView extends HookWidget {
  const TypeConfigView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TypeConfig typeConfig = useSelectedType(context);
    final variantListenable = useMemoized(
        () => Listenable.merge(
            [typeConfig.isEnumNotifier, typeConfig.isSumTypeNotifier]),
        [typeConfig]);
    final variantListListenable = useMemoized(
        () => Listenable.merge([typeConfig.classes, variantListenable]),
        [typeConfig]);

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          TypeConfigTitleView(typeConfig: typeConfig),
          const SizedBox(height: 15),
          variantListListenable.rebuild(
            () {
              if (typeConfig.isEnum) {
                return EnumTable(typeConfig: typeConfig);
              } else {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: (typeConfig.hasVariants.value
                          ? typeConfig.classes
                          : typeConfig.classes.take(1))
                      .map((e) => ClassPropertiesTable(data: e))
                      .toList(),
                );
              }
            },
          ),
          variantListenable.rebuild(
            () => typeConfig.isSumType && !typeConfig.isEnum
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: RaisedButton.icon(
                      onPressed: typeConfig.addVariant,
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
