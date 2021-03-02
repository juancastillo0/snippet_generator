import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:snippet_generator/models/root_store.dart';
import 'package:snippet_generator/models/type_models.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snippet_generator/resizable_scrollable/scrollable.dart';
import 'package:snippet_generator/templates/templates.dart';
import 'package:snippet_generator/utils/theme.dart';
import 'package:snippet_generator/widgets.dart';

class CodeGenerated extends HookWidget {
  final String sourceCode;

  const CodeGenerated({
    Key? key,
    required this.sourceCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rootStore = useRootStore(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: () => Clipboard.setData(
                ClipboardData(text: sourceCode),
              ),
              style: elevatedStyle(context),
              icon: const Icon(Icons.copy),
              label: const Text("Copy Source Code"),
            ),
            RowBoolField(
              label: "Null Safe",
              notifier: rootStore.isCodeGenNullSafeNotifier,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 12.0,
                bottom: 12.0,
                left: 12.0,
              ),
              child: SingleScrollable(
                child: SelectableText(
                  sourceCode,
                  style: GoogleFonts.cousine(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TypeCodeGenerated extends HookWidget {
  const TypeCodeGenerated({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rootStore = useRootStore(context);
    final TypeConfig typeConfig = useSelectedType(context);
    useListenable(typeConfig.deepListenable);
    useListenable(rootStore.isCodeGenNullSafeNotifier);

    return Observer(builder: (context) {
      String sourceCode;
      if (typeConfig.isEnum) {
        sourceCode = typeConfig.templateEnum();
      } else if (typeConfig.isSumType) {
        sourceCode = typeConfig.templateSumType();
      } else {
        final _class = typeConfig.classes[0];
        sourceCode = _class.templateClass();
      }
      try {
        sourceCode = rootStore.formatter.format(sourceCode);
      } catch (_) {}
      return CodeGenerated(sourceCode: sourceCode);
    });
  }
}
