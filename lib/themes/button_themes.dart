import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:snippet_generator/fields/fields.dart';
import 'package:snippet_generator/models/props_serializable.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';
import 'package:snippet_generator/resizable_scrollable/scrollable.dart';
import 'package:snippet_generator/themes/themes_tab_view.dart';

enum ButtonType {
  text,
  outlined,
  elevated,
}

abstract class BaseButtonThemeNotifier with PropsSerializable {
  final ButtonType type;
  @override
  final String name;

  BaseButtonThemeNotifier(this.type, {required this.name});

  final alignment = AppNotifier<Alignment?>(null, name: "alignment");
  final elevation = AppNotifier<double?>(null, name: "elevation");
  final fixedSize = AppNotifier<Size?>(null, name: "fixedSize");
  final minimumSize = AppNotifier<Size?>(null, name: "minimumSize");
  final padding = AppNotifier<EdgeInsets?>(null, name: "padding");
  final primary = AppNotifier<Color?>(null, name: "primary");
  final onSurface = AppNotifier<Color?>(null, name: "onSurface");
  final shadowColor = AppNotifier<Color?>(null, name: "shadowColor");
  final side = AppNotifier<BorderSide?>(null, name: "side");
  final visualDensity =
      AppNotifier<VisualDensity?>(null, name: "visualDensity");
  final tapTargetSize =
      AppNotifier<MaterialTapTargetSize?>(null, name: "tapTargetSize");
  final shape = AppNotifier<OutlinedBorder?>(null, name: "shape");

  Widget form() {
    return _ButtonForm(props: props);
  }

  static List<SerializableProp> defaultProps(
    BaseButtonThemeNotifier instance,
  ) {
    return [
      instance.alignment,
      instance.elevation,
      instance.fixedSize,
      instance.minimumSize,
      instance.padding,
      instance.primary,
      instance.shadowColor,
      instance.onSurface,
      instance.side,
      instance.visualDensity,
      instance.tapTargetSize,
      instance.shape,
    ];
  }
}

class _ButtonForm extends StatelessWidget {
  const _ButtonForm({
    Key? key,
    required this.props,
  }) : super(key: key);

  final Iterable<SerializableProp> props;

  @override
  Widget build(BuildContext context) {
    final colorProps = props.whereType<AppNotifier<Color?>>().toSet();
    return SizedBox(
      height: 300,
      child: SingleScrollable(
        padding: const EdgeInsets.only(right: 20),
        child: Wrap(
          children: [
            Column(
              children: [
                ...colorProps.map(
                  (notifier) => Observer(
                    builder: (context) => ColorFieldRow(
                      name: notifier.name,
                      onChanged: notifier.set,
                      value: notifier.value ?? Colors.white,
                    ),
                  ),
                )
              ],
            ),
            ...props
                .cast<AppNotifier<Object?>>()
                .where((p) => !colorProps.contains(p))
                .map(GlobalFields.get)
                .whereType<Widget>()
          ],
        ),
      ),
    );
  }
}

class TextButtonThemeNotifier extends BaseButtonThemeNotifier {
  TextButtonThemeNotifier({required String name})
      : super(ButtonType.text, name: name);
  final backgroundColor = AppNotifier<Color?>(null, name: "backgroundColor");

  TextButtonThemeData get value => computed.value;
  late final computed = Computed<TextButtonThemeData>(() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        alignment: alignment.value,
        elevation: elevation.value,
        fixedSize: fixedSize.value,
        minimumSize: minimumSize.value,
        onSurface: onSurface.value,
        padding: padding.value,
        primary: primary.value,
        shadowColor: shadowColor.value,
        side: side.value,
        visualDensity: visualDensity.value,
        tapTargetSize: tapTargetSize.value,
        shape: shape.value,
        backgroundColor: backgroundColor.value,
      ),
    );
  });

  @override
  late final List<SerializableProp> props = [
    ...BaseButtonThemeNotifier.defaultProps(this),
    backgroundColor,
  ];
}

class OutlinedButtonThemeNotifier extends BaseButtonThemeNotifier {
  OutlinedButtonThemeNotifier({required String name})
      : super(ButtonType.outlined, name: name);
  final backgroundColor = AppNotifier<Color?>(null, name: "backgroundColor");

  OutlinedButtonThemeData get value => computed.value;
  late final computed = Computed<OutlinedButtonThemeData>(() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        alignment: alignment.value,
        elevation: elevation.value,
        fixedSize: fixedSize.value,
        minimumSize: minimumSize.value,
        onSurface: onSurface.value,
        padding: padding.value,
        primary: primary.value,
        shadowColor: shadowColor.value,
        side: side.value,
        visualDensity: visualDensity.value,
        tapTargetSize: tapTargetSize.value,
        shape: shape.value,
        backgroundColor: backgroundColor.value,
      ),
    );
  });

  @override
  late final List<SerializableProp> props = [
    ...BaseButtonThemeNotifier.defaultProps(this),
    backgroundColor,
  ];
}

class ElevatedButtonThemeNotifier extends BaseButtonThemeNotifier {
  ElevatedButtonThemeNotifier({required String name})
      : super(ButtonType.elevated, name: name);
  final onPrimary = AppNotifier<Color?>(null, name: "onPrimary");

  ElevatedButtonThemeData get value => computed.value;
  late final computed = Computed<ElevatedButtonThemeData>(() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        alignment: alignment.value,
        elevation: elevation.value,
        fixedSize: fixedSize.value,
        minimumSize: minimumSize.value,
        onSurface: onSurface.value,
        padding: padding.value,
        primary: primary.value,
        shadowColor: shadowColor.value,
        side: side.value,
        visualDensity: visualDensity.value,
        tapTargetSize: tapTargetSize.value,
        shape: shape.value,
        onPrimary: onPrimary.value,
      ),
    );
  });

  @override
  late final List<SerializableProp> props = [
    ...BaseButtonThemeNotifier.defaultProps(this),
    onPrimary,
  ];
}
