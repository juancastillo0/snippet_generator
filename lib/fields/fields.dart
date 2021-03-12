import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:snippet_generator/fields/base_fields.dart';
import 'package:snippet_generator/fields/button_select_field.dart';
import 'package:snippet_generator/fields/flutter_fields.dart';

typedef FieldFunc<T> = Widget Function(PropClass<T>);

class _FunctionWrapper<T> {
  final FieldFunc<T> _func;

  _FunctionWrapper(this._func);

  Widget build(PropClass<T> notifier) {
    return AnimatedBuilder(
      animation: notifier,
      builder: (context, _child) {
        return _func(notifier);
      },
    );
  }
}

class GlobalFields {
  static final Map<Type, _FunctionWrapper<Object?>> _map = {};

  static Widget? get<T>(PropClass<T> notifier) {
    final builder = _map[notifier.type];
    return builder?.build(notifier);
  }

  static void add<T extends Object>(FieldFunc<T?> builder) {
    final _wrapper = _FunctionWrapper(builder);
    _map[T] = _wrapper;
    _addNullable<T?>(_wrapper);
  }

  static void _addNullable<T>(_FunctionWrapper<T?> wrapper) {
    _map[T] = wrapper;
  }

  static void init() {
    add<Alignment>(
      (notifier) => AlignmentInput(
        key: ValueKey(notifier.name),
        set: notifier.set,
        value: notifier.value,
      ),
    );
    add<EdgeInsets>(
      (notifier) => PaddingInput(
        key: ValueKey(notifier.name),
        set: notifier.set,
        value: notifier.value,
      ),
    );
    add<VisualDensity>(
      (notifier) => ButtonSelect<VisualDensity>(
        key: ValueKey(notifier.name),
        selected: notifier.value,
        options: const [
          VisualDensity.comfortable,
          VisualDensity.compact,
          VisualDensity.standard,
        ],
        onChange: notifier.set,
      ),
    );
    add<double>(
      (notifier) => DoubleInput(
        label: notifier.name,
        onChanged: notifier.set,
        value: notifier.value,
      ),
    );
    add<Size>((notifier) => SizeInput(notifier: notifier));
    add<Color>((notifier) => ColorInput(notifier: notifier));
  }
}

class SizeInput extends StatelessWidget {
  const SizeInput({
    Key? key,
    required this.notifier,
  }) : super(key: key);
  final PropClass<Size?> notifier;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(notifier.name),
            ),
            DoubleInput(
              label: "width",
              onChanged: (w) => notifier.set(
                Size(w, notifier.value?.height ?? 0),
              ),
              value: notifier.value?.width,
            ),
            DoubleInput(
              label: "height",
              onChanged: (h) => notifier.set(
                Size(notifier.value?.width ?? 0, h),
              ),
              value: notifier.value?.height,
            )
          ],
        ),
      ),
    );
  }
}

class ColorInput extends StatelessWidget {
  const ColorInput({
    Key? key,
    required this.notifier,
  }) : super(key: key);
  final PropClass<Color?> notifier;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(notifier.name),
            ),
            const SizedBox(height: 5),
            Builder(builder: (context) {
              final mq = MediaQuery.of(context);
              return MediaQuery(
                data: mq.copyWith(size: Size(250, mq.size.height)),
                child: ColorPicker(
                  pickerColor: notifier.value ?? Colors.black,
                  onColorChanged: notifier.set,
                  colorPickerWidth: 250.0,
                  pickerAreaHeightPercent: 0.7,
                  enableAlpha: true,
                  displayThumbColor: true,
                  showLabel: true,
                  paletteType: PaletteType.hsv,
                  pickerAreaBorderRadius: const BorderRadius.all(
                    Radius.circular(4.0),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

abstract class PropClass<T> implements ValueListenable<T> {
  Type get type;

  String get name;

  void set(T value);

  @override
  T get value;

  factory PropClass.fromNotifier(
    String name,
    ValueNotifier<T> valueNotifier,
  ) = _NotifierPropClass<T>;

  // factory PropClass.fromStream(
  //   String name,
  //   T initialValue,
  //   StreamController<T> valueNotifier,
  // ) = _StreamPropClass<T>;
}

class _NotifierPropClass<T> implements PropClass<T> {
  @override
  final String name;
  final ValueNotifier<T> valueNotifier;
  const _NotifierPropClass(this.name, this.valueNotifier);

  @override
  void set(T value) {
    valueNotifier.value = value;
  }

  @override
  T get value => valueNotifier.value;

  @override
  Type get type => T;

  @override
  void addListener(VoidCallback listener) {
    valueNotifier.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    valueNotifier.removeListener(listener);
  }
}

// class _StreamPropClass<T> implements PropClass<T> {
//   @override
//   final String name;

//   T _value;
//   final StreamController<T> controller;
//   _StreamPropClass(this.name, this._value, this.controller) {
//     controller.stream.listen((event) {
//       _value = event;
//     });
//   }

//   @override
//   void set(T value) {
//     controller.add(value);
//   }

//   @override
//   T get value => _value;

//   @override
//   Type get type => T;
// }
