import 'package:mobx/mobx.dart';
import 'package:petitparser/petitparser.dart';
import 'package:snippet_generator/notifiers/computed_notifier.dart';
import 'package:snippet_generator/parsers/signature_parser.dart';
import 'package:snippet_generator/types/advanced/advanced_config.dart';
import 'package:snippet_generator/types/advanced/serializable_config.dart';
import 'package:snippet_generator/types/advanced/sum_type_config.dart';
import 'package:snippet_generator/types/root_store.dart';
import 'package:snippet_generator/types/templates/serde_templates.dart';
import 'package:snippet_generator/types/type_models.dart';
import 'package:snippet_generator/utils/extensions.dart';

extension _ClassConfigTemplateExtension on ClassConfig {
  String get _classNameWithGenericIds => templates._classNameWithGenericIds;
}

class TemplateClassConfig {
  final ClassConfig innerClass;

  const TemplateClassConfig(this.innerClass);

  TypeConfig get typeConfig => innerClass.typeConfig;
  List<PropertyField> get properties => innerClass.properties;
  List<PropertyField> get propertiesSorted => innerClass.propertiesSorted;
  String get name => innerClass.name;

  String get className => typeConfig.isSumType
      ? '${typeConfig.sumTypeConfig.prefix.value}$name${typeConfig.sumTypeConfig.suffix.value}'
      : typeConfig.name;
  String get _classConstructor {
    return className;
  }

  String get _required {
    return typeConfig.rootStore.isCodeGenNullSafe ? "required" : "@required";
  }

  String get _nullable {
    return typeConfig.rootStore.isCodeGenNullSafe ? "?" : "/*?*/";
  }

  String get _classNameWithGenericIds =>
      "$className${typeConfig.templates.genericIds}";

  String get signature => typeConfig.isSumType
      ? '$className${typeConfig.templates.generics} extends ${typeConfig.name}${typeConfig.templates.genericIds}'
      : typeConfig.signature;

  String templateClass() {
    return """
${typeConfig.isDataValue && !typeConfig.isSumType ? "import 'dart:ui';" : ""}
class $signature {
  ${properties.map((p) => 'final ${p.type} ${p.name};').join('\n  ')}

  ${typeConfig.templates._const} $_classConstructor(${_templateClassParams()})${typeConfig.isSumType ? ": super._()" : ""};

  ${typeConfig.isSumType && typeConfig.sumTypeConfig.enumDiscriminant.value ? "@override\nType${typeConfig.name} get typeEnum => Type${typeConfig.name}.${name.asVariableName()};" : ""}

  ${typeConfig.isDataValue ? _templateClassCopyWith() : ""}
  ${typeConfig.isDataValue ? _templateClassClone() : ""}
  ${typeConfig.isDataValue ? _templateClassEquals() : ""}
  ${typeConfig.isSerializable && typeConfig.serializableConfig.generateFromJson.value ? _templateClassFromJson() : ""}
  ${typeConfig.isSerializable && typeConfig.serializableConfig.generateToJson.value ? _templateClassToJson() : ""}

}

${typeConfig.isListenable ? _templateClassNotifier() : ""}
  """;
  }

