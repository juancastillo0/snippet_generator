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
  String get className => typeConfig.isSumType ? "_$name" : typeConfig.name;
  String get _classConstructor =>
      '$className${typeConfig.isSumType ? "._" : ""}';

  String templateClass() {
    return """
class $className ${typeConfig.isSumType ? "extends ${typeConfig.name}" : ""}{
  ${properties.value.map((p) => 'final ${p.type.text} ${p.name.text};').join('\n  ')}

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
      ${properties.value.map((e) => "${e.name.text}: ${_parseFieldFromJson(e)},").join("\n      ")}
    );
  }
""";
  }

  String _templateClassToJson() {
    return """
Map<String, dynamic> toJson() {
    return {
      ${properties.value.map((e) => "'${e.name.text}': ${e.name.text},").join("\n      ")}
    };
  }
""";
  }

  String _templateClassParams() {
    return """{
    ${properties.value.map((p) => '${_required(p.isRequired.value)}this.${p.name.text},').join('\n    ')}
  }""";
  }

  String templateFactoryParams() {
    return """{
    ${properties.value.map((p) => '${_required(p.isRequired.value)}${p.type.text} ${p.name.text},').join('\n    ')}
  }""";
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
  final result = JsonTypeParser.parser.parse(e.type.text);
  if (result.isFailure) {
    return "map['${e.name.text}'] as ${e.type.text}";
  }

  return _parseJsonTypeFromJson("map['${e.name.text}']", result.value);

  // final jsonType = parseSupportedJsonType(e.name.text);

  // switch (jsonType) {
  //   case SupportedJsonType.List:
  //   case SupportedJsonType.Set:
  //     return "(map['${e.name.text}'] as List).map((e) => ),";
  //     break;
  //   case SupportedJsonType.Map:
  //     break;
  //   case SupportedJsonType.String:
  //   case SupportedJsonType.double:
  //   case SupportedJsonType.int:
  //   case SupportedJsonType.num:
  //     return "map['${e.name.text}'] as ${e.type.text},";
  // }
  // return "${e.type.text}.FromJson(map['${e.name.text}']),";
}

extension TemplateTypeConfig on TypeConfig {
  String templateSumType() {
    return """
abstract class $name {
  const $name._();
  
  ${classes.value.map((c) => "factory $name.${c.name.firstToLowerCase()}(${c.templateFactoryParams()}) = _${c.name}._;").join("\n  ")}
  
  T when<T>({${classes.value.map((c) => "@required T Function(${c.className} value) ${c.name.firstToLowerCase()},").join("\n    ")}}){
    final v = this;
    ${classes.value.map((c) => "if (v is ${c.className}) return ${c.name.firstToLowerCase()}(v);").join("\n    ")}
    throw "";
  }
  ${isSerializable ? _templateSymTypeFromJson() : ""}
  }
  
  ${classes.value.map((c) => c.templateClass()).join("\n")}
  """;
  }

  String templateEnum() {
    return """
enum $name {
  ${classes.value.map((e) => "${e.name},").join("\n  ")}
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

  ${classes.value.map((e) => "bool get is${e.name.firstToUpperCase()} => this == $name.${e.name};").join("\n  ")}

  T when<T>({
    ${classes.value.map((e) => "T Function() ${e.name},").join("\n    ")}
    T Function() orElse,
  }) {
    T Function() c;
    switch (this) {
      ${classes.value.map((e) => """
case $name.${e.name}:
        c = ${e.name};
        break;   
      """).join()}
      default:
        c = orElse;
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
    ${classes.value.map((e) => "case '${e.name}': return _${e.name}.fromJson(map);").join("\n    ")}
    default:
      return null;
  }
}
""";
  }
}

String _required(bool isRequired) => isRequired ? "@required " : "";
