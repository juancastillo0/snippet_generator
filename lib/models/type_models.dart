import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:petitparser/petitparser.dart';
import 'package:snippet_generator/collection_notifier/list_notifier.dart';
import 'package:snippet_generator/models/models.dart';
import 'package:snippet_generator/models/root_store.dart';
import 'package:snippet_generator/models/serializable_config.dart';
import 'package:snippet_generator/models/serializer.dart';
import 'package:snippet_generator/models/sum_type_config.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';
import 'package:snippet_generator/notifiers/computed_notifier.dart';
import 'package:snippet_generator/parsers/signature_parser.dart';
import 'package:snippet_generator/parsers/type_parser.dart';
import 'package:uuid/uuid.dart';

class AdvancedTypeConfig implements Serializable<AdvancedTypeConfig> {
  /*late final*/ TextNotifier customCodeNotifier;
  String get customCode => customCodeNotifier.text;

  /*late final*/ AppNotifier<bool> overrideConstructorNotifier;
  bool get overrideConstructor => overrideConstructorNotifier.value;

  /*late final*/ AppNotifier<bool> isConstNotifier;
  bool get isConst => isConstNotifier.value;

  /*late final*/ Listenable _listenable;
  Listenable get listenable => _listenable;

  AdvancedTypeConfig({
    String customCode,
    bool overrideConstructor,
    bool isConst,
  }) {
    overrideConstructorNotifier = AppNotifier(overrideConstructor ?? false,
        parent: this, name: "overrideConstructor");
    customCodeNotifier = TextNotifier(initialText: customCode, parent: this);
    isConstNotifier =
        AppNotifier(isConst ?? true, parent: this, name: "isConst");

    _listenable = Listenable.merge([
      overrideConstructorNotifier,
      customCodeNotifier.textNotifier,
      isConstNotifier,
    ]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "customCode": customCode,
      "overrideConstructor": overrideConstructor,
      "isConst": isConst,
    };
  }

  static AdvancedTypeConfig fromJson(Map<String, dynamic> json) {
    return AdvancedTypeConfig(
      customCode: json["customCode"] as String,
      overrideConstructor: json["overrideConstructor"] as bool,
      isConst: json["isConst"] as bool,
    );
  }
}

