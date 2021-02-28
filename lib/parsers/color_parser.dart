import 'package:flutter/material.dart';
import 'package:petitparser/petitparser.dart';
import 'package:snippet_generator/parsers/parsers.dart';
import 'package:test/test.dart' as test;

const _allMaterialColorsMap = {
  "red": Colors.red,
  "pink": Colors.pink,
  "purple": Colors.purple,
  "deepPurple": Colors.deepPurple,
  "indigo": Colors.indigo,
  "blue": Colors.blue,
  "lightBlue": Colors.lightBlue,
  "cyan": Colors.cyan,
  "teal": Colors.teal,
  "green": Colors.green,
  "lightGreen": Colors.lightGreen,
  "lime": Colors.lime,
  "yellow": Colors.yellow,
  "amber": Colors.amber,
  "orange": Colors.orange,
  "deepOrange": Colors.deepOrange,
  "brown": Colors.brown,
  "blueGrey": Colors.blueGrey,
};
const _allAccentColorsMap = {
  "redAccent": Colors.redAccent,
  "pinkAccent": Colors.pinkAccent,
  "purpleAccent": Colors.purpleAccent,
  "deepPurpleAccent": Colors.deepPurpleAccent,
  "indigoAccent": Colors.indigoAccent,
  "blueAccent": Colors.blueAccent,
  "lightBlueAccent": Colors.lightBlueAccent,
  "cyanAccent": Colors.cyanAccent,
  "tealAccent": Colors.tealAccent,
  "greenAccent": Colors.greenAccent,
  "lightGreenAccent": Colors.lightGreenAccent,
  "limeAccent": Colors.limeAccent,
  "yellowAccent": Colors.yellowAccent,
  "amberAccent": Colors.amberAccent,
  "orangeAccent": Colors.orangeAccent,
  "deepOrangeAccent": Colors.deepOrangeAccent,
};

Color /*!*/ _mapColorFromParse(dynamic value) {
  if (value is List) {
    final colorSwatch =
        _allMaterialColorsMap[value[1]] ?? _allAccentColorsMap[value[1]];
    if (value[2] == null) {
      return colorSwatch;
    } else {
      return colorSwatch[value[2] as int];
    }
  }
  throw Error();
}

final materialColorParser = (string("Colors.").optional() &
        stringsParser(_allMaterialColorsMap.keys) &
        (char("[") &
                stringsParser([
                  50,
                  100,
                  200,
                  300,
                  400,
                  500,
                  600,
                  700,
                  800,
                  900,
                ].map((v) => v.toString())).map(int.parse) &
                char("]"))
            .pick(1)
            .optional())
    .map(_mapColorFromParse);

final accentColorParser = (string("Colors.").optional() &
        stringsParser(_allAccentColorsMap.keys) &
        (char("[") &
                stringsParser([
                  100,
                  200,
                  400,
                  700,
                ].map((v) => v.toString())).map(int.parse) &
                char("]"))
            .pick(1)
            .optional())
    .map(_mapColorFromParse);

final hexColorParser =
    (string("0x").optional() & anyOf("0123456789abcdefABCDEF").repeat(1, 8))
        .pick(1)
        .map((value) {
          if (value is List<String>) {
            final _int = value.length > 6
                ? value.join("")
                : ("FF" +
                    Iterable<int>.generate(6 - value.length)
                        .map((e) => "0")
                        .join() +
                    value.join());
            return Color(int.parse(_int, radix: 16));
          }
          throw Error();
        } as Color Function(dynamic));

final colorParser =
    (accentColorParser | materialColorParser | hexColorParser).cast<Color>();

void main() {
  test.test("main test", () {
    Result<Color> result = colorParser.parse("0xFA783792");
    test.expect(result.isSuccess, true);
    test.expect(result.value, const Color(0xFA783792));

    result = colorParser.parse("783792");
    test.expect(result.isSuccess, true);
    test.expect(result.value, const Color(0xFF783792));

    result = colorParser.parse("AB7");
    test.expect(result.isSuccess, true);
    test.expect(result.value, const Color(0xFF000AB7));

    result = colorParser.parse("red");
    test.expect(result.isSuccess, true);
    test.expect(result.value, Colors.red);

    result = colorParser.parse("yellowAccent");
    test.expect(result.isSuccess, true);
    test.expect(result.value, Colors.yellowAccent);

    result = colorParser.parse("Colors.lime");
    test.expect(result.isSuccess, true);
    test.expect(result.value, Colors.lime);

    result = colorParser.parse("Colors.lime[600]");
    test.expect(result.isSuccess, true);
    test.expect(result.value, Colors.lime[600]);

    result = colorParser.parse("Colors.orangeAccent[400]");
    test.expect(result.isSuccess, true);
    test.expect(result.value, Colors.orangeAccent[400]);
  });
}
