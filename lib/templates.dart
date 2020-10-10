import 'package:snippet_generator/models/type_models.dart';
import 'package:snippet_generator/utils/json_type.dart';
import 'package:snippet_generator/utils/type_parser.dart';

extension CasingString on String {
  String firstToLowerCase() =>
      length > 0 ? substring(0, 1).toLowerCase() + substring(1) : this;
  String firstToUpperCase() =>
      length > 0 ? substring(0, 1).toUpperCase() + substring(1) : this;
}

extension TemplateClassConfig on ClassConfig {
  String get className => typeConfig.isSumType ? name : typeConfig.name;
  String get _classConstructor {
    return className;
  }

  String templateClass() {
    return """
class $className ${typeConfig.isSumType ? "extends ${typeConfig.name}" : ""}{
  ${properties.map((p) => 'final ${p.type} ${p.name};').join('\n  ')}

  const $_classConstructor(${_templateClassParams()})${typeConfig.isSumType ? ": super._()" : ""};

  ${typeConfig.isSerializable ? _templateClassFromJson() : ""}
  ${typeConfig.isSerializable ? _templateClassToJson() : ""}
}
  """;
  }

  String _templateClassFromJson() {
    return """
static $className fromJson(Map<String, dynamic> map) {
    return $_classConstructor(
      ${propertiesSorted.map((e) => "${e.isPositional ? '' : '${e.name}:'} ${_parseFieldFromJson(e)},").join("\n      ")}
    );
  }
""";
  }

  String _templateClassToJson() {
    return """
Map<String, dynamic> toJson() {
    return {
      ${properties.map((e) => "'${e.name}': ${e.name},").join("\n      ")}
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
  $_posReq ${_posNotReq.isEmpty ? '' : '[$_posNotReq]'}\
  ${_namedReq.isEmpty && _namedNotReq.isEmpty ? '' : '{$_namedReq $_namedNotReq}'}
  """;
  }
}

String _parseJsonTypeFromJson(String getter, JsonTypeParser t) {
  if (t == null) {
    return getter;
  }
  return t.when<String>(
    mapParser: (m) {
      return "($getter as Map).map((key, value) => MapEntry(${_parseJsonTypeFromJson('key', m.genericType?.left)}, ${_parseJsonTypeFromJson('value', m.genericType?.right)}))";
    },
    collectionParser: (c) {
      return "($getter as List).map((e) => ${_parseJsonTypeFromJson('e', c.genericType)}).to${c.collectionType.toEnumString()}()";
    },
    primitiveParser: (v) {
      return v.type.isCustom
          ? "${v.raw}.fromJson($getter)"
          : "$getter as ${v.raw}";
    },
  );
}

String _parseFieldFromJson(PropertyField e) {
  final result = JsonTypeParser.parser.parse(e.type);
  if (result.isFailure) {
    return "map['${e.name}'] as ${e.type}";
  }

  return _parseJsonTypeFromJson("map['${e.name}']", result.value);
}

extension TemplateTypeConfig on TypeConfig {
  String templateSumType() {
    return """
abstract class $name {
  const $name._();
  
  ${classes.map((c) => "factory $name.${c.name.replaceFirst("_", "").firstToLowerCase()}(${c.templateFactoryParams()}) = ${c._classConstructor};").join("\n  ")}
  
  T when<T>({${classes.map((c) => "@required T Function(${c.className} value) ${c.name.firstToLowerCase()},").join("\n    ")}}){
    final v = this;
    ${classes.map((c) => "if (v is ${c.className}) return ${c.name.firstToLowerCase()}(v);").join("\n    ")}
    throw "";
  }

  T maybeWhen<T>({T Function() orElse, ${classes.map((c) => "T Function(${c.className} value) ${c.name.firstToLowerCase()},").join("\n    ")}}){
    final v = this;
    ${classes.map((c) => "if (v is ${c.className}) return ${c.name.firstToLowerCase()} != null ? ${c.name.firstToLowerCase()}(v) : orElse?.call();").join("\n    ")}
    throw "";
  }
  ${isSerializable ? _templateSymTypeFromJson() : ""}
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
    ${classes.map((e) => "@required T Function() ${e.name},").join("\n    ")}
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
    ${classes.map((e) => "T Function() ${e.name},").join("\n    ")}
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
static $name fromJson(Map<String, dynamic> map) {
  switch (map["runtimeType"] as String) {
    ${classes.map((e) => "case '${e.name}': return ${e.className}.fromJson(map);").join("\n    ")}
    default:
      return null;
  }
}
""";
  }
}

String _required(bool isRequired) => isRequired ? "@required " : "";
