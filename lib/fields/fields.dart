import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:snippet_generator/fields/base_fields.dart';
import 'package:snippet_generator/fields/color_field.dart';
import 'package:snippet_generator/fields/enum_fields.dart';
import 'package:snippet_generator/fields/flutter_fields.dart';
import 'package:snippet_generator/models/props_serializable.dart';
import 'package:snippet_generator/resizable_scrollable/scrollable.dart';

typedef FieldFunc<T> = Widget Function(PropClass<T>);

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
    // TODO: support EdgeInsetsGeometry
    add<EdgeInsets>(
      (notifier) => PaddingInput(
        key: ValueKey(notifier.name),
        set: notifier.set,
        value: notifier.value,
      ),
    );
    add<double>(
      (notifier) => DefaultCardInput(
        label: notifier.name,
        children: [
          DoubleInput(
            label: notifier.name,
            onChanged: notifier.set,
            value: notifier.value,
          ),
        ],
      ),
    );
    add<int>(
      (notifier) => DefaultCardInput(
        label: notifier.name,
        children: [
          IntInput(
            label: notifier.name,
            onChanged: notifier.set,
            value: notifier.value,
          ),
        ],
      ),
    );
    add<bool>(
      (notifier) => DefaultCardInput(
        label: notifier.name,
        children: [
          Switch(
            onChanged: notifier.set,
            value: notifier.value!,
          ),
        ],
      ),
    );
    add<Size>((notifier) => SizeInput(notifier: notifier));
    add<Color>((notifier) => ColorInput(notifier: notifier));

    setUpEnumFields();
  }
}

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

class PropsForm extends StatelessWidget {
  const PropsForm({
    Key? key,
    required this.props,
  }) : super(key: key);

  final Iterable<SerializableProp> props;

  @override
  Widget build(BuildContext context) {
    final colorProps = props.whereType<PropClass<Color?>>().toSet();
    final boolProps = props.whereType<PropClass<bool>>().toSet();

    return SizedBox(
      height: 300,
      child: SingleScrollable(
        padding: const EdgeInsets.only(right: 6),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Column(
              children: [
                ...colorProps.map(
                  (notifier) => AnimatedBuilder(
                    animation: notifier,
                    builder: (context, _) => ColorFieldRow(
                      name: notifier.name,
                      onChanged: notifier.set,
                      value: notifier.value ?? Colors.white,
                    ),
                  ),
                )
              ],
            ),
            Column(
              children: [
                ...boolProps.map(
                  (notifier) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 160, child: Text(notifier.name)),
                      AnimatedBuilder(
                        animation: notifier,
                        builder: (context, _) => Checkbox(
                          onChanged: (value) => notifier.set(value!),
                          value: notifier.value,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            ...props
                .cast<PropClass<Object?>>()
                .where((p) => !colorProps.contains(p) && !boolProps.contains(p))
                .map(GlobalFields.get)
                .whereType<Widget>()
          ],
        ),
      ),
    );
  }
}

class DefaultCardInput extends StatelessWidget {
  final List<Widget> children;
  final String label;

  const DefaultCardInput({
    Key? key,
    required this.label,
    required this.children,
  }) : super(key: key);

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
              child: Text(label),
            ),
            ...children,
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
