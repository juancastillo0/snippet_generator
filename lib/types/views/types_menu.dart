import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:snippet_generator/types/root_store.dart';
import 'package:snippet_generator/types/type_models.dart';
import 'package:snippet_generator/utils/extensions.dart';
import 'package:snippet_generator/utils/theme.dart';

class TypesMenu extends HookWidget {
  const TypesMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rootStore = RootStore.of(context);
    useListenable(rootStore.types);
    useListenable(rootStore.selectedTypeNotifier);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6.0, top: 6.0, left: 6.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Types",
                    style: context.textTheme.headline5,
                  ),
                  IconButton(
                    onPressed: rootStore.selectDirectory,
                    splashRadius: 24,
                    icon: const Icon(Icons.folder),
                    tooltip: "Select workspace directory",
                  ),
                ],
              ),
              rootStore.directoryHandle.rebuild(
                (value) => value == null
                    ? const SizedBox()
                    : Tooltip(
                        message: value.name,
                        child: SelectableText(
                          value.name,
                          style: context.textTheme.caption,
                          maxLines: 1,
                          // overflow: TextOverflow.ellipsis,
                        ),
                      ),
              )
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              ...rootStore.types.values.map(
                (type) => TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: type == rootStore.selectedType
                        ? context.theme.primaryColorLight.withOpacity(0.7)
                        : context.theme.cardColor,
                    // no border radius
                    shape: const RoundedRectangleBorder(),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () {
                    rootStore.selectType(type);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6.0, top: 6.0, bottom: 6.0, right: 2),
                    child: Row(
                      children: [
                        Expanded(child: _TypeDescription(type: type)),
                        IconButton(
                          splashRadius: 20,
                          iconSize: 20,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            rootStore.removeType(type);
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.black,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: rootStore.addType,
                  style:
                      menuStyle(context, padding: const EdgeInsets.all(18.0)),
                  icon: const Icon(Icons.add),
                  label: const Text("Add Type"),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class _TypeDescription extends StatelessWidget {
  const _TypeDescription({
    Key? key,
    required this.type,
  }) : super(key: key);

  final TypeConfig type;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (signature) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              type.signature,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              // style: context.textTheme.button,
            ),
            Row(
              children: [
                TagInfo("Data", Colors.amber, enabled: type.isDataValue),
                TagInfo("Listen", Colors.amber, enabled: type.isListenable),
                TagInfo("Serde", Colors.amber, enabled: type.isSerializable),
                TagInfo("Sum", Colors.amber, enabled: type.isSumType),
                TagInfo("Enum", Colors.amber, enabled: type.isEnum),
              ]
                  .where((e) => e.enabled)
                  .map(
                    (e) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 1,
                      ),
                      margin: const EdgeInsets.only(top: 4, left: 2, right: 2),
                      decoration: BoxDecoration(
                          color: context.theme.cardColor,
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        e.name,
                        style: context.textTheme.caption?.copyWith(
                          fontSize: 10,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            )
          ],
        );
      },
    );
  }
}

class TagInfo {
  final String name;
  final Color color;
  final bool enabled;

  TagInfo(this.name, this.color, {this.enabled = true});
}
