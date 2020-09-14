import 'package:snippet_generator/models.dart';

extension CasingString on String {
  String firstToLowerCase() => substring(0, 1).toLowerCase() + substring(1);
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
}
  """;
  }

  String _templateClassFromJson() {
    return """
static $className fromJson(Map<String, dynamic> map) {
    return $_classConstructor(
      ${properties.value.map((e) => "${e.name.text}: map['${e.name.text}'] as ${e.type.text},").join("\n      ")}
    );
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
