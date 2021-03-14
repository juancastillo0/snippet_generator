import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snippet_generator/formatters.dart';

class DoubleInput extends HookWidget {
  final String label;
  final void Function(double) onChanged;
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
      inputFormatters: [Formatters.onlyDigitsOrDecimal],
      focusNode: input.focusNode,
      keyboardType: TextInputType.number,
    );
  }
}

class IntInput extends HookWidget {
  final String label;
  final void Function(int) onChanged;
  final int? value;

  const IntInput({
    Key? key,
    required this.label,
    required this.onChanged,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final input = useTextInput<int>(
      value,
      onChanged,
      intStringInput,
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
              child: const Icon(Icons.arrow_drop_up),
            ),
            TextButton(
              onPressed: value == null
                  ? null
                  : () {
                      onChanged(value! - 1);
                    },
              child: const Icon(Icons.arrow_drop_down),
            ),
          ],
        )
      ],
    );
  }
}

final doubleStringInput = StringInputSerializer<double>(
  double.tryParse,
  (v) => v.toString(),
);

final intStringInput = StringInputSerializer<int>(
  int.tryParse,
  (v) => v.toString(),
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
  void Function(T) onChanged,
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
      controller.value = controller.value.copyWith(
        text: serializer.asString(value),
      );
    }
  }, [serializer, value]);

  useEffect(() {
    void _onControllerChange() {
      final newValue = serializer.fromString(controller.text);
      final newError = serializer.validate?.call(controller.text, newValue);

      if (newValue != null && newError == null) {
        onChanged(newValue);
        error.value = null;
      } else {
        error.value = newError ?? '';
      }
    }

    controller.addListener(_onControllerChange);
    return () {
      controller.removeListener(_onControllerChange);
    };
  }, [serializer, onChanged]);

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
  );
}

class TextInputParams {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? error;
  final bool isTouched;

  const TextInputParams({
    required this.controller,
    required this.focusNode,
    required this.error,
    required this.isTouched,
  });

  String? get errorIfTouched => isTouched ? error : null;
  String? get errorIfTouchedNotEmpty =>
      isTouched && controller.text.isNotEmpty ? error : null;
}
