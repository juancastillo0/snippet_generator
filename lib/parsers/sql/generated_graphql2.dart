import 'dart:convert';
import 'dart:ui';
import 'package:petitparser/petitparser.dart';

extension ButNotParser<T> on Parser<T> {
  Parser<T> butNot(Parser not) {
    return this.and().seq(not.end().not()).pick(0).cast();
  }
}

final integerParser =
    (char('-').optional() & char('0').or(pattern('1-9') & digit().star()))
        .flatten()
        .map((value) => int.parse(value));
final doubleParser = (char('-').optional() &
        char('0').or(pattern('1-9') & digit().star()) &
        (char('.') & char('0').or(pattern('1-9') & digit().star())).optional())
    .flatten()
    .map((value) => double.parse(value));

final sourceCharacter = any();

final ignored = (whitespace().map((v) => Ignored.whitespace(value: v)) |
        comment.map((v) => Ignored.comment(value: v)) |
        char(',').map((v) => Ignored.comma(value: v)))
    .cast<Ignored>();

abstract class Ignored {
  const Ignored._();

  @override
  String toString() {
    return value.toString();
  }

  const factory Ignored.whitespace({
    required String value,
  }) = ignoredWhitespace;
  const factory Ignored.comment({
    required Comment value,
  }) = ignoredComment;
  const factory Ignored.comma({
    required String value,
  }) = ignoredComma;

  Object get value;

  _T when<_T>({
    required _T Function(String value) whitespace,
    required _T Function(Comment value) comment,
    required _T Function(String value) comma,
  }) {
    final v = this;
    if (v is ignoredWhitespace) {
      return whitespace(v.value);
    } else if (v is ignoredComment) {
      return comment(v.value);
    } else if (v is ignoredComma) {
      return comma(v.value);
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(String value)? whitespace,
    _T Function(Comment value)? comment,
    _T Function(String value)? comma,
  }) {
    final v = this;
    if (v is ignoredWhitespace) {
      return whitespace != null ? whitespace(v.value) : orElse.call();
    } else if (v is ignoredComment) {
      return comment != null ? comment(v.value) : orElse.call();
    } else if (v is ignoredComma) {
      return comma != null ? comma(v.value) : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(ignoredWhitespace value) whitespace,
    required _T Function(ignoredComment value) comment,
    required _T Function(ignoredComma value) comma,
  }) {
    final v = this;
    if (v is ignoredWhitespace) {
      return whitespace(v);
    } else if (v is ignoredComment) {
      return comment(v);
    } else if (v is ignoredComma) {
      return comma(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(ignoredWhitespace value)? whitespace,
    _T Function(ignoredComment value)? comment,
    _T Function(ignoredComma value)? comma,
  }) {
    final v = this;
    if (v is ignoredWhitespace) {
      return whitespace != null ? whitespace(v) : orElse.call();
    } else if (v is ignoredComment) {
      return comment != null ? comment(v) : orElse.call();
    } else if (v is ignoredComma) {
      return comma != null ? comma(v) : orElse.call();
    }
    throw Exception();
  }

  bool get isWhitespace => this is ignoredWhitespace;
  bool get isComment => this is ignoredComment;
  bool get isComma => this is ignoredComma;

  static Ignored fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Ignored) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    switch (map['runtimeType'] as String) {
      case 'whitespace':
        return ignoredWhitespace.fromJson(map);
      case 'comment':
        return ignoredComment.fromJson(map);
      case 'comma':
        return ignoredComma.fromJson(map);
      default:
        throw Exception('Invalid discriminator for Ignored.fromJson '
            '${map["runtimeType"]}. Input map: $map');
    }
  }

  Map<String, dynamic> toJson();
}

class ignoredWhitespace extends Ignored {
  final String value;

  const ignoredWhitespace({
    required this.value,
  }) : super._();

  ignoredWhitespace copyWith({
    String? value,
  }) {
    return ignoredWhitespace(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ignoredWhitespace) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ignoredWhitespace fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ignoredWhitespace) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ignoredWhitespace(
      value: map['value'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'whitespace',
      'value': value,
    };
  }
}

class ignoredComment extends Ignored {
  final Comment value;

  const ignoredComment({
    required this.value,
  }) : super._();

  ignoredComment copyWith({
    Comment? value,
  }) {
    return ignoredComment(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ignoredComment) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ignoredComment fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ignoredComment) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ignoredComment(
      value: Comment.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'comment',
      'value': value.toJson(),
    };
  }
}

class ignoredComma extends Ignored {
  final String value;

  const ignoredComma({
    required this.value,
  }) : super._();

  ignoredComma copyWith({
    String? value,
  }) {
    return ignoredComma(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ignoredComma) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ignoredComma fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ignoredComma) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ignoredComma(
      value: map['value'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'comma',
      'value': value,
    };
  }
}

final comment = (char('#') & commentChar.star()).map((l) {
  return Comment(
    chars: l[1] as List<String>?,
  );
});

class Comment {
  final List<String>? chars;

  @override
  String toString() {
    return '#${chars == null ? "" : "${chars!.join(" ")}"}';
  }

  const Comment({
    this.chars,
  });

  Comment copyWith({
    List<String>? chars,
  }) {
    return Comment(
      chars: chars ?? this.chars,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Comment) {
      return this.chars == other.chars;
    }
    return false;
  }

  @override
  int get hashCode => chars.hashCode;

  static Comment fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Comment) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return Comment(
      chars: (map['chars'] as List?)?.map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chars': chars?.map((e) => e).toList(),
    };
  }
}

final commentChar = (sourceCharacter.butNot(string('\n'))).flatten();

final name =
    ((letter() | char('_')) & (letter() | digit() | char('_'))).flatten();

final intValue = (integerParser).map((l) {
  return IntValue(
    value: l as int,
  );
});

class IntValue {
  final int value;

  @override
  String toString() {
    return '${value}';
  }

  const IntValue({
    required this.value,
  });

  IntValue copyWith({
    int? value,
  }) {
    return IntValue(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is IntValue) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static IntValue fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is IntValue) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return IntValue(
      value: map['value'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
    };
  }
}

final floatValue = (doubleParser).map((l) {
  return FloatValue(
    value: l as double,
  );
});

class FloatValue {
  final double value;

  @override
  String toString() {
    return '${value}';
  }

  const FloatValue({
    required this.value,
  });

  FloatValue copyWith({
    double? value,
  }) {
    return FloatValue(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is FloatValue) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static FloatValue fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is FloatValue) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return FloatValue(
      value: map['value'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
    };
  }
}

final stringValue = ((char('"') & stringCharacter.star() & char('"')).map((l) {
          return Line(
            str: l[1] as List<StringCharacter>?,
          );
        }).map((v) => StringValue.line(value: v)) |
        (string('"""') & blockStringCharacter.star() & string('""""')).map((l) {
          return Block(
            str: l[1] as List<String>?,
          );
        }).map((v) => StringValue.block(value: v)))
    .cast<StringValue>();

abstract class StringValue {
  const StringValue._();

  @override
  String toString() {
    return value.toString();
  }

  const factory StringValue.line({
    required Line value,
  }) = stringValueLine;
  const factory StringValue.block({
    required Block value,
  }) = stringValueBlock;

  Object get value;

  _T when<_T>({
    required _T Function(Line value) line,
    required _T Function(Block value) block,
  }) {
    final v = this;
    if (v is stringValueLine) {
      return line(v.value);
    } else if (v is stringValueBlock) {
      return block(v.value);
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(Line value)? line,
    _T Function(Block value)? block,
  }) {
    final v = this;
    if (v is stringValueLine) {
      return line != null ? line(v.value) : orElse.call();
    } else if (v is stringValueBlock) {
      return block != null ? block(v.value) : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(stringValueLine value) line,
    required _T Function(stringValueBlock value) block,
  }) {
    final v = this;
    if (v is stringValueLine) {
      return line(v);
    } else if (v is stringValueBlock) {
      return block(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(stringValueLine value)? line,
    _T Function(stringValueBlock value)? block,
  }) {
    final v = this;
    if (v is stringValueLine) {
      return line != null ? line(v) : orElse.call();
    } else if (v is stringValueBlock) {
      return block != null ? block(v) : orElse.call();
    }
    throw Exception();
  }

  bool get isLine => this is stringValueLine;
  bool get isBlock => this is stringValueBlock;

  static StringValue fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is StringValue) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    switch (map['runtimeType'] as String) {
      case 'line':
        return stringValueLine.fromJson(map);
      case 'block':
        return stringValueBlock.fromJson(map);
      default:
        throw Exception('Invalid discriminator for StringValue.fromJson '
            '${map["runtimeType"]}. Input map: $map');
    }
  }

  Map<String, dynamic> toJson();
}

class stringValueLine extends StringValue {
  final Line value;

  const stringValueLine({
    required this.value,
  }) : super._();

  stringValueLine copyWith({
    Line? value,
  }) {
    return stringValueLine(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is stringValueLine) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static stringValueLine fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is stringValueLine) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return stringValueLine(
      value: Line.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'line',
      'value': value.toJson(),
    };
  }
}

class stringValueBlock extends StringValue {
  final Block value;

  const stringValueBlock({
    required this.value,
  }) : super._();

  stringValueBlock copyWith({
    Block? value,
  }) {
    return stringValueBlock(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is stringValueBlock) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static stringValueBlock fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is stringValueBlock) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return stringValueBlock(
      value: Block.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'block',
      'value': value.toJson(),
    };
  }
}

class Line {
  final List<StringCharacter>? str;

  @override
  String toString() {
    return '"${str == null ? "" : "${str!.join(" ")}"}"';
  }

  const Line({
    this.str,
  });

  Line copyWith({
    List<StringCharacter>? str,
  }) {
    return Line(
      str: str ?? this.str,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Line) {
      return this.str == other.str;
    }
    return false;
  }

  @override
  int get hashCode => str.hashCode;

  static Line fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Line) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return Line(
      str: (map['str'] as List?)
          ?.map((e) => StringCharacter.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'str': str?.map((e) => e.toJson()).toList(),
    };
  }
}

class Block {
  final List<String>? str;

  @override
  String toString() {
    return '"""${str == null ? "" : "${str!.join(" ")}"}""""';
  }

  const Block({
    this.str,
  });

  Block copyWith({
    List<String>? str,
  }) {
    return Block(
      str: str ?? this.str,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Block) {
      return this.str == other.str;
    }
    return false;
  }

  @override
  int get hashCode => str.hashCode;

  static Block fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Block) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return Block(
      str: (map['str'] as List?)?.map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'str': str?.map((e) => e).toList(),
    };
  }
}

final stringCharacter = ((sourceCharacter
                .trim()
                .butNot((char('"').map((_) => SourceChar.doubleQuote) |
                        string('\n').map((_) => SourceChar.newLine))
                    .cast<SourceChar>()
                    .trim())
                .trim()
                .map((v) => StringCharacter.sourceChar(value: v)) |
            (string('\\u') & escapedUnicode).map((l) {
              return Unicode(
                character: l[1] as String,
              );
            }).map((v) => StringCharacter.unicode(value: v)) |
            (string('\\') & escapedCharacter).map((l) {
              return Escaped(
                character: l[1] as String,
              );
            }).map((v) => StringCharacter.escaped(value: v)))
        .cast<StringCharacter>()
        .trim())
    .trim();

abstract class StringCharacter {
  const StringCharacter._();

  @override
  String toString() {
    return value.toString();
  }

  const factory StringCharacter.sourceChar({
    required String value,
  }) = StringCharacterSourceChar;
  const factory StringCharacter.unicode({
    required Unicode value,
  }) = StringCharacterUnicode;
  const factory StringCharacter.escaped({
    required Escaped value,
  }) = StringCharacterEscaped;

  Object get value;

  _T when<_T>({
    required _T Function(String value) sourceChar,
    required _T Function(Unicode value) unicode,
    required _T Function(Escaped value) escaped,
  }) {
    final v = this;
    if (v is StringCharacterSourceChar) {
      return sourceChar(v.value);
    } else if (v is StringCharacterUnicode) {
      return unicode(v.value);
    } else if (v is StringCharacterEscaped) {
      return escaped(v.value);
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(String value)? sourceChar,
    _T Function(Unicode value)? unicode,
    _T Function(Escaped value)? escaped,
  }) {
    final v = this;
    if (v is StringCharacterSourceChar) {
      return sourceChar != null ? sourceChar(v.value) : orElse.call();
    } else if (v is StringCharacterUnicode) {
      return unicode != null ? unicode(v.value) : orElse.call();
    } else if (v is StringCharacterEscaped) {
      return escaped != null ? escaped(v.value) : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(StringCharacterSourceChar value) sourceChar,
    required _T Function(StringCharacterUnicode value) unicode,
    required _T Function(StringCharacterEscaped value) escaped,
  }) {
    final v = this;
    if (v is StringCharacterSourceChar) {
      return sourceChar(v);
    } else if (v is StringCharacterUnicode) {
      return unicode(v);
    } else if (v is StringCharacterEscaped) {
      return escaped(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(StringCharacterSourceChar value)? sourceChar,
    _T Function(StringCharacterUnicode value)? unicode,
    _T Function(StringCharacterEscaped value)? escaped,
  }) {
    final v = this;
    if (v is StringCharacterSourceChar) {
      return sourceChar != null ? sourceChar(v) : orElse.call();
    } else if (v is StringCharacterUnicode) {
      return unicode != null ? unicode(v) : orElse.call();
    } else if (v is StringCharacterEscaped) {
      return escaped != null ? escaped(v) : orElse.call();
    }
    throw Exception();
  }

  bool get isSourceChar => this is StringCharacterSourceChar;
  bool get isUnicode => this is StringCharacterUnicode;
  bool get isEscaped => this is StringCharacterEscaped;

  static StringCharacter fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is StringCharacter) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    switch (map['runtimeType'] as String) {
      case 'sourceChar':
        return StringCharacterSourceChar.fromJson(map);
      case 'unicode':
        return StringCharacterUnicode.fromJson(map);
      case 'escaped':
        return StringCharacterEscaped.fromJson(map);
      default:
        throw Exception('Invalid discriminator for StringCharacter.fromJson '
            '${map["runtimeType"]}. Input map: $map');
    }
  }

  Map<String, dynamic> toJson();
}

class StringCharacterSourceChar extends StringCharacter {
  final String value;

  const StringCharacterSourceChar({
    required this.value,
  }) : super._();

  StringCharacterSourceChar copyWith({
    String? value,
  }) {
    return StringCharacterSourceChar(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is StringCharacterSourceChar) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static StringCharacterSourceChar fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is StringCharacterSourceChar) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return StringCharacterSourceChar(
      value: map['value'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'sourceChar',
      'value': value,
    };
  }
}

class StringCharacterUnicode extends StringCharacter {
  final Unicode value;

  const StringCharacterUnicode({
    required this.value,
  }) : super._();

  StringCharacterUnicode copyWith({
    Unicode? value,
  }) {
    return StringCharacterUnicode(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is StringCharacterUnicode) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static StringCharacterUnicode fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is StringCharacterUnicode) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return StringCharacterUnicode(
      value: Unicode.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'unicode',
      'value': value.toJson(),
    };
  }
}

class StringCharacterEscaped extends StringCharacter {
  final Escaped value;

  const StringCharacterEscaped({
    required this.value,
  }) : super._();

  StringCharacterEscaped copyWith({
    Escaped? value,
  }) {
    return StringCharacterEscaped(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is StringCharacterEscaped) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static StringCharacterEscaped fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is StringCharacterEscaped) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return StringCharacterEscaped(
      value: Escaped.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'escaped',
      'value': value.toJson(),
    };
  }
}

class SourceChar {
  final String _inner;

  const SourceChar._(this._inner);

  static const doubleQuote = SourceChar._('"');
  static const newLine = SourceChar._('\n');

  static const values = [
    SourceChar.doubleQuote,
    SourceChar.newLine,
  ];

  static SourceChar fromJson(Object? json) {
    if (json == null) {
      throw Error();
    }
    for (final v in values) {
      if (json.toString() == v._inner) {
        return v;
      }
    }
    throw Error();
  }

  String toJson() {
    return _inner;
  }

  @override
  String toString() {
    return _inner;
  }

  @override
  bool operator ==(Object other) {
    return other is SourceChar &&
        other.runtimeType == runtimeType &&
        other._inner == _inner;
  }

  @override
  int get hashCode => _inner.hashCode;

  bool get isDoubleQuote => this == SourceChar.doubleQuote;
  bool get isNewLine => this == SourceChar.newLine;

  _T when<_T>({
    required _T Function() doubleQuote,
    required _T Function() newLine,
  }) {
    switch (this._inner) {
      case '"':
        return doubleQuote();
      case '\n':
        return newLine();
    }
    throw Error();
  }

  _T maybeWhen<_T>({
    _T Function()? doubleQuote,
    _T Function()? newLine,
    required _T Function() orElse,
  }) {
    _T Function()? c;
    switch (this._inner) {
      case '"':
        c = doubleQuote;
        break;
      case '\n':
        c = newLine;
        break;
    }
    return (c ?? orElse).call();
  }
}

class Unicode {
  final String character;

  @override
  String toString() {
    return '\\u${character}';
  }

  const Unicode({
    required this.character,
  });

  Unicode copyWith({
    String? character,
  }) {
    return Unicode(
      character: character ?? this.character,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Unicode) {
      return this.character == other.character;
    }
    return false;
  }

  @override
  int get hashCode => character.hashCode;

  static Unicode fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Unicode) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return Unicode(
      character: map['character'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'character': character,
    };
  }
}

class Escaped {
  final String character;

  @override
  String toString() {
    return '\\${character}';
  }

  const Escaped({
    required this.character,
  });

  Escaped copyWith({
    String? character,
  }) {
    return Escaped(
      character: character ?? this.character,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Escaped) {
      return this.character == other.character;
    }
    return false;
  }

  @override
  int get hashCode => character.hashCode;

  static Escaped fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Escaped) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return Escaped(
      character: map['character'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'character': character,
    };
  }
}

final escapedUnicode =
    ((digit() | patternIgnoreCase('a-f'))).flatten().repeat(4, 4);

final escapedCharacter = ((char('"') |
        string('\\') |
        char('/') |
        char('b') |
        char('f') |
        char('n') |
        char('r') |
        char('t')))
    .flatten();

final blockStringCharacter =
    ((sourceCharacter.butNot((string('"""') | string('\\"""'))) |
            string('\\"""')))
        .flatten();

final document = (definition.trim().plus()).map((l) {
  return Document(
    definitions: l as List<Definition>,
  );
});

class Document {
  final List<Definition> definitions;

  @override
  String toString() {
    return '${definitions.join(" ")} ';
  }

  const Document({
    required this.definitions,
  });

