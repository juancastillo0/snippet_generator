import 'package:snippet_generator/models.dart';

String templateSumType(TypeConfig typeConfig) {
  final className = typeConfig.name.text;

  return """
class $className {
  
  ${typeConfig.classes.value.map((c) => "factory $className.${c.name.text}(${templateFactoryParams(c)}) = _${c.name.text}._;").join("\n  ")}
}

${typeConfig.classes.value.map((c) => templateClass(c)).join("\n")}
""";
}

String templateClass(ClassConfig data) {
  final isFromSumType = data.typeConfig.isSumType.value;
  final className =
      isFromSumType ? "_${data.name.text}" : data.typeConfig.name.text;
  final properties = data.properties.value;

  return """
class $className {
  ${properties.map((p) => 'final ${p.type.text} ${p.name.text};').join('\n  ')}

  const $className.${isFromSumType ? "_" : ""}(${templateClassParams(data)})
}
  """;
}

String templateClassParams(ClassConfig data) {
  final properties = data.properties.value;
  return """{
    ${properties.map((p) => '${p.isRequired.value ? "@required " : ""}this.${p.name.text},').join('\n    ')}
  }""";
}

String templateFactoryParams(ClassConfig data) {
  final properties = data.properties.value;
  return """{
    ${properties.map((p) => '${p.isRequired.value ? "@required " : ""}${p.type.text} ${p.name.text},').join('\n    ')}
  }""";
}