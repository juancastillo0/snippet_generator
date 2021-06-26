import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:petitparser/petitparser.dart';
import 'package:snippet_generator/fields/flutter_fields.dart';

class WidgetFormState {
  WidgetFormState(this.tokenMap, this.mainController);
  final Token<Map<String, Token<Object>>>? tokenMap;
  Map<String, Token<Object>> get map => tokenMap!.value;
  final TextEditingController mainController;

  static WidgetFormState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_WidgetFormStateWidget>()!
        .state;
  }

  void replace(String key, String _value, Token? token) {
    int stop;
    int start;
    String value;
    if (token == null) {
      final _mapStr =
          tokenMap!.buffer.substring(tokenMap!.start, tokenMap!.stop);
      start = tokenMap!.start + _mapStr.lastIndexOf(')');
      stop = start;
      if (map.isNotEmpty && !RegExp(r',\s*\)\s*$').hasMatch(_mapStr)) {
        value = ', $key: $_value';
      } else {
        value = '$key: $_value';
      }
    } else {
      start = token.start;
      stop = token.stop;
      value = _value;
    }

    mainController.value = TextEditingValue(
      text: mainController.text.replaceRange(start, stop, value),
      selection: TextSelection.collapsed(
        offset: start + value.length,
      ),
    );
  }

  Widget provide(Widget child) {
    return _WidgetFormStateWidget(this, child: child);
  }
}

class _WidgetFormStateWidget extends InheritedWidget {
  final WidgetFormState state;
  const _WidgetFormStateWidget(this.state, {required Widget child, Key? key})
      : super(child: child, key: key);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return (oldWidget as _WidgetFormStateWidget).state != state;
  }
}

class AlignmentParserFormInput extends StatelessWidget {
  const AlignmentParserFormInput({
    required ValueKey<String> key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final key = this.key as ValueKey<String>;
    final global = WidgetFormState.of(context);
    final token = global.map[key.value];

    void set(Alignment? newValue) {
      String newStrValue = newValue.toString();
      newStrValue = newStrValue.startsWith('Alignment.')
          ? newStrValue.replaceRange(0, 10, '')
          : 'Alignment(${newValue!.x}, ${newValue.y})';

      global.replace(key.value, newStrValue, token);
    }

    return AlignmentInput(
      key: key,
      set: set,
      value: token?.value as Alignment?,
    );
  }
}

class ColorInput extends HookWidget {
  const ColorInput({
    required ValueKey<String> key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final key = this.key as ValueKey<String>;
    final global = WidgetFormState.of(context);
    final token = global.map[key.value];
    final value = token?.value as Color? ?? Colors.transparent;

    void set(Color newValue) {
      global.replace(
        key.value,
        "0x${newValue.value.toRadixString(16).padLeft(8, '0')}",
        token,
      );
    }

    return Card(
      child: Container(
        width: 550,
        padding: const EdgeInsets.only(top: 12, bottom: 12, left: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(key.value),
            ),
            ColorPicker(
              pickerColor: value,
              onColorChanged: set,
              colorPickerWidth: 100.0,
              showLabel: true,
              enableAlpha: true,
              pickerAreaHeightPercent: 0.7,
            ),
          ],
        ),
      ),
    );
  }
}

class DecorationInput extends HookWidget {
  const DecorationInput({
    required ValueKey<String> key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final key = this.key as ValueKey<String>;
    final global = WidgetFormState.of(context);
    final token = global.map[key.value];
    final value = token?.value as Decoration? ?? const BoxDecoration();

    void set(Decoration newValue) {
      if (newValue is ShapeDecoration) {
        global.replace(
          key.value,
          '0x$newValue',
          token,
        );
      } else if (newValue is BoxDecoration) {
        global.replace(
          key.value,
          '0x$newValue',
          token,
        );
      }
    }

    return Card(
      child: Container(
        width: 550,
        padding: const EdgeInsets.only(top: 12, bottom: 12, left: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(key.value),
            ),
            // ColorPicker(
            //   pickerColor: value,
            //   onColorChanged: set,
            //   colorPickerWidth: 100.0,
            //   showLabel: true,
            //   enableAlpha: true,
            //   pickerAreaHeightPercent: 0.7,
            // ),
          ],
        ),
      ),
    );
  }
}

class PaddingParserFormInput extends HookWidget {
  const PaddingParserFormInput({
    required ValueKey<String> key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final key = this.key as ValueKey<String>;
    final global = WidgetFormState.of(context);
    final token = global.map[key.value];

    void set(EdgeInsets newValue) {
      String _f(String v, double vd) => vd == 0 ? '' : '$v: $vd, ';

      String str;
      if (newValue.hasAll) {
        str = '${newValue.bottom}';
      } else if (newValue.hasHorizontal && newValue.hasVertical) {
        str =
            "(${_f("horizontal", newValue.left)}${_f("vertical", newValue.top)})";
      } else if (newValue.hasHorizontal) {
        str =
            "(${_f("horizontal", newValue.left)}${_f("top", newValue.top)}${_f("bottom", newValue.bottom)})";
      } else if (newValue.hasVertical) {
        str =
            "(${_f("left", newValue.left)}${_f("right", newValue.right)}${_f("vertical", newValue.top)})";
      } else {
        str = "(${_f("left", newValue.left)}${_f("right", newValue.right)}"
            "${_f("top", newValue.top)}${_f("bottom", newValue.bottom)})";
      }
      global.replace(key.value, str, token);
    }

    return PaddingInput(
      key: key,
      value: token?.value as EdgeInsets?,
      set: set,
    );
  }
}
