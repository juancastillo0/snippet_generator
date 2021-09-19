import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';

class MenuPortalEntry extends StatelessWidget {
  const MenuPortalEntry({
    Key? key,
    required this.options,
    required this.child,
    required this.isVisible,
    this.width = 100.0,
    this.onClose,
  }) : super(key: key);

  final List<Widget> options;
  final Widget child;
  final bool isVisible;
  final double width;
  final void Function()? onClose;

  @override
  Widget build(BuildContext context) {
    final menuWidget = PortalEntry(
      visible: isVisible && options.isNotEmpty,
      portalAnchor: Alignment.topCenter,
      childAnchor: Alignment.bottomCenter,
      portal: Container(
        constraints: const BoxConstraints(maxHeight: 300),
        width: width,
        margin: const EdgeInsets.only(top: 5),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
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
    );

    if (onClose == null) {
      return menuWidget;
    }
    return PortalEntry(
      visible: isVisible && options.isNotEmpty,
      portal: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onClose,
      ),
      child: menuWidget,
    );
  }
}
