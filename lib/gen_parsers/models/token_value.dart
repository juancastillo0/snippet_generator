import 'dart:convert';
import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:snippet_generator/gen_parsers/models/predifined_parsers.dart';
import 'package:snippet_generator/gen_parsers/models/tokens.dart';
import 'package:snippet_generator/utils/extensions.dart';

@immutable
abstract class TokenValue {
  const TokenValue._();

  const factory TokenValue.and(
    List<ParserToken> values, {
    required bool flatten,
  }) = TokenValueAnd;
  const factory TokenValue.or(
    List<ParserToken> values,
  ) = TokenValueOr;
  const factory TokenValue.string(
    String value, {
    required bool isPattern,
    required bool caseSensitive,
  }) = TokenValueString;
  const factory TokenValue.ref(
    String value,
  ) = TokenValueRef;
  const factory TokenValue.predifined(
    PredifinedParser value,
  ) = TokenValuePredifined;
  const factory TokenValue.separated({
    required ParserToken item,
    required ParserToken separator,
    required bool includeSeparators,
    required bool optionalSeparatorAtEnd,
  }) = TokenValueSeparated;
  const factory TokenValue.butNot({
    required ParserToken item,
    required ParserToken not,
  }) = TokenValueButNot;

  _T when<_T>({
    required _T Function(List<ParserToken> values, bool flatten) and,
    required _T Function(List<ParserToken> values) or,
    required _T Function(String value, bool isPattern, bool caseSensitive)
        string,
    required _T Function(String value) ref,
    required _T Function(PredifinedParser value) predifined,
    required _T Function(ParserToken item, ParserToken separator,
            bool includeSeparators, bool optionalSeparatorAtEnd)
        separated,
    required _T Function(ParserToken item, ParserToken not) butNot,
  }) {
    final v = this;
    if (v is TokenValueAnd) {
      return and(v.values, v.flatten);
    } else if (v is TokenValueOr) {
      return or(v.values);
    } else if (v is TokenValueString) {
      return string(v.value, v.isPattern, v.caseSensitive);
    } else if (v is TokenValueRef) {
      return ref(v.value);
    } else if (v is TokenValuePredifined) {
      return predifined(v.value);
    } else if (v is TokenValueSeparated) {
      return separated(
          v.item, v.separator, v.includeSeparators, v.optionalSeparatorAtEnd);
    } else if (v is TokenValueButNot) {
      return butNot(v.item, v.not);
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(List<ParserToken> values, bool flatten)? and,
    _T Function(List<ParserToken> values)? or,
    _T Function(String value, bool isPattern, bool caseSensitive)? string,
    _T Function(String value)? ref,
    _T Function(PredifinedParser value)? predifined,
    _T Function(ParserToken item, ParserToken separator, bool includeSeparators,
            bool optionalSeparatorAtEnd)?
        separated,
    _T Function(ParserToken item, ParserToken not)? butNot,
  }) {
    final v = this;
    if (v is TokenValueAnd) {
      return and != null ? and(v.values, v.flatten) : orElse.call();
    } else if (v is TokenValueOr) {
      return or != null ? or(v.values) : orElse.call();
    } else if (v is TokenValueString) {
      return string != null
          ? string(v.value, v.isPattern, v.caseSensitive)
          : orElse.call();
    } else if (v is TokenValueRef) {
      return ref != null ? ref(v.value) : orElse.call();
    } else if (v is TokenValuePredifined) {
      return predifined != null ? predifined(v.value) : orElse.call();
    } else if (v is TokenValueSeparated) {
      return separated != null
          ? separated(v.item, v.separator, v.includeSeparators,
              v.optionalSeparatorAtEnd)
          : orElse.call();
    } else if (v is TokenValueButNot) {
      return butNot != null ? butNot(v.item, v.not) : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(TokenValueAnd value) and,
    required _T Function(TokenValueOr value) or,
    required _T Function(TokenValueString value) string,
    required _T Function(TokenValueRef value) ref,
    required _T Function(TokenValuePredifined value) predifined,
    required _T Function(TokenValueSeparated value) separated,
    required _T Function(TokenValueButNot value) butNot,
  }) {
    final v = this;
    if (v is TokenValueAnd) {
      return and(v);
    } else if (v is TokenValueOr) {
      return or(v);
    } else if (v is TokenValueString) {
      return string(v);
    } else if (v is TokenValueRef) {
      return ref(v);
    } else if (v is TokenValuePredifined) {
      return predifined(v);
    } else if (v is TokenValueSeparated) {
      return separated(v);
    } else if (v is TokenValueButNot) {
      return butNot(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(TokenValueAnd value)? and,
    _T Function(TokenValueOr value)? or,
    _T Function(TokenValueString value)? string,
    _T Function(TokenValueRef value)? ref,
    _T Function(TokenValuePredifined value)? predifined,
    _T Function(TokenValueSeparated value)? separated,
    _T Function(TokenValueButNot value)? butNot,
  }) {
    final v = this;
    if (v is TokenValueAnd) {
      return and != null ? and(v) : orElse.call();
    } else if (v is TokenValueOr) {
      return or != null ? or(v) : orElse.call();
    } else if (v is TokenValueString) {
      return string != null ? string(v) : orElse.call();
    } else if (v is TokenValueRef) {
      return ref != null ? ref(v) : orElse.call();
    } else if (v is TokenValuePredifined) {
      return predifined != null ? predifined(v) : orElse.call();
    } else if (v is TokenValueSeparated) {
      return separated != null ? separated(v) : orElse.call();
    } else if (v is TokenValueButNot) {
      return butNot != null ? butNot(v) : orElse.call();
    }
    throw Exception();
  }

  bool get isAnd => this is TokenValueAnd;
  bool get isOr => this is TokenValueOr;
  bool get isString => this is TokenValueString;
  bool get isRef => this is TokenValueRef;
  bool get isPredifined => this is TokenValuePredifined;
  bool get isSeparated => this is TokenValueSeparated;
  bool get isButNot => this is TokenValueButNot;

  static TokenValue fromJson(Object? _map) {
    final Map<String, Object?> map;
    if (_map is TokenValue) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    switch (map['runtimeType']) {
      case 'and':
        return TokenValueAnd.fromJson(map);
      case 'or':
        return TokenValueOr.fromJson(map);
      case 'string':
        return TokenValueString.fromJson(map);
      case 'ref':
        return TokenValueRef.fromJson(map);
      case 'predifined':
        return TokenValuePredifined.fromJson(map);
      case 'separated':
        return TokenValueSeparated.fromJson(map);
      case 'butNot':
        return TokenValueButNot.fromJson(map);
      default:
        throw Exception('Invalid discriminator for TokenValue.fromJson '
            '${map["runtimeType"]}. Input map: $map');
    }
  }

  Map<String, dynamic> toJson();
}

class TokenValueAnd extends TokenValue {
  final List<ParserToken> values;
  final bool flatten;

