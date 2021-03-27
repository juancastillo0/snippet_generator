import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snippet_generator/models/root_store.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';
import 'package:snippet_generator/resizable_scrollable/scrollable.dart';
import 'package:snippet_generator/utils/theme.dart';
import 'package:snippet_generator/views/class_properties.dart';
import 'package:snippet_generator/models/type_models.dart';
import 'package:snippet_generator/utils/extensions.dart';
import 'package:snippet_generator/views/enum_config.dart';
import 'package:snippet_generator/widgets.dart';
import 'package:snippet_generator/collection_notifier/list_notifier.dart';

class TypeConfigTitleView extends HookWidget {
  const TypeConfigTitleView({
    Key? key,
    required this.typeConfig,
  }) : super(key: key);
  final TypeConfig typeConfig;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RowTextField(
              label: "Type Name",
              controller: typeConfig.signatureNotifier.controller,
              width: 220.0,
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
  const TypeConfigView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TypeConfig typeConfig = useSelectedType(context);
    final variantListenable = useMemoized(
      () => Listenable.merge(
          [typeConfig.isEnumNotifier, typeConfig.isSumTypeNotifier]),
      [typeConfig],
    );
    final variantListListenable = useMemoized(
      () => Listenable.merge([typeConfig.classes, variantListenable]),
      [typeConfig],
    );

    return SingleScrollable(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(left: 5.0, right: 8.0),
        child: Column(
          children: <Widget>[
            TypeConfigTitleView(typeConfig: typeConfig),
            const SizedBox(height: 15),
            TypeSettingsView(typeConfig: typeConfig),
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
                      child: ElevatedButton.icon(
                        onPressed: typeConfig.addVariant,
                        icon: const Icon(Icons.add),
                        style: elevatedStyle(context),
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
      ),
    );
  }
}

Listenable useMergedListenable(
  Iterable<Listenable> Function() listBuilder, [
  List<Object?> keys = const <dynamic>[],
]) {
  final list = useMemoized(
    () => Listenable.merge(listBuilder().toList()),
    keys,
  );
  return useListenable(list);
}

class TypeSettingsView extends HookWidget {
  const TypeSettingsView({
    Key? key,
    required this.typeConfig,
  }) : super(key: key);
  final TypeConfig typeConfig;

  @override
  Widget build(BuildContext context) {
    final isExpandedList = useMemoized(
      () => ListNotifier<bool>(
        Iterable<bool>.generate(typeConfig.allSettings.length + 1, (_) => false)
            .toList(),
        maxHistoryLength: 0,
      ),
    );
    useListenable(isExpandedList);
    useMergedListenable(() => typeConfig.allSettings.values, [typeConfig]);

    int gIndex = -1;
    final _map = <int>[];
    return ExpansionPanelList(
      expandedHeaderPadding: const EdgeInsets.symmetric(vertical: 8),
      expansionCallback: (index, isExpanded) {
        isExpandedList[_map[index]] = !isExpanded;
      },
      children: typeConfig.allSettings.entries
          .followedBy([MapEntry("Advanced", AppNotifier(true))])
          .map((e) {
            gIndex++;

            if (!e.value.value) {
              return null;
            }
            _map.add(gIndex);
            return ExpansionPanel(
              isExpanded: isExpandedList[gIndex],
              canTapOnHeader: true,
              headerBuilder: (context, isExpanded) =>
                  Center(child: Text(e.key)),
              body: _expansionPanelBuilders[e.key]!(typeConfig),
            );
          })
          .where((panel) => panel != null)
          .cast<ExpansionPanel>()
          .toList(),
    );
  }
}

final Map<String, Widget Function(TypeConfig)> _expansionPanelBuilders = {
  "Data Value": (typeConfig) => const Text("d"),
  "Listenable": (typeConfig) {
    final listenableConfig = typeConfig.listenableConfig;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
      child: Wrap(
        spacing: 15,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          RowBoolField(
            label: "Setters",
            notifier: listenableConfig.generateSetters,
          ),
          RowBoolField(
            label: "Props",
            notifier: listenableConfig.generateProps,
          ),
          RowBoolField(
            label: "Getters",
            notifier: listenableConfig.generateGetters,
          ),
          RowTextField(
            rowLayout: false,
            controller: listenableConfig.suffix.controller,
            label: "Suffix",
          ),
          RowTextField(
            rowLayout: false,
            controller: listenableConfig.notifierClass.controller,
            label: "Notifier Class",
          ),
        ],
      ),
    );
  },
  "Serializable": (typeConfig) {
    final serializableConfig = typeConfig.serializableConfig;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
      child: Wrap(
        spacing: 15,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          RowBoolField(
            label: "from/to String",
            notifier: serializableConfig.returnString,
          ),
          RowBoolField(
            label: "Static Function",
            notifier: serializableConfig.staticFunction,
          ),
          RowTextField(
            rowLayout: false,
            controller: serializableConfig.suffix.controller,
            label: "Suffix",
          ),
          RowTextField(
            rowLayout: false,
            controller: serializableConfig.discriminator.controller,
            label: "Discriminator",
          ),
          // RowBoolField(
          //   label: "bool getters",
          //   notifier: sumTypeConfig.isConstNotifier,
          // ),
        ],
      ),
    );
  },
  "Sum Type": (typeConfig) {
    final sumTypeConfig = typeConfig.sumTypeConfig;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          RowBoolField(
            label: "Enum",
            notifier: sumTypeConfig.enumDiscriminant,
          ),
          RowBoolField(
            label: "Bool Getters",
            notifier: sumTypeConfig.boolGetters,
          ),
          RowBoolField(
            label: "Generic Mappers",
            notifier: sumTypeConfig.genericMappers,
          ),
        ],
      ),
    );
  },
  "Enum": (typeConfig) => const Text("enum"),
  "Advanced": (typeConfig) {
    final advancedConfig = typeConfig.advancedConfig;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 420),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Custom Code"),
                RowBoolField(
                  label: "Const",
                  notifier: advancedConfig.isConstNotifier,
                ),
                RowBoolField(
                  label: "Override Constructor",
                  notifier: advancedConfig.overrideConstructorNotifier,
                )
              ],
            ),
            const SizedBox(height: 3),
            TextField(
              controller: advancedConfig.customCodeNotifier.controller,
              focusNode: advancedConfig.customCodeNotifier.focusNode,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 5,
                ),
              ),
              maxLines: 6,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
};