  Document copyWith({
    List<Definition>? definitions,
  }) {
    return Document(
      definitions: definitions ?? this.definitions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Document) {
      return this.definitions == other.definitions;
    }
    return false;
  }

  @override
  int get hashCode => definitions.hashCode;

  static Document fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Document) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return Document(
      definitions: (map['definitions'] as List)
          .map((e) => Definition.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'definitions': definitions.map((e) => e.toJson()).toList(),
    };
  }
}

final definition =
    ((executableDefinition.map((v) => Definition.executable(value: v)) |
            string('sd').map((v) => Definition.sd(value: v)))
        .cast<Definition>());

abstract class Definition {
  const Definition._();

  @override
  String toString() {
    return value.toString();
  }

  const factory Definition.executable({
    required ExecutableDefinition value,
  }) = DefinitionExecutable;
  const factory Definition.sd({
    required String value,
  }) = DefinitionSd;

  Object get value;

  _T when<_T>({
    required _T Function(ExecutableDefinition value) executable,
    required _T Function(String value) sd,
  }) {
    final v = this;
    if (v is DefinitionExecutable) {
      return executable(v.value);
    } else if (v is DefinitionSd) {
      return sd(v.value);
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(ExecutableDefinition value)? executable,
    _T Function(String value)? sd,
  }) {
    final v = this;
    if (v is DefinitionExecutable) {
      return executable != null ? executable(v.value) : orElse.call();
    } else if (v is DefinitionSd) {
      return sd != null ? sd(v.value) : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(DefinitionExecutable value) executable,
    required _T Function(DefinitionSd value) sd,
  }) {
    final v = this;
    if (v is DefinitionExecutable) {
      return executable(v);
    } else if (v is DefinitionSd) {
      return sd(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(DefinitionExecutable value)? executable,
    _T Function(DefinitionSd value)? sd,
  }) {
    final v = this;
    if (v is DefinitionExecutable) {
      return executable != null ? executable(v) : orElse.call();
    } else if (v is DefinitionSd) {
      return sd != null ? sd(v) : orElse.call();
    }
    throw Exception();
  }

  bool get isExecutable => this is DefinitionExecutable;
  bool get isSd => this is DefinitionSd;

  static Definition fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Definition) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    switch (map['runtimeType'] as String) {
      case 'executable':
        return DefinitionExecutable.fromJson(map);
      case 'sd':
        return DefinitionSd.fromJson(map);
      default:
        throw Exception('Invalid discriminator for Definition.fromJson '
            '${map["runtimeType"]}. Input map: $map');
    }
  }

  Map<String, dynamic> toJson();
}

class DefinitionExecutable extends Definition {
  final ExecutableDefinition value;

  const DefinitionExecutable({
    required this.value,
  }) : super._();

  DefinitionExecutable copyWith({
    ExecutableDefinition? value,
  }) {
    return DefinitionExecutable(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is DefinitionExecutable) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static DefinitionExecutable fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is DefinitionExecutable) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return DefinitionExecutable(
      value: ExecutableDefinition.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'executable',
      'value': value.toJson(),
    };
  }
}

class DefinitionSd extends Definition {
  final String value;

  const DefinitionSd({
    required this.value,
  }) : super._();

  DefinitionSd copyWith({
    String? value,
  }) {
    return DefinitionSd(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is DefinitionSd) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static DefinitionSd fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is DefinitionSd) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return DefinitionSd(
      value: map['value'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'sd',
      'value': value,
    };
  }
}

final executableDefinition = ((operationDefinition
            .map((v) => ExecutableDefinition.operation(value: v)) |
        fragmentDefinition.map((v) => ExecutableDefinition.fragment(value: v)))
    .cast<ExecutableDefinition>());

abstract class ExecutableDefinition {
  const ExecutableDefinition._();

  @override
  String toString() {
    return value.toString();
  }

  const factory ExecutableDefinition.operation({
    required OperationDefinition value,
  }) = ExecutableDefinitionOperation;
  const factory ExecutableDefinition.fragment({
    required FragmentDefinition value,
  }) = ExecutableDefinitionFragment;

  Object get value;

  _T when<_T>({
    required _T Function(OperationDefinition value) operation,
    required _T Function(FragmentDefinition value) fragment,
  }) {
    final v = this;
    if (v is ExecutableDefinitionOperation) {
      return operation(v.value);
    } else if (v is ExecutableDefinitionFragment) {
      return fragment(v.value);
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(OperationDefinition value)? operation,
    _T Function(FragmentDefinition value)? fragment,
  }) {
    final v = this;
    if (v is ExecutableDefinitionOperation) {
      return operation != null ? operation(v.value) : orElse.call();
    } else if (v is ExecutableDefinitionFragment) {
      return fragment != null ? fragment(v.value) : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(ExecutableDefinitionOperation value) operation,
    required _T Function(ExecutableDefinitionFragment value) fragment,
  }) {
    final v = this;
    if (v is ExecutableDefinitionOperation) {
      return operation(v);
    } else if (v is ExecutableDefinitionFragment) {
      return fragment(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(ExecutableDefinitionOperation value)? operation,
    _T Function(ExecutableDefinitionFragment value)? fragment,
  }) {
    final v = this;
    if (v is ExecutableDefinitionOperation) {
      return operation != null ? operation(v) : orElse.call();
    } else if (v is ExecutableDefinitionFragment) {
      return fragment != null ? fragment(v) : orElse.call();
    }
    throw Exception();
  }

  bool get isOperation => this is ExecutableDefinitionOperation;
  bool get isFragment => this is ExecutableDefinitionFragment;

  static ExecutableDefinition fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ExecutableDefinition) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    switch (map['runtimeType'] as String) {
      case 'operation':
        return ExecutableDefinitionOperation.fromJson(map);
      case 'fragment':
        return ExecutableDefinitionFragment.fromJson(map);
      default:
        throw Exception(
            'Invalid discriminator for ExecutableDefinition.fromJson '
            '${map["runtimeType"]}. Input map: $map');
    }
  }

  Map<String, dynamic> toJson();
}

class ExecutableDefinitionOperation extends ExecutableDefinition {
  final OperationDefinition value;

  const ExecutableDefinitionOperation({
    required this.value,
  }) : super._();

  ExecutableDefinitionOperation copyWith({
    OperationDefinition? value,
  }) {
    return ExecutableDefinitionOperation(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ExecutableDefinitionOperation) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ExecutableDefinitionOperation fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ExecutableDefinitionOperation) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ExecutableDefinitionOperation(
      value: OperationDefinition.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'operation',
      'value': value.toJson(),
    };
  }
}

class ExecutableDefinitionFragment extends ExecutableDefinition {
  final FragmentDefinition value;

  const ExecutableDefinitionFragment({
    required this.value,
  }) : super._();

  ExecutableDefinitionFragment copyWith({
    FragmentDefinition? value,
  }) {
    return ExecutableDefinitionFragment(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ExecutableDefinitionFragment) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ExecutableDefinitionFragment fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ExecutableDefinitionFragment) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ExecutableDefinitionFragment(
      value: FragmentDefinition.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'fragment',
      'value': value.toJson(),
    };
  }
}

final operationDefinition =
    ((selectionSet.map((v) => OperationDefinition.selectionSet(value: v)) |
            (operationType.trim() &
                    name.trim().optional() &
                    variableDefinitions.trim().optional() &
                    directives.trim().optional() &
                    selectionSet.trim())
                .map((l) {
              return Operation(
                operationType: l[0] as OperationType,
                name: l[1] as String?,
                variableDefinitions: l[2] as VariableDefinitions?,
                directives: l[3] as Directives?,
                selectionSet: l[4] as SelectionSet,
              );
            }).map((v) => OperationDefinition.operation(value: v)))
        .cast<OperationDefinition>());

abstract class OperationDefinition {
  const OperationDefinition._();

  @override
  String toString() {
    return value.toString();
  }

  const factory OperationDefinition.selectionSet({
    required SelectionSet value,
  }) = OperationDefinitionSelectionSet;
  const factory OperationDefinition.operation({
    required Operation value,
  }) = OperationDefinitionOperation;

  Object get value;

  _T when<_T>({
    required _T Function(SelectionSet value) selectionSet,
    required _T Function(Operation value) operation,
  }) {
    final v = this;
    if (v is OperationDefinitionSelectionSet) {
      return selectionSet(v.value);
    } else if (v is OperationDefinitionOperation) {
      return operation(v.value);
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(SelectionSet value)? selectionSet,
    _T Function(Operation value)? operation,
  }) {
    final v = this;
    if (v is OperationDefinitionSelectionSet) {
      return selectionSet != null ? selectionSet(v.value) : orElse.call();
    } else if (v is OperationDefinitionOperation) {
      return operation != null ? operation(v.value) : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(OperationDefinitionSelectionSet value) selectionSet,
    required _T Function(OperationDefinitionOperation value) operation,
  }) {
    final v = this;
    if (v is OperationDefinitionSelectionSet) {
      return selectionSet(v);
    } else if (v is OperationDefinitionOperation) {
      return operation(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(OperationDefinitionSelectionSet value)? selectionSet,
    _T Function(OperationDefinitionOperation value)? operation,
  }) {
    final v = this;
    if (v is OperationDefinitionSelectionSet) {
      return selectionSet != null ? selectionSet(v) : orElse.call();
    } else if (v is OperationDefinitionOperation) {
      return operation != null ? operation(v) : orElse.call();
    }
    throw Exception();
  }

  bool get isSelectionSet => this is OperationDefinitionSelectionSet;
  bool get isOperation => this is OperationDefinitionOperation;

  static OperationDefinition fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is OperationDefinition) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    switch (map['runtimeType'] as String) {
      case 'selectionSet':
        return OperationDefinitionSelectionSet.fromJson(map);
      case 'operation':
        return OperationDefinitionOperation.fromJson(map);
      default:
        throw Exception(
            'Invalid discriminator for OperationDefinition.fromJson '
            '${map["runtimeType"]}. Input map: $map');
    }
  }

  Map<String, dynamic> toJson();
}

class OperationDefinitionSelectionSet extends OperationDefinition {
  final SelectionSet value;

  const OperationDefinitionSelectionSet({
    required this.value,
  }) : super._();

  OperationDefinitionSelectionSet copyWith({
    SelectionSet? value,
  }) {
    return OperationDefinitionSelectionSet(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is OperationDefinitionSelectionSet) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static OperationDefinitionSelectionSet fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is OperationDefinitionSelectionSet) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return OperationDefinitionSelectionSet(
      value: SelectionSet.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'selectionSet',
      'value': value.toJson(),
    };
  }
}

class OperationDefinitionOperation extends OperationDefinition {
  final Operation value;

  const OperationDefinitionOperation({
    required this.value,
  }) : super._();

  OperationDefinitionOperation copyWith({
    Operation? value,
  }) {
    return OperationDefinitionOperation(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is OperationDefinitionOperation) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static OperationDefinitionOperation fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is OperationDefinitionOperation) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return OperationDefinitionOperation(
      value: Operation.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'operation',
      'value': value.toJson(),
    };
  }
}

class Operation {
  final OperationType operationType;
  final String? name;
  final VariableDefinitions? variableDefinitions;
  final Directives? directives;
  final SelectionSet selectionSet;

  @override
  String toString() {
    return '${operationType} ${name == null ? "" : "${name!}"} ${variableDefinitions == null ? "" : "${variableDefinitions!}"} ${directives == null ? "" : "${directives!}"} ${selectionSet} ';
  }

  const Operation({
    required this.operationType,
    required this.selectionSet,
    this.name,
    this.variableDefinitions,
    this.directives,
  });

  Operation copyWith({
    OperationType? operationType,
    String? name,
    VariableDefinitions? variableDefinitions,
    Directives? directives,
    SelectionSet? selectionSet,
  }) {
    return Operation(
      operationType: operationType ?? this.operationType,
      selectionSet: selectionSet ?? this.selectionSet,
      name: name ?? this.name,
      variableDefinitions: variableDefinitions ?? this.variableDefinitions,
      directives: directives ?? this.directives,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Operation) {
      return this.operationType == other.operationType &&
          this.name == other.name &&
          this.variableDefinitions == other.variableDefinitions &&
          this.directives == other.directives &&
          this.selectionSet == other.selectionSet;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(
      operationType, name, variableDefinitions, directives, selectionSet);

  static Operation fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Operation) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return Operation(
      operationType: OperationType.fromJson(map['operationType']),
      selectionSet: SelectionSet.fromJson(map['selectionSet']),
      name: map['name'] as String,
      variableDefinitions: map['variableDefinitions'] == null
          ? null
          : VariableDefinitions.fromJson(map['variableDefinitions']),
      directives: map['directives'] == null
          ? null
          : Directives.fromJson(map['directives']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'operationType': operationType.toJson(),
      'name': name,
      'variableDefinitions': variableDefinitions?.toJson(),
      'directives': directives?.toJson(),
      'selectionSet': selectionSet.toJson(),
    };
  }
}

SettableParser<SelectionSet>? _selectionSet;

Parser<SelectionSet> get selectionSet {
  if (_selectionSet != null) {
    return _selectionSet!;
  }
  _selectionSet = undefined();
  final p =
      (char('{').trim() & selection.trim().plus() & char('}').trim()).map((l) {
    return SelectionSet(
      selections: l[1] as List<Selection>,
    );
  });
  _selectionSet!.set(p);
  return _selectionSet!;
}

class SelectionSet {
  final List<Selection> selections;

  @override
  String toString() {
    return '{ ${selections.join(" ")} } ';
  }

  const SelectionSet({
    required this.selections,
  });

  SelectionSet copyWith({
    List<Selection>? selections,
  }) {
    return SelectionSet(
      selections: selections ?? this.selections,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is SelectionSet) {
      return this.selections == other.selections;
    }
    return false;
  }

  @override
  int get hashCode => selections.hashCode;

  static SelectionSet fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is SelectionSet) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return SelectionSet(
      selections: (map['selections'] as List)
          .map((e) => Selection.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selections': selections.map((e) => e.toJson()).toList(),
    };
  }
}

final operationType = ((string('query').map((_) => OperationType.query) |
        string('mutation').map((_) => OperationType.mutation) |
        string('subscription').map((_) => OperationType.subscription))
    .cast<OperationType>());

class OperationType {
  final String _inner;

  const OperationType._(this._inner);

  static const query = OperationType._('query');
  static const mutation = OperationType._('mutation');
  static const subscription = OperationType._('subscription');

  static const values = [
    OperationType.query,
    OperationType.mutation,
    OperationType.subscription,
  ];

  static OperationType fromJson(Object? json) {
    if (json == null) {
      throw Error();
    }
    for (final v in values) {
      if (json.toString() == v._inner) {
        return v;
      }
    }
    throw Error();
  }

  String toJson() {
    return _inner;
  }

  @override
  String toString() {
    return _inner;
  }

  @override
  bool operator ==(Object other) {
    return other is OperationType &&
        other.runtimeType == runtimeType &&
        other._inner == _inner;
  }

  @override
  int get hashCode => _inner.hashCode;

  bool get isQuery => this == OperationType.query;
  bool get isMutation => this == OperationType.mutation;
  bool get isSubscription => this == OperationType.subscription;

  _T when<_T>({
    required _T Function() query,
    required _T Function() mutation,
    required _T Function() subscription,
  }) {
    switch (this._inner) {
      case 'query':
        return query();
      case 'mutation':
        return mutation();
      case 'subscription':
        return subscription();
    }
    throw Error();
  }

  _T maybeWhen<_T>({
    _T Function()? query,
    _T Function()? mutation,
    _T Function()? subscription,
    required _T Function() orElse,
  }) {
    _T Function()? c;
    switch (this._inner) {
      case 'query':
        c = query;
        break;
      case 'mutation':
        c = mutation;
        break;
      case 'subscription':
        c = subscription;
        break;
    }
    return (c ?? orElse).call();
  }
}

SettableParser<Selection>? _selection;

Parser<Selection> get selection {
  if (_selection != null) {
    return _selection!;
  }
  _selection = undefined();
  final p = ((field.trim().map((v) => Selection.field(value: v)) |
          fragmentSpread.trim().map((v) => Selection.fragmentSpread(value: v)) |
          inlineFragment.trim().map((v) => Selection.inlineFragment(value: v)))
      .cast<Selection>()
      .trim());
  _selection!.set(p);
  return _selection!;
}

abstract class Selection {
  const Selection._();

  @override
  String toString() {
    return value.toString();
  }

  const factory Selection.field({
    required Field value,
  }) = SelectionField;
  const factory Selection.fragmentSpread({
    required FragmentSpread value,
  }) = SelectionFragmentSpread;
  const factory Selection.inlineFragment({
    required InlineFragment value,
  }) = SelectionInlineFragment;

  Object get value;

  _T when<_T>({
    required _T Function(Field value) field,
    required _T Function(FragmentSpread value) fragmentSpread,
    required _T Function(InlineFragment value) inlineFragment,
  }) {
    final v = this;
    if (v is SelectionField) {
      return field(v.value);
    } else if (v is SelectionFragmentSpread) {
      return fragmentSpread(v.value);
    } else if (v is SelectionInlineFragment) {
      return inlineFragment(v.value);
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(Field value)? field,
    _T Function(FragmentSpread value)? fragmentSpread,
    _T Function(InlineFragment value)? inlineFragment,
  }) {
    final v = this;
    if (v is SelectionField) {
      return field != null ? field(v.value) : orElse.call();
    } else if (v is SelectionFragmentSpread) {
      return fragmentSpread != null ? fragmentSpread(v.value) : orElse.call();
    } else if (v is SelectionInlineFragment) {
      return inlineFragment != null ? inlineFragment(v.value) : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(SelectionField value) field,
    required _T Function(SelectionFragmentSpread value) fragmentSpread,
    required _T Function(SelectionInlineFragment value) inlineFragment,
  }) {
    final v = this;
    if (v is SelectionField) {
      return field(v);
    } else if (v is SelectionFragmentSpread) {
      return fragmentSpread(v);
    } else if (v is SelectionInlineFragment) {
      return inlineFragment(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(SelectionField value)? field,
    _T Function(SelectionFragmentSpread value)? fragmentSpread,
    _T Function(SelectionInlineFragment value)? inlineFragment,
  }) {
    final v = this;
    if (v is SelectionField) {
      return field != null ? field(v) : orElse.call();
    } else if (v is SelectionFragmentSpread) {
      return fragmentSpread != null ? fragmentSpread(v) : orElse.call();
    } else if (v is SelectionInlineFragment) {
      return inlineFragment != null ? inlineFragment(v) : orElse.call();
    }
    throw Exception();
  }

  bool get isField => this is SelectionField;
  bool get isFragmentSpread => this is SelectionFragmentSpread;
  bool get isInlineFragment => this is SelectionInlineFragment;

  static Selection fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Selection) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    switch (map['runtimeType'] as String) {
      case 'field':
        return SelectionField.fromJson(map);
      case 'fragmentSpread':
        return SelectionFragmentSpread.fromJson(map);
      case 'inlineFragment':
        return SelectionInlineFragment.fromJson(map);
      default:
        throw Exception('Invalid discriminator for Selection.fromJson '
            '${map["runtimeType"]}. Input map: $map');
    }
  }

  Map<String, dynamic> toJson();
}

