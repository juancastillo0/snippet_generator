import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';
import 'package:snippet_generator/utils/extensions.dart';

class RowBoolField extends StatelessWidget {
  const RowBoolField({
    Key? key,
    required this.notifier,
    required this.label,
  }) : super(key: key);

  final AppNotifier<bool> notifier;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        notifier.rebuild(
          (value) => Checkbox(
            value: value,
            onChanged: (value) {
              assert(value != null);
              notifier.value = value!;
            }
          ),
        ),
      ],
    );
  }
}

class RowTextField extends StatelessWidget {
  const RowTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.inputFormatters,
    double? width,
    this.rowLayout = true,
  })  : this.width = width ?? (rowLayout ? 165.0 : 120.0),
        super(key: key);

  final TextEditingController controller;
  final List<TextInputFormatter>? inputFormatters;
  final String label;
  final double width;
  final bool rowLayout;

  @override
  Widget build(BuildContext context) {
    if (rowLayout) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.subtitle1!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 15),
          SizedBox(
            width: width,
            child: TextField(
              controller: controller,
              textCapitalization: TextCapitalization.sentences,
              inputFormatters: inputFormatters,
            ),
          ),
        ],
      );
    } else {
      return SizedBox(
        width: width,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
          ),
          textCapitalization: TextCapitalization.sentences,
          inputFormatters: inputFormatters,
        ),
      );
    }
  }
}
