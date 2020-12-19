import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_portal/flutter_portal.dart';
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
  const RowTextField(
      {Key key,
      @required this.controller,
      @required this.label,
      this.inputFormatters,
      this.width = 165.0})
      : super(key: key);

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

class MenuPortalEntry<T> extends StatelessWidget {
  const MenuPortalEntry({
    Key key,
    @required this.options,
    @required this.child,
    @required this.isVisible,
    this.onClose,
  }) : super(key: key);

  final List<Widget> options;
  final Widget child;
  final bool isVisible;
  final void Function() onClose;

  @override
  Widget build(BuildContext context) {
    return PortalEntry(
      visible: isVisible && options.isNotEmpty,
      portal: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onClose,
      ),
      child: PortalEntry(
        visible: isVisible && options.isNotEmpty,
        portalAnchor: Alignment.topCenter,
        childAnchor: Alignment.bottomCenter,
        portal: Container(
          constraints: const BoxConstraints(maxHeight: 300),
          width: 100,
          margin: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: const [
              BoxShadow(
                blurRadius: 2,
                spreadRadius: 1,
                offset: Offset(0, 1.5),
                color: Colors.black12,
              )
            ],
          ),
          child: ListView(
            itemExtent: 32,
            shrinkWrap: true,
            children: options,
          ),
        ),
        child: child,
      ),
    );
  }
}
