import 'package:snippet_generator/gen_parsers/models/token_value.dart';

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

  bool get isOptional => min == 0 && max == 1;
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

  String toDart() {
    if (max == null) {
      return '.repeat($min)';
    } else if (max == 1) {
      return min == 0 ? '.optional()' : '';
    } else {
      return '.repeat($min, $max)';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "min": min,
      "max": max,
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
  });

  const ParserToken.def({
    this.name = '',
    this.value = const TokenValue.string('', isPattern: false, caseSensitive: true),
    this.repeat = const RepeatRange.times(1),
    this.trim = true,
    this.negated = false,
  });

  ParserToken copyWith({
    String? name,
    TokenValue? value,
    RepeatRange? repeat,
    bool? trim,
    bool? negated,
  }) {
    return ParserToken(
      name: name ?? this.name,
      value: value ?? this.value,
      repeat: repeat ?? this.repeat,
      trim: trim ?? this.trim,
      negated: negated ?? this.negated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value.toJson(),
      'repeat': repeat.toJson(),
      'trim': trim,
      'negated': negated,
    };
  }

  factory ParserToken.fromJson(Map<String, dynamic> map) {
    return ParserToken(
      name: map['name'] as String,
      value: TokenValue.fromJson(map['value'] as Map<String, dynamic>),
      repeat: RepeatRange.fromJson(map['repeat'] as Map<String, dynamic>),
      trim: map['trim'] as bool,
      negated: map['negated'] as bool,
    );
  }
}