class SelectionField extends Selection {
  final Field value;

  const SelectionField({
    required this.value,
  }) : super._();

  SelectionField copyWith({
    Field? value,
  }) {
    return SelectionField(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is SelectionField) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static SelectionField fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is SelectionField) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return SelectionField(
      value: Field.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'field',
      'value': value.toJson(),
    };
  }
}

class SelectionFragmentSpread extends Selection {
  final FragmentSpread value;

  const SelectionFragmentSpread({
    required this.value,
  }) : super._();

  SelectionFragmentSpread copyWith({
    FragmentSpread? value,
  }) {
    return SelectionFragmentSpread(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is SelectionFragmentSpread) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static SelectionFragmentSpread fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is SelectionFragmentSpread) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return SelectionFragmentSpread(
      value: FragmentSpread.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'fragmentSpread',
      'value': value.toJson(),
    };
  }
}

class SelectionInlineFragment extends Selection {
  final InlineFragment value;

  const SelectionInlineFragment({
    required this.value,
  }) : super._();

  SelectionInlineFragment copyWith({
    InlineFragment? value,
  }) {
    return SelectionInlineFragment(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is SelectionInlineFragment) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static SelectionInlineFragment fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is SelectionInlineFragment) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return SelectionInlineFragment(
      value: InlineFragment.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'inlineFragment',
      'value': value.toJson(),
    };
  }
}

SettableParser<Field>? _field;

Parser<Field> get field {
  if (_field != null) {
    return _field!;
  }
  _field = undefined();
  final p = (alias.trim().optional() &
          name.trim() &
          arguments.trim().optional() &
          directives.trim().optional() &
          selectionSet.trim().optional())
      .map((l) {
    return Field(
      alias: l[0] as Alias?,
      name: l[1] as String,
      arguments: l[2] as Arguments?,
      directives: l[3] as Directives?,
      selectionSet: l[4] as SelectionSet?,
    );
  }).trim();
  _field!.set(p);
  return _field!;
}

class Field {
  final Alias? alias;
  final String name;
  final Arguments? arguments;
  final Directives? directives;
  final SelectionSet? selectionSet;

  @override
  String toString() {
    return '${alias == null ? "" : "${alias!}"} ${name} ${arguments == null ? "" : "${arguments!}"} ${directives == null ? "" : "${directives!}"} ${selectionSet == null ? "" : "${selectionSet!}"} ';
  }

  const Field({
    required this.name,
    this.alias,
    this.arguments,
    this.directives,
    this.selectionSet,
  });

  Field copyWith({
    Alias? alias,
    String? name,
    Arguments? arguments,
    Directives? directives,
    SelectionSet? selectionSet,
  }) {
    return Field(
      name: name ?? this.name,
      alias: alias ?? this.alias,
      arguments: arguments ?? this.arguments,
      directives: directives ?? this.directives,
      selectionSet: selectionSet ?? this.selectionSet,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Field) {
      return this.alias == other.alias &&
          this.name == other.name &&
          this.arguments == other.arguments &&
          this.directives == other.directives &&
          this.selectionSet == other.selectionSet;
    }
    return false;
  }

  @override
  int get hashCode =>
      hashValues(alias, name, arguments, directives, selectionSet);

  static Field fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Field) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return Field(
      name: map['name'] as String,
      alias: map['alias'] == null ? null : Alias.fromJson(map['alias']),
      arguments: map['arguments'] == null
          ? null
          : Arguments.fromJson(map['arguments']),
      directives: map['directives'] == null
          ? null
          : Directives.fromJson(map['directives']),
      selectionSet: map['selectionSet'] == null
          ? null
          : SelectionSet.fromJson(map['selectionSet']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alias': alias?.toJson(),
      'name': name,
      'arguments': arguments?.toJson(),
      'directives': directives?.toJson(),
      'selectionSet': selectionSet?.toJson(),
    };
  }
}

final alias = (name.trim() & char(':').trim()).map((l) {
  return Alias(
    name: l[0] as String,
  );
});

class Alias {
  final String name;

  @override
  String toString() {
    return '${name} : ';
  }

  const Alias({
    required this.name,
  });

  Alias copyWith({
    String? name,
  }) {
    return Alias(
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Alias) {
      return this.name == other.name;
    }
    return false;
  }

  @override
  int get hashCode => name.hashCode;

  static Alias fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Alias) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return Alias(
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

final arguments =
    (char('(').trim() & argument.trim().plus() & char(')').trim()).map((l) {
  return Arguments(
    arguments: l[1] as List<Argument>,
  );
});

class Arguments {
  final List<Argument> arguments;

  @override
  String toString() {
    return '( ${arguments.join(" ")} ) ';
  }

  const Arguments({
    required this.arguments,
  });

  Arguments copyWith({
    List<Argument>? arguments,
  }) {
    return Arguments(
      arguments: arguments ?? this.arguments,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Arguments) {
      return this.arguments == other.arguments;
    }
    return false;
  }

  @override
  int get hashCode => arguments.hashCode;

  static Arguments fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Arguments) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return Arguments(
      arguments:
          (map['arguments'] as List).map((e) => Argument.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'arguments': arguments.map((e) => e.toJson()).toList(),
    };
  }
}

final argument = (name.trim() & char(':').trim() & value.trim()).map((l) {
  return Argument(
    name: l[0] as String,
    value: l[2] as Value,
  );
});

class Argument {
  final String name;
  final Value value;

  @override
  String toString() {
    return '${name} : ${value} ';
  }

  const Argument({
    required this.name,
    required this.value,
  });

  Argument copyWith({
    String? name,
    Value? value,
  }) {
    return Argument(
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Argument) {
      return this.name == other.name && this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(name, value);

  static Argument fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Argument) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return Argument(
      name: map['name'] as String,
      value: Value.fromJson(map['value']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value.toJson(),
    };
  }
}

SettableParser<Value>? _value;

Parser<Value> get value {
  if (_value != null) {
    return _value!;
  }
  _value = undefined();
  final p = ((variable.map((v) => Value.variable(value: v)) |
          floatValue.map((v) => Value.float(value: v)) |
          intValue.map((v) => Value.int(value: v)) |
          stringValue.map((v) => Value.string(value: v)) |
          booleanValue.map((v) => Value.boolean(value: v)) |
          nullValue.map((v) => Value.null_(value: v)) |
          enumValue.map((v) => Value.enum_(value: v)) |
          listValue.map((v) => Value.list(value: v)) |
          objectValue.map((v) => Value.object(value: v)))
      .cast<Value>());
  _value!.set(p);
  return _value!;
}

abstract class Value {
  const Value._();

  @override
  String toString() {
    return value.toString();
  }

  const factory Value.variable({
    required Variable value,
  }) = ValueVariable;
  const factory Value.float({
    required FloatValue value,
  }) = ValueFloat;
  const factory Value.int({
    required IntValue value,
  }) = ValueInt;
  const factory Value.string({
    required StringValue value,
  }) = ValueString;
  const factory Value.boolean({
    required BooleanValue value,
  }) = ValueBoolean;
  const factory Value.null_({
    required NullValue value,
  }) = ValueNull;
  const factory Value.enum_({
    required EnumValue value,
  }) = ValueEnum;
  const factory Value.list({
    required ListValue value,
  }) = ValueList;
  const factory Value.object({
    required ObjectValue value,
  }) = ValueObject;

  Object get value;

  _T when<_T>({
    required _T Function(Variable value) variable,
    required _T Function(FloatValue value) float,
    required _T Function(IntValue value) int,
    required _T Function(StringValue value) string,
    required _T Function(BooleanValue value) boolean,
    required _T Function(NullValue value) null_,
    required _T Function(EnumValue value) enum_,
    required _T Function(ListValue value) list,
    required _T Function(ObjectValue value) object,
  }) {
    final v = this;
    if (v is ValueVariable) {
      return variable(v.value);
    } else if (v is ValueFloat) {
      return float(v.value);
    } else if (v is ValueInt) {
      return int(v.value);
    } else if (v is ValueString) {
      return string(v.value);
    } else if (v is ValueBoolean) {
      return boolean(v.value);
    } else if (v is ValueNull) {
      return null_(v.value);
    } else if (v is ValueEnum) {
      return enum_(v.value);
    } else if (v is ValueList) {
      return list(v.value);
    } else if (v is ValueObject) {
      return object(v.value);
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(Variable value)? variable,
    _T Function(FloatValue value)? float,
    _T Function(IntValue value)? int,
    _T Function(StringValue value)? string,
    _T Function(BooleanValue value)? boolean,
    _T Function(NullValue value)? null_,
    _T Function(EnumValue value)? enum_,
    _T Function(ListValue value)? list,
    _T Function(ObjectValue value)? object,
  }) {
    final v = this;
    if (v is ValueVariable) {
      return variable != null ? variable(v.value) : orElse.call();
    } else if (v is ValueFloat) {
      return float != null ? float(v.value) : orElse.call();
    } else if (v is ValueInt) {
      return int != null ? int(v.value) : orElse.call();
    } else if (v is ValueString) {
      return string != null ? string(v.value) : orElse.call();
    } else if (v is ValueBoolean) {
      return boolean != null ? boolean(v.value) : orElse.call();
    } else if (v is ValueNull) {
      return null_ != null ? null_(v.value) : orElse.call();
    } else if (v is ValueEnum) {
      return enum_ != null ? enum_(v.value) : orElse.call();
    } else if (v is ValueList) {
      return list != null ? list(v.value) : orElse.call();
    } else if (v is ValueObject) {
      return object != null ? object(v.value) : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(ValueVariable value) variable,
    required _T Function(ValueFloat value) float,
    required _T Function(ValueInt value) int,
    required _T Function(ValueString value) string,
    required _T Function(ValueBoolean value) boolean,
    required _T Function(ValueNull value) null_,
    required _T Function(ValueEnum value) enum_,
    required _T Function(ValueList value) list,
    required _T Function(ValueObject value) object,
  }) {
    final v = this;
    if (v is ValueVariable) {
      return variable(v);
    } else if (v is ValueFloat) {
      return float(v);
    } else if (v is ValueInt) {
      return int(v);
    } else if (v is ValueString) {
      return string(v);
    } else if (v is ValueBoolean) {
      return boolean(v);
    } else if (v is ValueNull) {
      return null_(v);
    } else if (v is ValueEnum) {
      return enum_(v);
    } else if (v is ValueList) {
      return list(v);
    } else if (v is ValueObject) {
      return object(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(ValueVariable value)? variable,
    _T Function(ValueFloat value)? float,
    _T Function(ValueInt value)? int,
    _T Function(ValueString value)? string,
    _T Function(ValueBoolean value)? boolean,
    _T Function(ValueNull value)? null_,
    _T Function(ValueEnum value)? enum_,
    _T Function(ValueList value)? list,
    _T Function(ValueObject value)? object,
  }) {
    final v = this;
    if (v is ValueVariable) {
      return variable != null ? variable(v) : orElse.call();
    } else if (v is ValueFloat) {
      return float != null ? float(v) : orElse.call();
    } else if (v is ValueInt) {
      return int != null ? int(v) : orElse.call();
    } else if (v is ValueString) {
      return string != null ? string(v) : orElse.call();
    } else if (v is ValueBoolean) {
      return boolean != null ? boolean(v) : orElse.call();
    } else if (v is ValueNull) {
      return null_ != null ? null_(v) : orElse.call();
    } else if (v is ValueEnum) {
      return enum_ != null ? enum_(v) : orElse.call();
    } else if (v is ValueList) {
      return list != null ? list(v) : orElse.call();
    } else if (v is ValueObject) {
      return object != null ? object(v) : orElse.call();
    }
    throw Exception();
  }

  bool get isVariable => this is ValueVariable;
  bool get isFloat => this is ValueFloat;
  bool get isInt => this is ValueInt;
  bool get isString => this is ValueString;
  bool get isBoolean => this is ValueBoolean;
  bool get isNull => this is ValueNull;
  bool get isEnum => this is ValueEnum;
  bool get isList => this is ValueList;
  bool get isObject => this is ValueObject;

  static Value fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Value) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    switch (map['runtimeType'] as String) {
      case 'variable':
        return ValueVariable.fromJson(map);
      case 'float':
        return ValueFloat.fromJson(map);
      case 'int':
        return ValueInt.fromJson(map);
      case 'string':
        return ValueString.fromJson(map);
      case 'boolean':
        return ValueBoolean.fromJson(map);
      case 'null':
        return ValueNull.fromJson(map);
      case 'enum':
        return ValueEnum.fromJson(map);
      case 'list':
        return ValueList.fromJson(map);
      case 'object':
        return ValueObject.fromJson(map);
      default:
        throw Exception('Invalid discriminator for Value.fromJson '
            '${map["runtimeType"]}. Input map: $map');
    }
  }

  Map<String, dynamic> toJson();
}

class ValueVariable extends Value {
  final Variable value;

  const ValueVariable({
    required this.value,
  }) : super._();

  ValueVariable copyWith({
    Variable? value,
  }) {
    return ValueVariable(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ValueVariable) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ValueVariable fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ValueVariable) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ValueVariable(
      value: Variable.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'variable',
      'value': value.toJson(),
    };
  }
}

class ValueFloat extends Value {
  final FloatValue value;

  const ValueFloat({
    required this.value,
  }) : super._();

  ValueFloat copyWith({
    FloatValue? value,
  }) {
    return ValueFloat(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ValueFloat) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ValueFloat fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ValueFloat) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ValueFloat(
      value: FloatValue.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'float',
      'value': value.toJson(),
    };
  }
}

class ValueInt extends Value {
  final IntValue value;

  const ValueInt({
    required this.value,
  }) : super._();

  ValueInt copyWith({
    IntValue? value,
  }) {
    return ValueInt(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ValueInt) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ValueInt fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ValueInt) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ValueInt(
      value: IntValue.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'int',
      'value': value.toJson(),
    };
  }
}

class ValueString extends Value {
  final StringValue value;

  const ValueString({
    required this.value,
  }) : super._();

  ValueString copyWith({
    StringValue? value,
  }) {
    return ValueString(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ValueString) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ValueString fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ValueString) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ValueString(
      value: StringValue.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'string',
      'value': value.toJson(),
    };
  }
}

class ValueBoolean extends Value {
  final BooleanValue value;

  const ValueBoolean({
    required this.value,
  }) : super._();

  ValueBoolean copyWith({
    BooleanValue? value,
  }) {
    return ValueBoolean(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ValueBoolean) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ValueBoolean fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ValueBoolean) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ValueBoolean(
      value: BooleanValue.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'boolean',
      'value': value.toJson(),
    };
  }
}

class ValueNull extends Value {
  final NullValue value;

  const ValueNull({
    required this.value,
  }) : super._();

  ValueNull copyWith({
    NullValue? value,
  }) {
    return ValueNull(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ValueNull) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ValueNull fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ValueNull) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ValueNull(
      value: NullValue.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'null',
      'value': value.toJson(),
    };
  }
}

class ValueEnum extends Value {
  final EnumValue value;

  const ValueEnum({
    required this.value,
  }) : super._();

  ValueEnum copyWith({
    EnumValue? value,
  }) {
    return ValueEnum(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ValueEnum) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ValueEnum fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ValueEnum) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ValueEnum(
      value: EnumValue.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'enum',
      'value': value.toJson(),
    };
  }
}

class ValueList extends Value {
  final ListValue value;

  const ValueList({
    required this.value,
  }) : super._();

  ValueList copyWith({
    ListValue? value,
  }) {
    return ValueList(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ValueList) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ValueList fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ValueList) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ValueList(
      value: ListValue.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'list',
      'value': value.toJson(),
    };
  }
}

class ValueObject extends Value {
  final ObjectValue value;

  const ValueObject({
    required this.value,
  }) : super._();

  ValueObject copyWith({
    ObjectValue? value,
  }) {
    return ValueObject(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ValueObject) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ValueObject fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ValueObject) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ValueObject(
      value: ObjectValue.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'object',
      'value': value.toJson(),
    };
  }
}

final variable = (string('\$').trim() & name.trim()).map((l) {
  return Variable(
    name: l[1] as String,
  );
});

class Variable {
  final String name;

  @override
  String toString() {
    return '\$ ${name} ';
  }

  const Variable({
    required this.name,
  });

  Variable copyWith({
    String? name,
  }) {
    return Variable(
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Variable) {
      return this.name == other.name;
    }
    return false;
  }

  @override
  int get hashCode => name.hashCode;

  static Variable fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Variable) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return Variable(
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

final booleanValue = ((string('true').map((_) => BooleanValue.true_) |
        string('false').map((_) => BooleanValue.false_))
    .cast<BooleanValue>());

class BooleanValue {
  final String _inner;

  const BooleanValue._(this._inner);

  static const true_ = BooleanValue._('true');
  static const false_ = BooleanValue._('false');

  static const values = [
    BooleanValue.true_,
    BooleanValue.false_,
  ];

  static BooleanValue fromJson(Object? json) {
    if (json == null) {
      throw Error();
    }
    for (final v in values) {
      if (json.toString() == v._inner) {
        return v;
      }
    }
    throw Error();
  }

  String toJson() {
    return _inner;
  }

  @override
  String toString() {
    return _inner;
  }

  @override
  bool operator ==(Object other) {
    return other is BooleanValue &&
        other.runtimeType == runtimeType &&
        other._inner == _inner;
  }

  @override
  int get hashCode => _inner.hashCode;

  bool get isTrue_ => this == BooleanValue.true_;
  bool get isFalse_ => this == BooleanValue.false_;

  _T when<_T>({
    required _T Function() true_,
    required _T Function() false_,
  }) {
    switch (this._inner) {
      case 'true':
        return true_();
      case 'false':
        return false_();
    }
    throw Error();
  }

  _T maybeWhen<_T>({
    _T Function()? true_,
    _T Function()? false_,
    required _T Function() orElse,
  }) {
    _T Function()? c;
    switch (this._inner) {
      case 'true':
        c = true_;
        break;
      case 'false':
        c = false_;
        break;
    }
    return (c ?? orElse).call();
  }
}

final nullValue = (string('null')).map((l) {
  return NullValue();
});

class NullValue {
  @override
  String toString() {
    return 'null';
  }

  const NullValue();

  NullValue copyWith() {
    return const NullValue();
  }

  @override
  bool operator ==(Object other) {
    if (other is NullValue) {
      return true;
    }
    return false;
  }

  @override
  int get hashCode => const NullValue().hashCode;

  static NullValue fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is NullValue) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return const NullValue();
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}