  String _templateClassNotifier() {
// class ${className}Notifier${typeConfig.templates.generics} extends ValueNotifier<$classNameWithGenericIds> {
//   ${className}Notifier($classNameWithGenericIds value): super(value);
    // ${properties.map((p) => "set ${p.name}(${p.type} _v) => value = value.copyWith(${p.name}:  _v);\n"
    //         "${p.type} get ${p.name} => value.${p.name};").join()}
    final listenableConfig = typeConfig.listenableConfig;
    final suffix = listenableConfig.suffix.value;
    final generateGetters = listenableConfig.generateGetters.value;
    final generateSetters = listenableConfig.generateSetters.value;
    final notifierClass = listenableConfig.notifierClass.value;
    final nameParam = listenableConfig.nameParam.value;
    return """
class $className$suffix${typeConfig.templates.generics} {
  $className$suffix($_classNameWithGenericIds value): ${properties.map((p) => "${p.name}$suffix = $notifierClass(value.${p.name} ${nameParam.isNotEmpty ? ', $nameParam:"${p.name}"' : ''})").join(",")};

  ${properties.map((p) => "final $notifierClass<${p.type}> ${p.name}$suffix; "
            '${generateSetters ? "set ${p.name}(${p.type} _v) => ${p.name}$suffix.value = _v; " : ""} '
            '${generateGetters ? "${p.type} get ${p.name} => ${p.name}$suffix.value;" : ""} ').join()}

  set value($_classNameWithGenericIds newValue) {
${properties.map((p) => "${p.name}$suffix.value = newValue.${p.name};").join()}
  }

  $_classNameWithGenericIds get value {
    return $className(${properties.map((p) => "${p.name}:${p.name}$suffix.value,").join()});
  }

  late final props = [
    ${properties.map((p) => "${p.name}$suffix,").join()}
  ];
}
    """;
  }

  String _templateClassCopyWith() {
    final _params = properties
        .map((p) =>
            '${p.type}${p.type.endsWith("?") ? "" : _nullable} ${p.name},')
        .join('\n    ');
    return """
$_classNameWithGenericIds copyWith(${properties.isEmpty ? "" : "{$_params}"}) {
    return ${properties.isEmpty ? typeConfig.templates._const : ""} $_classConstructor(
      ${propertiesSorted.map((e) => "${e.isPositional ? '' : '${e.name}:'} ${e.name} ?? this.${e.name},").join("\n      ")}
    );
  }
""";
  }

  String _templateClassClone() {
    return "";
//     return """
// $classNameWithGenericIds clone() {
//     return $_classConstructor(
//       ${propertiesSorted.map((e) => "${e.isPositional ? '' : '${e.name}:'} this.${e.name},").join("\n      ")}
//     );
//   }
// """;
  }

  String _templateClassEquals() {
    final _joinedHashCodes = properties.map((e) => e.name).join(",");
    final String _hashCode;
    if (properties.length == 1) {
      _hashCode = '${properties.first.name}.hashCode';
    } else if (properties.length <= 20) {
      _hashCode = 'hashValues($_joinedHashCodes)';
    } else {
      _hashCode = 'hashList([$_joinedHashCodes])';
    }
    return """
@override
bool operator ==(Object other) {
  if (other is $_classNameWithGenericIds){
    return ${properties.isEmpty ? "true" : properties.map((e) => 'this.${e.name} == other.${e.name}').join(" && ")};
  }
  return false;
}

@override
int get hashCode => ${properties.isEmpty ? "${typeConfig.templates._const} $_classConstructor().hashCode" : _hashCode};
""";
  }

  String _templateClassFromJson() {
    return """
static $_classNameWithGenericIds fromJson${typeConfig.templates.generics}(Map<String, dynamic> map) {
    return ${properties.isEmpty ? typeConfig.templates._const : ""} $_classConstructor(
      ${propertiesSorted.map((e) => "${e.isPositional ? '' : '${e.name}:'} ${parseFieldFromJson(e)},").join("\n      ")}
    );
  }
""";
  }

  String _templateClassToJson() {
    return """
${typeConfig.isSumType ? "@override" : ""}
Map<String, dynamic> toJson() {
    return {
      ${typeConfig.isSumType ? '"${typeConfig.serializableConfig.discriminator.value}": "${name.asVariableName()}",' : ""}
      ${properties.map((e) => '"${e.name}": ${parseFieldToJson(e)},').join()}
    };
  }
""";
  }

  String _templateClassParams() {
    return _params((_) => "this.");
  }

  String templateFactoryParams() {
    return _params((p) => '${p.type} ');
  }

