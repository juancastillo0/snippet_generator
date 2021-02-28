import 'package:meta/meta.dart';
import 'package:snippet_generator/models/type_models.dart';
import 'package:snippet_generator/templates/serde_templates.dart';
import 'package:snippet_generator/utils/extensions.dart';

extension CasingString on String {
  String firstToLowerCase() =>
      length > 0 ? substring(0, 1).toLowerCase() + substring(1) : this;
  String firstToUpperCase() =>
      length > 0 ? substring(0, 1).toUpperCase() + substring(1) : this;
  String asVariableName() => replaceFirst("_", "").firstToLowerCase();
}

extension TemplateClassConfig on ClassConfig {
  String get className => typeConfig.isSumType ? name : typeConfig.name;
  String get _classConstructor {
    return className;
  }

  String get _required {
    return typeConfig.rootStore.isCodeGenNullSafe ? "required" : "@required";
  }

  String get classNameWithGenericIds => "$className${typeConfig.genericIds}";

  String get signature => typeConfig.isSumType
      ? '$name${typeConfig.generics} extends ${typeConfig.name}${typeConfig.genericIds}'
      : typeConfig.signature;

  String templateClass() {
    return """
class $signature {
  ${properties.map((p) => 'final ${p.type} ${p.name};').join('\n  ')}

  ${typeConfig._const} $_classConstructor(${_templateClassParams()})${typeConfig.isSumType ? ": super._()" : ""};

  ${typeConfig.isSumType && typeConfig.sumTypeConfig.enumDiscriminant.value ? "@override\nType${typeConfig.name} get typeEnum => Type${typeConfig.name}.${name.asVariableName()};" : ""}

  ${typeConfig.isDataValue ? _templateClassCopyWith() : ""}
  ${typeConfig.isDataValue ? _templateClassClone() : ""}
  ${typeConfig.isDataValue ? _templateClassEquals() : ""}
  ${typeConfig.isSerializable ? _templateClassFromJson() : ""}
  ${typeConfig.isSerializable ? _templateClassToJson() : ""}
}
  """;
  }

  String _templateClassCopyWith() {
    final _params =
        properties.map((p) => '${p.type} ${p.name},').join('\n    ');
    return """
$classNameWithGenericIds copyWith({$_params}) {
    return $_classConstructor(
      ${propertiesSorted.map((e) => "${e.isPositional ? '' : '${e.name}:'} ${e.name} ?? this.${e.name},").join("\n      ")}
    );
  }
""";
  }

  String _templateClassClone() {
    return """
$classNameWithGenericIds clone() {
    return $_classConstructor(
      ${propertiesSorted.map((e) => "${e.isPositional ? '' : '${e.name}:'} this.${e.name},").join("\n      ")}
    );
  }
""";
  }

  String _templateClassEquals() {
    return """
@override
bool operator ==(Object other) {
  if (other is $classNameWithGenericIds){
    return ${properties.map((e) => 'this.${e.name} == other.${e.name}').join(" && ")};
  }
  return false;
}

@override
int get hashCode => ${properties.map((e) => '${e.name}.hashCode').join(" + ")};
""";
  }