final enumValue = (name
        .trim()
        .butNot((booleanValue.trim().map((v) => Name.boolean(value: v)) |
                nullValue.trim().map((v) => Name.null_(value: v)))
            .cast<Name>()
            .trim())
        .trim())
    .map((l) {
  return EnumValue(
    name: l as String,
  );
});

class EnumValue {
  final String name;

  @override
  String toString() {
    return '${name} ';
  }

  const EnumValue({
    required this.name,
  });

  EnumValue copyWith({
    String? name,
  }) {
    return EnumValue(
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is EnumValue) {
      return this.name == other.name;
    }
    return false;
  }

  @override
  int get hashCode => name.hashCode;

  static EnumValue fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is EnumValue) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return EnumValue(
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

abstract class Name {
  const Name._();

  @override
  String toString() {
    return value.toString();
  }

  const factory Name.boolean({
    required BooleanValue value,
  }) = NameBoolean;
  const factory Name.null_({
    required NullValue value,
  }) = NameNull;

  Object get value;

  _T when<_T>({
    required _T Function(BooleanValue value) boolean,
    required _T Function(NullValue value) null_,
  }) {
    final v = this;
    if (v is NameBoolean) {
      return boolean(v.value);
    } else if (v is NameNull) {
      return null_(v.value);
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(BooleanValue value)? boolean,
    _T Function(NullValue value)? null_,
  }) {
    final v = this;
    if (v is NameBoolean) {
      return boolean != null ? boolean(v.value) : orElse.call();
    } else if (v is NameNull) {
      return null_ != null ? null_(v.value) : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(NameBoolean value) boolean,
    required _T Function(NameNull value) null_,
  }) {
    final v = this;
    if (v is NameBoolean) {
      return boolean(v);
    } else if (v is NameNull) {
      return null_(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(NameBoolean value)? boolean,
    _T Function(NameNull value)? null_,
  }) {
    final v = this;
    if (v is NameBoolean) {
      return boolean != null ? boolean(v) : orElse.call();
    } else if (v is NameNull) {
      return null_ != null ? null_(v) : orElse.call();
    }
    throw Exception();
  }

  bool get isBoolean => this is NameBoolean;
  bool get isNull => this is NameNull;

  static Name fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Name) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    switch (map['runtimeType'] as String) {
      case 'boolean':
        return NameBoolean.fromJson(map);
      case 'null':
        return NameNull.fromJson(map);
      default:
        throw Exception('Invalid discriminator for Name.fromJson '
            '${map["runtimeType"]}. Input map: $map');
    }
  }

  Map<String, dynamic> toJson();
}

class NameBoolean extends Name {
  final BooleanValue value;

  const NameBoolean({
    required this.value,
  }) : super._();

  NameBoolean copyWith({
    BooleanValue? value,
  }) {
    return NameBoolean(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is NameBoolean) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static NameBoolean fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is NameBoolean) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return NameBoolean(
      value: BooleanValue.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'boolean',
      'value': value.toJson(),
    };
  }
}

class NameNull extends Name {
  final NullValue value;

  const NameNull({
    required this.value,
  }) : super._();

  NameNull copyWith({
    NullValue? value,
  }) {
    return NameNull(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is NameNull) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static NameNull fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is NameNull) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return NameNull(
      value: NullValue.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'null',
      'value': value.toJson(),
    };
  }
}

final fragmentSpread =
    (string('...').trim() & fragmentName.trim() & string('').trim()).map((l) {
  return FragmentSpread(
    name: l[1] as FragmentName,
  );
});

class FragmentSpread {
  final FragmentName name;

  @override
  String toString() {
    return '... ${name}  ';
  }

  const FragmentSpread({
    required this.name,
  });

  FragmentSpread copyWith({
    FragmentName? name,
  }) {
    return FragmentSpread(
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is FragmentSpread) {
      return this.name == other.name;
    }
    return false;
  }

  @override
  int get hashCode => name.hashCode;

  static FragmentSpread fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is FragmentSpread) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return FragmentSpread(
      name: FragmentName.fromJson(map['name']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name.toJson(),
    };
  }
}

final fragmentName = (name.trim().butNot(string('on').trim()).trim()).map((l) {
  return FragmentName(
    name: l as String,
  );
}).trim();

class FragmentName {
  final String name;

  @override
  String toString() {
    return '${name} ';
  }

  const FragmentName({
    required this.name,
  });

  FragmentName copyWith({
    String? name,
  }) {
    return FragmentName(
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is FragmentName) {
      return this.name == other.name;
    }
    return false;
  }

  @override
  int get hashCode => name.hashCode;

  static FragmentName fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is FragmentName) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return FragmentName(
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

final directives =
    (char('@').trim() & name.trim() & arguments.trim().optional()).map((l) {
  return Directives(
    name: l[1] as String,
    arguments: l[2] as Arguments?,
  );
});

class Directives {
  final String name;
  final Arguments? arguments;

  @override
  String toString() {
    return '@ ${name} ${arguments == null ? "" : "${arguments!}"} ';
  }

  const Directives({
    required this.name,
    this.arguments,
  });

  Directives copyWith({
    String? name,
    Arguments? arguments,
  }) {
    return Directives(
      name: name ?? this.name,
      arguments: arguments ?? this.arguments,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Directives) {
      return this.name == other.name && this.arguments == other.arguments;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(name, arguments);

  static Directives fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Directives) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return Directives(
      name: map['name'] as String,
      arguments: map['arguments'] == null
          ? null
          : Arguments.fromJson(map['arguments']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'arguments': arguments?.toJson(),
    };
  }
}

final variableDefinitions =
    (char('(').trim() & variableDefinition.trim().plus() & char(')').trim())
        .map((l) {
  return VariableDefinitions(
    definitions: l[1] as List<VariableDefinition>,
  );
});

class VariableDefinitions {
  final List<VariableDefinition> definitions;

  @override
  String toString() {
    return '( ${definitions.join(" ")} ) ';
  }

  const VariableDefinitions({
    required this.definitions,
  });

  VariableDefinitions copyWith({
    List<VariableDefinition>? definitions,
  }) {
    return VariableDefinitions(
      definitions: definitions ?? this.definitions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is VariableDefinitions) {
      return this.definitions == other.definitions;
    }
    return false;
  }

  @override
  int get hashCode => definitions.hashCode;

  static VariableDefinitions fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is VariableDefinitions) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return VariableDefinitions(
      definitions: (map['definitions'] as List)
          .map((e) => VariableDefinition.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'definitions': definitions.map((e) => e.toJson()).toList(),
    };
  }
}

final variableDefinition = (variable.trim() &
        char(':').trim() &
        graphqlType.trim() &
        defaultValue.trim().optional())
    .map((l) {
  return VariableDefinition(
    variable: l[0] as Variable,
    type: l[2] as GraphqlType,
    defaultValue: l[3] as DefaultValue?,
  );
});

class VariableDefinition {
  final Variable variable;
  final GraphqlType type;
  final DefaultValue? defaultValue;

  @override
  String toString() {
    return '${variable} : ${type} ${defaultValue == null ? "" : "${defaultValue!}"} ';
  }

  const VariableDefinition({
    required this.variable,
    required this.type,
    this.defaultValue,
  });

  VariableDefinition copyWith({
    Variable? variable,
    GraphqlType? type,
    DefaultValue? defaultValue,
  }) {
    return VariableDefinition(
      variable: variable ?? this.variable,
      type: type ?? this.type,
      defaultValue: defaultValue ?? this.defaultValue,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is VariableDefinition) {
      return this.variable == other.variable &&
          this.type == other.type &&
          this.defaultValue == other.defaultValue;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(variable, type, defaultValue);

  static VariableDefinition fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is VariableDefinition) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return VariableDefinition(
      variable: Variable.fromJson(map['variable']),
      type: GraphqlType.fromJson(map['type']),
      defaultValue: map['defaultValue'] == null
          ? null
          : DefaultValue.fromJson(map['defaultValue']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'variable': variable.toJson(),
      'type': type.toJson(),
      'defaultValue': defaultValue?.toJson(),
    };
  }
}

SettableParser<GraphqlType>? _graphqlType;

Parser<GraphqlType> get graphqlType {
  if (_graphqlType != null) {
    return _graphqlType!;
  }
  _graphqlType = undefined();
  final p = ((name.map((v) => GraphqlTypeValue.named(value: v)) |
                  listType.map((v) => GraphqlTypeValue.list(value: v)))
              .cast<GraphqlTypeValue>()
              .trim() &
          char('!').trim().optional())
      .map((l) {
    return GraphqlType(
      value: l[0] as GraphqlTypeValue,
      notNull: l[1] as String?,
    );
  });
  _graphqlType!.set(p);
  return _graphqlType!;
}

class GraphqlType {
  final GraphqlTypeValue value;
  final String? notNull;

  @override
  String toString() {
    return '${value} ${notNull == null ? "" : "${notNull!}"} ';
  }

  const GraphqlType({
    required this.value,
    this.notNull,
  });

  GraphqlType copyWith({
    GraphqlTypeValue? value,
    String? notNull,
  }) {
    return GraphqlType(
      value: value ?? this.value,
      notNull: notNull ?? this.notNull,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is GraphqlType) {
      return this.value == other.value && this.notNull == other.notNull;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(value, notNull);

  static GraphqlType fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is GraphqlType) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return GraphqlType(
      value: GraphqlTypeValue.fromJson(map['value']),
      notNull: map['notNull'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value.toJson(),
      'notNull': notNull,
    };
  }
}

abstract class GraphqlTypeValue {
  const GraphqlTypeValue._();

  @override
  String toString() {
    return value.toString();
  }

  const factory GraphqlTypeValue.named({
    required String value,
  }) = GraphqlTypeNamed;
  const factory GraphqlTypeValue.list({
    required ListType value,
  }) = GraphqlTypeList;

  Object get value;

  _T when<_T>({
    required _T Function(String value) named,
    required _T Function(ListType value) list,
  }) {
    final v = this;
    if (v is GraphqlTypeNamed) {
      return named(v.value);
    } else if (v is GraphqlTypeList) {
      return list(v.value);
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(String value)? named,
    _T Function(ListType value)? list,
  }) {
    final v = this;
    if (v is GraphqlTypeNamed) {
      return named != null ? named(v.value) : orElse.call();
    } else if (v is GraphqlTypeList) {
      return list != null ? list(v.value) : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(GraphqlTypeNamed value) named,
    required _T Function(GraphqlTypeList value) list,
  }) {
    final v = this;
    if (v is GraphqlTypeNamed) {
      return named(v);
    } else if (v is GraphqlTypeList) {
      return list(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(GraphqlTypeNamed value)? named,
    _T Function(GraphqlTypeList value)? list,
  }) {
    final v = this;
    if (v is GraphqlTypeNamed) {
      return named != null ? named(v) : orElse.call();
    } else if (v is GraphqlTypeList) {
      return list != null ? list(v) : orElse.call();
    }
    throw Exception();
  }

  bool get isNamed => this is GraphqlTypeNamed;
  bool get isList => this is GraphqlTypeList;

  static GraphqlTypeValue fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is GraphqlTypeValue) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    switch (map['runtimeType'] as String) {
      case 'named':
        return GraphqlTypeNamed.fromJson(map);
      case 'list':
        return GraphqlTypeList.fromJson(map);
      default:
        throw Exception('Invalid discriminator for GraphqlTypeValue.fromJson '
            '${map["runtimeType"]}. Input map: $map');
    }
  }

  Map<String, dynamic> toJson();
}

class GraphqlTypeNamed extends GraphqlTypeValue {
  final String value;

  const GraphqlTypeNamed({
    required this.value,
  }) : super._();

  GraphqlTypeNamed copyWith({
    String? value,
  }) {
    return GraphqlTypeNamed(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is GraphqlTypeNamed) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static GraphqlTypeNamed fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is GraphqlTypeNamed) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return GraphqlTypeNamed(
      value: map['value'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'named',
      'value': value,
    };
  }
}

class GraphqlTypeList extends GraphqlTypeValue {
  final ListType value;

  const GraphqlTypeList({
    required this.value,
  }) : super._();

  GraphqlTypeList copyWith({
    ListType? value,
  }) {
    return GraphqlTypeList(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is GraphqlTypeList) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static GraphqlTypeList fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is GraphqlTypeList) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return GraphqlTypeList(
      value: ListType.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'list',
      'value': value.toJson(),
    };
  }
}

SettableParser<ListType>? _listType;

Parser<ListType> get listType {
  if (_listType != null) {
    return _listType!;
  }
  _listType = undefined();
  final p = (char('[').trim() & graphqlType.trim() & char(']').trim()).map((l) {
    return ListType(
      type: l[1] as GraphqlType,
    );
  });
  _listType!.set(p);
  return _listType!;
}

class ListType {
  final GraphqlType type;

  @override
  String toString() {
    return '[ ${type} ] ';
  }

  const ListType({
    required this.type,
  });

  ListType copyWith({
    GraphqlType? type,
  }) {
    return ListType(
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ListType) {
      return this.type == other.type;
    }
    return false;
  }

  @override
  int get hashCode => type.hashCode;

  static ListType fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ListType) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ListType(
      type: GraphqlType.fromJson(map['type']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toJson(),
    };
  }
}

final defaultValue = (char('=').trim() & value.trim()).map((l) {
  return DefaultValue(
    value: l[1] as Value,
  );
});

class DefaultValue {
  final Value value;

  @override
  String toString() {
    return '= ${value} ';
  }

  const DefaultValue({
    required this.value,
  });

  DefaultValue copyWith({
    Value? value,
  }) {
    return DefaultValue(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is DefaultValue) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static DefaultValue fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is DefaultValue) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return DefaultValue(
      value: Value.fromJson(map['value']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value.toJson(),
    };
  }
}

SettableParser<ListValue>? _listValue;

Parser<ListValue> get listValue {
  if (_listValue != null) {
    return _listValue!;
  }
  _listValue = undefined();
  final p =
      (char('[').trim() & value.trim().star() & char(']').trim()).map((l) {
    return ListValue(
      values: l[1] as List<Value>?,
    );
  });
  _listValue!.set(p);
  return _listValue!;
}

class ListValue {
  final List<Value>? values;

  @override
  String toString() {
    return '[ ${values == null ? "" : "${values!.join(" ")}"} ] ';
  }

  const ListValue({
    this.values,
  });

  ListValue copyWith({
    List<Value>? values,
  }) {
    return ListValue(
      values: values ?? this.values,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ListValue) {
      return this.values == other.values;
    }
    return false;
  }

  @override
  int get hashCode => values.hashCode;

  static ListValue fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ListValue) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ListValue(
      values: (map['values'] as List?)?.map((e) => Value.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'values': values?.map((e) => e.toJson()).toList(),
    };
  }
}

final objectValue =
    (char('{').trim() & string('').trim() & char('}').trim()).map((l) {
  return ObjectValue();
});

class ObjectValue {
  @override
  String toString() {
    return '{  } ';
  }

  const ObjectValue();

  ObjectValue copyWith() {
    return const ObjectValue();
  }

  @override
  bool operator ==(Object other) {
    if (other is ObjectValue) {
      return true;
    }
    return false;
  }

  @override
  int get hashCode => const ObjectValue().hashCode;

  static ObjectValue fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ObjectValue) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return const ObjectValue();
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}

final objectField = (name.trim() & char(':').trim() & value.trim()).map((l) {
  return ObjectField(
    name: l[0] as String,
    value: l[2] as Value,
  );
});

class ObjectField {
  final String name;
  final Value value;

  @override
  String toString() {
    return '${name} : ${value} ';
  }

  const ObjectField({
    required this.name,
    required this.value,
  });

  ObjectField copyWith({
    String? name,
    Value? value,
  }) {
    return ObjectField(
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ObjectField) {
      return this.name == other.name && this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(name, value);

  static ObjectField fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ObjectField) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ObjectField(
      name: map['name'] as String,
      value: Value.fromJson(map['value']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value.toJson(),
    };
  }
}

SettableParser<InlineFragment>? _inlineFragment;

Parser<InlineFragment> get inlineFragment {
  if (_inlineFragment != null) {
    return _inlineFragment!;
  }
  _inlineFragment = undefined();
  final p = (string('...').trim() &
          typeCondition.trim().optional() &
          directives.trim().optional() &
          selectionSet.trim())
      .map((l) {
    return InlineFragment(
      condition: l[1] as TypeCondition?,
      directives: l[2] as Directives?,
      selection: l[3] as SelectionSet,
    );
  });
  _inlineFragment!.set(p);
  return _inlineFragment!;
}

class InlineFragment {
  final TypeCondition? condition;
  final Directives? directives;
  final SelectionSet selection;

  @override
  String toString() {
    return '... ${condition == null ? "" : "${condition!}"} ${directives == null ? "" : "${directives!}"} ${selection} ';
  }

  const InlineFragment({
    required this.selection,
    this.condition,
    this.directives,
  });

  InlineFragment copyWith({
    TypeCondition? condition,
    Directives? directives,
    SelectionSet? selection,
  }) {
    return InlineFragment(
      selection: selection ?? this.selection,
      condition: condition ?? this.condition,
      directives: directives ?? this.directives,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is InlineFragment) {
      return this.condition == other.condition &&
          this.directives == other.directives &&
          this.selection == other.selection;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(condition, directives, selection);

  static InlineFragment fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is InlineFragment) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return InlineFragment(
      selection: SelectionSet.fromJson(map['selection']),
      condition: map['condition'] == null
          ? null
          : TypeCondition.fromJson(map['condition']),
      directives: map['directives'] == null
          ? null
          : Directives.fromJson(map['directives']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'condition': condition?.toJson(),
      'directives': directives?.toJson(),
      'selection': selection.toJson(),
    };
  }
}

final typeCondition = (string('on').trim() & name.trim()).map((l) {
  return TypeCondition(
    typeName: l[1] as String,
  );
});

class TypeCondition {
  final String typeName;

  @override
  String toString() {
    return 'on ${typeName} ';
  }

  const TypeCondition({
    required this.typeName,
  });

  TypeCondition copyWith({
    String? typeName,
  }) {
    return TypeCondition(
      typeName: typeName ?? this.typeName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is TypeCondition) {
      return this.typeName == other.typeName;
    }
    return false;
  }

  @override
  int get hashCode => typeName.hashCode;

