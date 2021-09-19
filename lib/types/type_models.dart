import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart' hide Listenable;
import 'package:petitparser/petitparser.dart';
import 'package:snippet_generator/globals/models.dart';
import 'package:snippet_generator/globals/props_serializable.dart';
import 'package:snippet_generator/globals/serializer.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';
import 'package:snippet_generator/notifiers/collection_notifier/list_notifier.dart';
import 'package:snippet_generator/notifiers/computed_notifier.dart';
import 'package:snippet_generator/parsers/class_fields_parser.dart';
import 'package:snippet_generator/parsers/signature_parser.dart';
import 'package:snippet_generator/parsers/type_parser.dart';
import 'package:snippet_generator/types/advanced/advanced_config.dart';
import 'package:snippet_generator/types/advanced/listenable_config.dart';
import 'package:snippet_generator/types/advanced/serializable_config.dart';
import 'package:snippet_generator/types/advanced/sum_type_config.dart';
import 'package:snippet_generator/types/root_store.dart';
import 'package:snippet_generator/types/templates/templates.dart';
import 'package:uuid/uuid.dart';
import 'package:y_crdt/y_crdt.dart';

class TypeConfig
    with ItemsSerializable
    implements Serializable, Keyed, Clonable<TypeConfig> {
  @override
  final String key;

  late final TextNotifier signatureNotifier;
  String get signature => signatureNotifier.text;

  late final ComputedNotifier<Result<SignatureParser>> signatureParserNotifier;
  String get name {
    final Result<SignatureParser> result = signatureParserNotifier.value;
    if (result.isSuccess) {
      return result.value.name;
    } else {
      return signature;
    }
  }

  late final templates = TemplateTypeConfig(this);

  late final Computed<String> sourceCode = Computed(() {
    String sourceCode;
    if (isEnum) {
      sourceCode = templates.templateEnum();
    } else if (isSumType) {
      sourceCode = templates.templateSumType();
    } else {
      final _class = classes[0];
      sourceCode = _class.templates.templateClass();
    }
    try {
      sourceCode = rootStore.formatter.format(sourceCode);
    } catch (_) {}
    return sourceCode;
  });

  // Settings

  late final AppNotifier<bool> isDataValueNotifier;
  bool get isDataValue => isDataValueNotifier.value;

  late final AppNotifier<bool> isSumTypeNotifier;
  bool get isSumType => isSumTypeNotifier.value;
  late final SumTypeConfig sumTypeConfig;

  late final AppNotifier<bool> isSerializableNotifier;
  bool get isSerializable => isSerializableNotifier.value;
  late final SerializableConfig serializableConfig;

  late final AppNotifier<bool> isListenableNotifier;
  bool get isListenable => isListenableNotifier.value;
  final listenableConfig = ListenableConfig(name: 'listenableConfig');

  late final AppNotifier<bool> isEnumNotifier;
  bool get isEnum => isEnumNotifier.value;

  // Advanced

  final AdvancedTypeConfig advancedConfig;

  // Enum

  late final AppNotifier<String?> defaultEnumKeyNotifier;
  late final ComputedNotifier<ClassConfig?> defaultEnumNotifier;
  ClassConfig? get defaultEnum => defaultEnumNotifier.value;

  late final ComputedNotifier<bool> hasVariants;

  final ListNotifier<ClassConfig> classes;

  Map<String, AppNotifier<bool>> get allSettings => {
        'Data Value': isDataValueNotifier,
        'Listenable': isListenableNotifier,
        'Serializable': isSerializableNotifier,
        'Sum Type': isSumTypeNotifier,
        'Enum': isEnumNotifier,
      };

  RootStore get rootStore => Globals.get<RootStore>();

  late final YMap<Object?> _ymap = rootStore.ydoc.getMap(key);

  TypeConfig({
    String? key,
    String? signature,
    bool? isEnum,
    bool? isDataValue,
    bool? isSumType,
    bool? isSerializable,
    bool? isListenable,
    String? defaultEnumKey,
    List<ClassConfig>? classes,
    AdvancedTypeConfig? advancedConfig,
    SumTypeConfig? sumTypeConfig,
    SerializableConfig? serializableConfig,
  })  : key = key ?? uuid.v4(),
        classes = ListNotifier(classes ?? []),
        sumTypeConfig = sumTypeConfig ?? SumTypeConfig(name: 'sumTypeConfig'),
        serializableConfig = serializableConfig ??
            SerializableConfig(name: 'serializableConfig'),
        advancedConfig =
            advancedConfig ?? AdvancedTypeConfig(name: 'advancedConfig') {
    isEnumNotifier = AppNotifier(isEnum ?? false, parent: this, name: 'isEnum');
    isDataValueNotifier =
        AppNotifier(isDataValue ?? false, parent: this, name: 'isDataValue');
    isSumTypeNotifier =
        AppNotifier(isSumType ?? false, parent: this, name: 'isSumType');
    isSerializableNotifier = AppNotifier(isSerializable ?? true,
        parent: this, name: 'isSerializable');
    isListenableNotifier =
        AppNotifier(isListenable ?? false, parent: this, name: 'isListenable');
    defaultEnumKeyNotifier =
        AppNotifier(defaultEnumKey, parent: this, name: 'defaultEnumKey');
    signatureNotifier =
        TextNotifier(initialText: signature, parent: this, name: 'signature');
    signatureParserNotifier = ComputedNotifier(
      () => SignatureParser.parser.parse(signatureNotifier.text),
      [signatureNotifier.textNotifier],
    );
    defaultEnumNotifier = ComputedNotifier(
      () => defaultEnumKeyNotifier.value != null
          ? this.classes.firstWhereOrNull(
                (e) => e.key == defaultEnumKeyNotifier.value,
              )
          : null,
      [defaultEnumKeyNotifier, this.classes],
    );

    hasVariants = ComputedNotifier(
      () => this.isEnum || this.isSumType,
      [
        isEnumNotifier,
        isSumTypeNotifier,
      ],
    );
    // _setUpCrdt();
  }

  void _setUpCrdt() {
    autorun((reaction) {
      final serialized = this.toJson();
      print('_ymap updated mobx: $serialized');
      transact(_ymap.doc!, (transaction) {
        for (final entry in serialized.entries) {
          if (!areEqualDeep(entry.value, _ymap.get(entry.key))) {
            _ymap.set(entry.key, entry.value);
          }
        }
      });
    }, delay: 1000);
    final serialized = this.toJson();
    print('_ymap updated mobx: $serialized');
    _ymap.observeDeep((_, __) {
      print('_ymap updated: ${_ymap.toJSON()}');
      for (final prop in props) {
        final value = _ymap.get(prop.name);
        if (!areEqualDeep(prop.toJson(), value)) {
          print(
              '_ymap updated: ${prop.name} from: ${prop.toJson()} to - $value');
          prop.trySetFromJson(value);
        }
      }
    });
  }

  void addVariant() {
    classes.add(ClassConfig(typeConfigKey: key));
  }

  @override
  Map<String, dynamic> toJson() {
    return super.toJson()..set('key', key);
  }

  static TypeConfig fromJson(Map<String, dynamic>? json) {
    return TypeConfig(
      key: json!['key'] as String?,
      signature: json['signature'] as String?,
      isEnum: json['isEnum'] as bool?,
      isDataValue: json['isDataValue'] as bool?,
      isSumType: json['isSumType'] as bool?,
      isSerializable: json['isSerializable'] as bool?,
      isListenable: json['isListenable'] as bool?,
      defaultEnumKey: json['defaultEnumKey'] as String?,
      sumTypeConfig: SumTypeConfig(name: 'sumTypeConfig')
        ..trySetFromJson(json['sumTypeConfig']),
      serializableConfig: SerializableConfig(name: 'serializableConfig')
        ..trySetFromJson(json['serializableConfig']),
    )
      ..listenableConfig.trySetFromJson(json['listenableConfig'])
      ..advancedConfig.trySetFromJson(
        json['advancedConfig'] as Map<String, dynamic>? ??
            {
              'customCode': json['customCode'] as String?,
              'overrideConstructor': json['overrideConstructor'] as bool?,
              'isConst': json['isConst'] as bool?,
            },
      );
  }

  static final serializer = SerializerFunc<TypeConfig>(fromJson: fromJson);

  TypeConfig copyWith({
    String? name,
    bool? isEnum,
    bool? isDataValue,
    bool? isSumType,
    bool? isSerializable,
    bool? isListenable,
    String? defaultEnumKey,
    String? signature,
    List<ClassConfig>? classes,
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

  @override
  late final List<SerializableProp> props = [
    signatureNotifier,
    isEnumNotifier,
    isDataValueNotifier,
    isSumTypeNotifier,
    isSerializableNotifier,
    isListenableNotifier,
    defaultEnumKeyNotifier,
    advancedConfig,
    sumTypeConfig,
    serializableConfig,
    listenableConfig,
  ];
}

class ClassConfig implements Serializable, Keyed, Clonable<ClassConfig> {
  @override
  final String key;

  late final TextNotifier nameNotifier;
  String get name => nameNotifier.text;

  final rawImport = TextNotifier();

  late final Computed<Result<List<RawField>>> parsedRawImport = Computed(
    () => fieldsParser.parse(rawImport.text),
  );

  late final TemplateClassConfig templates = TemplateClassConfig(this);

  late final AppNotifier<bool> isReorderingNotifier;
  bool get isReordering => isReorderingNotifier.value;

  bool get isDefault => this == typeConfig.defaultEnum;

  final ListNotifier<PropertyField> properties;
  late final ComputedNotifier<List<PropertyField>> propertiesSortedNotifier;
  List<PropertyField> get propertiesSorted => propertiesSortedNotifier.value;

  final String typeConfigKey;
  TypeConfig? _typeConfig;
  TypeConfig get typeConfig {
    return (_typeConfig ??= Globals.get<RootStore>().types[typeConfigKey])!;
  }

  set typeConfig(TypeConfig c) {
    _typeConfig = c;
  }

  final _deepListenable = AppNotifier<Listenable?>(null);
  Listenable? get deepListenable => _deepListenable.value;
  Listenable? _listenable;
  Listenable? get listenable => _listenable;

  ClassConfig({
    required this.typeConfigKey,
    String? name,
    String? key,
    List<PropertyField>? properties,
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

  PropertyField addProperty() {
    final prop = PropertyField(classConfigKey: key);
    properties.add(prop);
    return prop;
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'typeKey': typeConfig.key,
      'key': key,
      'name': name,
    };
  }

  static ClassConfig fromJson(Map<String, dynamic>? json) {
    final typeKey = json!['typeKey'] as String?;
    if (typeKey == null) {
      throw Exception('PropertyField fromJson parsing error. input: $json');
    }
    return ClassConfig(
      typeConfigKey: typeKey,
      key: json['key'] as String?,
      name: json['name'] as String?,
    );
  }

  static final serializer = SerializerFunc<ClassConfig>(fromJson: fromJson);

  ClassConfig copyWith({
    String? typeConfigKey,
    String? name,
    List<PropertyField>? properties,
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
        Serializable,
        Keyed,
        Clonable<PropertyField> {
  @override
  final String key;

  late final TextNotifier nameNotifier;
  String get name => nameNotifier.text;

  late final TextNotifier typeNotifier;
  String get type => typeNotifier.text;

  late final ComputedNotifier<Result<JsonTypeParser>> parsedTypeNotifier;
  Result<JsonTypeParser> get parsedType => parsedTypeNotifier.value;

  late final AppNotifier<bool> isRequiredNotifier;
  bool get isRequired => isRequiredNotifier.value;

  late final AppNotifier<bool> isPositionalNotifier;
  bool get isPositional => isPositionalNotifier.value;

  late final AppNotifier<bool> isSelectedNotifier;
  bool get isSelected => isSelectedNotifier.value;

  final String classConfigKey;
  ClassConfig? _classConfig;
  ClassConfig? get classConfig {
    return _classConfig ??= Globals.get<RootStore>()
        .types
        .values
        .expand((e) => e.classes)
        .firstWhereOrNull((e) => e.key == classConfigKey);
  }

  set classConfig(ClassConfig? c) {
    _classConfig = c;
  }

  PropertyField({
    required this.classConfigKey,
    String? key,
    String? name,
    String? type,
    bool? isRequired,
    bool? isPositional,
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

  Listenable? _listenable;
  Listenable? get listenable => _listenable;

  @override
  Map<String, Object?> toJson() {
    return {
      'classKey': classConfig!.key,
      'key': key,
      'name': name,
      'type': type,
      'isRequired': isRequired,
      'isPositional': isPositional
    };
  }

  static PropertyField fromJson(Map<String, dynamic>? json) {
    final classKey = json!['classKey'] as String?;
    if (classKey == null) {
      return throw Exception(
          'PropertyField fromJson parsing error. input: $json');
    }
    return PropertyField(
      classConfigKey: classKey,
      key: json['key'] as String?,
      name: json['name'] as String?,
      type: json['type'] as String?,
      isRequired: json['isRequired'] as bool?,
      isPositional: json['isPositional'] as bool?,
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
    String? classConfigKey,
    String? name,
    String? type,
    bool? isRequired,
    bool? isPositional,
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
  String init(String? key) {
    return key ?? uuid.v4();
  }

  void collect(String key) {}
}

final _s = KeySetter();

abstract class Clonable<T> {
  T clone();
}