  String _params(String Function(PropertyField) accessor) {
    const _join = '\n    ';
    String _map(PropertyField p) => "${accessor(p)}${p.name},";

    final _posReq = properties
        .where((p) => p.isPositional && p.isRequired)
        .map(_map)
        .join(_join);
    final _posNotReq = properties
        .where((p) => p.isPositional && !p.isRequired)
        .map(_map)
        .join(_join);
    final _namedReq = properties
        .where((p) => !p.isPositional && p.isRequired)
        .map((p) => "$_required ${accessor(p)}${p.name},")
        .join(_join);
    final _namedNotReq = properties
        .where((p) => !p.isPositional && !p.isRequired)
        .map(_map)
        .join(_join);

    return """
  $_posReq ${_posNotReq.isEmpty ? '' : '[$_posNotReq]'}
  ${_namedReq.isEmpty && _namedNotReq.isEmpty ? '' : '{$_namedReq $_namedNotReq}'}
  """;
  }
}

class TemplateTypeConfig {
  final TypeConfig innerType;

  TemplateTypeConfig(this.innerType);

  AdvancedTypeConfig get advancedConfig => innerType.advancedConfig;
  RootStore get rootStore => innerType.rootStore;
  List<ClassConfig> get classes => innerType.classes;
  SumTypeConfig get sumTypeConfig => innerType.sumTypeConfig;
  SerializableConfig get serializableConfig => innerType.serializableConfig;
  ComputedNotifier<Result<SignatureParser>> get signatureParserNotifier =>
      innerType.signatureParserNotifier;
  String get name => innerType.name;

  String get genericIds {
    final result = this.signatureParserNotifier.value;
    if (result.isSuccess) {
      final generics = result.value.genericIds.join(",");
      return generics.isNotEmpty ? "<$generics>" : "";
    } else {
      return "";
    }
  }

  List<String> get genericIdsList {
    final result = this.signatureParserNotifier.value;
    if (result.isSuccess) {
      return result.value.genericIds;
    } else {
      return [];
    }
  }

  String get generics {
    final result = this.signatureParserNotifier.value;
    if (result.isSuccess) {
      return innerType.signature.replaceFirst(name, "");
    } else {
      return "";
    }
  }

  String _funcParams(ClassConfig c) {
    final _repeatedProps = repeatedProps.value;
    return c.propertiesSorted
        .where((p) => _repeatedProps[p.name]?.sameType == null)
        .map((p) => '${p.type} ${p.name}')
        .join(', ');
  }

  String _funcParamsCall(ClassConfig c) {
    final _repeatedProps = repeatedProps.value;
    return c.propertiesSorted
        .where((p) => _repeatedProps[p.name]?.sameType == null)
        .map((p) => 'v.${p.name}')
        .join(', ');
  }

  String get _const {
    return advancedConfig.isConst ? "const" : "";
  }

  String get _nullable => this.rootStore.isCodeGenNullSafe ? "?" : "/*?*/";

  String get _required =>
      this.rootStore.isCodeGenNullSafe ? "required" : "@required";