  String _templateClassFromJson() {
    return """
static $classNameWithGenericIds fromJson${typeConfig.generics}(Map<String, dynamic> map) {
    return $_classConstructor(
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
      ${typeConfig.isSumType ? '"${typeConfig.serializableConfig.discriminator.value}": "$className",' : ""}
      ${properties.map((e) => '"${e.name}": ${parseFieldToJson(e)},').join("\n      ")}
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

extension TemplateTypeConfig on TypeConfig {
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
      return signature.replaceFirst(name, "");
    } else {
      return "";
    }
  }

  String _funcParams(ClassConfig c) {
    return c.propertiesSorted.map((p) => '${p.type} ${p.name}').join(', ');
  }

  String _funcParamsCall(ClassConfig c) {
    return c.propertiesSorted.map((p) => 'v.${p.name}').join(', ');
  }

  String get _const {
    return advancedConfig.isConst ? "const" : "";
  }

  String get _required {
    return this.rootStore.isCodeGenNullSafe ? "required" : "@required";
  }

  String templateSumType() {
    return """
import 'package:meta/meta.dart';

abstract class $signature {
  ${advancedConfig.overrideConstructor ? '' : '$_const $name._();'}

  ${advancedConfig.customCode}
  
  ${classes.map((c) => "$_const factory $name.${c.name.asVariableName()}(${c.templateFactoryParams()}) = ${c._classConstructor};").join("\n  ")}
  
  _T when<_T>({${classes.map((c) => "$_required _T Function(${_funcParams(c)}) ${c.name.asVariableName()},").join("\n    ")}}){
    final v = this;
    ${classes.map((c) => "if (v is ${c.classNameWithGenericIds}) return ${c.name.asVariableName()}(${_funcParamsCall(c)});").join("\n    ")}
    throw "";
  }

  _T maybeWhen<_T>({$_required _T Function() orElse, ${classes.map((c) => "_T Function(${_funcParams(c)}) ${c.name.asVariableName()},").join("\n    ")}}){
    final v = this;
    ${classes.map((c) => "if (v is ${c.classNameWithGenericIds}) return ${c.name.asVariableName()} != null ? ${c.name.asVariableName()}(${_funcParamsCall(c)}) : orElse.call();").join("\n    ")}
    throw "";
  }

  _T map<_T>({${classes.map((c) => "$_required _T Function(${c.classNameWithGenericIds} value) ${c.name.asVariableName()},").join("\n    ")}}){
    final v = this;
    ${classes.map((c) => "if (v is ${c.classNameWithGenericIds}) return ${c.name.asVariableName()}(v);").join("\n    ")}
    throw "";
  }

  _T maybeMap<_T>({$_required _T Function() orElse, ${classes.map((c) => "_T Function(${c.classNameWithGenericIds} value) ${c.name.asVariableName()},").join("\n    ")}}){
    final v = this;
    ${classes.map((c) => "if (v is ${c.classNameWithGenericIds}) return ${c.name.asVariableName()} != null ? ${c.name.asVariableName()}(v) : orElse.call();").join("\n    ")}
    throw "";
  }

  ${sumTypeConfig.boolGetters.value ? templateBoolGetters() : ""}
  ${sumTypeConfig.enumDiscriminant.value ? "Type$name get typeEnum;" : ""}
  ${sumTypeConfig.genericMappers.value ? _templateGenericMappers() : ""}

  ${isSerializable ? _templateSymTypeFromJson() : ""}
  ${isSerializable ? "Map<String, dynamic> toJson();" : ""}
  }

  ${sumTypeConfig.enumDiscriminant.value ? templateTypeEnum() : ""}
  
  ${classes.map((c) => c.templateClass()).join("\n")}

  
  """;
  }

  String _templateGenericMappers() {
    return this.genericIdsList.mapIndex((generic, index) => """

      $signature mapGeneric$generic <_T>(_T Function($generic) mapper) {
        return map(
          ${classes.map((c) => """
          ${c.name.asVariableName()}: (v) => $name.${c.name.asVariableName()} (
            ${c.propertiesSorted.map((p) => (p.isPositional ? '' : '${p.name}:') + (p.type != generic ? "v.${p.name}" : "mapper(v.${p.name})")).join(",")}
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
                  "bool get is${c.name.replaceFirst("_", "").firstToUpperCase()} => this is ${c.name};",
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
    ${classes.map((e) => 'case "${e.name}": return ${e.className}.fromJson$genericIds(map);').join("\n    ")}
    default:
      return null;
  }
}
""";
  }
}

// String _required(bool isRequired) => isRequired ? "@required " : "";

String globalTemplateEnum({
  @required String name,
  @required List<String> variants,
  @required bool nullSafe,
}) {
  final _required = nullSafe ? "required " : "@required ";

  return """
enum $name {
  ${variants.map((e) => "$e,").join("\n  ")}
}

$name parse$name(String rawString, {$name defaultValue}) {
  for (final variant in $name.values) {
    if (rawString == variant.toEnumString()) {
      return variant;
    }
  }
  return defaultValue;
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
    throw "";
  }

  _T maybeWhen<_T>({
    ${variants.map((e) => "_T Function() ${e.firstToLowerCase()},").join("\n    ")}
    $_required _T Function() orElse,
  }) {
    _T Function() c;
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
