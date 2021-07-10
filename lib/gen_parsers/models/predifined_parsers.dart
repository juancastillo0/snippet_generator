

import 'package:petitparser/petitparser.dart';
import 'package:snippet_generator/parsers/parsers.dart';

enum PredifinedParser {
  integer,
  double,
  whitespace,
  digit,
  letter,
  any,
}

extension PredifinedParserToJson on PredifinedParser {
  String toJson() => this.toString().split('.')[1];

  String toDart() {
    switch (this) {
      case PredifinedParser.any:
        return 'any()';
      case PredifinedParser.letter:
        return 'letter()';
      case PredifinedParser.digit:
        return 'digit()';
      case PredifinedParser.whitespace:
        return 'whitespace()';
      case PredifinedParser.integer:
        return 'integerParser';
      case PredifinedParser.double:
        return 'doubleParser';
    }
  }

  String toDartType() {
    switch (this) {
      case PredifinedParser.any:
        return 'String';
      case PredifinedParser.letter:
        return 'String';
      case PredifinedParser.digit:
        return 'String';
      case PredifinedParser.whitespace:
        return 'String';
      case PredifinedParser.integer:
        return 'int';
      case PredifinedParser.double:
        return 'double';
    }
  }

  Parser parser() {
    switch (this) {
      case PredifinedParser.any:
        return any();
      case PredifinedParser.letter:
        return letter();
      case PredifinedParser.digit:
        return digit();
      case PredifinedParser.whitespace:
        return whitespace();
      case PredifinedParser.integer:
        return intParser;
      case PredifinedParser.double:
        return doubleParser;
    }
  }

  String? dartDefinition() {
    switch (this) {
      case PredifinedParser.any:
      case PredifinedParser.letter:
      case PredifinedParser.digit:
      case PredifinedParser.whitespace:
        return null;
      case PredifinedParser.integer:
        return "final integerParser = (char('-').optional() & "
            "char('0').or(pattern('1-9') & digit().star()) "
            ').flatten().map((value) => int.parse(value));';
      case PredifinedParser.double:
        return "final doubleParser =(char('-').optional() & "
            "char('0').or(pattern('1-9') & digit().star()) & "
            "(char('.') & char('0').or(pattern('1-9') & digit().star())).optional() "
            ').flatten().map((value) => double.parse(value));';
    }
  }
}