  String templateSumType() {
    return """
${!this.rootStore.isCodeGenNullSafe ? "import 'package:meta/meta.dart';" : ""}
${innerType.isDataValue ? "import 'dart:ui';" : ""}

abstract class ${innerType.signature} {
  ${advancedConfig.overrideConstructor ? '' : '$_const $name._();'}

  ${advancedConfig.customCode}
  
  ${classes.map((c) => "$_const factory $name.${c.name.asVariableName()}(${c.templates.templateFactoryParams()}) = ${c.templates._classConstructor};").join("\n  ")}

  ${_repeatedPropsTemplate()}
  
  _T when<_T>({${classes.map((c) => "$_required _T Function(${_funcParams(c)}) ${c.name.asVariableName()},").join("\n    ")}}){
    final v = this;
    ${classes.map((c) => "if (v is ${c._classNameWithGenericIds}) {return ${c.name.asVariableName()}(${_funcParamsCall(c)});}").join("\nelse ")}
    $_throwNotFoundVariant
  }

  _T maybeWhen<_T>({$_required _T Function() orElse, ${classes.map((c) => "_T Function(${_funcParams(c)})$_nullable ${c.name.asVariableName()},").join("\n    ")}}){
    final v = this;
    ${classes.map((c) => "if (v is ${c._classNameWithGenericIds}) {return ${c.name.asVariableName()} != null ? ${c.name.asVariableName()}(${_funcParamsCall(c)}) : orElse.call();}").join("\nelse ")}
    $_throwNotFoundVariant
  }

  _T map<_T>({${classes.map((c) => "$_required _T Function(${c._classNameWithGenericIds} value) ${c.name.asVariableName()},").join("\n    ")}}){
    final v = this;
    ${classes.map((c) => "if (v is ${c._classNameWithGenericIds}) {return ${c.name.asVariableName()}(v);}").join("\nelse ")}
    $_throwNotFoundVariant
  }

  _T maybeMap<_T>({$_required _T Function() orElse, ${classes.map((c) => "_T Function(${c._classNameWithGenericIds} value)$_nullable ${c.name.asVariableName()},").join("\n    ")}}){
    final v = this;
    ${classes.map((c) => "if (v is ${c._classNameWithGenericIds}) {return ${c.name.asVariableName()} != null ? ${c.name.asVariableName()}(v) : orElse.call();}").join("\nelse ")}
    $_throwNotFoundVariant
  }

  ${sumTypeConfig.boolGetters.value ? templateBoolGetters() : ""}
  ${sumTypeConfig.enumDiscriminant.value ? "Type$name get typeEnum;" : ""}
  ${sumTypeConfig.genericMappers.value ? _templateGenericMappers() : ""}

  ${innerType.isSerializable && serializableConfig.generateFromJson.value ? _templateSymTypeFromJson() : ""}
  ${innerType.isSerializable && serializableConfig.generateToJson.value ? "Map<String, dynamic> toJson();" : ""}
  }

  ${sumTypeConfig.enumDiscriminant.value ? templateTypeEnum() : ""}
  
  ${classes.map((c) => c.templates.templateClass()).join("\n")}

  
  """;
  }

  late final repeatedProps = Computed<Map<String, CummProp>>(() {
    final repeated = <String, List<PropertyField>>{};
    for (final p in classes.expand((c) => c.properties)) {
      final l = repeated.putIfAbsent(p.name, () => []);
      l.add(p);
    }
    repeated.removeWhere((_, l) => l.length != classes.length);
    return repeated.map(
      (key, value) => MapEntry(key, CummProp.fromProps(value)),
    );
  });

  String _repeatedPropsTemplate() {
    final props = repeatedProps.value;
    if (props.isEmpty) {
      return "";
    }

    return props.entries
        .map((e) =>
            "${e.value.sameType ?? 'Object'}${e.value.isNullable && e.value.sameType == null ? _nullable : ''} get ${e.key};")
        .join();
  }

  String get _throwNotFoundVariant {
    return "throw Exception();";
  }

  String _templateGenericMappers() {
    String _propToMapped(PropertyField p, String generic) {
      String _setter;
      if (p.type == generic) {
        _setter = "mapper(v.${p.name})";
      } else if (p.type.endsWith("?") && "$generic?" == p.type) {
        _setter = "v.${p.name} == null ? null : mapper(v.${p.name}!)";
      } else {
        _setter = "v.${p.name}";
      }
      return (p.isPositional ? '' : '${p.name}:') + _setter;
    }

    final _signatureParsed = signatureParserNotifier.value;
    return this.genericIdsList.mapIndex((generic, index) => """

      $name<${_signatureParsed.isSuccess ? _signatureParsed.value.genericIds.map((g) => g == generic ? "_T" : g).join(",") : ""}> mapGeneric$generic <_T>(_T Function($generic) mapper) {
        return map(
          ${classes.map((c) => """
          ${c.name.asVariableName()}: (v) => $name.${c.name.asVariableName()} (
            ${c.propertiesSorted.map((p) => _propToMapped(p, generic)).join(",")}
          ),
            """).join()}
        );
      }
      
    
    """).join();
  }

