import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snippet_generator/models/root_store.dart';
import 'package:snippet_generator/utils/extensions.dart';

class TypesMenu extends HookWidget {
  const TypesMenu({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rootStore = RootStore.of(context);
    useListenable(rootStore.types);
    useListenable(rootStore.selectedTypeNotifier);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0, top: 6.0),
          child: Text(
            "Types",
            style: context.textTheme.headline5,
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              ...rootStore.types.values.map(
                (type) => DecoratedBox(
                  decoration: BoxDecoration(
                    color: type == rootStore.selectedType
                        ? context.theme.primaryColorLight
                        : Colors.white,
                  ),
                  child: TextButton(
                    onPressed: () {
                      rootStore.selectType(type);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: type.signatureNotifier.textNotifier
                                .rebuild((signature) {
                              return Text(
                                signature,
                                style: context.textTheme.button,
                              );
                            }),
                          ),
                          IconButton(
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
              ),
              Align(
                alignment: Alignment.centerRight,
                child: FlatButton.icon(
                  padding: const EdgeInsets.all(18.0),
                  onPressed: rootStore.addType,
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