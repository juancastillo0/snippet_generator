import 'package:snippet_generator/parsers/models/json_type.dart';
import 'package:snippet_generator/parsers/signature_parser.dart';
import 'package:snippet_generator/parsers/type_parser.dart';
import 'package:snippet_generator/types/type_models.dart';

String _parseJsonTypeFromJson(
  String getter,
  JsonTypeParser? t,
  List<SignatureGeneric> generics,
) {
  if (t == null) {
    return getter;
  }
  return t.when<String>(
    mapParser: (m) {
      final _nullable = m.nullable ? '?' : '';
      return "($getter as Map$_nullable)$_nullable.map((key, value) => MapEntry("
          "${_parseJsonTypeFromJson('key', m.genericType?.left, generics)}, "
          "${_parseJsonTypeFromJson('value', m.genericType?.right, generics)}))";
    },
    collectionParser: (c) {
      final _nullable = c.nullable ? '?' : '';
      return "($getter as List$_nullable)$_nullable.map((e) => "
          "${_parseJsonTypeFromJson('e', c.genericType, generics)}).to${c.collectionType.toEnumString()}()";
    },
    primitiveParser: (v) {
      if (v.type.isCustom) {
        if (generics.any((g) => g.id == v.raw)) {
          return 'Serializers.fromJson<${v.raw}>($getter)';
        } else {
          final _genericIds = v.genericIds.join(',');
          final genericIds = _genericIds.isNotEmpty ? '<$_genericIds>' : '';

          return (v.nullable ? '$getter == null ? null : ' : '') +
              '${v.raw}.fromJson$genericIds($getter)';
        }
      } else {
        return '$getter as ${v.raw}';
      }
    },
  );
}

String parseFieldFromJson(PropertyField e) {
  final result = e.parsedType;
  if (result.isFailure) {
    return "map['${e.name}'] as ${e.type}";
  }
  final parsedResult = e.classConfig!.typeConfig.signatureParserNotifier.value;
  // TODO: can parsedResult fail?
  final generics = parsedResult.isSuccess
      ? parsedResult.value.generics
      : <SignatureGeneric>[];
  return _parseJsonTypeFromJson("map['${e.name}']", result.value, generics);
}

String _parseJsonTypeToJson(
  String getter,
  JsonTypeParser? t,
  List<SignatureGeneric> generics,
) {
  if (t == null) {
    return getter;
  }
  return t.when<String>(
    mapParser: (m) {
      return "$getter${m.nullable ? '?' : ''}.map((key, value) => MapEntry(${_parseJsonTypeToJson('key', m.genericType?.left, generics)}, ${_parseJsonTypeToJson('value', m.genericType?.right, generics)}))";
    },
    collectionParser: (c) {
      return "$getter${c.nullable ? '?' : ''}.map((e) => ${_parseJsonTypeToJson('e', c.genericType, generics)}).toList()";
    },
    primitiveParser: (v) {
      if (v.type.isCustom) {
        if (generics.any((g) => g.id == v.raw)) {
          return 'Serializers.toJson<${v.raw}>($getter)'; //"($getter as dynamic).toJson()";
        } else {
          return '$getter${v.nullable ? "?" : ""}.toJson()';
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
    return '${e.name}.toJson()';
  }
  final parsedResult = e.classConfig!.typeConfig.signatureParserNotifier.value;
  // TODO: can parsedResult fail?
  final generics = parsedResult.isSuccess
      ? parsedResult.value.generics
      : <SignatureGeneric>[];
  return _parseJsonTypeToJson(e.name, result.value, generics);
}
