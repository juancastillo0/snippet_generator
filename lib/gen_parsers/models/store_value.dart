import 'package:snippet_generator/gen_parsers/models/tokens.dart';
import 'package:snippet_generator/globals/serializer.dart';
import 'package:uuid/uuid.dart';

class GenerateParserStoreValue implements Serializable {
  final List<MapEntry<String, ParserToken>> tokens;
  final String name;
  final String key;

  const GenerateParserStoreValue(this.key, this.tokens, {required this.name});

  static GenerateParserStoreValue fromJson(Map<String, dynamic>? json) {
    final _tokens = json!['tokens'] as List?;
    if (_tokens is List) {
      final tokens = _tokens.cast<Map<String, dynamic>>().map((e) {
        final key = e['key'] as String;
        final value = e['value'] as Map<String, dynamic>;
        final token = ParserToken.fromJson(value);
        return MapEntry(key, token);
      }).toList();

      return GenerateParserStoreValue(
        json['key'] as String? ?? const Uuid().v4(),
        tokens,
        name: json['name'] as String? ?? '',
      );
    } else {
      throw Exception();
    }
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'key': key,
      'name': name,
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
