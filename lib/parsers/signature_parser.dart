import 'package:snippet_generator/parsers/parsers.dart';
import 'package:petitparser/petitparser.dart';

class SignatureParser {
  const SignatureParser(this.name, this.generics);
  final String name;
  final List<SignatureGeneric> generics;

  List<String> get genericIds => generics.map((e) => e.id).toList();

  static final parser = (identifier &
          ManyGeneric.parser(SignatureGeneric.parser).trim().optional())
      .map(
    (value) => SignatureParser(
      value[0] as String,
      value[1] != null ? (value[1] as ManyGeneric<SignatureGeneric>).list : [],
    ),
  );
}

class SignatureGeneric {
  const SignatureGeneric(this.id, this.inherits);
  final String id;
  final String inherits;

  static final parser =
      (identifier & (string("extends") & identifier.trim()).trim().optional())
          .map(
    (value) => SignatureGeneric(
      value[0] as String,
      value[1] != null ? value[1][1] as String : null,
    ),
  );
}
