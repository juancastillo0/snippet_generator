import 'package:petitparser/petitparser.dart';

final _validString =
    ((letter() | char('_')) & (letter() | digit() | pattern('_?<>')).star())
        .flatten();

final _name =
    (pattern('\'"').optional() & _validString & pattern('\'"').optional())
        .pick(1);
final _required =
    (char('@').optional() & string('req') & string('uired').optional())
        .flatten();

const supportedTypes = {
  'datetime': 'DateTime',
  'time': 'DateTime',
  'timestamp': 'DateTime',
  'date': 'DateTime',
  'string': 'String',
  'str': 'String',
  'number': 'num',
  'int': 'int',
  'bigint': 'int',
  'num': 'num',
  'double': 'double',
  'float': 'double',
  'array': 'List',
  'map': 'Map',
  'set': 'Set',
  'text': 'String',
  'char': 'String',
  'varchar': 'String',
  'bool': 'bool',
  'boolean': 'bool',
};

final fieldsParser =
    (_required.trim().optional() & _name & char(':').optional().trim() & _name)
        .separatedBy(
  pattern(',;\n\t').star().trim(),
  includeSeparators: false,
  optionalSeparatorAtEnd: true,
)
        .map<List<RawField>>((value) {
  final leftTyped = <RawField>[];
  final rightTyped = <RawField>[];

  int typeIsRightCount = 0;
  for (final List _field in List.castFrom(value)) {
    final List<String?> field = List.castFrom(_field);
    final String left = field[1]!;
    final String right = field[3]!;
    // final String? defaultValue = field.last;
    final _isRequired = field[0] != null;

    final lowerLeft = left.toLowerCase();
    if (supportedTypes.containsKey(lowerLeft)) {
      typeIsRightCount -= 1;
    }

    final lowerRight = right.toLowerCase();
    if (supportedTypes.containsKey(lowerRight)) {
      typeIsRightCount += 1;
    }

    leftTyped.add(
      RawField(
        isRequired: _isRequired,
        name: right,
        type: supportedTypes[lowerLeft] ?? left,
      ),
    );
    rightTyped.add(
      RawField(
        isRequired: _isRequired,
        name: left,
        type: supportedTypes[lowerRight] ?? right,
      ),
    );
  }

  return typeIsRightCount > 0 ? rightTyped : leftTyped;
});

class RawField {
  final String name;
  final String type;
  final bool isRequired;

  const RawField({
    required this.name,
    required this.type,
    required this.isRequired,
  });
}
