import 'package:petitparser/petitparser.dart';
import 'package:snippet_generator/parsers/models/json_type.dart';
import 'package:snippet_generator/parsers/parsers.dart';

// ignore: constant_identifier_names
enum CollectionType { List, Set }

CollectionType? parseCollectionType(String rawString,
    {CollectionType? defaultValue}) {
  for (final variant in CollectionType.values) {
    if (rawString == variant.toEnumString()) {
      return variant;
    }
  }
  return defaultValue;
}

extension CollectionTypeExtension on CollectionType {
  String toEnumString() => toString().split('.')[1];
  String enumType() => toString().split('.')[0];

  bool get isList => this == CollectionType.List;
  bool get isSet => this == CollectionType.Set;

  T? when<T>({
    T Function()? list,
    T Function()? set,
    T Function()? orElse,
  }) {
    T Function()? c;
    switch (this) {
      case CollectionType.List:
        c = list;
        break;
      case CollectionType.Set:
        c = set;
        break;

      default:
        c = orElse;
    }
    return (c ?? orElse)?.call();
  }
}

class CollectionParser extends JsonTypeParser {
  const CollectionParser(
    this.collectionType,
    this.genericType, {
    required this.nullable,
  });
  final CollectionType collectionType;
  final JsonTypeParser? genericType;
  final bool nullable;

  static CollectionParser _collect(dynamic parserOutput) {
    if (parserOutput is List) {
      return CollectionParser(
        parserOutput[0] == 'List' ? CollectionType.List : CollectionType.Set,
        parserOutput[1] as JsonTypeParser?,
        nullable: parserOutput[2] != null,
      );
    }
    throw '';
  }

  static final listParser = (string('List').trim() &
          singleGeneric(JsonTypeParser.parser).optional() &
          char('?').trim().optional())
      .map(_collect);
  static final setParser = (string('Set').trim() &
          singleGeneric(JsonTypeParser.parser).optional() &
          char('?').trim().optional())
      .end()
      .map(_collect);
}

class MapParser extends JsonTypeParser {
  const MapParser(this.genericType, {required this.nullable});
  final DoubleGeneric<PrimitiveParser, JsonTypeParser>? genericType;
  final bool nullable;

  static final parser = (string('Map').trim() &
          DoubleGeneric.parser(
            PrimitiveParser.parser,
            JsonTypeParser._parser,
          ).optional() & char('?').trim().optional())
      .map(_collect);

  static MapParser _collect(List<dynamic> parserOutput) => MapParser(
        parserOutput[1] as DoubleGeneric<PrimitiveParser, JsonTypeParser>?,
        nullable: parserOutput[2] != null,
      );
}

class PrimitiveParser extends JsonTypeParser {
  const PrimitiveParser(
    this.type,
    this.raw, {
    this.genericIds = const <String>[],
    required this.nullable,
  });
  final PrimitiveJson type;
  final String raw;
  final List<String> genericIds;
  final bool nullable;

  static PrimitiveParser _collect(dynamic _raw) {
    final raw = (_raw as List).first;
    final nullable = _raw.last != null;
    if (raw is String) {
      final type = parsePrimitiveJson(raw);
      return PrimitiveParser(type, raw, nullable: nullable);
    } else if (raw is List) {
      final rawString = raw[0] as String;
      final type = parsePrimitiveJson(rawString);
      return type.when(
        custom: () => PrimitiveParser(
          type,
          rawString,
          genericIds: raw[1] != null
              ? (raw[1] as List).map((e) => e as String).toList()
              : const <String>[],
          nullable: nullable,
        ),
        orElse: () => PrimitiveParser(type, rawString, nullable: nullable),
      )!;
    }
    throw '';
  }

  static final parser = ((string('int') |
              string('double') |
              string('num') |
              string('String') |
              string('bool') |
              (identifier &
                  (char('<') &
                          identifier.separatedBy(char(','),
                              includeSeparators: false) &
                          char('>'))
                      .pick(1)
                      .optional())) &
          char('?').trim().optional())
      .map(_collect);
}

class JsonTypeParser {
  const JsonTypeParser();

  T when<T>({
    required T Function(MapParser value) mapParser,
    required T Function(CollectionParser value) collectionParser,
    required T Function(PrimitiveParser value) primitiveParser,
  }) {
    final JsonTypeParser v = this;
    if (v is MapParser) return mapParser(v);
    if (v is CollectionParser) return collectionParser(v);
    if (v is PrimitiveParser) return primitiveParser(v);
    throw '';
  }

  static void init() {
    _parser.set((MapParser.parser |
            CollectionParser.listParser |
            CollectionParser.setParser |
            PrimitiveParser.parser)
        .map((value) => value as JsonTypeParser));
  }

  static final SettableParser<JsonTypeParser> _parser =
      undefined<JsonTypeParser>();
  static Parser<JsonTypeParser> get parser => _parser;
}
