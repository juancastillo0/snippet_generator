import 'package:flutter/material.dart';

class SmallIconButton extends StatelessWidget {
  final bool center;
  final void Function()? onPressed;
  final Widget child;
  final double? splashRadius;

  const SmallIconButton({
    Key? key,
    this.center = true,
    required this.child,
    required this.onPressed,
    this.splashRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _button = IconButton(
      icon: child,
      constraints: const BoxConstraints(),
      alignment: Alignment.center,
      padding: EdgeInsets.zero,
      splashRadius: splashRadius ?? 22,
      iconSize: 18,
      onPressed: onPressed,
    );

    return Center(
      child: _button,
    );
  }
}
