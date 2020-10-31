import 'package:snippet_generator/models/type_models.dart';
import 'package:snippet_generator/templates/serde_templates.dart';

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

  String get classNameWithGenericIds => "$className${typeConfig.genericIds}";

  String get signature => typeConfig.isSumType
      ? '$name${typeConfig.generics} extends ${typeConfig.name}${typeConfig.genericIds}'
      : typeConfig.signature;

  String templateClass() {
    return """
class $signature {
  ${properties.map((p) => 'final ${p.type} ${p.name};').join('\n  ')}

  ${typeConfig._const} $_classConstructor(${_templateClassParams()})${typeConfig.isSumType ? ": super._()" : ""};

  ${typeConfig.isDataValue ? _templateClassCopyWith() : ""}
  ${typeConfig.isDataValue ? _templateClassClone() : ""}
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
      ${typeConfig.isSumType ? '"runtimeType": "$className",' : ""}
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
        .map((p) => "@required ${accessor(p)}${p.name},")
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
    return isConst ? "const" : "";
  }

  String templateSumType() {
    return """
abstract class $signature {
  ${overrideConstructor ? '' : '$_const $name._();'}

  $customCode
  
  ${classes.map((c) => "$_const factory $name.${c.name.asVariableName()}(${c.templateFactoryParams()}) = ${c._classConstructor};").join("\n  ")}
  
  T when<T>({${classes.map((c) => "@required T Function(${_funcParams(c)}) ${c.name.asVariableName()},").join("\n    ")}}){
    final v = this;
    ${classes.map((c) => "if (v is ${c.classNameWithGenericIds}) return ${c.name.asVariableName()}(${_funcParamsCall(c)});").join("\n    ")}
    throw "";
  }

  T maybeWhen<T>({T Function() orElse, ${classes.map((c) => "T Function(${_funcParams(c)}) ${c.name.asVariableName()},").join("\n    ")}}){
    final v = this;
    ${classes.map((c) => "if (v is ${c.classNameWithGenericIds}) return ${c.name.asVariableName()} != null ? ${c.name.asVariableName()}(${_funcParamsCall(c)}) : orElse?.call();").join("\n    ")}
    throw "";
  }

  T map<T>({${classes.map((c) => "@required T Function(${c.className} value) ${c.name.asVariableName()},").join("\n    ")}}){
    final v = this;
    ${classes.map((c) => "if (v is ${c.classNameWithGenericIds}) return ${c.name.asVariableName()}(v);").join("\n    ")}
    throw "";
  }

  T maybeMap<T>({T Function() orElse, ${classes.map((c) => "T Function(${c.className} value) ${c.name.asVariableName()},").join("\n    ")}}){
    final v = this;
    ${classes.map((c) => "if (v is ${c.classNameWithGenericIds}) return ${c.name.asVariableName()} != null ? ${c.name.asVariableName()}(v) : orElse?.call();").join("\n    ")}
    throw "";
  }
  ${isSerializable ? _templateSymTypeFromJson() : ""}
  ${isSerializable ? "Map<String, dynamic> toJson();" : ""}
  }
  
  ${classes.map((c) => c.templateClass()).join("\n")}
  """;
  }

  String templateEnum() {
    return """
enum $name {
  ${classes.map((e) => "${e.name},").join("\n  ")}
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

  ${classes.map((e) => "bool get is${e.name.firstToUpperCase()} => this == $name.${e.name};").join("\n  ")}

  T when<T>({
    ${classes.map((e) => "@required T Function() ${e.name.firstToLowerCase()},").join("\n    ")}
  }) {
    switch (this) {
      ${classes.map((e) => """
case $name.${e.name}:
        return ${e.name}();
      """).join()}
    }
    throw "";
  }

  T maybeWhen<T>({
    ${classes.map((e) => "T Function() ${e.name.firstToLowerCase()},").join("\n    ")}
    T Function() orElse,
  }) {
    T Function() c;
    switch (this) {
      ${classes.map((e) => """
case $name.${e.name}:
        c = ${e.name};
        break;   
      """).join()}
    }
    return (c ?? orElse)?.call();
  }
}
""";
  }

  String _templateSymTypeFromJson() {
    return """
static $name$genericIds fromJson$generics(Map<String, dynamic> map) {
  switch (map["runtimeType"] as String) {
    ${classes.map((e) => "case '${e.name}': return ${e.className}.fromJson$genericIds(map);").join("\n    ")}
    default:
      return null;
  }
}
""";
  }
}

String _required(bool isRequired) => isRequired ? "@required " : "";