  static TypeCondition fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is TypeCondition) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return TypeCondition(
      typeName: map['typeName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'typeName': typeName,
    };
  }
}

final fragmentDefinition = (string('fragment').trim() &
        fragmentName.trim() &
        typeCondition.trim() &
        directives.trim().optional() &
        selectionSet.trim())
    .map((l) {
  return FragmentDefinition(
    name: l[1] as FragmentName,
    typeCondition: l[2] as TypeCondition,
    directives: l[3] as Directives?,
    selectionSet: l[4] as SelectionSet,
  );
});

class FragmentDefinition {
  final FragmentName name;
  final TypeCondition typeCondition;
  final Directives? directives;
  final SelectionSet selectionSet;

  @override
  String toString() {
    return 'fragment ${name} ${typeCondition} ${directives == null ? "" : "${directives!}"} ${selectionSet} ';
  }

  const FragmentDefinition({
    required this.name,
    required this.typeCondition,
    required this.selectionSet,
    this.directives,
  });

  FragmentDefinition copyWith({
    FragmentName? name,
    TypeCondition? typeCondition,
    Directives? directives,
    SelectionSet? selectionSet,
  }) {
    return FragmentDefinition(
      name: name ?? this.name,
      typeCondition: typeCondition ?? this.typeCondition,
      selectionSet: selectionSet ?? this.selectionSet,
      directives: directives ?? this.directives,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is FragmentDefinition) {
      return this.name == other.name &&
          this.typeCondition == other.typeCondition &&
          this.directives == other.directives &&
          this.selectionSet == other.selectionSet;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(name, typeCondition, directives, selectionSet);

  static FragmentDefinition fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is FragmentDefinition) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return FragmentDefinition(
      name: FragmentName.fromJson(map['name']),
      typeCondition: TypeCondition.fromJson(map['typeCondition']),
      selectionSet: SelectionSet.fromJson(map['selectionSet']),
      directives: map['directives'] == null
          ? null
          : Directives.fromJson(map['directives']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name.toJson(),
      'typeCondition': typeCondition.toJson(),
      'directives': directives?.toJson(),
      'selectionSet': selectionSet.toJson(),
    };
  }
}

final typeSystemDefinition =
    ((schemaDefinition.map((v) => TypeSystemDefinition.schema(value: v)) |
            typeDefinition.map((v) => TypeSystemDefinition.type(value: v)) |
            directiveDefinition
                .map((v) => TypeSystemDefinition.directive(value: v)))
        .cast<TypeSystemDefinition>());

abstract class TypeSystemDefinition {
  const TypeSystemDefinition._();

  @override
  String toString() {
    return value.toString();
  }

  const factory TypeSystemDefinition.schema({
    required SchemaDefinition value,
  }) = TypeSystemDefinitionSchema;
  const factory TypeSystemDefinition.type({
    required TypeDefinition value,
  }) = TypeSystemDefinitionType;
  const factory TypeSystemDefinition.directive({
    required DirectiveDefinition value,
  }) = TypeSystemDefinitionDirective;

  Object get value;

  _T when<_T>({
    required _T Function(SchemaDefinition value) schema,
    required _T Function(TypeDefinition value) type,
    required _T Function(DirectiveDefinition value) directive,
  }) {
    final v = this;
    if (v is TypeSystemDefinitionSchema) {
      return schema(v.value);
    } else if (v is TypeSystemDefinitionType) {
      return type(v.value);
    } else if (v is TypeSystemDefinitionDirective) {
      return directive(v.value);
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(SchemaDefinition value)? schema,
    _T Function(TypeDefinition value)? type,
    _T Function(DirectiveDefinition value)? directive,
  }) {
    final v = this;
    if (v is TypeSystemDefinitionSchema) {
      return schema != null ? schema(v.value) : orElse.call();
    } else if (v is TypeSystemDefinitionType) {
      return type != null ? type(v.value) : orElse.call();
    } else if (v is TypeSystemDefinitionDirective) {
      return directive != null ? directive(v.value) : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(TypeSystemDefinitionSchema value) schema,
    required _T Function(TypeSystemDefinitionType value) type,
    required _T Function(TypeSystemDefinitionDirective value) directive,
  }) {
    final v = this;
    if (v is TypeSystemDefinitionSchema) {
      return schema(v);
    } else if (v is TypeSystemDefinitionType) {
      return type(v);
    } else if (v is TypeSystemDefinitionDirective) {
      return directive(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(TypeSystemDefinitionSchema value)? schema,
    _T Function(TypeSystemDefinitionType value)? type,
    _T Function(TypeSystemDefinitionDirective value)? directive,
  }) {
    final v = this;
    if (v is TypeSystemDefinitionSchema) {
      return schema != null ? schema(v) : orElse.call();
    } else if (v is TypeSystemDefinitionType) {
      return type != null ? type(v) : orElse.call();
    } else if (v is TypeSystemDefinitionDirective) {
      return directive != null ? directive(v) : orElse.call();
    }
    throw Exception();
  }

  bool get isSchema => this is TypeSystemDefinitionSchema;
  bool get isType => this is TypeSystemDefinitionType;
  bool get isDirective => this is TypeSystemDefinitionDirective;

  static TypeSystemDefinition fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is TypeSystemDefinition) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    switch (map['runtimeType'] as String) {
      case 'schema':
        return TypeSystemDefinitionSchema.fromJson(map);
      case 'type':
        return TypeSystemDefinitionType.fromJson(map);
      case 'directive':
        return TypeSystemDefinitionDirective.fromJson(map);
      default:
        throw Exception(
            'Invalid discriminator for TypeSystemDefinition.fromJson '
            '${map["runtimeType"]}. Input map: $map');
    }
  }

  Map<String, dynamic> toJson();
}

class TypeSystemDefinitionSchema extends TypeSystemDefinition {
  final SchemaDefinition value;

  const TypeSystemDefinitionSchema({
    required this.value,
  }) : super._();

  TypeSystemDefinitionSchema copyWith({
    SchemaDefinition? value,
  }) {
    return TypeSystemDefinitionSchema(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is TypeSystemDefinitionSchema) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static TypeSystemDefinitionSchema fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is TypeSystemDefinitionSchema) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return TypeSystemDefinitionSchema(
      value: SchemaDefinition.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'schema',
      'value': value.toJson(),
    };
  }
}

class TypeSystemDefinitionType extends TypeSystemDefinition {
  final TypeDefinition value;

  const TypeSystemDefinitionType({
    required this.value,
  }) : super._();

  TypeSystemDefinitionType copyWith({
    TypeDefinition? value,
  }) {
    return TypeSystemDefinitionType(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is TypeSystemDefinitionType) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static TypeSystemDefinitionType fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is TypeSystemDefinitionType) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return TypeSystemDefinitionType(
      value: TypeDefinition.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'type',
      'value': value.toJson(),
    };
  }
}

class TypeSystemDefinitionDirective extends TypeSystemDefinition {
  final DirectiveDefinition value;

  const TypeSystemDefinitionDirective({
    required this.value,
  }) : super._();

  TypeSystemDefinitionDirective copyWith({
    DirectiveDefinition? value,
  }) {
    return TypeSystemDefinitionDirective(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is TypeSystemDefinitionDirective) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static TypeSystemDefinitionDirective fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is TypeSystemDefinitionDirective) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return TypeSystemDefinitionDirective(
      value: DirectiveDefinition.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'directive',
      'value': value.toJson(),
    };
  }
}

final schemaDefinition = (string('schema').trim() &
        directives.trim().optional() &
        char('{').trim() &
        operationTypeDefinition.trim().plus() &
        char('}').trim())
    .map((l) {
  return SchemaDefinition(
    directives: l[1] as Directives?,
    operationTypes: l[3] as List<OperationTypeDefinition>,
  );
});

class SchemaDefinition {
  final Directives? directives;
  final List<OperationTypeDefinition> operationTypes;

  @override
  String toString() {
    return 'schema ${directives == null ? "" : "${directives!}"} { ${operationTypes.join(" ")} } ';
  }

  const SchemaDefinition({
    required this.operationTypes,
    this.directives,
  });

  SchemaDefinition copyWith({
    Directives? directives,
    List<OperationTypeDefinition>? operationTypes,
  }) {
    return SchemaDefinition(
      operationTypes: operationTypes ?? this.operationTypes,
      directives: directives ?? this.directives,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is SchemaDefinition) {
      return this.directives == other.directives &&
          this.operationTypes == other.operationTypes;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(directives, operationTypes);

  static SchemaDefinition fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is SchemaDefinition) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return SchemaDefinition(
      operationTypes: (map['operationTypes'] as List)
          .map((e) => OperationTypeDefinition.fromJson(e))
          .toList(),
      directives: map['directives'] == null
          ? null
          : Directives.fromJson(map['directives']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'directives': directives?.toJson(),
      'operationTypes': operationTypes.map((e) => e.toJson()).toList(),
    };
  }
}

final operationTypeDefinition =
    (operationType.trim() & char(':').trim() & name.trim()).map((l) {
  return OperationTypeDefinition(
    type: l[0] as OperationType,
    typeName: l[2] as String,
  );
});

class OperationTypeDefinition {
  final OperationType type;
  final String typeName;

  @override
  String toString() {
    return '${type} : ${typeName} ';
  }

  const OperationTypeDefinition({
    required this.type,
    required this.typeName,
  });

  OperationTypeDefinition copyWith({
    OperationType? type,
    String? typeName,
  }) {
    return OperationTypeDefinition(
      type: type ?? this.type,
      typeName: typeName ?? this.typeName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is OperationTypeDefinition) {
      return this.type == other.type && this.typeName == other.typeName;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(type, typeName);

  static OperationTypeDefinition fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is OperationTypeDefinition) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return OperationTypeDefinition(
      type: OperationType.fromJson(map['type']),
      typeName: map['typeName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toJson(),
      'typeName': typeName,
    };
  }
}

final typeDefinition = ((scalarTypeDefinition
            .map((v) => TypeDefinition.scalar(value: v)) |
        objectTypeDefinition.map((v) => TypeDefinition.object(value: v)) |
        interfaceTypeDefinition.map((v) => TypeDefinition.interface(value: v)) |
        unionTypeDefinition.map((v) => TypeDefinition.union(value: v)) |
        enumTypeDefinition.map((v) => TypeDefinition.enum_(value: v)) |
        inputObjectTypeDefinition
            .map((v) => TypeDefinition.inputObject(value: v)))
    .cast<TypeDefinition>());

abstract class TypeDefinition {
  const TypeDefinition._();

  @override
  String toString() {
    return value.toString();
  }

  const factory TypeDefinition.scalar({
    required ScalarTypeDefinition value,
  }) = TypeDefinitionScalar;
  const factory TypeDefinition.object({
    required ObjectTypeDefinition value,
  }) = TypeDefinitionObject;
  const factory TypeDefinition.interface({
    required InterfaceTypeDefinition value,
  }) = TypeDefinitionInterface;
  const factory TypeDefinition.union({
    required UnionTypeDefinition value,
  }) = TypeDefinitionUnion;
  const factory TypeDefinition.enum_({
    required EnumTypeDefinition value,
  }) = TypeDefinitionEnum;
  const factory TypeDefinition.inputObject({
    required InputObjectTypeDefinition value,
  }) = TypeDefinitionInputObject;

  Object get value;

  _T when<_T>({
    required _T Function(ScalarTypeDefinition value) scalar,
    required _T Function(ObjectTypeDefinition value) object,
    required _T Function(InterfaceTypeDefinition value) interface,
    required _T Function(UnionTypeDefinition value) union,
    required _T Function(EnumTypeDefinition value) enum_,
    required _T Function(InputObjectTypeDefinition value) inputObject,
  }) {
    final v = this;
    if (v is TypeDefinitionScalar) {
      return scalar(v.value);
    } else if (v is TypeDefinitionObject) {
      return object(v.value);
    } else if (v is TypeDefinitionInterface) {
      return interface(v.value);
    } else if (v is TypeDefinitionUnion) {
      return union(v.value);
    } else if (v is TypeDefinitionEnum) {
      return enum_(v.value);
    } else if (v is TypeDefinitionInputObject) {
      return inputObject(v.value);
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(ScalarTypeDefinition value)? scalar,
    _T Function(ObjectTypeDefinition value)? object,
    _T Function(InterfaceTypeDefinition value)? interface,
    _T Function(UnionTypeDefinition value)? union,
    _T Function(EnumTypeDefinition value)? enum_,
    _T Function(InputObjectTypeDefinition value)? inputObject,
  }) {
    final v = this;
    if (v is TypeDefinitionScalar) {
      return scalar != null ? scalar(v.value) : orElse.call();
    } else if (v is TypeDefinitionObject) {
      return object != null ? object(v.value) : orElse.call();
    } else if (v is TypeDefinitionInterface) {
      return interface != null ? interface(v.value) : orElse.call();
    } else if (v is TypeDefinitionUnion) {
      return union != null ? union(v.value) : orElse.call();
    } else if (v is TypeDefinitionEnum) {
      return enum_ != null ? enum_(v.value) : orElse.call();
    } else if (v is TypeDefinitionInputObject) {
      return inputObject != null ? inputObject(v.value) : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(TypeDefinitionScalar value) scalar,
    required _T Function(TypeDefinitionObject value) object,
    required _T Function(TypeDefinitionInterface value) interface,
    required _T Function(TypeDefinitionUnion value) union,
    required _T Function(TypeDefinitionEnum value) enum_,
    required _T Function(TypeDefinitionInputObject value) inputObject,
  }) {
    final v = this;
    if (v is TypeDefinitionScalar) {
      return scalar(v);
    } else if (v is TypeDefinitionObject) {
      return object(v);
    } else if (v is TypeDefinitionInterface) {
      return interface(v);
    } else if (v is TypeDefinitionUnion) {
      return union(v);
    } else if (v is TypeDefinitionEnum) {
      return enum_(v);
    } else if (v is TypeDefinitionInputObject) {
      return inputObject(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(TypeDefinitionScalar value)? scalar,
    _T Function(TypeDefinitionObject value)? object,
    _T Function(TypeDefinitionInterface value)? interface,
    _T Function(TypeDefinitionUnion value)? union,
    _T Function(TypeDefinitionEnum value)? enum_,
    _T Function(TypeDefinitionInputObject value)? inputObject,
  }) {
    final v = this;
    if (v is TypeDefinitionScalar) {
      return scalar != null ? scalar(v) : orElse.call();
    } else if (v is TypeDefinitionObject) {
      return object != null ? object(v) : orElse.call();
    } else if (v is TypeDefinitionInterface) {
      return interface != null ? interface(v) : orElse.call();
    } else if (v is TypeDefinitionUnion) {
      return union != null ? union(v) : orElse.call();
    } else if (v is TypeDefinitionEnum) {
      return enum_ != null ? enum_(v) : orElse.call();
    } else if (v is TypeDefinitionInputObject) {
      return inputObject != null ? inputObject(v) : orElse.call();
    }
    throw Exception();
  }

  bool get isScalar => this is TypeDefinitionScalar;
  bool get isObject => this is TypeDefinitionObject;
  bool get isInterface => this is TypeDefinitionInterface;
  bool get isUnion => this is TypeDefinitionUnion;
  bool get isEnum => this is TypeDefinitionEnum;
  bool get isInputObject => this is TypeDefinitionInputObject;

  static TypeDefinition fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is TypeDefinition) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    switch (map['runtimeType'] as String) {
      case 'scalar':
        return TypeDefinitionScalar.fromJson(map);
      case 'object':
        return TypeDefinitionObject.fromJson(map);
      case 'interface':
        return TypeDefinitionInterface.fromJson(map);
      case 'union':
        return TypeDefinitionUnion.fromJson(map);
      case 'enum':
        return TypeDefinitionEnum.fromJson(map);
      case 'inputObject':
        return TypeDefinitionInputObject.fromJson(map);
      default:
        throw Exception('Invalid discriminator for TypeDefinition.fromJson '
            '${map["runtimeType"]}. Input map: $map');
    }
  }

  Map<String, dynamic> toJson();
}

class TypeDefinitionScalar extends TypeDefinition {
  final ScalarTypeDefinition value;

  const TypeDefinitionScalar({
    required this.value,
  }) : super._();

  TypeDefinitionScalar copyWith({
    ScalarTypeDefinition? value,
  }) {
    return TypeDefinitionScalar(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is TypeDefinitionScalar) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static TypeDefinitionScalar fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is TypeDefinitionScalar) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return TypeDefinitionScalar(
      value: ScalarTypeDefinition.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'scalar',
      'value': value.toJson(),
    };
  }
}

class TypeDefinitionObject extends TypeDefinition {
  final ObjectTypeDefinition value;

  const TypeDefinitionObject({
    required this.value,
  }) : super._();

  TypeDefinitionObject copyWith({
    ObjectTypeDefinition? value,
  }) {
    return TypeDefinitionObject(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is TypeDefinitionObject) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static TypeDefinitionObject fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is TypeDefinitionObject) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return TypeDefinitionObject(
      value: ObjectTypeDefinition.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'object',
      'value': value.toJson(),
    };
  }
}

class TypeDefinitionInterface extends TypeDefinition {
  final InterfaceTypeDefinition value;

  const TypeDefinitionInterface({
    required this.value,
  }) : super._();

  TypeDefinitionInterface copyWith({
    InterfaceTypeDefinition? value,
  }) {
    return TypeDefinitionInterface(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is TypeDefinitionInterface) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static TypeDefinitionInterface fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is TypeDefinitionInterface) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return TypeDefinitionInterface(
      value: InterfaceTypeDefinition.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'interface',
      'value': value.toJson(),
    };
  }
}

class TypeDefinitionUnion extends TypeDefinition {
  final UnionTypeDefinition value;

  const TypeDefinitionUnion({
    required this.value,
  }) : super._();

  TypeDefinitionUnion copyWith({
    UnionTypeDefinition? value,
  }) {
    return TypeDefinitionUnion(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is TypeDefinitionUnion) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static TypeDefinitionUnion fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is TypeDefinitionUnion) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return TypeDefinitionUnion(
      value: UnionTypeDefinition.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'union',
      'value': value.toJson(),
    };
  }
}

class TypeDefinitionEnum extends TypeDefinition {
  final EnumTypeDefinition value;

  const TypeDefinitionEnum({
    required this.value,
  }) : super._();

  TypeDefinitionEnum copyWith({
    EnumTypeDefinition? value,
  }) {
    return TypeDefinitionEnum(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is TypeDefinitionEnum) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static TypeDefinitionEnum fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is TypeDefinitionEnum) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return TypeDefinitionEnum(
      value: EnumTypeDefinition.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'enum',
      'value': value.toJson(),
    };
  }
}

class TypeDefinitionInputObject extends TypeDefinition {
  final InputObjectTypeDefinition value;

  const TypeDefinitionInputObject({
    required this.value,
  }) : super._();

