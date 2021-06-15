import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snippet_generator/types/root_store.dart';
import 'package:snippet_generator/types/type_models.dart';
import 'package:snippet_generator/utils/theme.dart';
import 'package:snippet_generator/widgets/resizable_scrollable/scrollable.dart';
import 'package:snippet_generator/widgets/row_fields.dart';

class CodeGenerated extends HookWidget {
  final String sourceCode;
  final bool showNullSafe;

  const CodeGenerated({
    Key? key,
    required this.sourceCode,
    this.showNullSafe = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rootStore = useRootStore(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 2, bottom: 2),
              child: ElevatedButton.icon(
                onPressed: () {
                  rootStore.copySourceCode(sourceCode);
                },
                style: elevatedStyle(context),
                icon: const Icon(Icons.copy),
                label: const Text("Copy Source Code"),
              ),
            ),
            if (showNullSafe)
              RowBoolField(
                label: "Null Safe",
                notifier: rootStore.isCodeGenNullSafeNotifier,
              ),
          ],
        ),
        const SizedBox(height: 6),
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
                  style: GoogleFonts.cousine(fontSize: 13),
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
    useListenable(rootStore.isCodeGenNullSafeNotifier);

    return Observer(builder: (context) {
      return CodeGenerated(sourceCode: typeConfig.sourceCode.value);
    });
  }
}