  const TokenValueAnd(
    this.values, {
    required this.flatten,
  }) : super._();

  TokenValueAnd copyWith({
    List<ParserToken>? values,
    bool? flatten,
  }) {
    return TokenValueAnd(
      values ?? this.values,
      flatten: flatten ?? this.flatten,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is TokenValueAnd) {
      return this.values == other.values && this.flatten == other.flatten;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(values, flatten);

  static TokenValueAnd fromJson(Object? _map) {
    final Map<String, Object?> map;
    if (_map is TokenValueAnd) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, Object?>;
    } else {
      map = (_map! as Map).cast();
    }

    return TokenValueAnd(
      (map['values']! as List)
          .map((Object? e) => ParserToken.fromJson(e))
          .toList(),
      flatten: map['flatten']! as bool,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'runtimeType': 'and',
      'values': values.map((e) => e.toJson()).toList(),
      'flatten': flatten,
    };
  }
}

class TokenValueOr extends TokenValue {
  final List<ParserToken> values;

  const TokenValueOr(
    this.values,
  ) : super._();

  TokenValueOr copyWith({
    List<ParserToken>? values,
  }) {
    return TokenValueOr(
      values ?? this.values,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is TokenValueOr) {
      return this.values == other.values;
    }
    return false;
  }

  @override
  int get hashCode => values.hashCode;

  static TokenValueOr fromJson(Object? _map) {
    final Map<String, Object?> map;
    if (_map is TokenValueOr) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, Object?>;
    } else {
      map = (_map! as Map).cast();
    }

    return TokenValueOr(
      (map['values']! as List)
          .map((Object? e) => ParserToken.fromJson(e))
          .toList(),
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'runtimeType': 'or',
      'values': values.map((e) => e.toJson()).toList(),
    };
  }
}

class TokenValueString extends TokenValue {
  final String value;
  final bool isPattern;
  final bool caseSensitive;

  const TokenValueString(
    this.value, {
    required this.isPattern,
    required this.caseSensitive,
  }) : super._();