  TypeDefinitionInputObject copyWith({
    InputObjectTypeDefinition? value,
  }) {
    return TypeDefinitionInputObject(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is TypeDefinitionInputObject) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static TypeDefinitionInputObject fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is TypeDefinitionInputObject) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return TypeDefinitionInputObject(
      value: InputObjectTypeDefinition.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'inputObject',
      'value': value.toJson(),
    };
  }
}

final scalarTypeDefinition = (stringValue.trim().optional() &
        string('scalar').trim() &
        name.trim() &
        directives.trim().optional())
    .map((l) {
  return ScalarTypeDefinition(
    description: l[0] as StringValue?,
    name: l[2] as String,
    directives: l[3] as Directives?,
  );
});

class ScalarTypeDefinition {
  final StringValue? description;
  final String name;
  final Directives? directives;

  @override
  String toString() {
    return '${description == null ? "" : "${description!}"} scalar ${name} ${directives == null ? "" : "${directives!}"} ';
  }

  const ScalarTypeDefinition({
    required this.name,
    this.description,
    this.directives,
  });

  ScalarTypeDefinition copyWith({
    StringValue? description,
    String? name,
    Directives? directives,
  }) {
    return ScalarTypeDefinition(
      name: name ?? this.name,
      description: description ?? this.description,
      directives: directives ?? this.directives,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ScalarTypeDefinition) {
      return this.description == other.description &&
          this.name == other.name &&
          this.directives == other.directives;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(description, name, directives);

  static ScalarTypeDefinition fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ScalarTypeDefinition) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ScalarTypeDefinition(
      name: map['name'] as String,
      description: map['description'] == null
          ? null
          : StringValue.fromJson(map['description']),
      directives: map['directives'] == null
          ? null
          : Directives.fromJson(map['directives']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description?.toJson(),
      'name': name,
      'directives': directives?.toJson(),
    };
  }
}

final objectTypeDefinition = (stringValue.trim().optional() &
        string('type').trim() &
        name.trim() &
        implementsInterfaces.trim().optional() &
        directives.trim().optional() &
        fieldsDefinition.trim().optional())
    .map((l) {
  return ObjectTypeDefinition(
    description: l[0] as StringValue?,
    name: l[2] as String,
    interfaces: l[3] as ImplementsInterfaces?,
    directives: l[4] as Directives?,
    fields: l[5] as FieldsDefinition?,
  );
});

class ObjectTypeDefinition {
  final StringValue? description;
  final String name;
  final ImplementsInterfaces? interfaces;
  final Directives? directives;
  final FieldsDefinition? fields;

  @override
  String toString() {
    return '${description == null ? "" : "${description!}"} type ${name} ${interfaces == null ? "" : "${interfaces!}"} ${directives == null ? "" : "${directives!}"} ${fields == null ? "" : "${fields!}"} ';
  }

  const ObjectTypeDefinition({
    required this.name,
    this.description,
    this.interfaces,
    this.directives,
    this.fields,
  });

  ObjectTypeDefinition copyWith({
    StringValue? description,
    String? name,
    ImplementsInterfaces? interfaces,
    Directives? directives,
    FieldsDefinition? fields,
  }) {
    return ObjectTypeDefinition(
      name: name ?? this.name,
      description: description ?? this.description,
      interfaces: interfaces ?? this.interfaces,
      directives: directives ?? this.directives,
      fields: fields ?? this.fields,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ObjectTypeDefinition) {
      return this.description == other.description &&
          this.name == other.name &&
          this.interfaces == other.interfaces &&
          this.directives == other.directives &&
          this.fields == other.fields;
    }
    return false;
  }

  @override
  int get hashCode =>
      hashValues(description, name, interfaces, directives, fields);

  static ObjectTypeDefinition fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ObjectTypeDefinition) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ObjectTypeDefinition(
      name: map['name'] as String,
      description: map['description'] == null
          ? null
          : StringValue.fromJson(map['description']),
      interfaces: map['interfaces'] == null
          ? null
          : ImplementsInterfaces.fromJson(map['interfaces']),
      directives: map['directives'] == null
          ? null
          : Directives.fromJson(map['directives']),
      fields: map['fields'] == null
          ? null
          : FieldsDefinition.fromJson(map['fields']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description?.toJson(),
      'name': name,
      'interfaces': interfaces?.toJson(),
      'directives': directives?.toJson(),
      'fields': fields?.toJson(),
    };
  }
}

SettableParser<ImplementsInterfaces>? _implementsInterfaces;

Parser<ImplementsInterfaces> get implementsInterfaces {
  if (_implementsInterfaces != null) {
    return _implementsInterfaces!;
  }
  _implementsInterfaces = undefined();
  final p =
      ((string('implements').trim() & char('&').trim().optional() & name.trim())
                  .map((l) {
                return ImplementsItem(
                  typeName: l[2] as String,
                );
              }).map((v) => ImplementsInterfaces.implementsItem(value: v)) |
              (implementsInterfaces.trim() & char('&').trim() & name.trim())
                  .map((l) {
                return ImplementsItemList(
                  other: l[0] as ImplementsInterfaces,
                  typeName: l[2] as String,
                );
              }).map((v) => ImplementsInterfaces.implementsItemList(value: v)))
          .cast<ImplementsInterfaces>();
  _implementsInterfaces!.set(p);
  return _implementsInterfaces!;
}

abstract class ImplementsInterfaces {
  const ImplementsInterfaces._();

  @override
  String toString() {
    return value.toString();
  }

  const factory ImplementsInterfaces.implementsItem({
    required ImplementsItem value,
  }) = implementsInterfacesImplementsItem;
  const factory ImplementsInterfaces.implementsItemList({
    required ImplementsItemList value,
  }) = implementsInterfacesImplementsItemList;

  Object get value;

  _T when<_T>({
    required _T Function(ImplementsItem value) implementsItem,
    required _T Function(ImplementsItemList value) implementsItemList,
  }) {
    final v = this;
    if (v is implementsInterfacesImplementsItem) {
      return implementsItem(v.value);
    } else if (v is implementsInterfacesImplementsItemList) {
      return implementsItemList(v.value);
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(ImplementsItem value)? implementsItem,
    _T Function(ImplementsItemList value)? implementsItemList,
  }) {
    final v = this;
    if (v is implementsInterfacesImplementsItem) {
      return implementsItem != null ? implementsItem(v.value) : orElse.call();
    } else if (v is implementsInterfacesImplementsItemList) {
      return implementsItemList != null
          ? implementsItemList(v.value)
          : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(implementsInterfacesImplementsItem value)
        implementsItem,
    required _T Function(implementsInterfacesImplementsItemList value)
        implementsItemList,
  }) {
    final v = this;
    if (v is implementsInterfacesImplementsItem) {
      return implementsItem(v);
    } else if (v is implementsInterfacesImplementsItemList) {
      return implementsItemList(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(implementsInterfacesImplementsItem value)? implementsItem,
    _T Function(implementsInterfacesImplementsItemList value)?
        implementsItemList,
  }) {
    final v = this;
    if (v is implementsInterfacesImplementsItem) {
      return implementsItem != null ? implementsItem(v) : orElse.call();
    } else if (v is implementsInterfacesImplementsItemList) {
      return implementsItemList != null ? implementsItemList(v) : orElse.call();
    }
    throw Exception();
  }

  bool get isImplementsItem => this is implementsInterfacesImplementsItem;
  bool get isImplementsItemList =>
      this is implementsInterfacesImplementsItemList;

  static ImplementsInterfaces fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ImplementsInterfaces) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    switch (map['runtimeType'] as String) {
      case 'implementsItem':
        return implementsInterfacesImplementsItem.fromJson(map);
      case 'implementsItemList':
        return implementsInterfacesImplementsItemList.fromJson(map);
      default:
        throw Exception(
            'Invalid discriminator for ImplementsInterfaces.fromJson '
            '${map["runtimeType"]}. Input map: $map');
    }
  }

  Map<String, dynamic> toJson();
}

class implementsInterfacesImplementsItem extends ImplementsInterfaces {
  final ImplementsItem value;

  const implementsInterfacesImplementsItem({
    required this.value,
  }) : super._();

  implementsInterfacesImplementsItem copyWith({
    ImplementsItem? value,
  }) {
    return implementsInterfacesImplementsItem(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is implementsInterfacesImplementsItem) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static implementsInterfacesImplementsItem fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is implementsInterfacesImplementsItem) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return implementsInterfacesImplementsItem(
      value: ImplementsItem.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'implementsItem',
      'value': value.toJson(),
    };
  }
}

class implementsInterfacesImplementsItemList extends ImplementsInterfaces {
  final ImplementsItemList value;

  const implementsInterfacesImplementsItemList({
    required this.value,
  }) : super._();

  implementsInterfacesImplementsItemList copyWith({
    ImplementsItemList? value,
  }) {
    return implementsInterfacesImplementsItemList(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is implementsInterfacesImplementsItemList) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static implementsInterfacesImplementsItemList fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is implementsInterfacesImplementsItemList) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return implementsInterfacesImplementsItemList(
      value: ImplementsItemList.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'implementsItemList',
      'value': value.toJson(),
    };
  }
}

class ImplementsItem {
  final String typeName;

  @override
  String toString() {
    return 'implements & ${typeName} ';
  }

  const ImplementsItem({
    required this.typeName,
  });

  ImplementsItem copyWith({
    String? typeName,
  }) {
    return ImplementsItem(
      typeName: typeName ?? this.typeName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ImplementsItem) {
      return this.typeName == other.typeName;
    }
    return false;
  }

  @override
  int get hashCode => typeName.hashCode;

  static ImplementsItem fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ImplementsItem) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ImplementsItem(
      typeName: map['typeName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'typeName': typeName,
    };
  }
}

class ImplementsItemList {
  final ImplementsInterfaces other;
  final String typeName;

  @override
  String toString() {
    return '${other} & ${typeName} ';
  }

  const ImplementsItemList({
    required this.other,
    required this.typeName,
  });

  ImplementsItemList copyWith({
    ImplementsInterfaces? other,
    String? typeName,
  }) {
    return ImplementsItemList(
      other: other ?? this.other,
      typeName: typeName ?? this.typeName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ImplementsItemList) {
      return this.other == other.other && this.typeName == other.typeName;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(other, typeName);

  static ImplementsItemList fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ImplementsItemList) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ImplementsItemList(
      other: ImplementsInterfaces.fromJson(map['other']),
      typeName: map['typeName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'other': other.toJson(),
      'typeName': typeName,
    };
  }
}

final fieldsDefinition =
    (char('{').trim() & fieldDefinition.trim().plus() & char('}').trim())
        .map((l) {
  return FieldsDefinition(
    fields: l[1] as List<FieldDefinition>,
  );
});

class FieldsDefinition {
  final List<FieldDefinition> fields;

  @override
  String toString() {
    return '{ ${fields.join(" ")} } ';
  }

  const FieldsDefinition({
    required this.fields,
  });

  FieldsDefinition copyWith({
    List<FieldDefinition>? fields,
  }) {
    return FieldsDefinition(
      fields: fields ?? this.fields,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is FieldsDefinition) {
      return this.fields == other.fields;
    }
    return false;
  }

  @override
  int get hashCode => fields.hashCode;

  static FieldsDefinition fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is FieldsDefinition) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return FieldsDefinition(
      fields: (map['fields'] as List)
          .map((e) => FieldDefinition.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fields': fields.map((e) => e.toJson()).toList(),
    };
  }
}

final fieldDefinition = (stringValue.trim().optional() &
        name.trim() &
        argumentsDefinition.trim().optional() &
        char(':').trim() &
        graphqlType.trim() &
        directives.trim().optional())
    .map((l) {
  return FieldDefinition(
    description: l[0] as StringValue?,
    name: l[1] as String,
    arguments: l[2] as ArgumentsDefinition?,
    type: l[4] as GraphqlType,
    directives: l[5] as Directives?,
  );
});

class FieldDefinition {
  final StringValue? description;
  final String name;
  final ArgumentsDefinition? arguments;
  final GraphqlType type;
  final Directives? directives;

  @override
  String toString() {
    return '${description == null ? "" : "${description!}"} ${name} ${arguments == null ? "" : "${arguments!}"} : ${type} ${directives == null ? "" : "${directives!}"} ';
  }

  const FieldDefinition({
    required this.name,
    required this.type,
    this.description,
    this.arguments,
    this.directives,
  });

  FieldDefinition copyWith({
    StringValue? description,
    String? name,
    ArgumentsDefinition? arguments,
    GraphqlType? type,
    Directives? directives,
  }) {
    return FieldDefinition(
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      arguments: arguments ?? this.arguments,
      directives: directives ?? this.directives,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is FieldDefinition) {
      return this.description == other.description &&
          this.name == other.name &&
          this.arguments == other.arguments &&
          this.type == other.type &&
          this.directives == other.directives;
    }
    return false;
  }

  @override
  int get hashCode =>
      hashValues(description, name, arguments, type, directives);

  static FieldDefinition fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is FieldDefinition) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return FieldDefinition(
      name: map['name'] as String,
      type: GraphqlType.fromJson(map['type']),
      description: map['description'] == null
          ? null
          : StringValue.fromJson(map['description']),
      arguments: map['arguments'] == null
          ? null
          : ArgumentsDefinition.fromJson(map['arguments']),
      directives: map['directives'] == null
          ? null
          : Directives.fromJson(map['directives']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description?.toJson(),
      'name': name,
      'arguments': arguments?.toJson(),
      'type': type.toJson(),
      'directives': directives?.toJson(),
    };
  }
}

final argumentsDefinition =
    (char('(').trim() & inputValueDefinition.trim().plus() & char(')').trim())
        .map((l) {
  return ArgumentsDefinition(
    inputs: l[1] as List<InputValueDefinition>,
  );
});

class ArgumentsDefinition {
  final List<InputValueDefinition> inputs;

  @override
  String toString() {
    return '( ${inputs.join(" ")} ) ';
  }

  const ArgumentsDefinition({
    required this.inputs,
  });

  ArgumentsDefinition copyWith({
    List<InputValueDefinition>? inputs,
  }) {
    return ArgumentsDefinition(
      inputs: inputs ?? this.inputs,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ArgumentsDefinition) {
      return this.inputs == other.inputs;
    }
    return false;
  }

  @override
  int get hashCode => inputs.hashCode;

  static ArgumentsDefinition fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ArgumentsDefinition) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ArgumentsDefinition(
      inputs: (map['inputs'] as List)
          .map((e) => InputValueDefinition.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inputs': inputs.map((e) => e.toJson()).toList(),
    };
  }
}

final inputValueDefinition = (stringValue.trim().optional() &
        name.trim() &
        char(':').trim() &
        graphqlType.trim() &
        defaultValue.trim().optional() &
        directives.trim().optional())
    .map((l) {
  return InputValueDefinition(
    description: l[0] as StringValue?,
    name: l[1] as String,
    type: l[3] as GraphqlType,
    defaultValue: l[4] as DefaultValue?,
    directives: l[5] as Directives?,
  );
});

class InputValueDefinition {
  final StringValue? description;
  final String name;
  final GraphqlType type;
  final DefaultValue? defaultValue;
  final Directives? directives;

  @override
  String toString() {
    return '${description == null ? "" : "${description!}"} ${name} : ${type} ${defaultValue == null ? "" : "${defaultValue!}"} ${directives == null ? "" : "${directives!}"} ';
  }

  const InputValueDefinition({
    required this.name,
    required this.type,
    this.description,
    this.defaultValue,
    this.directives,
  });

  InputValueDefinition copyWith({
    StringValue? description,
    String? name,
    GraphqlType? type,
    DefaultValue? defaultValue,
    Directives? directives,
  }) {
    return InputValueDefinition(
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      defaultValue: defaultValue ?? this.defaultValue,
      directives: directives ?? this.directives,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is InputValueDefinition) {
      return this.description == other.description &&
          this.name == other.name &&
          this.type == other.type &&
          this.defaultValue == other.defaultValue &&
          this.directives == other.directives;
    }
    return false;
  }

  @override
  int get hashCode =>
      hashValues(description, name, type, defaultValue, directives);

  static InputValueDefinition fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is InputValueDefinition) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return InputValueDefinition(
      name: map['name'] as String,
      type: GraphqlType.fromJson(map['type']),
      description: map['description'] == null
          ? null
          : StringValue.fromJson(map['description']),
      defaultValue: map['defaultValue'] == null
          ? null
          : DefaultValue.fromJson(map['defaultValue']),
      directives: map['directives'] == null
          ? null
          : Directives.fromJson(map['directives']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description?.toJson(),
      'name': name,
      'type': type.toJson(),
      'defaultValue': defaultValue?.toJson(),
      'directives': directives?.toJson(),
    };
  }
}

final interfaceTypeDefinition = (stringValue.trim().optional() &
        string('interface').trim() &
        name.trim() &
        directives.trim().optional() &
        fieldsDefinition.trim().optional())
    .map((l) {
  return InterfaceTypeDefinition(
    description: l[0] as StringValue?,
    name: l[2] as String,
    directives: l[3] as Directives?,
    fields: l[4] as FieldsDefinition?,
  );
});

class InterfaceTypeDefinition {
  final StringValue? description;
  final String name;
  final Directives? directives;
  final FieldsDefinition? fields;

  @override
  String toString() {
    return '${description == null ? "" : "${description!}"} interface ${name} ${directives == null ? "" : "${directives!}"} ${fields == null ? "" : "${fields!}"} ';
  }

  const InterfaceTypeDefinition({
    required this.name,
    this.description,
    this.directives,
    this.fields,
  });

  InterfaceTypeDefinition copyWith({
    StringValue? description,
    String? name,
    Directives? directives,
    FieldsDefinition? fields,
  }) {
    return InterfaceTypeDefinition(
      name: name ?? this.name,
      description: description ?? this.description,
      directives: directives ?? this.directives,
      fields: fields ?? this.fields,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is InterfaceTypeDefinition) {
      return this.description == other.description &&
          this.name == other.name &&
          this.directives == other.directives &&
          this.fields == other.fields;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(description, name, directives, fields);

  static InterfaceTypeDefinition fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is InterfaceTypeDefinition) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return InterfaceTypeDefinition(
      name: map['name'] as String,
      description: map['description'] == null
          ? null
          : StringValue.fromJson(map['description']),
      directives: map['directives'] == null
          ? null
          : Directives.fromJson(map['directives']),
      fields: map['fields'] == null
          ? null
          : FieldsDefinition.fromJson(map['fields']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description?.toJson(),
      'name': name,
      'directives': directives?.toJson(),
      'fields': fields?.toJson(),
    };
  }
}

final unionTypeDefinition = (stringValue.trim().optional() &
        string('union').trim() &
        name.trim() &
        directives.trim().optional() &
        unionMemberTypes.trim().optional())
    .map((l) {
  return UnionTypeDefinition(
    description: l[0] as StringValue?,
    name: l[2] as String,
    directives: l[3] as Directives?,
    types: l[4] as UnionMemberTypes?,
  );
});

class UnionTypeDefinition {
  final StringValue? description;
  final String name;
  final Directives? directives;
  final UnionMemberTypes? types;

