import 'package:snippet_generator/models/type_models.dart';
import 'package:snippet_generator/parsers/signature_parser.dart';
import 'package:snippet_generator/parsers/type_parser.dart';
import 'package:snippet_generator/utils/json_type.dart';

String _parseJsonTypeFromJson(
  String getter,
  JsonTypeParser t,
  List<SignatureGeneric> generics,
) {
  if (t == null) {
    return getter;
  }
  return t.when<String>(
    mapParser: (m) {
      return "($getter as Map).map((key, value) => MapEntry(${_parseJsonTypeFromJson('key', m.genericType?.left, generics)}, ${_parseJsonTypeFromJson('value', m.genericType?.right, generics)}))";
    },
    collectionParser: (c) {
      return "($getter as List).map((e) => ${_parseJsonTypeFromJson('e', c.genericType, generics)}).to${c.collectionType.toEnumString()}()";
    },
    primitiveParser: (v) {
      if (v.type.isCustom) {
        if (generics.any((g) => g.id == v.raw)) {
          return "Serializers.fromJson<${v.raw}>($getter)";
        } else {
          final _genericIds = v.genericIds.join(",");
          final genericIds = _genericIds.isNotEmpty ? "<$_genericIds>" : "";
          return "${v.raw}.fromJson$genericIds($getter as Map<String, dynamic>)";
        }
      } else {
        return "$getter as ${v.raw}";
      }
    },
  );
}

String parseFieldFromJson(PropertyField e) {
  final result = e.parsedType;
  if (result.isFailure) {
    return "map['${e.name}'] as ${e.type}";
  }
  final generics =
      e.classConfig.typeConfig.signatureParserNotifier.value.value?.generics ??
          [];

  return _parseJsonTypeFromJson("map['${e.name}']", result.value, generics);
}

String _parseJsonTypeToJson(
  String getter,
  JsonTypeParser t,
  List<SignatureGeneric> generics,
) {
  if (t == null) {
    return getter;
  }
  return t.when<String>(
    mapParser: (m) {
      return "$getter.map((key, value) => MapEntry(${_parseJsonTypeToJson('key', m.genericType?.left, generics)}, ${_parseJsonTypeToJson('value', m.genericType?.right, generics)}))";
    },
    collectionParser: (c) {
      return "$getter.map((e) => ${_parseJsonTypeToJson('e', c.genericType, generics)}).toList()";
    },
    primitiveParser: (v) {
      if (v.type.isCustom) {
        if (generics.any((g) => g.id == v.raw)) {
          return "($getter as dynamic).toJson()";
        } else {
          return "$getter.toJson()";
        }
      } else {
        return getter;
      }
    },
  );
}

String parseFieldToJson(PropertyField e) {
  final result = e.parsedType;
  if (result.isFailure) {
    return "${e.name}'.toJson()";
  }
  final generics =
      e.classConfig.typeConfig.signatureParserNotifier.value.value?.generics ??
          [];
  return _parseJsonTypeToJson(e.name, result.value, generics);
}
