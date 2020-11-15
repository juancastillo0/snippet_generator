import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snippet_generator/main.dart';
import 'package:snippet_generator/models/rebuilder.dart';
import 'package:snippet_generator/parsers/widget_parser.dart';

class ParsersView extends HookWidget {
  const ParsersView({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    useListenable(controller);

    final result = WidgetParser.parser.parse(controller.text);

    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              controller: controller,
              expands: true,
              maxLines: null,
              minLines: null,
            ),
          ),
        ),
        Expanded(
          child: result.isSuccess
              ? result.value.widget
              : Center(
                  child: Text(
                    "Invalid text:\n$result",
                    textAlign: TextAlign.center,
                  ),
                ),
        ),
        SizedBox(
          width: 300,
          child: Rebuilder(
            builder: (context) {
              return CodeGenerated(sourceCode: "");
            },
          ),
        ),
      ],
    );
  }
}
