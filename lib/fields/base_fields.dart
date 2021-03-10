import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

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
    final controller = useTextEditingController();
    useEffect(() {
      if (value == null) {
        controller.value = controller.value.copyWith(text: "");
      } else if (double.tryParse(controller.text) != value) {
        controller.value = controller.value.copyWith(text: value.toString());
      }
      return () {};
    }, [value]);

    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      onChanged: (String dx) {
        final dxNum = double.tryParse(dx);
        if (dxNum != null) {
          onChanged(dxNum);
        }
      },
    );
  }
}
