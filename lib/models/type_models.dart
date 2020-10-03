import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:snippet_generator/collection_notifier/list_notifier.dart';
import 'package:snippet_generator/models/models.dart';

class TextValue {
  TextValue() {
    textNotifier = Computed(() => controller.text, [controller]);
  }

  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  Computed<String> textNotifier;
  String get text => controller.text;
}

class TypeConfig {
  final nameNotifier = TextEditingController();
  String get name => nameNotifier.text;

  // Settings

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

  final defaultEnumNotifier = AppNotifier<ClassConfig>(null);
  ClassConfig get defaultEnum => defaultEnumNotifier.value;

  Computed<bool> hasVariants;

  final classes = ListNotifier<ClassConfig>([]);

  Map<String, AppNotifier<bool>> get allSettings => {
        "Data Value": isDataValueNotifier,
        "Listenable": isListenableNotifier,
        "Serializable": isSerializableNotifier,
        "Sum Type": isSumTypeNotifier,
        "Enum": isEnumNotifier,
      };

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
      classes,
      defaultEnumNotifier
    ]);
    hasVariants = Computed(
      () => isEnum || isSumType,
      [
        isEnumNotifier,
        isSumTypeNotifier,
      ],
    );
    classes.add(ClassConfig(this));
    classes.addListener(() {
      if (defaultEnum != null && !classes.contains(defaultEnum)) {
        defaultEnumNotifier.value = null;
      }
    });
    classes.addListener(_setUpDeepListenable);
    _setUpDeepListenable();
  }

  void addVariant() => classes.add(ClassConfig(this));

  var __s = <AppNotifier<Listenable>>{};
  void _setUpDeepListenable() {
    final _s = classes.map((e) => e._deepListenable).toSet();

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
      ...classes.map((e) => e.deepListenable)
    ]);
  }
}

class ClassConfig {
  final nameNotifier = TextEditingController();
  String get name => nameNotifier.text;

  bool get isDefault => this == typeConfig.defaultEnum;

  final properties = ListNotifier<PropertyField>([]);

  final TypeConfig typeConfig;
  final _deepListenable = AppNotifier<Listenable>(null);
  Listenable get deepListenable => _deepListenable.value;
  Listenable _listenable;
  Listenable get listenable => _listenable;

  ClassConfig(this.typeConfig) {
    _listenable = Listenable.merge([nameNotifier, properties]);
    properties.addListener(_setUpDeepListenable);
    _setUpDeepListenable();
  }

  void _setUpDeepListenable() {
    _deepListenable.value = Listenable.merge(
        [_deepListenable, _listenable, ...properties.map((e) => e.listenable)]);
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
