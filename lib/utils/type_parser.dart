import 'package:meta/meta.dart';
import 'package:petitparser/petitparser.dart';
import 'package:snippet_generator/utils/json_type.dart';

final id = (letter() & (letter() | digit()).star()).flatten();

Parser<T> _singleGeneric<T>(Parser<T> p) =>
    (char("<") & p.trim() & char(">")).pick<T>(1);

class _DoubleGeneric {
  const _DoubleGeneric(this.left, this.right);
  final PrimitiveParser left;
  final JsonTypeParser right;

  static final parser = (char("<") &
          PrimitiveParser.parser.trim() &
          char(",") &
          JsonTypeParser.parser.trim() &
          char(">"))
      .map<_DoubleGeneric>(
    (list) =>
        _DoubleGeneric(list[1] as PrimitiveParser, list[3] as JsonTypeParser),
  );
}

// ignore: constant_identifier_names
enum CollectionType { List, Set }

CollectionType parseCollectionType(String rawString,
    {CollectionType defaultValue}) {
  for (final variant in CollectionType.values) {
    if (rawString == variant.toEnumString()) {
      return variant;
    }
  }
  return defaultValue;
}

extension CollectionTypeExtension on CollectionType {
  String toEnumString() => toString().split(".")[1];
  String enumType() => toString().split(".")[0];

  bool get isList => this == CollectionType.List;
  bool get isSet => this == CollectionType.Set;

  T when<T>({
    T Function() List,
    T Function() Set,
    T Function() orElse,
  }) {
    T Function() c;
    switch (this) {
      case CollectionType.List:
        c = List;
        break;
      case CollectionType.Set:
        c = Set;
        break;

      default:
        c = orElse;
    }
    return (c ?? orElse)?.call();
  }
}

class CollectionParser extends JsonTypeParser {
  const CollectionParser(this.collectionType, this.genericType);
  final CollectionType collectionType;
  final JsonTypeParser genericType;

  static CollectionParser _collect(List<dynamic> parserOutput) =>
      CollectionParser(
          parserOutput[0] == "List" ? CollectionType.List : CollectionType.Set,
          parserOutput[1] as JsonTypeParser);

  static final listParser =
      (string("List") & _singleGeneric(JsonTypeParser.parser).optional().trim())
          .map(_collect);
  static final setParser =
      (string("Set") & _singleGeneric(JsonTypeParser.parser).optional().trim())
          .map(_collect);
}

class MapParser extends JsonTypeParser {
  const MapParser(this.genericType);
  final _DoubleGeneric genericType;

  static final parser =
      (string("Map") & _DoubleGeneric.parser.optional().trim()).map(_collect);

  static MapParser _collect(List<dynamic> parserOutput) =>
      MapParser(parserOutput[1] as _DoubleGeneric);
}

class PrimitiveParser extends JsonTypeParser {
  const PrimitiveParser(this.type, this.raw);
  final PrimitiveJson type;
  final String raw;

  static PrimitiveParser _collect(String raw) =>
      PrimitiveParser(parsePrimitiveJson(raw), raw);
  static final parser = (string("int") |
          string("double") |
          string("num") |
          string("String") |
          string("bool") |
          id)
      .map((s) => _collect(s as String));
}

class JsonTypeParser {
  const JsonTypeParser();

  T when<T>({
    @required T Function(MapParser value) mapParser,
    @required T Function(CollectionParser value) collectionParser,
    @required T Function(PrimitiveParser value) primitiveParser,
  }) {
    final v = this;
    if (v is MapParser) return mapParser(v);
    if (v is CollectionParser) return collectionParser(v);
    if (v is PrimitiveParser) return primitiveParser(v);
    throw "";
  }

  static void init() {
    parser.set((MapParser.parser |
            CollectionParser.listParser |
            CollectionParser.setParser |
            PrimitiveParser.parser)
        .map((value) => value as JsonTypeParser));
  }

  static final SettableParser<JsonTypeParser> parser =
      undefined<JsonTypeParser>();
}

class TEST {
  static const Parser<T> Function<T>(Parser<T>) singleGeneric = _singleGeneric;
}
