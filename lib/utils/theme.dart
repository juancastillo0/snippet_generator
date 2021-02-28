import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

ButtonStyle elevatedStyle(BuildContext context) => ElevatedButton.styleFrom(
      primary: Colors.white,
      onPrimary: Colors.black,
    );

ButtonStyle actionStyle(BuildContext context) => TextButton.styleFrom(
      primary: Colors.white,
      onSurface: Colors.white,
      disabledMouseCursor: MouseCursor.defer,
      enabledMouseCursor: SystemMouseCursors.click,
      padding: const EdgeInsets.symmetric(horizontal: 17),
    );

ButtonStyle menuStyle(BuildContext context, {EdgeInsetsGeometry? padding}) => TextButton.styleFrom(
      primary: Colors.black,
      padding: padding,
    );