  String templateBoolGetters() {
    return """
    ${classes.map(
              (c) =>
                  "bool get is${c.name.replaceFirst("_", "").firstToUpperCase()} => this is ${c.templates.className};",
            ).join("\n")}
    """;
  }

  String templateTypeEnum() {
    return globalTemplateEnum(
      name: "Type$name",
      variants: classes.map((e) => e.name.asVariableName()).toList(),
      nullSafe: rootStore.isCodeGenNullSafe,
    );
  }

  String templateEnum() {
    return globalTemplateEnum(
      name: name,
      variants: classes.map((e) => e.name).toList(),
      nullSafe: rootStore.isCodeGenNullSafe,
    );
  }

  String _templateSymTypeFromJson() {
    return """
static $name$genericIds fromJson$generics(Map<String, dynamic> map) {
  switch (map["${serializableConfig.discriminator.value}"] as String) {
    ${classes.map((e) => 'case "${e.name.asVariableName()}": return ${e.templates.className}.fromJson$genericIds(map);').join("\n    ")}
    default:
      throw Exception('Invalid discriminator for ${innerType.signature}.fromJson \${map["${serializableConfig.discriminator.value}"]}. Input map: \$map');
  }
}
""";
  }
}

class CummProp {
  final String? sameType;
  final bool isNullable;

  const CummProp({required this.sameType, required this.isNullable});

  static CummProp fromProps(List<PropertyField> value) {
    final isNullable = value.any((p) => p.type.endsWith("?"));
    final initialType = value.isEmpty
        ? null
        : (value.first.type.endsWith("?")
            ? value.first.type.substring(0, value.first.type.length - 1)
            : value.first.type);
    final isSameType =
        value.every((p) => p.type == initialType || p.type == "$initialType?");
    return CummProp(
      isNullable: isNullable,
      sameType: isSameType ? initialType : null,
    );
  }
}

// String _required(bool isRequired) => isRequired ? "@required " : "";

String globalTemplateEnum({
  required String name,
  required List<String> variants,
  required bool nullSafe,
}) {
  final _required = nullSafe ? "required " : "@required ";
  final _nullable = nullSafe ? "?" : "/*?*/";

  return """
enum $name {
  ${variants.map((e) => "$e,").join("\n  ")}
}

$name$_nullable parse$name(String rawString, {bool caseSensitive = true}) {
  final _rawString = caseSensitive ? rawString : rawString.toLowerCase();
  for (final variant in $name.values) {
    final variantString = caseSensitive ? variant.toEnumString() : variant.toEnumString().toLowerCase();
    if (_rawString == variantString) {
      return variant;
    }
  }
  return null;
}

extension ${name}Extension on $name {
  String toEnumString() => toString().split(".")[1];
  String enumType() => toString().split(".")[0];

  ${variants.map((e) => "bool get is${e.firstToUpperCase()} => this == $name.$e;").join("\n  ")}

  _T when<_T>({
    ${variants.map((e) => "$_required _T Function() ${e.firstToLowerCase()},").join("\n    ")}
  }) {
    switch (this) {
      ${variants.map((e) => """
case $name.$e:
        return $e();
      """).join()}
    }
    ${nullSafe ? '' : 'throw Exception("");'}
  }

  _T maybeWhen<_T>({
    ${variants.map((e) => "_T Function()$_nullable ${e.firstToLowerCase()},").join("\n    ")}
    $_required _T Function() orElse,
  }) {
    _T Function()$_nullable c;
    switch (this) {
      ${variants.map((e) => """
case $name.$e:
        c = $e;
        break;   
      """).join()}
    }
    return (c ?? orElse).call();
  }
}
""";
}