  @override
  String toString() {
    return '${description == null ? "" : "${description!}"} union ${name} ${directives == null ? "" : "${directives!}"} ${types == null ? "" : "${types!}"} ';
  }

  const UnionTypeDefinition({
    required this.name,
    this.description,
    this.directives,
    this.types,
  });

  UnionTypeDefinition copyWith({
    StringValue? description,
    String? name,
    Directives? directives,
    UnionMemberTypes? types,
  }) {
    return UnionTypeDefinition(
      name: name ?? this.name,
      description: description ?? this.description,
      directives: directives ?? this.directives,
      types: types ?? this.types,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is UnionTypeDefinition) {
      return this.description == other.description &&
          this.name == other.name &&
          this.directives == other.directives &&
          this.types == other.types;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(description, name, directives, types);

  static UnionTypeDefinition fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is UnionTypeDefinition) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return UnionTypeDefinition(
      name: map['name'] as String,
      description: map['description'] == null
          ? null
          : StringValue.fromJson(map['description']),
      directives: map['directives'] == null
          ? null
          : Directives.fromJson(map['directives']),
      types:
          map['types'] == null ? null : UnionMemberTypes.fromJson(map['types']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description?.toJson(),
      'name': name,
      'directives': directives?.toJson(),
      'types': types?.toJson(),
    };
  }
}

SettableParser<UnionMemberTypes>? _unionMemberTypes;

Parser<UnionMemberTypes> get unionMemberTypes {
  if (_unionMemberTypes != null) {
    return _unionMemberTypes!;
  }
  _unionMemberTypes = undefined();
  final p = ((char('=').trim() & char('|').trim().optional() & name.trim())
              .map((l) {
            return UnionItem(
              typeName: l[2] as String,
            );
          }).map((v) => UnionMemberTypes.unionItem(value: v)) |
          (unionMemberTypes.trim() & char('|').trim() & name.trim()).map((l) {
            return UnionItemList(
              other: l[0] as UnionMemberTypes,
              typeName: l[2] as String,
            );
          }).map((v) => UnionMemberTypes.unionItemList(value: v)))
      .cast<UnionMemberTypes>();
  _unionMemberTypes!.set(p);
  return _unionMemberTypes!;
}

abstract class UnionMemberTypes {
  const UnionMemberTypes._();

  @override
  String toString() {
    return value.toString();
  }

  const factory UnionMemberTypes.unionItem({
    required UnionItem value,
  }) = unionMemberTypesUnionItem;
  const factory UnionMemberTypes.unionItemList({
    required UnionItemList value,
  }) = unionMemberTypesUnionItemList;

  Object get value;

  _T when<_T>({
    required _T Function(UnionItem value) unionItem,
    required _T Function(UnionItemList value) unionItemList,
  }) {
    final v = this;
    if (v is unionMemberTypesUnionItem) {
      return unionItem(v.value);
    } else if (v is unionMemberTypesUnionItemList) {
      return unionItemList(v.value);
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(UnionItem value)? unionItem,
    _T Function(UnionItemList value)? unionItemList,
  }) {
    final v = this;
    if (v is unionMemberTypesUnionItem) {
      return unionItem != null ? unionItem(v.value) : orElse.call();
    } else if (v is unionMemberTypesUnionItemList) {
      return unionItemList != null ? unionItemList(v.value) : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(unionMemberTypesUnionItem value) unionItem,
    required _T Function(unionMemberTypesUnionItemList value) unionItemList,
  }) {
    final v = this;
    if (v is unionMemberTypesUnionItem) {
      return unionItem(v);
    } else if (v is unionMemberTypesUnionItemList) {
      return unionItemList(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(unionMemberTypesUnionItem value)? unionItem,
    _T Function(unionMemberTypesUnionItemList value)? unionItemList,
  }) {
    final v = this;
    if (v is unionMemberTypesUnionItem) {
      return unionItem != null ? unionItem(v) : orElse.call();
    } else if (v is unionMemberTypesUnionItemList) {
      return unionItemList != null ? unionItemList(v) : orElse.call();
    }
    throw Exception();
  }

  bool get isUnionItem => this is unionMemberTypesUnionItem;
  bool get isUnionItemList => this is unionMemberTypesUnionItemList;

  static UnionMemberTypes fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is UnionMemberTypes) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    switch (map['runtimeType'] as String) {
      case 'unionItem':
        return unionMemberTypesUnionItem.fromJson(map);
      case 'unionItemList':
        return unionMemberTypesUnionItemList.fromJson(map);
      default:
        throw Exception('Invalid discriminator for UnionMemberTypes.fromJson '
            '${map["runtimeType"]}. Input map: $map');
    }
  }

  Map<String, dynamic> toJson();
}

class unionMemberTypesUnionItem extends UnionMemberTypes {
  final UnionItem value;

  const unionMemberTypesUnionItem({
    required this.value,
  }) : super._();

  unionMemberTypesUnionItem copyWith({
    UnionItem? value,
  }) {
    return unionMemberTypesUnionItem(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is unionMemberTypesUnionItem) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static unionMemberTypesUnionItem fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is unionMemberTypesUnionItem) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return unionMemberTypesUnionItem(
      value: UnionItem.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'unionItem',
      'value': value.toJson(),
    };
  }
}

class unionMemberTypesUnionItemList extends UnionMemberTypes {
  final UnionItemList value;

  const unionMemberTypesUnionItemList({
    required this.value,
  }) : super._();

  unionMemberTypesUnionItemList copyWith({
    UnionItemList? value,
  }) {
    return unionMemberTypesUnionItemList(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is unionMemberTypesUnionItemList) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static unionMemberTypesUnionItemList fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is unionMemberTypesUnionItemList) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return unionMemberTypesUnionItemList(
      value: UnionItemList.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'unionItemList',
      'value': value.toJson(),
    };
  }
}

class UnionItem {
  final String typeName;

  @override
  String toString() {
    return '= | ${typeName} ';
  }

  const UnionItem({
    required this.typeName,
  });

  UnionItem copyWith({
    String? typeName,
  }) {
    return UnionItem(
      typeName: typeName ?? this.typeName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is UnionItem) {
      return this.typeName == other.typeName;
    }
    return false;
  }

  @override
  int get hashCode => typeName.hashCode;

  static UnionItem fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is UnionItem) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return UnionItem(
      typeName: map['typeName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'typeName': typeName,
    };
  }
}

class UnionItemList {
  final UnionMemberTypes other;
  final String typeName;

  @override
  String toString() {
    return '${other} | ${typeName} ';
  }

  const UnionItemList({
    required this.other,
    required this.typeName,
  });

  UnionItemList copyWith({
    UnionMemberTypes? other,
    String? typeName,
  }) {
    return UnionItemList(
      other: other ?? this.other,
      typeName: typeName ?? this.typeName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is UnionItemList) {
      return this.other == other.other && this.typeName == other.typeName;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(other, typeName);

  static UnionItemList fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is UnionItemList) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return UnionItemList(
      other: UnionMemberTypes.fromJson(map['other']),
      typeName: map['typeName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'other': other.toJson(),
      'typeName': typeName,
    };
  }
}

final enumTypeDefinition = (stringValue.trim().optional() &
        string('enum').trim() &
        name.trim() &
        directives.trim().optional() &
        enumValuesDefinition.trim().optional())
    .map((l) {
  return EnumTypeDefinition(
    description: l[0] as StringValue?,
    name: l[2] as String,
    directives: l[3] as Directives?,
    values: l[4] as EnumValuesDefinition?,
  );
});

class EnumTypeDefinition {
  final StringValue? description;
  final String name;
  final Directives? directives;
  final EnumValuesDefinition? values;

  @override
  String toString() {
    return '${description == null ? "" : "${description!}"} enum ${name} ${directives == null ? "" : "${directives!}"} ${values == null ? "" : "${values!}"} ';
  }

  const EnumTypeDefinition({
    required this.name,
    this.description,
    this.directives,
    this.values,
  });

  EnumTypeDefinition copyWith({
    StringValue? description,
    String? name,
    Directives? directives,
    EnumValuesDefinition? values,
  }) {
    return EnumTypeDefinition(
      name: name ?? this.name,
      description: description ?? this.description,
      directives: directives ?? this.directives,
      values: values ?? this.values,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is EnumTypeDefinition) {
      return this.description == other.description &&
          this.name == other.name &&
          this.directives == other.directives &&
          this.values == other.values;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(description, name, directives, values);

  static EnumTypeDefinition fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is EnumTypeDefinition) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return EnumTypeDefinition(
      name: map['name'] as String,
      description: map['description'] == null
          ? null
          : StringValue.fromJson(map['description']),
      directives: map['directives'] == null
          ? null
          : Directives.fromJson(map['directives']),
      values: map['values'] == null
          ? null
          : EnumValuesDefinition.fromJson(map['values']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description?.toJson(),
      'name': name,
      'directives': directives?.toJson(),
      'values': values?.toJson(),
    };
  }
}

final enumValuesDefinition =
    (char('{').trim() & enumValueDefinition.trim().plus() & char('}').trim())
        .map((l) {
  return EnumValuesDefinition(
    values: l[1] as List<EnumValueDefinition>,
  );
});

class EnumValuesDefinition {
  final List<EnumValueDefinition> values;

  @override
  String toString() {
    return '{ ${values.join(" ")} } ';
  }

  const EnumValuesDefinition({
    required this.values,
  });

  EnumValuesDefinition copyWith({
    List<EnumValueDefinition>? values,
  }) {
    return EnumValuesDefinition(
      values: values ?? this.values,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is EnumValuesDefinition) {
      return this.values == other.values;
    }
    return false;
  }

  @override
  int get hashCode => values.hashCode;

  static EnumValuesDefinition fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is EnumValuesDefinition) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return EnumValuesDefinition(
      values: (map['values'] as List)
          .map((e) => EnumValueDefinition.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'values': values.map((e) => e.toJson()).toList(),
    };
  }
}

final enumValueDefinition =
    (stringValue.trim() & enumValue.trim() & directives.trim().optional())
        .map((l) {
  return EnumValueDefinition(
    description: l[0] as StringValue,
    value: l[1] as EnumValue,
    directives: l[2] as Directives?,
  );
});

class EnumValueDefinition {
  final StringValue description;
  final EnumValue value;
  final Directives? directives;

  @override
  String toString() {
    return '${description} ${value} ${directives == null ? "" : "${directives!}"} ';
  }

  const EnumValueDefinition({
    required this.description,
    required this.value,
    this.directives,
  });

  EnumValueDefinition copyWith({
    StringValue? description,
    EnumValue? value,
    Directives? directives,
  }) {
    return EnumValueDefinition(
      description: description ?? this.description,
      value: value ?? this.value,
      directives: directives ?? this.directives,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is EnumValueDefinition) {
      return this.description == other.description &&
          this.value == other.value &&
          this.directives == other.directives;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(description, value, directives);

  static EnumValueDefinition fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is EnumValueDefinition) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return EnumValueDefinition(
      description: StringValue.fromJson(map['description']),
      value: EnumValue.fromJson(map['value']),
      directives: map['directives'] == null
          ? null
          : Directives.fromJson(map['directives']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description.toJson(),
      'value': value.toJson(),
      'directives': directives?.toJson(),
    };
  }
}

final inputObjectTypeDefinition = (stringValue.trim().optional() &
        string('input').trim() &
        name.trim() &
        directives.trim().optional() &
        inputFieldsDefinition.trim().optional())
    .map((l) {
  return InputObjectTypeDefinition(
    description: l[0] as StringValue?,
    name: l[2] as String,
    directives: l[3] as Directives?,
    inputs: l[4] as InputFieldsDefinition?,
  );
});

class InputObjectTypeDefinition {
  final StringValue? description;
  final String name;
  final Directives? directives;
  final InputFieldsDefinition? inputs;

  @override
  String toString() {
    return '${description == null ? "" : "${description!}"} input ${name} ${directives == null ? "" : "${directives!}"} ${inputs == null ? "" : "${inputs!}"} ';
  }

  const InputObjectTypeDefinition({
    required this.name,
    this.description,
    this.directives,
    this.inputs,
  });

  InputObjectTypeDefinition copyWith({
    StringValue? description,
    String? name,
    Directives? directives,
    InputFieldsDefinition? inputs,
  }) {
    return InputObjectTypeDefinition(
      name: name ?? this.name,
      description: description ?? this.description,
      directives: directives ?? this.directives,
      inputs: inputs ?? this.inputs,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is InputObjectTypeDefinition) {
      return this.description == other.description &&
          this.name == other.name &&
          this.directives == other.directives &&
          this.inputs == other.inputs;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(description, name, directives, inputs);

  static InputObjectTypeDefinition fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is InputObjectTypeDefinition) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return InputObjectTypeDefinition(
      name: map['name'] as String,
      description: map['description'] == null
          ? null
          : StringValue.fromJson(map['description']),
      directives: map['directives'] == null
          ? null
          : Directives.fromJson(map['directives']),
      inputs: map['inputs'] == null
          ? null
          : InputFieldsDefinition.fromJson(map['inputs']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description?.toJson(),
      'name': name,
      'directives': directives?.toJson(),
      'inputs': inputs?.toJson(),
    };
  }
}

final inputFieldsDefinition =
    (char('{').trim() & inputValueDefinition.trim().plus() & char('}').trim())
        .map((l) {
  return InputFieldsDefinition(
    values: l[1] as List<InputValueDefinition>,
  );
});

class InputFieldsDefinition {
  final List<InputValueDefinition> values;

  @override
  String toString() {
    return '{ ${values.join(" ")} } ';
  }

  const InputFieldsDefinition({
    required this.values,
  });

  InputFieldsDefinition copyWith({
    List<InputValueDefinition>? values,
  }) {
    return InputFieldsDefinition(
      values: values ?? this.values,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is InputFieldsDefinition) {
      return this.values == other.values;
    }
    return false;
  }

  @override
  int get hashCode => values.hashCode;

  static InputFieldsDefinition fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is InputFieldsDefinition) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return InputFieldsDefinition(
      values: (map['values'] as List)
          .map((e) => InputValueDefinition.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'values': values.map((e) => e.toJson()).toList(),
    };
  }
}

final directiveDefinition = (stringValue.trim() &
        string('directive').trim() &
        char('@').trim() &
        name.trim() &
        argumentsDefinition.trim().optional() &
        string('on').trim() &
        directiveLocations.trim())
    .map((l) {
  return DirectiveDefinition(
    description: l[0] as StringValue,
    name: l[3] as String,
    arguments: l[4] as ArgumentsDefinition?,
    locations: l[6] as DirectiveLocations,
  );
});

class DirectiveDefinition {
  final StringValue description;
  final String name;
  final ArgumentsDefinition? arguments;
  final DirectiveLocations locations;

  @override
  String toString() {
    return '${description} directive @ ${name} ${arguments == null ? "" : "${arguments!}"} on ${locations} ';
  }

  const DirectiveDefinition({
    required this.description,
    required this.name,
    required this.locations,
    this.arguments,
  });

  DirectiveDefinition copyWith({
    StringValue? description,
    String? name,
    ArgumentsDefinition? arguments,
    DirectiveLocations? locations,
  }) {
    return DirectiveDefinition(
      description: description ?? this.description,
      name: name ?? this.name,
      locations: locations ?? this.locations,
      arguments: arguments ?? this.arguments,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is DirectiveDefinition) {
      return this.description == other.description &&
          this.name == other.name &&
          this.arguments == other.arguments &&
          this.locations == other.locations;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(description, name, arguments, locations);

  static DirectiveDefinition fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is DirectiveDefinition) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return DirectiveDefinition(
      description: StringValue.fromJson(map['description']),
      name: map['name'] as String,
      locations: DirectiveLocations.fromJson(map['locations']),
      arguments: map['arguments'] == null
          ? null
          : ArgumentsDefinition.fromJson(map['arguments']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description.toJson(),
      'name': name,
      'arguments': arguments?.toJson(),
      'locations': locations.toJson(),
    };
  }
}

SettableParser<DirectiveLocations>? _directiveLocations;

Parser<DirectiveLocations> get directiveLocations {
  if (_directiveLocations != null) {
    return _directiveLocations!;
  }
  _directiveLocations = undefined();
  final p = ((char('|').trim().optional() & directiveLocation.trim()).map((l) {
            return DirectiveLocationItem(
              location: l[1] as DirectiveLocation,
            );
          }).map((v) => DirectiveLocations.directiveLocationItem(value: v)) |
          (directiveLocations.trim() &
                  char('|').trim() &
                  directiveLocation.trim())
              .map((l) {
            return DirectiveLocationItemList(
              other: l[0] as DirectiveLocations,
              location: l[2] as DirectiveLocation,
            );
          }).map((v) => DirectiveLocations.directiveLocationItemList(value: v)))
      .cast<DirectiveLocations>();
  _directiveLocations!.set(p);
  return _directiveLocations!;
}

abstract class DirectiveLocations {
  const DirectiveLocations._();

  @override
  String toString() {
    return value.toString();
  }

  const factory DirectiveLocations.directiveLocationItem({
    required DirectiveLocationItem value,
  }) = directiveLocationsDirectiveLocationItem;
  const factory DirectiveLocations.directiveLocationItemList({
    required DirectiveLocationItemList value,
  }) = directiveLocationsDirectiveLocationItemList;

  Object get value;

