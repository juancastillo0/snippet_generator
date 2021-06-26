import 'package:petitparser/petitparser.dart' show TrimmingParserExtension;
import 'package:snippet_generator/parsers/models/json_type.dart';
import 'package:snippet_generator/parsers/parsers.dart';
import 'package:snippet_generator/parsers/type_parser.dart';
import 'package:test/test.dart';

void main() {
  JsonTypeParser.init();

  group('Primitive parser', () {
    test('simple', () {
      final r1 = PrimitiveParser.parser.parse('int');

      expect(r1.isSuccess, true);
      expect(r1.value.type.toEnumString(), 'int');
      expect(r1.value.raw, 'int');

      final r2 = PrimitiveParser.parser.parse('Bo');
      expect(r2.isSuccess, true);
      expect(r2.value.type.toEnumString(), 'custom');
      expect(r2.value.raw, 'Bo');

      print(singleGeneric(JsonTypeParser.parser).trim().parse(' < int>').value);
    });
  });

  group('List and Set parser', () {
    test('simple', () {
      final r1 = CollectionParser.listParser.parse('List < int>');

      expect(r1.isSuccess, true);
      print(r1.value.genericType);
      expect(
          (r1.value.genericType as PrimitiveParser).type.toEnumString(), 'int');
      expect(r1.value.collectionType, CollectionType.List);

      final r2 = CollectionParser.setParser.parse('Set<int >');
      expect(r2.isSuccess, true);
      expect(
          (r2.value.genericType as PrimitiveParser).type.toEnumString(), 'int');
      expect(r2.value.collectionType, CollectionType.Set);

      // final r3 = CollectionParser.setParser.parse("Sets<int ");
      // print(r3);
      // expect(r3.isSuccess, false);
    });
  });

  group('Map parser', () {
    test('simple', () {
      final r1 = MapParser.parser.parse('Map< int, String>');
      expect(r1.isSuccess, true);
      final r1Type = r1.value.genericType!;
      expect(r1Type.left.type.toEnumString(), 'int');
      expect((r1Type.right as PrimitiveParser).type.toEnumString(), 'String');
      print(r1);

      final r2 = MapParser.parser.parse('Map <String,String > ');
      expect(r2.isSuccess, true);
      final r2Type = r2.value.genericType!;
      expect(r2Type.left.type.toEnumString(), 'String');
      expect((r2Type.right as PrimitiveParser).type.toEnumString(), 'String');
    });
  });

  group('Json parser', () {
    test('simple', () {
      final r1 = JsonTypeParser.parser.parse('Map< int, Map<String, double>>');
      expect(r1.isSuccess, true);
      expect(r1.value is MapParser, true);
      final mapGeneric = (r1.value as MapParser).genericType!;
      expect(mapGeneric.left.type.isInt, true);
      expect((mapGeneric.right as MapParser).genericType!.left.type.isString,
          true);
    });
  });

  group('None', () {
    test('simple', () {
      final Map m = {
        'd': {'w': 2}
      };

      final m2 = m.cast<String, Map<String, int>>();
      print(m2);
    });
  });
}
