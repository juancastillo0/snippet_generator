import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snippet_generator/utils/extensions.dart';
import 'package:snippet_generator/models/models.dart';

class RowBoolField extends StatelessWidget {
  const RowBoolField({
    Key key,
    @required this.notifier,
    @required this.label,
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
            onChanged: notifier.set,
          ),
        ),
      ],
    );
  }
}

class RowTextField extends StatelessWidget {
  const RowTextField({
    Key key,
    @required this.controller,
    @required this.label,
    this.inputFormatters,
    this.width = 165.0
  }) : super(key: key);

  final TextEditingController controller;
  final List<TextInputFormatter> inputFormatters;
  final String label;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.subtitle1.copyWith(
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
  }
}