class TypeConfig
    implements Serializable<TypeConfig>, Keyed, Clonable<TypeConfig> {
  @override
  final String key;

  /*late final*/ TextNotifier signatureNotifier;
  String get signature => signatureNotifier.text;

  /*late final*/ ComputedNotifier<Result<SignatureParser>> signatureParserNotifier;
  String get name {
    final result = signatureParserNotifier.value;
    if (result.isSuccess) {
      return result.value.name;
    } else {
      return signature;
    }
  }

  // Settings

  /*late final*/ AppNotifier<bool> isDataValueNotifier;
  bool get isDataValue => isDataValueNotifier.value;

  /*late final*/ AppNotifier<bool> isSumTypeNotifier;
  bool get isSumType => isSumTypeNotifier.value;
  /*late final*/ SumTypeConfig sumTypeConfig;

  /*late final*/ AppNotifier<bool> isSerializableNotifier;
  bool get isSerializable => isSerializableNotifier.value;
  /*late final*/ SerializableConfig serializableConfig;

  /*late final*/ AppNotifier<bool> isListenableNotifier;
  bool get isListenable => isListenableNotifier.value;

  /*late final*/ AppNotifier<bool> isEnumNotifier;
  bool get isEnum => isEnumNotifier.value;

  // Advanced

  /*late final*/ AdvancedTypeConfig advancedConfig;

  // Enum

  /*late final*/ AppNotifier<String> defaultEnumKeyNotifier;
  /*late final*/ ComputedNotifier<ClassConfig> defaultEnumNotifier;
  ClassConfig get defaultEnum => defaultEnumNotifier.value;

  /*late final*/ ComputedNotifier<bool> hasVariants;

  final ListNotifier<ClassConfig/*!*/> classes;

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

  RootStore get rootStore => Globals.get<RootStore>();

  TypeConfig({
    String key,
    String signature,
    bool isEnum,
    bool isDataValue,
    bool isSumType,
    bool isSerializable,
    bool isListenable,
    String defaultEnumKey,
    List<ClassConfig> classes,
    AdvancedTypeConfig advancedConfig,
    SumTypeConfig sumTypeConfig,
    SerializableConfig serializableConfig,
  })  : key = key ?? uuid.v4(),
        classes = ListNotifier(classes ?? []),
        sumTypeConfig = sumTypeConfig ?? SumTypeConfig(),
        serializableConfig = serializableConfig ?? SerializableConfig() {
    isEnumNotifier = AppNotifier(isEnum ?? false, parent: this);
    isDataValueNotifier = AppNotifier(isDataValue ?? false, parent: this);
    isSumTypeNotifier = AppNotifier(isSumType ?? false, parent: this);
    isSerializableNotifier = AppNotifier(isSerializable ?? true, parent: this);
    isListenableNotifier = AppNotifier(isListenable ?? false, parent: this);
    defaultEnumKeyNotifier = AppNotifier(defaultEnumKey, parent: this);
    this.advancedConfig = advancedConfig ?? AdvancedTypeConfig();
    signatureNotifier = TextNotifier(initialText: signature, parent: this);
    signatureParserNotifier = ComputedNotifier(
      () => SignatureParser.parser.parse(signatureNotifier.text),
      [signatureNotifier.textNotifier],
    );
    defaultEnumNotifier = ComputedNotifier(
      () => defaultEnumKeyNotifier.value != null
          ? this.classes.firstWhere(
                (e) => e.key == defaultEnumKeyNotifier.value,
                orElse: () => null,
              )
          : null,
      [defaultEnumKeyNotifier, this.classes],
    );

    _listenable = Listenable.merge([
      isEnumNotifier,
      isDataValueNotifier,
      isSumTypeNotifier,
      isSerializableNotifier,
      isListenableNotifier,
      signatureNotifier.textNotifier,
      this.advancedConfig.listenable,
      this.classes,
      defaultEnumNotifier
    ]);

    hasVariants = ComputedNotifier(
      () => this.isEnum || this.isSumType,
      [
        isEnumNotifier,
        isSumTypeNotifier,
      ],
    );
    this.classes.addListener(_setUpDeepListenable);
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
      ...classes.map((e) => e.deepListenable),
    ]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "key": key,
      "signature": signature,
      "isEnum": isEnum,
      "isDataValue": isDataValue,
      "isSumType": isSumType,
      "isSerializable": isSerializable,
      "isListenable": isListenable,
      "defaultEnumKey": defaultEnum?.key,
      "advancedConfig": advancedConfig.toJson(),
      "sumTypeConfig": sumTypeConfig.toMap(),
      "serializableConfig": serializableConfig.toMap(),
    };
  }

  static TypeConfig fromJson(Map<String, dynamic> json) {
    return TypeConfig(
      key: json["key"] as String,
      signature: json["signature"] as String,
      isEnum: json["isEnum"] as bool,
      isDataValue: json["isDataValue"] as bool,
      isSumType: json["isSumType"] as bool,
      isSerializable: json["isSerializable"] as bool,
      isListenable: json["isListenable"] as bool,
      defaultEnumKey: json["defaultEnumKey"] as String,
      advancedConfig: AdvancedTypeConfig.fromJson(
        json["advancedConfig"] as Map<String, dynamic> ??
            {
              "customCode": json["customCode"] as String,
              "overrideConstructor": json["overrideConstructor"] as bool,
              "isConst": json["isConst"] as bool,
            },
      ),
      sumTypeConfig: SumTypeConfig()
        ..tryFromMap(json["sumTypeConfig"] as Map<String, dynamic>),
      serializableConfig: SerializableConfig()
        ..tryFromMap(json["serializableConfig"] as Map<String, dynamic>),
    );
  }

  static final serializer = SerializerFunc<TypeConfig>(fromJson: fromJson);

  TypeConfig copyWith({
    String name,
    bool isEnum,
    bool isDataValue,
    bool isSumType,
    bool isSerializable,
    bool isListenable,
    String defaultEnumKey,
    List<ClassConfig> classes,
  }) {
    return TypeConfig(
      signature: signature ?? this.signature,
      isEnum: isEnum ?? this.isEnum,
      isDataValue: isDataValue ?? this.isDataValue,
      isSumType: isSumType ?? this.isSumType,
      isSerializable: isSerializable ?? this.isSerializable,
      isListenable: isListenable ?? this.isListenable,
      defaultEnumKey: defaultEnumKey ?? this.defaultEnum?.key,
      classes: classes ?? this.classes,
    );
  }

  @override
  TypeConfig clone() {
    return copyWith(classes: this.classes.map((e) => e.clone()).toList());
  }
}

