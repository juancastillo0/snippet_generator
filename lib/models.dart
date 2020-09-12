import 'package:flutter/widgets.dart';

enum SnippetEnum {
  sumType,
  serializable,
  dataValue,
}

class AppNotifier<T> extends ValueNotifier<T> {
  AppNotifier(T value) : super(value);

  void set(T value) {
    this.value = value;
  }

  Widget rebuild(Widget Function(T value) fn) {
    return AnimatedBuilder(
      animation: this,
      builder: (context, _) {
        return fn(value);
      },
    );
  }
}

class PropertyField {
  final name = TextEditingController();
  final type = TextEditingController();
  final isRequired = AppNotifier(true);
  final isPositional = AppNotifier(false);

  PropertyField() {
    _listenable = Listenable.merge([name, type, isRequired, isPositional]);
  }

  Listenable _listenable;
  Listenable get listenable => _listenable;
}

class TypeConfig {
  final name = TextEditingController();
  final isDataValue = AppNotifier(false);
  final isSumType = AppNotifier(false);
  final isSerializable = AppNotifier(true);
  final isListenable = AppNotifier(false);
  final classes = ListNotifier<ClassConfig>([]);

  final _deepListenable = AppNotifier<Listenable>(null);
  Listenable get deepListenable => _deepListenable.value;
  Listenable _listenable;
  Listenable get listenable => _listenable;

  TypeConfig() {
    _listenable = Listenable.merge(
        [isDataValue, isSumType, isSerializable, isListenable, name, classes]);

    classes.addListener(_setUpDeepListenable);
    classes.add(ClassConfig(this));
  }

  var __s = <AppNotifier<Listenable>>{};
  void _setUpDeepListenable() {
    final _s = classes.value.map((e) => e._deepListenable).toSet();

    __s.difference(_s).forEach((element) {
      element.removeListener(_setUpDeepListenable);
    });
    _s.difference(__s).forEach((element) {
      element.addListener(_setUpDeepListenable);
    });
    __s = _s;

    _deepListenable.value = Listenable.merge(
        [_deepListenable, _listenable, ...classes.value.map((e) => e.deepListenable)]);
  }
}

class ClassConfig {
  final name = TextEditingController();
  final isPrivate = AppNotifier(true);
  final properties = ListNotifier<PropertyField>([]);

  final TypeConfig typeConfig;
  final _deepListenable = AppNotifier<Listenable>(null);
  Listenable get deepListenable => _deepListenable.value;
  Listenable _listenable;
  Listenable get listenable => _listenable;

  ClassConfig(this.typeConfig) {
    _listenable = Listenable.merge([name, properties, isPrivate]);
    properties.addListener(_setUpDeepListenable);
  }

  void _setUpDeepListenable() {
    _deepListenable.value = Listenable.merge(
        [_deepListenable, _listenable, ...properties.value.map((e) => e.listenable)]);
  }
}

class ListNotifier<T> extends AppNotifier<List<T>> {
  ListNotifier(List<T> value) : super(value);

  void add(T item) {
    value = [...value, item];
  }

  void remove(T property) {
    value = [...value..remove(property)];
  }
}
