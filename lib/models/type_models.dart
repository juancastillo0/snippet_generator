import 'package:flutter/widgets.dart';
import 'package:snippet_generator/models/models.dart';

class TypeConfig {
  final nameNotifier = TextEditingController();
  String get name => nameNotifier.text;

  final isDataValueNotifier = AppNotifier(false);
  bool get isDataValue => isDataValueNotifier.value;

  final isSumTypeNotifier = AppNotifier(false);
  bool get isSumType => isSumTypeNotifier.value;

  final isSerializableNotifier = AppNotifier(true);
  bool get isSerializable => isSerializableNotifier.value;

  final isListenableNotifier = AppNotifier(false);
  bool get isListenable => isListenableNotifier.value;

  final isEnumNotifier = AppNotifier(false);
  bool get isEnum => isEnumNotifier.value;

  Computed<bool> hasVariants;

  final classes = ListNotifier<ClassConfig>([]);

  final _deepListenable = AppNotifier<Listenable>(null);
  Listenable get deepListenable => _deepListenable.value;
  Listenable _listenable;
  Listenable get listenable => _listenable;

  TypeConfig() {
    _listenable = Listenable.merge([
      isEnumNotifier,
      isDataValueNotifier,
      isSumTypeNotifier,
      isSerializableNotifier,
      isListenableNotifier,
      nameNotifier,
      classes
    ]);
    hasVariants = Computed(
      () => isEnum || isSumType,
      [
        isEnumNotifier,
        isSumTypeNotifier,
      ],
    );
    classes.add(ClassConfig(this));
    classes.addListener(_setUpDeepListenable);
    _setUpDeepListenable();
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

    _deepListenable.value = Listenable.merge([
      _deepListenable,
      _listenable,
      ...classes.value.map((e) => e.deepListenable)
    ]);
  }
}

class ClassConfig {
  final nameNotifier = TextEditingController();
  String get name => nameNotifier.text;

  final isPrivateNotifier = AppNotifier(true);
  bool get isPrivate => isPrivateNotifier.value;

  final properties = ListNotifier<PropertyField>([]);

  final TypeConfig typeConfig;
  final _deepListenable = AppNotifier<Listenable>(null);
  Listenable get deepListenable => _deepListenable.value;
  Listenable _listenable;
  Listenable get listenable => _listenable;

  ClassConfig(this.typeConfig) {
    _listenable = Listenable.merge([
      nameNotifier,
      properties,
      isPrivateNotifier,
    ]);
    properties.addListener(_setUpDeepListenable);
    _setUpDeepListenable();
  }

  void _setUpDeepListenable() {
    _deepListenable.value = Listenable.merge([
      _deepListenable,
      _listenable,
      ...properties.value.map((e) => e.listenable)
    ]);
  }
}

class PropertyField {
  final name = TextEditingController();
  final type = TextEditingController();
  final typeFocusNode = FocusNode();
  final isRequired = AppNotifier(true);
  final isPositional = AppNotifier(false);

  PropertyField() {
    _listenable = Listenable.merge([name, type, isRequired, isPositional]);
  }

  Listenable _listenable;
  Listenable get listenable => _listenable;
}

class Computed<T> extends AppNotifier<T> {
  Computed(
    T Function() computer,
    List<Listenable> dependencies,
  ) : super(computer()) {
    Listenable.merge(dependencies).addListener(() {
      value = computer();
    });
  }
}
