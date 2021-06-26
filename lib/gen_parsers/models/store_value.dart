import 'package:snippet_generator/gen_parsers/models/tokens.dart';
import 'package:snippet_generator/globals/serializer.dart';

class GenerateParserStoreValue
    implements Serializable<GenerateParserStoreValue> {
  final List<MapEntry<String, ParserToken>> tokens;

  const GenerateParserStoreValue(this.tokens);

  static GenerateParserStoreValue fromJson(Map<String, dynamic>? json) {
    final _tokens = json!["tokens"] as List?;
    if (_tokens is List) {
      final tokens = _tokens.cast<Map<String, dynamic>>().map((e) {
        final key = e['key'] as String;
        final value = e['value'] as Map<String, dynamic>;
        final token = ParserToken.fromJson(value);
        return MapEntry(key, token);
      }).toList();

      return GenerateParserStoreValue(tokens);
    } else {
      throw Exception();
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'tokens': tokens
          .map((e) => {
                'key': e.key,
                'value': e.value.toJson(),
              })
          .toList()
    };
  }

  static final serializer =
      SerializerFunc<GenerateParserStoreValue>(fromJson: fromJson);
}
