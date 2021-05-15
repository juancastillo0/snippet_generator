
import 'package:flutter/material.dart';

class HighlightedTextController extends TextEditingController {
  /// Creates a controller for an editable text field.
  ///
  /// This constructor treats a null [text] argument as if it were the empty
  /// string.
  HighlightedTextController({required this.errorsFn, String? text})
      : super(text: text);

  final List<TextRange> Function() errorsFn;

  /// Builds [TextSpan] from current editing value.
  ///
  /// By default makes text in composing range appear as underlined. Descendants
  /// can override this method to customize appearance of text.
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    assert(!value.composing.isValid ||
        !withComposing ||
        value.isComposingRangeValid);
    // If the composing range is out of range for the current text, ignore it to
    // preserve the tree integrity, otherwise in release mode a RangeError will
    // be thrown and this EditableText will be built with a broken subtree.
    final _errors = errorsFn();
    if (_errors.isEmpty && (!value.isComposingRangeValid || !withComposing)) {
      return TextSpan(style: style, text: text);
    }
    final TextStyle composingStyle = style!.merge(
      const TextStyle(decoration: TextDecoration.underline),
    );
    final TextStyle errorStyle = style.merge(
      TextStyle(backgroundColor: Colors.red[100]),
    );

    final spans = <TextSpan>[];
    int lastErrorIndex = 0;
    for (final errToken in _errors) {
      spans.add(TextSpan(
        text: value.text.substring(lastErrorIndex, errToken.start),
      ));
      spans.add(TextSpan(
        text: value.text.substring(errToken.start, errToken.end),
        style: errorStyle,
      ));
      lastErrorIndex = errToken.end;
    }
    spans.add(TextSpan(
      text: value.text.substring(lastErrorIndex),
    ));

    return TextSpan(
      style: style,
      children: _errors.isEmpty
          ? <TextSpan>[
              TextSpan(text: value.composing.textBefore(value.text)),
              TextSpan(
                style: composingStyle,
                text: value.composing.textInside(value.text),
              ),
              TextSpan(text: value.composing.textAfter(value.text)),
            ]
          : spans,
    );
  }
}