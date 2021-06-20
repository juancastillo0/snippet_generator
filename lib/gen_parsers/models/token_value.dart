import 'dart:ui';

import 'package:snippet_generator/gen_parsers/models/predifined_parsers.dart';
import 'package:snippet_generator/gen_parsers/models/tokens.dart';
import 'package:snippet_generator/utils/extensions.dart';

abstract class TokenValue {
  const TokenValue._();

  const factory TokenValue.and(
    List<ParserToken> values,
  ) = TokenValueAnd;
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

  _T when<_T>({
    required _T Function(List<ParserToken> values) and,
    required _T Function(List<ParserToken> values) or,
    required _T Function(String value, bool isPattern, bool caseSensitive)
        string,
    required _T Function(String value) ref,
    required _T Function(PredifinedParser value) predifined,
  }) {
    final v = this;
    if (v is TokenValueAnd) {
      return and(v.values);
    } else if (v is TokenValueOr) {
      return or(v.values);
    } else if (v is TokenValueString) {
      return string(v.value, v.isPattern, v.caseSensitive);
    } else if (v is TokenValueRef) {
      return ref(v.value);
    } else if (v is TokenValuePredifined) {
      return predifined(v.value);
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(List<ParserToken> values)? and,
    _T Function(List<ParserToken> values)? or,
    _T Function(String value, bool isPattern, bool caseSensitive)? string,
    _T Function(String value)? ref,
    _T Function(PredifinedParser value)? predifined,
  }) {
    final v = this;
    if (v is TokenValueAnd) {
      return and != null ? and(v.values) : orElse.call();
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
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(TokenValueAnd value) and,
    required _T Function(TokenValueOr value) or,
    required _T Function(TokenValueString value) string,
    required _T Function(TokenValueRef value) ref,
    required _T Function(TokenValuePredifined value) predifined,
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
    }
    throw Exception();
  }

  bool get isAnd => this is TokenValueAnd;
  bool get isOr => this is TokenValueOr;
  bool get isString => this is TokenValueString;
  bool get isRef => this is TokenValueRef;
  bool get isPredifined => this is TokenValuePredifined;

  static TokenValue fromJson(Map<String, dynamic> map) {
    switch (map["runtimeType"] as String) {
      case "and":
        return TokenValueAnd.fromJson(map);
      case "or":
        return TokenValueOr.fromJson(map);
      case "string":
        return TokenValueString.fromJson(map);
      case "ref":
        return TokenValueRef.fromJson(map);
      case "predifined":
        return TokenValuePredifined.fromJson(map);
      default:
        throw Exception(
            'Invalid discriminator for TokenValue.fromJson ${map["runtimeType"]}. Input map: $map');
    }
  }

  Map<String, dynamic> toJson();
}

class TokenValueAnd extends TokenValue {
  final List<ParserToken> values;

  const TokenValueAnd(
    this.values,
  ) : super._();

  TokenValueAnd copyWith({
    List<ParserToken>? values,
  }) {
    return TokenValueAnd(
      values ?? this.values,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is TokenValueAnd) {
      return this.values == other.values;
    }
    return false;
  }

  @override
  int get hashCode => values.hashCode;

  static TokenValueAnd fromJson(Map<String, dynamic> map) {
    return TokenValueAnd(
      (map['values'] as List)
          .map((e) => ParserToken.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "runtimeType": "and",
      "values": values.map((e) => e.toJson()).toList(),
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

  static TokenValueOr fromJson(Map<String, dynamic> map) {
    return TokenValueOr(
      (map['values'] as List)
          .map((e) => ParserToken.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "runtimeType": "or",
      "values": values.map((e) => e.toJson()).toList(),
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

  static TokenValueString fromJson(Map<String, dynamic> map) {
    return TokenValueString(
      map['value'] as String,
      isPattern: map['isPattern'] as bool,
      caseSensitive: map['caseSensitive'] as bool,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "runtimeType": "string",
      "value": value,
      "isPattern": isPattern,
      "caseSensitive": caseSensitive,
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

  static TokenValueRef fromJson(Map<String, dynamic> map) {
    return TokenValueRef(
      map['value'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "runtimeType": "ref",
      "value": value,
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

  static TokenValuePredifined fromJson(Map<String, dynamic> map) {
    return TokenValuePredifined(
      parseEnum(map['value'] as String, PredifinedParser.values)!,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "runtimeType": "predifined",
      "value": value.toJson(),
    };
  }
}
