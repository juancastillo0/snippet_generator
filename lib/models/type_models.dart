import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:snippet_generator/collection_notifier/list_notifier.dart';
import 'package:snippet_generator/models/models.dart';
import 'package:snippet_generator/models/root_store.dart';
import 'package:snippet_generator/models/serializer.dart';
import 'package:uuid/uuid.dart';

class TypeConfig implements Serializable<TypeConfig>, Keyed {
  @override
  final String key;

  TextEditingController nameNotifier;
  String get name => nameNotifier.text;

  // Settings

  AppNotifier<bool> isDataValueNotifier;
  bool get isDataValue => isDataValueNotifier.value;

  AppNotifier<bool> isSumTypeNotifier;
  bool get isSumType => isSumTypeNotifier.value;

  AppNotifier<bool> isSerializableNotifier;
  bool get isSerializable => isSerializableNotifier.value;

  AppNotifier<bool> isListenableNotifier;
  bool get isListenable => isListenableNotifier.value;

  AppNotifier<bool> isEnumNotifier;
  bool get isEnum => isEnumNotifier.value;

  AppNotifier<String> defaultEnumKeyNotifier;
  Computed<ClassConfig> defaultEnumNotifier;
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

  TypeConfig({
    String key,
    String name,
    bool isEnum,
    bool isDataValue,
    bool isSumType,
    bool isSerializable,
    bool isListenable,
    String defaultEnumKey,
  }) : key = key ?? uuid.v4() {
    isEnumNotifier = AppNotifier(isEnum ?? false, parent: this);
    isDataValueNotifier = AppNotifier(isDataValue ?? false, parent: this);
    isSumTypeNotifier = AppNotifier(isSumType ?? false, parent: this);
    isSerializableNotifier = AppNotifier(isSerializable ?? true, parent: this);
    isListenableNotifier = AppNotifier(isListenable ?? false, parent: this);
    defaultEnumKeyNotifier = AppNotifier(defaultEnumKey, parent: this);
    defaultEnumNotifier = Computed(
        () => defaultEnumKeyNotifier.value != null
            ? classes.firstWhere(
                (e) => e.key == defaultEnumKeyNotifier.value,
                orElse: () => null,
              )
            : null,
        [defaultEnumKeyNotifier, classes]);
    nameNotifier = TextEditingController(text: name);

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
      () => this.isEnum || this.isSumType,
      [
        isEnumNotifier,
        isSumTypeNotifier,
      ],
    );
    // classes.addListener(() {
    //   if (defaultEnum != null && !classes.contains(defaultEnum)) {
    //     defaultEnumNotifier.value = null;
    //   }
    // });
    classes.addListener(_setUpDeepListenable);
    _setUpDeepListenable();
  }

  void addVariant() {
    classes.add(ClassConfig(typeConfigKey: key));
  }

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

  @override
  Map<String, dynamic> toJson() {
    return {
      "key": key,
      "name": name,
      "isEnum": isEnum,
      "isDataValue": isDataValue,
      "isSumType": isSumType,
      "isSerializable": isSerializable,
      "isListenable": isListenable,
      "defaultEnumKey": defaultEnum?.key
    };
  }

  static TypeConfig fromJson(Map<String, dynamic> json) {
    return TypeConfig(
      key: json["key"] as String,
      name: json["name"] as String,
      isEnum: json["isEnum"] as bool,
      isDataValue: json["isDataValue"] as bool,
      isSumType: json["isSumType"] as bool,
      isSerializable: json["isSerializable"] as bool,
      isListenable: json["isListenable"] as bool,
      defaultEnumKey: json["defaultEnumKey"] as String,
    );
  }

  static final serializer = SerializerFunc<TypeConfig>(fromJson: fromJson);
}

class ClassConfig implements Serializable<ClassConfig>, Keyed {
  @override
  final String key;

  TextNotifier nameNotifier;
  String get name => nameNotifier.text;

  bool get isDefault => this == typeConfig.defaultEnum;

  final ListNotifier<PropertyField> properties =
      ListNotifier<PropertyField>([]);
  Computed<List<PropertyField>> propertiesSortedNotifier;
  List<PropertyField> get propertiesSorted => propertiesSortedNotifier.value;

  final String typeConfigKey;
  TypeConfig _typeConfig;
  TypeConfig get typeConfig {
    return _typeConfig ??= Globals.get<RootStore>().types[typeConfigKey];
  }

