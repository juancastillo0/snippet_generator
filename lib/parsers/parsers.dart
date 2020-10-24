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