  TokenValueString copyWith({
    String? value,
    bool? isPattern,
    bool? caseSensitive,
  }) {
    return TokenValueString(
      value ?? this.value,
      isPattern: isPattern ?? this.isPattern,
      caseSensitive: caseSensitive ?? this.caseSensitive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is TokenValueString) {
      return this.value == other.value &&
          this.isPattern == other.isPattern &&
          this.caseSensitive == other.caseSensitive;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(value, isPattern, caseSensitive);

  static TokenValueString fromJson(Object? _map) {
    final Map<String, Object?> map;
    if (_map is TokenValueString) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, Object?>;
    } else {
      map = (_map! as Map).cast();
    }

    return TokenValueString(
      map['value']! as String,
      isPattern: map['isPattern']! as bool,
      caseSensitive: map['caseSensitive']! as bool,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'runtimeType': 'string',
      'value': value,
      'isPattern': isPattern,
      'caseSensitive': caseSensitive,
    };
  }
}

class TokenValueRef extends TokenValue {
  final String value;

  const TokenValueRef(
    this.value,
  ) : super._();

  TokenValueRef copyWith({
    String? value,
  }) {
    return TokenValueRef(
      value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is TokenValueRef) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static TokenValueRef fromJson(Object? _map) {
    final Map<String, Object?> map;
    if (_map is TokenValueRef) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, Object?>;
    } else {
      map = (_map! as Map).cast();
    }

    return TokenValueRef(
      map['value']! as String,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'runtimeType': 'ref',
      'value': value,
    };
  }
}

class TokenValuePredifined extends TokenValue {
  final PredifinedParser value;

  const TokenValuePredifined(
    this.value,
  ) : super._();

  TokenValuePredifined copyWith({
    PredifinedParser? value,
  }) {
    return TokenValuePredifined(
      value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is TokenValuePredifined) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static TokenValuePredifined fromJson(Object? _map) {
    final Map<String, Object?> map;
    if (_map is TokenValuePredifined) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, Object?>;
    } else {
      map = (_map! as Map).cast();
    }

    return TokenValuePredifined(
      parseEnum(map['value']! as String, PredifinedParser.values)!,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'runtimeType': 'predifined',
      'value': value.toJson(),
    };
  }
}

class TokenValueSeparated extends TokenValue {
  final ParserToken item;
  final ParserToken separator;
  final bool includeSeparators;
  final bool optionalSeparatorAtEnd;

  const TokenValueSeparated({
    required this.item,
    required this.separator,
    required this.includeSeparators,
    required this.optionalSeparatorAtEnd,
  }) : super._();

  TokenValueSeparated copyWith({
    ParserToken? item,
    ParserToken? separator,
    bool? includeSeparators,
    bool? optionalSeparatorAtEnd,
  }) {
    return TokenValueSeparated(
      item: item ?? this.item,
      separator: separator ?? this.separator,
      includeSeparators: includeSeparators ?? this.includeSeparators,
      optionalSeparatorAtEnd:
          optionalSeparatorAtEnd ?? this.optionalSeparatorAtEnd,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is TokenValueSeparated) {
      return this.item == other.item &&
          this.separator == other.separator &&
          this.includeSeparators == other.includeSeparators &&
          this.optionalSeparatorAtEnd == other.optionalSeparatorAtEnd;
    }
    return false;
  }

  @override
  int get hashCode =>
      hashValues(item, separator, includeSeparators, optionalSeparatorAtEnd);

  static TokenValueSeparated fromJson(Object? _map) {
    final Map<String, Object?> map;
    if (_map is TokenValueSeparated) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, Object?>;
    } else {
      map = (_map! as Map).cast();
    }

    return TokenValueSeparated(
      item: ParserToken.fromJson(map['item']),
      separator: ParserToken.fromJson(map['separator']),
      includeSeparators: map['includeSeparators']! as bool,
      optionalSeparatorAtEnd: map['optionalSeparatorAtEnd']! as bool,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'runtimeType': 'separated',
      'item': item.toJson(),
      'separator': separator.toJson(),
      'includeSeparators': includeSeparators,
      'optionalSeparatorAtEnd': optionalSeparatorAtEnd,
    };
  }
}

class TokenValueButNot extends TokenValue {
  final ParserToken item;
  final ParserToken not;

  const TokenValueButNot({
    required this.item,
    required this.not,
  }) : super._();

  TokenValueButNot copyWith({
    ParserToken? item,
    ParserToken? not,
  }) {
    return TokenValueButNot(
      item: item ?? this.item,
      not: not ?? this.not,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is TokenValueButNot) {
      return this.item == other.item && this.not == other.not;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(item, not);

  static TokenValueButNot fromJson(Object? _map) {
    final Map<String, Object?> map;
    if (_map is TokenValueButNot) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, Object?>;
    } else {
      map = (_map! as Map).cast();
    }

    return TokenValueButNot(
      item: ParserToken.fromJson(map['item']),
      not: ParserToken.fromJson(map['not']),
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'runtimeType': 'butNot',
      'item': item.toJson(),
      'not': not.toJson(),
    };
  }
}