class ClassConfig
    implements Serializable<ClassConfig>, Keyed, Clonable<ClassConfig> {
  @override
  final String key;

  /*late final*/ TextNotifier nameNotifier;
  String get name => nameNotifier.text;

  /*late final*/ AppNotifier<bool> isReorderingNotifier;
  bool get isReordering => isReorderingNotifier.value;

  bool get isDefault => this == typeConfig.defaultEnum;

  final ListNotifier<PropertyField/*!*/> properties;
  /*late final*/ComputedNotifier<List<PropertyField>> propertiesSortedNotifier;
  List<PropertyField>/*!*/ get propertiesSorted => propertiesSortedNotifier.value;

  final String typeConfigKey;
  TypeConfig _typeConfig;
  TypeConfig/*!*/ get typeConfig {
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
    List<PropertyField> properties,
  })  : key = key ?? uuid.v4(),
        properties =
            ListNotifier<PropertyField>(properties ?? <PropertyField>[]) {
    nameNotifier = TextNotifier(initialText: name, parent: this);
    isReorderingNotifier = AppNotifier(false, parent: this);
    _listenable = Listenable.merge([
      nameNotifier.textNotifier,
      this.properties,
    ]);

    propertiesSortedNotifier = ComputedNotifier(
      () {
        final list = [...this.properties];
        list.sort();
        return list;
      },
      [this.properties],
      derivedDependencies: () {
        return this.properties.expand(
          (e) sync* {
            yield e.isRequiredNotifier;
            yield e.isPositionalNotifier;
          },
        );
      },
    );

    this.properties.addListener(_setUpDeepListenable);
    _setUpDeepListenable();
  }

  void _setUpDeepListenable() {
    _deepListenable.value = Listenable.merge([
      _deepListenable,
      _listenable,
      ...properties.map((e) => e.listenable),
    ]);
  }

  void addProperty() {
    properties.add(PropertyField(classConfigKey: key));
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
      throw Exception("PropertyField fromJson parsing error. input: $json");
    }
    return ClassConfig(
      typeConfigKey: typeKey,
      key: json["key"] as String,
      name: json["name"] as String,
    );
  }

  static final serializer = SerializerFunc<ClassConfig>(fromJson: fromJson);

  ClassConfig copyWith({
    String typeConfigKey,
    String name,
    List<PropertyField> properties,
  }) {
    return ClassConfig(
      typeConfigKey: typeConfigKey ?? this.typeConfigKey,
      name: name ?? this.name,
      properties: properties ?? this.properties,
    );
  }

  @override
  ClassConfig clone() {
    return copyWith(properties: this.properties.map((e) => e.clone()).toList());
  }
}

class PropertyField
    implements
        Comparable<PropertyField>,
        Serializable<PropertyField>,
        Keyed,
        Clonable<PropertyField> {
  @override
  final String key;

  /*late final*/ TextNotifier nameNotifier;
  String get name => nameNotifier.text;

  /*late final*/ TextNotifier typeNotifier;
  String get type => typeNotifier.text;

  /*late final*/ ComputedNotifier<Result<JsonTypeParser>> parsedTypeNotifier;
  Result<JsonTypeParser> get parsedType => parsedTypeNotifier.value;

  /*late final*/ AppNotifier<bool/*!*/> isRequiredNotifier;
  bool get isRequired => isRequiredNotifier.value;

  /*late final*/ AppNotifier<bool/*!*/> isPositionalNotifier;
  bool get isPositional => isPositionalNotifier.value;

  /*late final*/ AppNotifier<bool/*!*/> isSelectedNotifier;
  bool get isSelected => isSelectedNotifier.value;

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
    isSelectedNotifier = AppNotifier(false);

    _listenable = Listenable.merge([
      nameNotifier.textNotifier,
      typeNotifier.textNotifier,
      isRequiredNotifier,
      isPositionalNotifier
    ]);
    parsedTypeNotifier = ComputedNotifier(
      () => JsonTypeParser.parser.parse(this.type),
      [typeNotifier.textNotifier],
    );
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
      return throw Exception("PropertyField fromJson parsing error. input: $json");
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

  PropertyField copyWith({
    String classConfigKey,
    String name,
    String type,
    bool isRequired,
    bool isPositional,
  }) {
    return PropertyField(
      classConfigKey: classConfigKey ?? this.classConfigKey,
      name: name ?? this.name,
      type: type ?? this.type,
      isRequired: isRequired ?? this.isRequired,
      isPositional: isPositional ?? this.isPositional,
    );
  }

  @override
  PropertyField clone() {
    return copyWith();
  }
}

const uuid = Uuid();

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

abstract class Clonable<T> {
  T clone();
}
