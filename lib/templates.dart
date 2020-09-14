import 'package:snippet_generator/models.dart';

extension TemplateTypeConfig on TypeConfig {
  String templateSumType() {
    return """
class $name {
  
  ${classes.value.map((c) => "factory $name.${c.name}(${c.templateFactoryParams()}) = _${c.name}._;").join("\n  ")}
  
  ${isSerializable ? templateSymTypeFromJson() : ""}
  }
  
  ${classes.value.map((c) => c.templateClass()).join("\n")}
  """;
  }

  String templateSymTypeFromJson() {
    return """
static $name fromJson(Map<String, dynamic> map) {
  switch (map["type"]) {
    ${classes.value.map((e) => "case '${e.name}': return _${e.name}.fromJson(map);").join("\n    ")}
    default:
      return null;
  }
}
""";
  }
}

String _required(bool isRequired) => isRequired ? "@required " : "";

extension TemplateClassConfig on ClassConfig {
  String get className => typeConfig.isSumType ? "_$name" : typeConfig.name;

  String templateClass() {
    return """
class $className {
  ${properties.value.map((p) => 'final ${p.type.text} ${p.name.text};').join('\n  ')}

  const $className${typeConfig.isSumType ? "._" : ""}(${templateClassParams()});

  ${typeConfig.isSerializable ? templateClassFromJson() : ""}
}
  """;
  }

  String templateClassFromJson() {
    return """
static $className fromJson(Map<String, dynamic> map) {
    return $className(
      ${properties.value.map((e) => "${e.name.text}: map['${e.name.text}'],").join("\n      ")}
    );
  }
""";
  }

  String templateClassParams() {
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
