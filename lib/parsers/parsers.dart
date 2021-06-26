import 'package:petitparser/petitparser.dart';

final identifier = (letter() & (letter() | digit()).star()).flatten();

Parser<T> singleGeneric<T>(Parser<T> p) =>
    (char('<') & p.trim() & char('>')).pick(1).cast();

class DoubleGeneric<L, R> {
  const DoubleGeneric(this.left, this.right);
  final L left;
  final R right;

  static Parser<DoubleGeneric<L, R>> parser<L, R>(
    Parser<L> left,
    Parser<R> right,
  ) =>
      (char('<') & left.trim() & char(',') & right.trim() & char('>')).map(
        (list) => DoubleGeneric(list[1] as L, list[3] as R),
      );
}

class ManyGeneric<T> {
  const ManyGeneric(this.list);
  final List<T> list;

  static Parser<ManyGeneric<T>> parser<T>(
    Parser<T> p,
  ) =>
      (char('<') & p.trim() & (char(',') & p.trim()).star() & char('>')).map(
        (list) {
          final out = [list[1] as T];
          if (list[2] != null) {
            int index = 0;
            out.addAll((list[2] as List)
                .expand((l) => l as List)
                .where((e) => (index++ % 2) == 1)
                .map((e) => e as T));
          }
          return ManyGeneric(out);
        },
      );
}

Parser<T> enumParser<T>(List<T> enumValues, {String? optionalPrefix}) {
  return enumValues.fold<Parser<T>?>(null, (Parser<T>? value, T element) {
    Parser<T> curr =
        string(element.toString().split('.')[1]).map((value) => element);
    if (optionalPrefix != null) {
      curr = (string('$optionalPrefix.').optional() & curr).pick(1).cast();
    }
    if (value == null) {
      value = curr;
    } else {
      value = value.or(curr).cast();
    }
    return value;
  })!;
}

Parser<String> stringsParser(Iterable<String> enumValues) {
  return enumValues.fold<Parser<String>?>(null, (value, element) {
    final curr = string(element);
    if (value == null) {
      value = curr;
    } else {
      value = value.or(curr).cast<String>();
    }
    return value;
  })!;
}

Parser<List<T>> separatedParser<T>(
  Parser<T> parser, {
  Parser? left,
  Parser? right,
  Parser? separator,
}) {
  return ((left ?? char('[')).trim() &
          parser
              .separatedBy(
                (separator ?? char(',')).trim(),
                includeSeparators: false,
                optionalSeparatorAtEnd: true,
              )
              .optional() &
          (right ?? char(']')).trim())
      .pick(1)
      .map((value) => List.castFrom<dynamic, T>(value as List? ?? []));
}

Parser<Map<String, T>> structParser<T>(
  Map<String, Parser<T>> params, {
  String? optionalName,
}) {
  final parser = separatedParser(
    structParamsParser(params),
    left: char('('),
    right: char(')'),
  ).map((entries) => Map.fromEntries(entries));
  final hasFactory = params['factory'] != null;

  Parser<Map<String, T>> result = parser;

  if (hasFactory && optionalName != null) {
    result = ((string(optionalName).trim() & char('.').trim()).optional() &
            params['factory']!.optional() &
            parser)
        .map((value) {
      final r = value[2] as Map<String, T>;
      if (value[1] != null) {
        r['factory'] = value[1] as T;
      }
      return r;
    });
  } else if (hasFactory) {
    result = (params['factory']!.optional() & parser).map((value) {
      final r = value[1] as Map<String, T>;
      if (value[0] != null) {
        r['factory'] = value[0] as T;
      }
      return r;
    });
  } else if (optionalName != null) {
    result = (string(optionalName).trim().optional() & parser).pick(1).cast();
  }
  return result;
}

Parser<MapEntry<String, T>> structParamsParser<T>(
    Map<String, Parser<T>> params) {
  final parser = params.entries.fold<Parser<MapEntry<String, T>>?>(null,
      (previousValue, element) {
    final curr =
        (string(element.key).trim() & char(':').trim() & element.value.trim())
            .map((value) => MapEntry(value[0] as String, value[2] as T));
    if (previousValue == null) {
      previousValue = curr;
    } else {
      previousValue = previousValue.or(curr).cast<MapEntry<String, T>>();
    }
    return previousValue;
  })!;
  return parser;
}

Parser<String> orManyString(Iterable<String> params) {
  return orMany<String, String>(params, (s) => string(s));
}

Parser<T> orMany<T, V>(Iterable<V> params, Parser<T> Function(V) parserFn) {
  final parser = params.fold<Parser<T>?>(null, (previousValue, element) {
    final curr = parserFn(element);
    if (previousValue == null) {
      previousValue = curr;
    } else {
      previousValue = previousValue.or(curr).cast<T>();
    }
    return previousValue;
  })!;
  return parser;
}

Parser<MapEntry<String, Token<T>>> structParamsParserToken<T>(
    Map<String, Parser<T>> params) {
  final parser = params.entries.fold<Parser<MapEntry<String, Token<T>>>?>(null,
      (previousValue, element) {
    final curr = (string(element.key).trim() &
            char(':').trim() &
            element.value.trim().token())
        .map((value) => MapEntry(value[0] as String, value[2] as Token<T>));
    if (previousValue == null) {
      previousValue = curr;
    } else {
      previousValue = previousValue.or(curr).cast<MapEntry<String, Token<T>>>();
    }
    return previousValue;
  })!;
  return parser;
}

Parser<List<T>> tupleParser<T>(
  List<Parser<T>> params, {
  String? optionalName,
  int? numberRequired,
}) {
  int index = 0;
  final parser = (char('(').trim() &
          params.fold<Parser<List<T>>?>(null,
              (Parser<List<T>>? previousValue, Parser<T> element) {
            Parser curr = element.trim();

            if (index == params.length - 1) {
              curr = (curr & char(',').trim().optional()).pick(0);
            } else {
              curr = (curr & char(',').trim()).pick(0);
            }
            if (numberRequired != null && index > numberRequired) {
              curr = curr.optional();
            }

            if (previousValue == null) {
              previousValue = curr.map((value) => [value as T]);
            } else {
              previousValue = previousValue
                  .seq(curr)
                  .map((v) => List.castFrom((v[0] as List)..add(v[1])));
            }
            index++;
            return previousValue;
          })! &
          char(')').trim())
      .pick(1)
      .cast<List<T>>();

  if (optionalName != null) {
    return (string(optionalName).trim().optional() & parser).pick(1).cast();
  }
  return parser;
}

final boolParser =
    (string('true') | string('false')).map((value) => value == 'true');

final _num = char('0').or(pattern('1-9') & digit().star());
final unsignedIntParser = _num.flatten().map((value) => int.parse(value));
final intParser =
    (char('-').optional() & _num).flatten().map((value) => int.parse(value));
final unsignedDoubleParser = (_num & char('.').seq(_num).optional())
    .flatten()
    .map((value) => double.parse(value));
final doubleParser =
    (char('-').optional() & _num & char('.').seq(_num).optional())
        .flatten()
        .map((value) => double.parse(value));
