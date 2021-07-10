import 'package:petitparser/petitparser.dart';
import 'package:snippet_generator/gen_parsers/models/predifined_parsers.dart';
import 'package:snippet_generator/gen_parsers/models/stores.dart';
import 'package:snippet_generator/gen_parsers/models/token_value.dart';
import 'package:snippet_generator/widgets/make_table.dart';

// any
// digit
// letter
// int (min-max-unsigned)
// double (min-max-unsigned)
// whitespace
// bool (ignoreCase)

// pattern
// ignoreCase

// flatten

// trim
// not

// star *
// plus +
// repeat min-max
// times min=max
// optional

// separatedBy

class RepeatRange {
  final int min;
  final int? max;

  const RepeatRange(this.min, [this.max]);

  const RepeatRange.optional()
      : min = 0,
        max = 1;
  const RepeatRange.star()
      : min = 0,
        max = null;
  const RepeatRange.plus()
      : min = 1,
        max = null;
  const RepeatRange.times(int times)
      : min = times,
        max = times;

  bool get isOptionalSingle => min == 0 && isSingle;
  bool get isOptionalMany => min == 0 && canBeMany;
  bool get isStar => min == 0 && max == null;
  bool get isPlus => min == 1 && max == null;
  bool get isFixed => min == max;

  bool get canBeMany => max == null || max! > 1;
  bool get isSingle => max == 1;

  String userString() {
    if (isFixed) {
      return min.toString();
    } else if (max != null) {
      return '$min-$max';
    } else {
      return '$min-*';
    }
  }

  Parser apply(Parser parser) {
    if (max == null) {
      return parser.repeat(min, unbounded);
    } else if (max == 1) {
      return min == 0 ? parser.optional() : parser;
    } else {
      return parser.repeat(min, max);
    }
  }

  String toDart() {
    if (max == null) {
      return min == 0
          ? '.star()'
          : min == 1
              ? '.plus()'
              : '.repeat($min, unbounded)';
    } else if (max == 1) {
      return min == 0 ? '.optional()' : '';
    } else {
      return '.repeat($min, $max)';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
    };
  }

  factory RepeatRange.fromJson(Map<String, dynamic> json) {
    return RepeatRange(
      json['min'] as int,
      json['max'] as int?,
    );
  }
}

class ParserToken {
  final String name;
  final String? parentKey;
  final TokenValue value;
  final RepeatRange repeat;
  final bool trim;
  final bool negated;

  const ParserToken({
    required this.name,
    required this.value,
    required this.repeat,
    required this.trim,
    required this.negated,
    required this.parentKey,
  });

  const ParserToken.def({
    this.name = '',
    this.value =
        const TokenValue.string('', isPattern: false, caseSensitive: true),
    this.repeat = const RepeatRange.times(1),
    this.trim = true,
    this.negated = false,
    this.parentKey,
  });

  ParserToken copyWith({
    String? name,
    TokenValue? value,
    RepeatRange? repeat,
    bool? trim,
    bool? negated,
    Ref<String?>? parentKey,
  }) {
    return ParserToken(
      name: name ?? this.name,
      value: value ?? this.value,
      repeat: repeat ?? this.repeat,
      trim: trim ?? this.trim,
      negated: negated ?? this.negated,
      parentKey: parentKey != null ? parentKey.value : this.parentKey,
    );
  }

  String dartType(
    Map<String, ParserTokenNotifier> tokens, {
    required ParserToken? parent,
  }) {
    return this.value.map(
          and: (and) => and.flatten ? 'String' : this.name.toClassName(),
          or: (or) =>
              (parent?.name.toClassName() ?? '') + this.name.toClassName(),
          string: (string) => 'String',
          ref: (ref) =>
              tokens[ref.value]?.value.dartType(tokens, parent: null) ?? '',
          predifined: (predifined) => predifined.value.toDartType(),
          separated: (separated) => 'List<${separated.item.dartType(
            tokens,
            parent: this,
          )}>',
        );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value.toJson(),
      'repeat': repeat.toJson(),
      'trim': trim,
      'negated': negated,
      'parentKey': parentKey,
    };
  }

  factory ParserToken.fromJson(Map<String, dynamic> map) {
    return ParserToken(
      name: map['name'] as String,
      value: TokenValue.fromJson(map['value'] as Map<String, dynamic>),
      repeat: RepeatRange.fromJson(map['repeat'] as Map<String, dynamic>),
      trim: map['trim'] as bool,
      negated: map['negated'] as bool,
      parentKey: map['parentKey'] as String?,
    );
  }
}
