import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:snippet_generator/fields/base_fields.dart';
import 'package:snippet_generator/fields/color_field.dart';
import 'package:snippet_generator/fields/enum_fields.dart';
import 'package:snippet_generator/fields/flutter_border_fields.dart';
import 'package:snippet_generator/fields/flutter_fields.dart';
import 'package:snippet_generator/fields/text_theme_fields.dart';
import 'package:snippet_generator/models/props_serializable.dart';
import 'package:snippet_generator/resizable_scrollable/scrollable.dart';
import 'package:snippet_generator/themes/text_themes.dart';

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
    add<EdgeInsetsGeometry>(
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
    add<InputBorder>((notifier) => InputBorderInput(notifier: notifier));
    add<BorderSide>((notifier) => BorderSideInput(notifier: notifier));
    add<BorderRadius>((notifier) => BorderRadiusInput(notifier: notifier));
    add<TextTheme>((notifier) => TextThemeInput(
          set: notifier.set,
          key: ValueKey(notifier.name),
          value: notifier.value,
        ));

    add<TextStyle>((notifier) {
      final n = notifier;
      if (n is TextStyleNotifier) {
        return PropsForm(
          props: n.props,
        );
      } else {
        return Container();
      }
    });

    setUpEnumFields();
  }
}

class _FunctionWrapper<T> {
  final FieldFunc<T> _func;

  _FunctionWrapper(this._func);

  Widget build(PropClass<T> notifier) {
    return FocusTraversalGroup(
      child: AnimatedBuilder(
        animation: notifier,
        builder: (context, _child) {
          return _func(notifier);
        },
      ),
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
    final boolProps = props.whereType<PropClass<bool?>>().toSet();
    final numProps = props.whereType<PropClass<num?>>().toSet();

    return FocusTraversalGroup(
      child: SizedBox(
        height: 300,
        child: SingleScrollable(
          padding: const EdgeInsets.only(right: 6),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FocusTraversalGroup(
                child: Column(
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
              ),
              FocusTraversalGroup(
                child: Column(
                  children: [
                    ...boolProps.map(
                      (notifier) => SizedBox(
                        width: 180,
                        child: Row(
                          children: [
                            AnimatedBuilder(
                              animation: notifier,
                              builder: (context, _) => Checkbox(
                                onChanged: (value) => notifier.set(value!),
                                value: notifier.value,
                              ),
                            ),
                            Expanded(
                              child: Text(notifier.name),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              FocusTraversalGroup(
                child: Column(
                  children: [
                    ...numProps.map(
                      (notifier) => SizedBox(
                        width: 150,
                        child: AnimatedBuilder(
                          animation: notifier,
                          builder: (context, _) {
                            if (notifier is PropClass<int?>) {
                              return IntInput(
                                onChanged: (value) => notifier.set(value!),
                                value: notifier.value,
                                label: notifier.name,
                              );
                            } else {
                              return DoubleInput(
                                onChanged: (value) => notifier.set(value!),
                                value: notifier.value as double?,
                                label: notifier.name,
                              );
                            }
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
              ...props
                  .cast<PropClass<Object?>>()
                  .where((p) =>
                      !colorProps.contains(p) &&
                      !boolProps.contains(p) &&
                      !numProps.contains(p))
                  .map(GlobalFields.get)
                  .whereType<Widget>()
            ],
          ),
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
