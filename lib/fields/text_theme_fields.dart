import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snippet_generator/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class TextThemeInput extends HookWidget {
  const TextThemeInput({
    required ValueKey<String> key,
    TextTheme? value,
    required this.set,
  })   : value = value ?? const TextTheme(),
        super(key: key);

  final TextTheme value;
  final void Function(TextTheme) set;

  static final _lowercaseFonts =
      GoogleFonts.asMap().map((e, v) => MapEntry(e.toLowerCase(), e));

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final focusNode = useFocusNode();
    final lowercaseText = useState(controller.text);
    useListenable(focusNode);

    Future<void> fetch() async {
      if (GoogleFonts.asMap().containsKey(controller.text)) {
        final _theme = GoogleFonts.getTextTheme(controller.text);
        set(_theme);
      }
    }

    final found = _lowercaseFonts.entries
        .where((k) => k.key.contains(lowercaseText.value));

    return Align(
      child: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Font Family"),
                TextButton(
                  onPressed: () {
                    launch("https://fonts.google.com/");
                  },
                  child: Text(
                    "Open Google Fonts",
                    style: Theme.of(context).textTheme.button!.copyWith(
                          decoration: TextDecoration.underline,
                        ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: MenuPortalEntry<String>(
                    options: found
                        .map(
                          (e) => TextButton(
                            onPressed: () {
                              controller.value = TextEditingValue(
                                text: e.value,
                                selection: TextSelection.collapsed(
                                  offset: e.value.length,
                                ),
                              );
                              lowercaseText.value =
                                  controller.text.toLowerCase();
                            },
                            key: Key(e.value),
                            child: Text(e.value),
                          ),
                        )
                        .toList(),
                    width: 200,
                    isVisible: controller.text.isNotEmpty &&
                        focusNode.hasPrimaryFocus &&
                        (found.length != 1 ||
                            found.first.value != controller.text),
                    child: TextField(
                      controller: controller,
                      onChanged: (textStr) {
                        lowercaseText.value = textStr.toLowerCase();
                      },
                      focusNode: focusNode,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: fetch,
                  child: const Text("Fetch"),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
