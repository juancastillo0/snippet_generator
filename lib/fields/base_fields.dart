import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snippet_generator/utils/formatters.dart';

class DoubleInput extends HookWidget {
  final String label;
  final void Function(double?) onChanged;
  final double? value;

  const DoubleInput({
    Key? key,
    required this.label,
    required this.onChanged,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final input = useTextInput<double>(
      value,
      onChanged,
      doubleStringInput,
    );

    return TextField(
      controller: input.controller,
      decoration: InputDecoration(
        labelText: label,
        errorText: input.errorIfTouchedNotEmpty,
      ),
      onChanged: input.onChangedString,
      inputFormatters: [Formatters.onlyDigitsOrDecimal],
      focusNode: input.focusNode,
      keyboardType: TextInputType.number,
    );
  }
}

class IntInput extends HookWidget {
  final String label;
  final void Function(int?) onChanged;
  final int? value;

  const IntInput({
    Key? key,
    required this.label,
    required this.onChanged,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const _size = 20.0;
    final input = useTextInput<int>(
      value,
      onChanged,
      intStringInput,
    );
    final _buttonStyle = TextButton.styleFrom(
      padding: EdgeInsets.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      fixedSize: const Size(_size, _size),
      minimumSize: const Size(_size, _size),
    );

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: input.controller,
            decoration: InputDecoration(
              labelText: label,
              errorText: input.errorIfTouchedNotEmpty,
            ),
            onChanged: input.onChangedString,
            inputFormatters: [Formatters.onlyDigits],
            focusNode: input.focusNode,
            keyboardType: TextInputType.number,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: value == null
                  ? null
                  : () {
                      onChanged(value! + 1);
                    },
              style: _buttonStyle,
              child: const Icon(Icons.arrow_drop_up, size: _size - 2),
            ),
            TextButton(
              onPressed: value == null
                  ? null
                  : () {
                      onChanged(value! - 1);
                    },
              style: _buttonStyle,
              child: const Icon(Icons.arrow_drop_down, size: _size - 2),
            ),
          ],
        ),
      ],
    );
  }
}

final doubleStringInput = StringInputSerializer<double>(
  double.tryParse,
  (v) {
    final str = v.toString();
    return str.endsWith(".0") ? str.substring(0, str.length - 2) : str;
  },
);

String objectToString(Object v) => v.toString();

const intStringInput = StringInputSerializer<int>(
  int.tryParse,
  objectToString,
);

class StringInputSerializer<T> {
  final T? Function(String) fromString;
  final String Function(T) asString;
  final String? Function(String, T?)? validate;

  const StringInputSerializer(
    this.fromString,
    this.asString, {
    this.validate,
  });
}

TextInputParams useTextInput<T>(
  T? value,
  void Function(T?) onChanged,
  StringInputSerializer<T> serializer,
) {
  final controller = useTextEditingController();
  final focusNode = useFocusNode();
  final error = useState<String?>(null);
  final isTouched = useState(false);

  useEffect(() {
    if (value == null) {
      controller.value = controller.value.copyWith(text: "");
    } else if (serializer.fromString(controller.text) != value) {
      error.value = null;
      controller.value = controller.value.copyWith(
        text: serializer.asString(value),
      );
    }
  }, [serializer, value]);

  final onChangedString = useMemoized(() {
    void _onControllerChange(String newString) {
      final newValue = serializer.fromString(newString);
      final newError = serializer.validate?.call(newString, newValue);

      if (newValue != null && newError == null) {
        if (value != newValue) {
          onChanged(newValue);
        }
        error.value = null;
      } else if (newString.isEmpty) {
        if (value != newValue) {
          onChanged(null);
        }
      } else {
        error.value = newError ?? '';
      }
    }

    return _onControllerChange;
  }, [serializer, value, onChanged]);

  useValueChanged<bool, void>(focusNode.hasPrimaryFocus, (prev, _) {
    if (prev && !focusNode.hasPrimaryFocus) {
      isTouched.value = true;
    }
  });

  return TextInputParams(
    controller: controller,
    focusNode: focusNode,
    error: error.value,
    isTouched: isTouched.value,
    onChangedString: onChangedString,
  );
}

class TextInputParams {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? error;
  final bool isTouched;
  final void Function(String) onChangedString;

  const TextInputParams({
    required this.controller,
    required this.focusNode,
    required this.error,
    required this.isTouched,
    required this.onChangedString,
  });

  String? get errorIfTouched => isTouched ? error : null;
  String? get errorIfTouchedNotEmpty =>
      isTouched && controller.text.isNotEmpty ? error : null;
}