  _T when<_T>({
    required _T Function(DirectiveLocationItem value) directiveLocationItem,
    required _T Function(DirectiveLocationItemList value)
        directiveLocationItemList,
  }) {
    final v = this;
    if (v is directiveLocationsDirectiveLocationItem) {
      return directiveLocationItem(v.value);
    } else if (v is directiveLocationsDirectiveLocationItemList) {
      return directiveLocationItemList(v.value);
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(DirectiveLocationItem value)? directiveLocationItem,
    _T Function(DirectiveLocationItemList value)? directiveLocationItemList,
  }) {
    final v = this;
    if (v is directiveLocationsDirectiveLocationItem) {
      return directiveLocationItem != null
          ? directiveLocationItem(v.value)
          : orElse.call();
    } else if (v is directiveLocationsDirectiveLocationItemList) {
      return directiveLocationItemList != null
          ? directiveLocationItemList(v.value)
          : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(directiveLocationsDirectiveLocationItem value)
        directiveLocationItem,
    required _T Function(directiveLocationsDirectiveLocationItemList value)
        directiveLocationItemList,
  }) {
    final v = this;
    if (v is directiveLocationsDirectiveLocationItem) {
      return directiveLocationItem(v);
    } else if (v is directiveLocationsDirectiveLocationItemList) {
      return directiveLocationItemList(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(directiveLocationsDirectiveLocationItem value)?
        directiveLocationItem,
    _T Function(directiveLocationsDirectiveLocationItemList value)?
        directiveLocationItemList,
  }) {
    final v = this;
    if (v is directiveLocationsDirectiveLocationItem) {
      return directiveLocationItem != null
          ? directiveLocationItem(v)
          : orElse.call();
    } else if (v is directiveLocationsDirectiveLocationItemList) {
      return directiveLocationItemList != null
          ? directiveLocationItemList(v)
          : orElse.call();
    }
    throw Exception();
  }

  bool get isDirectiveLocationItem =>
      this is directiveLocationsDirectiveLocationItem;
  bool get isDirectiveLocationItemList =>
      this is directiveLocationsDirectiveLocationItemList;

  static DirectiveLocations fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is DirectiveLocations) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    switch (map['runtimeType'] as String) {
      case 'directiveLocationItem':
        return directiveLocationsDirectiveLocationItem.fromJson(map);
      case 'directiveLocationItemList':
        return directiveLocationsDirectiveLocationItemList.fromJson(map);
      default:
        throw Exception('Invalid discriminator for DirectiveLocations.fromJson '
            '${map["runtimeType"]}. Input map: $map');
    }
  }

  Map<String, dynamic> toJson();
}

class directiveLocationsDirectiveLocationItem extends DirectiveLocations {
  final DirectiveLocationItem value;

  const directiveLocationsDirectiveLocationItem({
    required this.value,
  }) : super._();

  directiveLocationsDirectiveLocationItem copyWith({
    DirectiveLocationItem? value,
  }) {
    return directiveLocationsDirectiveLocationItem(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is directiveLocationsDirectiveLocationItem) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static directiveLocationsDirectiveLocationItem fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is directiveLocationsDirectiveLocationItem) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return directiveLocationsDirectiveLocationItem(
      value: DirectiveLocationItem.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'directiveLocationItem',
      'value': value.toJson(),
    };
  }
}

class directiveLocationsDirectiveLocationItemList extends DirectiveLocations {
  final DirectiveLocationItemList value;

  const directiveLocationsDirectiveLocationItemList({
    required this.value,
  }) : super._();

  directiveLocationsDirectiveLocationItemList copyWith({
    DirectiveLocationItemList? value,
  }) {
    return directiveLocationsDirectiveLocationItemList(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is directiveLocationsDirectiveLocationItemList) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static directiveLocationsDirectiveLocationItemList fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is directiveLocationsDirectiveLocationItemList) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return directiveLocationsDirectiveLocationItemList(
      value: DirectiveLocationItemList.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'directiveLocationItemList',
      'value': value.toJson(),
    };
  }
}

class DirectiveLocationItem {
  final DirectiveLocation location;

  @override
  String toString() {
    return '| ${location} ';
  }

  const DirectiveLocationItem({
    required this.location,
  });

  DirectiveLocationItem copyWith({
    DirectiveLocation? location,
  }) {
    return DirectiveLocationItem(
      location: location ?? this.location,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is DirectiveLocationItem) {
      return this.location == other.location;
    }
    return false;
  }

  @override
  int get hashCode => location.hashCode;

  static DirectiveLocationItem fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is DirectiveLocationItem) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return DirectiveLocationItem(
      location: DirectiveLocation.fromJson(map['location']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
    };
  }
}

class DirectiveLocationItemList {
  final DirectiveLocations other;
  final DirectiveLocation location;

  @override
  String toString() {
    return '${other} | ${location} ';
  }

  const DirectiveLocationItemList({
    required this.other,
    required this.location,
  });

  DirectiveLocationItemList copyWith({
    DirectiveLocations? other,
    DirectiveLocation? location,
  }) {
    return DirectiveLocationItemList(
      other: other ?? this.other,
      location: location ?? this.location,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is DirectiveLocationItemList) {
      return this.other == other.other && this.location == other.location;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(other, location);

  static DirectiveLocationItemList fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is DirectiveLocationItemList) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return DirectiveLocationItemList(
      other: DirectiveLocations.fromJson(map['other']),
      location: DirectiveLocation.fromJson(map['location']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'other': other.toJson(),
      'location': location.toJson(),
    };
  }
}

final directiveLocation = ((executableDirectiveLocation
            .map((v) => DirectiveLocation.executable(value: v)) |
        typeSystemDirectiveLocation
            .map((v) => DirectiveLocation.typeSystem(value: v)))
    .cast<DirectiveLocation>());

abstract class DirectiveLocation {
  const DirectiveLocation._();

  @override
  String toString() {
    return value.toString();
  }

  const factory DirectiveLocation.executable({
    required ExecutableDirectiveLocation value,
  }) = DirectiveLocationExecutable;
  const factory DirectiveLocation.typeSystem({
    required TypeSystemDirectiveLocation value,
  }) = DirectiveLocationTypeSystem;

  Object get value;

  _T when<_T>({
    required _T Function(ExecutableDirectiveLocation value) executable,
    required _T Function(TypeSystemDirectiveLocation value) typeSystem,
  }) {
    final v = this;
    if (v is DirectiveLocationExecutable) {
      return executable(v.value);
    } else if (v is DirectiveLocationTypeSystem) {
      return typeSystem(v.value);
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(ExecutableDirectiveLocation value)? executable,
    _T Function(TypeSystemDirectiveLocation value)? typeSystem,
  }) {
    final v = this;
    if (v is DirectiveLocationExecutable) {
      return executable != null ? executable(v.value) : orElse.call();
    } else if (v is DirectiveLocationTypeSystem) {
      return typeSystem != null ? typeSystem(v.value) : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(DirectiveLocationExecutable value) executable,
    required _T Function(DirectiveLocationTypeSystem value) typeSystem,
  }) {
    final v = this;
    if (v is DirectiveLocationExecutable) {
      return executable(v);
    } else if (v is DirectiveLocationTypeSystem) {
      return typeSystem(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(DirectiveLocationExecutable value)? executable,
    _T Function(DirectiveLocationTypeSystem value)? typeSystem,
  }) {
    final v = this;
    if (v is DirectiveLocationExecutable) {
      return executable != null ? executable(v) : orElse.call();
    } else if (v is DirectiveLocationTypeSystem) {
      return typeSystem != null ? typeSystem(v) : orElse.call();
    }
    throw Exception();
  }

  bool get isExecutable => this is DirectiveLocationExecutable;
  bool get isTypeSystem => this is DirectiveLocationTypeSystem;

  static DirectiveLocation fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is DirectiveLocation) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    switch (map['runtimeType'] as String) {
      case 'executable':
        return DirectiveLocationExecutable.fromJson(map);
      case 'typeSystem':
        return DirectiveLocationTypeSystem.fromJson(map);
      default:
        throw Exception('Invalid discriminator for DirectiveLocation.fromJson '
            '${map["runtimeType"]}. Input map: $map');
    }
  }

  Map<String, dynamic> toJson();
}

class DirectiveLocationExecutable extends DirectiveLocation {
  final ExecutableDirectiveLocation value;

  const DirectiveLocationExecutable({
    required this.value,
  }) : super._();

  DirectiveLocationExecutable copyWith({
    ExecutableDirectiveLocation? value,
  }) {
    return DirectiveLocationExecutable(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is DirectiveLocationExecutable) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static DirectiveLocationExecutable fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is DirectiveLocationExecutable) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return DirectiveLocationExecutable(
      value: ExecutableDirectiveLocation.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'executable',
      'value': value.toJson(),
    };
  }
}

class DirectiveLocationTypeSystem extends DirectiveLocation {
  final TypeSystemDirectiveLocation value;

  const DirectiveLocationTypeSystem({
    required this.value,
  }) : super._();

  DirectiveLocationTypeSystem copyWith({
    TypeSystemDirectiveLocation? value,
  }) {
    return DirectiveLocationTypeSystem(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is DirectiveLocationTypeSystem) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static DirectiveLocationTypeSystem fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is DirectiveLocationTypeSystem) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return DirectiveLocationTypeSystem(
      value: TypeSystemDirectiveLocation.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'typeSystem',
      'value': value.toJson(),
    };
  }
}

final executableDirectiveLocation = ((string('QUERY')
            .map((_) => ExecutableDirectiveLocation.query) |
        string('MUTATION').map((_) => ExecutableDirectiveLocation.mutation) |
        string('SUBSCRIPTION')
            .map((_) => ExecutableDirectiveLocation.subscription) |
        string('FIELD').map((_) => ExecutableDirectiveLocation.field) |
        string('FRAGMENT_DEFINITION')
            .map((_) => ExecutableDirectiveLocation.fragmentdefinition) |
        string('FRAGMENT_SPREAD')
            .map((_) => ExecutableDirectiveLocation.fragmentspread) |
        string('INLINE_FRAGMENT')
            .map((_) => ExecutableDirectiveLocation.inlinefragment))
    .cast<ExecutableDirectiveLocation>());

class ExecutableDirectiveLocation {
  final String _inner;

  const ExecutableDirectiveLocation._(this._inner);

  static const query = ExecutableDirectiveLocation._('query');
  static const mutation = ExecutableDirectiveLocation._('mutation');
  static const subscription = ExecutableDirectiveLocation._('subscription');
  static const field = ExecutableDirectiveLocation._('field');
  static const fragmentdefinition =
      ExecutableDirectiveLocation._('fragment_definition');
  static const fragmentspread =
      ExecutableDirectiveLocation._('fragment_spread');
  static const inlinefragment =
      ExecutableDirectiveLocation._('inline_fragment');

  static const values = [
    ExecutableDirectiveLocation.query,
    ExecutableDirectiveLocation.mutation,
    ExecutableDirectiveLocation.subscription,
    ExecutableDirectiveLocation.field,
    ExecutableDirectiveLocation.fragmentdefinition,
    ExecutableDirectiveLocation.fragmentspread,
    ExecutableDirectiveLocation.inlinefragment,
  ];

  static ExecutableDirectiveLocation fromJson(Object? json) {
    if (json == null) {
      throw Error();
    }
    for (final v in values) {
      if (json.toString() == v._inner) {
        return v;
      }
    }
    throw Error();
  }

  String toJson() {
    return _inner;
  }

  @override
  String toString() {
    return _inner;
  }

  @override
  bool operator ==(Object other) {
    return other is ExecutableDirectiveLocation &&
        other.runtimeType == runtimeType &&
        other._inner == _inner;
  }

  @override
  int get hashCode => _inner.hashCode;

  bool get isQuery => this == ExecutableDirectiveLocation.query;
  bool get isMutation => this == ExecutableDirectiveLocation.mutation;
  bool get isSubscription => this == ExecutableDirectiveLocation.subscription;
  bool get isField => this == ExecutableDirectiveLocation.field;
  bool get isFragmentdefinition =>
      this == ExecutableDirectiveLocation.fragmentdefinition;
  bool get isFragmentspread =>
      this == ExecutableDirectiveLocation.fragmentspread;
  bool get isInlinefragment =>
      this == ExecutableDirectiveLocation.inlinefragment;

  _T when<_T>({
    required _T Function() query,
    required _T Function() mutation,
    required _T Function() subscription,
    required _T Function() field,
    required _T Function() fragmentdefinition,
    required _T Function() fragmentspread,
    required _T Function() inlinefragment,
  }) {
    switch (this._inner) {
      case 'query':
        return query();
      case 'mutation':
        return mutation();
      case 'subscription':
        return subscription();
      case 'field':
        return field();
      case 'fragment_definition':
        return fragmentdefinition();
      case 'fragment_spread':
        return fragmentspread();
      case 'inline_fragment':
        return inlinefragment();
    }
    throw Error();
  }

  _T maybeWhen<_T>({
    _T Function()? query,
    _T Function()? mutation,
    _T Function()? subscription,
    _T Function()? field,
    _T Function()? fragmentdefinition,
    _T Function()? fragmentspread,
    _T Function()? inlinefragment,
    required _T Function() orElse,
  }) {
    _T Function()? c;
    switch (this._inner) {
      case 'query':
        c = query;
        break;
      case 'mutation':
        c = mutation;
        break;
      case 'subscription':
        c = subscription;
        break;
      case 'field':
        c = field;
        break;
      case 'fragment_definition':
        c = fragmentdefinition;
        break;
      case 'fragment_spread':
        c = fragmentspread;
        break;
      case 'inline_fragment':
        c = inlinefragment;
        break;
    }
    return (c ?? orElse).call();
  }
}

final typeSystemDirectiveLocation = ((string('SCHEMA')
            .map((_) => TypeSystemDirectiveLocation.schema) |
        string('SCALAR').map((_) => TypeSystemDirectiveLocation.scalar) |
        string('OBJECT').map((_) => TypeSystemDirectiveLocation.object) |
        string('FIELD_DEFINITION')
            .map((_) => TypeSystemDirectiveLocation.fielddefinition) |
        string('ARGUMENT_DEFINITION')
            .map((_) => TypeSystemDirectiveLocation.argumentdefinition) |
        string('INTERFACE').map((_) => TypeSystemDirectiveLocation.interface) |
        string('UNION').map((_) => TypeSystemDirectiveLocation.union) |
        string('ENUM_VALUE').map((_) => TypeSystemDirectiveLocation.enumvalue) |
        string('ENUM').map((_) => TypeSystemDirectiveLocation.enum_) |
        string('INPUT_OBJECT')
            .map((_) => TypeSystemDirectiveLocation.inputobject) |
        string('INPUT_FIELD_DEFINITION')
            .map((_) => TypeSystemDirectiveLocation.inputfield_definition))
    .cast<TypeSystemDirectiveLocation>());

class TypeSystemDirectiveLocation {
  final String _inner;

  const TypeSystemDirectiveLocation._(this._inner);

  static const schema = TypeSystemDirectiveLocation._('schema');
  static const scalar = TypeSystemDirectiveLocation._('scalar');
  static const object = TypeSystemDirectiveLocation._('object');
  static const fielddefinition =
      TypeSystemDirectiveLocation._('field_definition');
  static const argumentdefinition =
      TypeSystemDirectiveLocation._('argument_definition');
  static const interface = TypeSystemDirectiveLocation._('interface');
  static const union = TypeSystemDirectiveLocation._('union');
  static const enumvalue = TypeSystemDirectiveLocation._('enum_value');
  static const enum_ = TypeSystemDirectiveLocation._('enum');
  static const inputobject = TypeSystemDirectiveLocation._('input_object');
  static const inputfield_definition =
      TypeSystemDirectiveLocation._('input_field_definition');

  static const values = [
    TypeSystemDirectiveLocation.schema,
    TypeSystemDirectiveLocation.scalar,
    TypeSystemDirectiveLocation.object,
    TypeSystemDirectiveLocation.fielddefinition,
    TypeSystemDirectiveLocation.argumentdefinition,
    TypeSystemDirectiveLocation.interface,
    TypeSystemDirectiveLocation.union,
    TypeSystemDirectiveLocation.enumvalue,
    TypeSystemDirectiveLocation.enum_,
    TypeSystemDirectiveLocation.inputobject,
    TypeSystemDirectiveLocation.inputfield_definition,
  ];

  static TypeSystemDirectiveLocation fromJson(Object? json) {
    if (json == null) {
      throw Error();
    }
    for (final v in values) {
      if (json.toString() == v._inner) {
        return v;
      }
    }
    throw Error();
  }

  String toJson() {
    return _inner;
  }

  @override
  String toString() {
    return _inner;
  }

  @override
  bool operator ==(Object other) {
    return other is TypeSystemDirectiveLocation &&
        other.runtimeType == runtimeType &&
        other._inner == _inner;
  }

  @override
  int get hashCode => _inner.hashCode;

  bool get isSchema => this == TypeSystemDirectiveLocation.schema;
  bool get isScalar => this == TypeSystemDirectiveLocation.scalar;
  bool get isObject => this == TypeSystemDirectiveLocation.object;
  bool get isFielddefinition =>
      this == TypeSystemDirectiveLocation.fielddefinition;
  bool get isArgumentdefinition =>
      this == TypeSystemDirectiveLocation.argumentdefinition;
  bool get isInterface => this == TypeSystemDirectiveLocation.interface;
  bool get isUnion => this == TypeSystemDirectiveLocation.union;
  bool get isEnumvalue => this == TypeSystemDirectiveLocation.enumvalue;
  bool get isEnum_ => this == TypeSystemDirectiveLocation.enum_;
  bool get isInputobject => this == TypeSystemDirectiveLocation.inputobject;
  bool get isInputfield_definition =>
      this == TypeSystemDirectiveLocation.inputfield_definition;

  _T when<_T>({
    required _T Function() schema,
    required _T Function() scalar,
    required _T Function() object,
    required _T Function() fielddefinition,
    required _T Function() argumentdefinition,
    required _T Function() interface,
    required _T Function() union,
    required _T Function() enumvalue,
    required _T Function() enum_,
    required _T Function() inputobject,
    required _T Function() inputfield_definition,
  }) {
    switch (this._inner) {
      case 'schema':
        return schema();
      case 'scalar':
        return scalar();
      case 'object':
        return object();
      case 'field_definition':
        return fielddefinition();
      case 'argument_definition':
        return argumentdefinition();
      case 'interface':
        return interface();
      case 'union':
        return union();
      case 'enum_value':
        return enumvalue();
      case 'enum':
        return enum_();
      case 'input_object':
        return inputobject();
      case 'input_field_definition':
        return inputfield_definition();
    }
    throw Error();
  }

  _T maybeWhen<_T>({
    _T Function()? schema,
    _T Function()? scalar,
    _T Function()? object,
    _T Function()? fielddefinition,
    _T Function()? argumentdefinition,
    _T Function()? interface,
    _T Function()? union,
    _T Function()? enumvalue,
    _T Function()? enum_,
    _T Function()? inputobject,
    _T Function()? inputfield_definition,
    required _T Function() orElse,
  }) {
    _T Function()? c;
    switch (this._inner) {
      case 'schema':
        c = schema;
        break;
      case 'scalar':
        c = scalar;
        break;
      case 'object':
        c = object;
        break;
      case 'field_definition':
        c = fielddefinition;
        break;
      case 'argument_definition':
        c = argumentdefinition;
        break;
      case 'interface':
        c = interface;
        break;
      case 'union':
        c = union;
        break;
      case 'enum_value':
        c = enumvalue;
        break;
      case 'enum':
        c = enum_;
        break;
      case 'input_object':
        c = inputobject;
        break;
      case 'input_field_definition':
        c = inputfield_definition;
        break;
    }
    return (c ?? orElse).call();
  }
}
