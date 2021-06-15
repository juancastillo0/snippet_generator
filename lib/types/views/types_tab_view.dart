
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snippet_generator/notifiers/collection_notifier/collection_notifier.dart';
import 'package:snippet_generator/types/root_store.dart';
import 'package:snippet_generator/types/views/code_generated.dart';
import 'package:snippet_generator/types/views/type_config.dart';
import 'package:snippet_generator/types/views/types_menu.dart';
import 'package:snippet_generator/widgets/resizable_scrollable/resizable.dart';

class TypesTabView extends HookWidget {
  const TypesTabView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rootStore = useRootStore(context);
    return Row(
      children: [
        Resizable(
          defaultWidth: 200,
          horizontal: ResizeHorizontal.right,
          child: Column(
            children: [
              const Expanded(
                flex: 2,
                child: TypesMenu(),
              ),
              Expanded(
                child: HistoryView(eventConsumer: rootStore.types),
              )
            ],
          ),
        ),
        const Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: 600,
              child: TypeConfigView(),
            ),
          ),
        ),
        const Resizable(
          defaultWidth: 450,
          horizontal: ResizeHorizontal.left,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: TypeCodeGenerated(),
          ),
        ),
      ],
    );
  }
}


class HistoryView extends HookWidget {
  const HistoryView({Key? key, required this.eventConsumer}) : super(key: key);
  final EventConsumer<Object?> eventConsumer;

  @override
  Widget build(BuildContext context) {
    useListenable(eventConsumer);
    final history = eventConsumer.history;
    return Column(
      children: [
        Text("Position: ${history.position}"),
        Text("canUndo: ${history.canUndo}"),
        Text("canRedo: ${history.canRedo}"),
        Expanded(
          child: ListView(
            children: history.events
                .map(
                  (event) => Text(event.runtimeType.toString()),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