  final _deepListenable = AppNotifier<Listenable>(null);
  Listenable get deepListenable => _deepListenable.value;
  Listenable _listenable;
  Listenable get listenable => _listenable;

  ClassConfig({
    @required this.typeConfigKey,
    String name,
    String key,
  }) : key = key ?? uuid.v4() {
    nameNotifier = TextNotifier(initialText: name, parent: this);
    _listenable = Listenable.merge([nameNotifier.textNotifier, properties]);

    propertiesSortedNotifier = Computed(() {
      final list = [...properties];
      list.sort();
      return list;
    }, [properties]);

    properties.addListener(_setUpDeepListenable);
    _setUpDeepListenable();
  }

  void _setUpDeepListenable() {
    _deepListenable.value = Listenable.merge(
        [_deepListenable, _listenable, ...properties.map((e) => e.listenable)]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "typeKey": typeConfig.key,
      "key": key,
      "name": name,
    };
  }

  static ClassConfig fromJson(Map<String, dynamic> json) {
    final typeKey = json["typeKey"] as String;
    if (typeKey == null) {
      return null;
    }
    return ClassConfig(
      typeConfigKey: typeKey,
      key: json["key"] as String,
      name: json["name"] as String,
    );
  }

  static final serializer = SerializerFunc<ClassConfig>(fromJson: fromJson);
}

class PropertyField
    implements Comparable<PropertyField>, Serializable<PropertyField>, Keyed {
  @override
  final String key;

  TextNotifier nameNotifier;
  String get name => nameNotifier.text;

  TextNotifier typeNotifier;
  String get type => typeNotifier.text;

  AppNotifier<bool> isRequiredNotifier;
  bool get isRequired => isRequiredNotifier.value;

  AppNotifier<bool> isPositionalNotifier;
  bool get isPositional => isPositionalNotifier.value;

  final String classConfigKey;
  ClassConfig _classConfig;
  ClassConfig get classConfig {
    return _classConfig ??= Globals.get<RootStore>()
        .types
        .values
        .expand((e) => e.classes)
        .firstWhere((e) => e.key == classConfigKey, orElse: () => null);
  }

  PropertyField({
    @required this.classConfigKey,
    String key,
    String name,
    String type,
    bool isRequired,
    bool isPositional,
  }) : key = _s.init(key) {
    typeNotifier = TextNotifier(initialText: type, parent: this);
    nameNotifier = TextNotifier(initialText: name, parent: this);
    isRequiredNotifier = AppNotifier(isRequired ?? true);
    isPositionalNotifier = AppNotifier(isPositional ?? false);

    _listenable = Listenable.merge([
      nameNotifier.textNotifier,
      typeNotifier.textNotifier,
      isRequiredNotifier,
      isPositionalNotifier
    ]);
    _s.collect(this.key);
  }

  Listenable _listenable;
  Listenable get listenable => _listenable;

  @override
  Map<String, dynamic> toJson() {
    return {
      "classKey": classConfig.key,
      "key": key,
      "name": name,
      "type": type,
      "isRequired": isRequired,
      "isPositional": isPositional
    };
  }

  static PropertyField fromJson(Map<String, dynamic> json) {
    final classKey = json["classKey"] as String;
    if (classKey == null) {
      return null;
    }
    return PropertyField(
      classConfigKey: classKey,
      key: json["key"] as String,
      name: json["name"] as String,
      type: json["type"] as String,
      isRequired: json["isRequired"] as bool,
      isPositional: json["isPositional"] as bool,
    );
  }

  static final serializer = SerializerFunc<PropertyField>(fromJson: fromJson);

  @override
  int compareTo(PropertyField other) {
    int _compareRequired() {
      if (isRequired) {
        return -1;
      } else if (other.isRequired) {
        return 1;
      } else {
        return 0;
      }
    }

    if (isPositional) {
      if (other.isPositional) {
        return _compareRequired();
      } else {
        return -1;
      }
    } else if (other.isPositional) {
      return 1;
    } else {
      return _compareRequired();
    }
  }
}

final uuid = Uuid();

abstract class Keyed {
  String get key;
}

class KeySetter {
  String init(String key) {
    return key ?? uuid.v4();
  }

  void collect(String key) {}
}

final _s = KeySetter();
