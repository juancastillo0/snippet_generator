import 'package:petitparser/petitparser.dart';

final identifier = (letter() & (letter() | digit()).star()).flatten();

Parser<T> singleGeneric<T>(Parser<T> p) =>
    (char("<") & p.trim() & char(">")).pick<T>(1);

class DoubleGeneric<L, R> {
  const DoubleGeneric(this.left, this.right);
  final L left;
  final R right;

  static Parser<DoubleGeneric<L, R>> parser<L, R>(
    Parser<L> left,
    Parser<R> right,
  ) =>
      (char("<") & left.trim() & char(",") & right.trim() & char(">")).map(
        (list) => DoubleGeneric(list[1] as L, list[3] as R),
      );
}

class ManyGeneric<T> {
  const ManyGeneric(this.list);
  final List<T> list;

  static Parser<ManyGeneric<T>> parser<T>(
    Parser<T> p,
  ) =>
      (char("<") & p.trim() & (char(",") & p.trim()).star() & char(">")).map(
        (list) {
          final out = [list[1] as T];
          if (list[2] != null) {
            int index = 0;
            out.addAll((list[2] as List)
                .where((e) => (index++ % 2) == 1)
                .map((e) => e as T));
          }
          return ManyGeneric(out);
        },
      );
}

Parser<T> enumParser<T>(List<T> enumValues, {String optionalPrefix}) {
  return enumValues.fold<Parser<T>>(null, (value, element) {
    Parser<T> curr =
        string(element.toString().split(".")[1]).map((value) => element);
    if (optionalPrefix != null) {
      curr = (string("$optionalPrefix.").optional() & curr).pick<T>(1);
    }
    if (value == null) {
      value = curr;
    } else {
      value = value.or(curr).map((v) => v as T);
    }
    return value;
  });
}

Parser<String> stringsParser(Iterable<String> enumValues) {
  return enumValues.fold<Parser<String>>(null, (value, element) {
    final curr = string(element);
    if (value == null) {
      value = curr;
    } else {
      value = value.or(curr).map((v) => v as String);
    }
    return value;
  });
}

Parser<List<T>> separatedParser<T>(
  Parser<T> parser, {
  Parser left,
  Parser right,
  Parser separator,
}) {
  return ((left ?? char("[")).trim() &
          parser
              .separatedBy(
                (separator ?? char(",")).trim(),
                includeSeparators: false,
                optionalSeparatorAtEnd: true,
              )
              .optional() &
          (right ?? char("]")).trim())
      .pick(1)
      .map((value) => List.castFrom<dynamic, T>(value as List ?? []));
}
