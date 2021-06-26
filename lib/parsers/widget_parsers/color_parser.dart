import 'package:flutter/material.dart';
import 'package:petitparser/petitparser.dart';
import 'package:snippet_generator/parsers/parsers.dart';
import 'package:test/test.dart' as test;

const _allMaterialColorsMap = {
  'red': Colors.red,
  'pink': Colors.pink,
  'purple': Colors.purple,
  'deepPurple': Colors.deepPurple,
  'indigo': Colors.indigo,
  'blueGrey': Colors.blueGrey,
  'blue': Colors.blue,
  'lightBlue': Colors.lightBlue,
  'cyan': Colors.cyan,
  'teal': Colors.teal,
  'green': Colors.green,
  'lightGreen': Colors.lightGreen,
  'lime': Colors.lime,
  'yellow': Colors.yellow,
  'amber': Colors.amber,
  'orange': Colors.orange,
  'deepOrange': Colors.deepOrange,
  'brown': Colors.brown,
};

const _allBlackAndWhiteColorsMap = {
  'black12': Colors.black12,
  'black26': Colors.black26,
  'black38': Colors.black38,
  'black45': Colors.black45,
  'black54': Colors.black54,
  'black87': Colors.black87,
  'black': Colors.black,
  'white10': Colors.white10,
  'white12': Colors.white12,
  'white24': Colors.white24,
  'white30': Colors.white30,
  'white38': Colors.white38,
  'white45': Colors.black45,
  'white54': Colors.white54,
  'white87': Colors.black87,
  'white': Colors.white,
};

const _allAccentColorsMap = {
  'redAccent': Colors.redAccent,
  'pinkAccent': Colors.pinkAccent,
  'purpleAccent': Colors.purpleAccent,
  'deepPurpleAccent': Colors.deepPurpleAccent,
  'indigoAccent': Colors.indigoAccent,
  'blueAccent': Colors.blueAccent,
  'lightBlueAccent': Colors.lightBlueAccent,
  'cyanAccent': Colors.cyanAccent,
  'tealAccent': Colors.tealAccent,
  'greenAccent': Colors.greenAccent,
  'lightGreenAccent': Colors.lightGreenAccent,
  'limeAccent': Colors.limeAccent,
  'yellowAccent': Colors.yellowAccent,
  'amberAccent': Colors.amberAccent,
  'orangeAccent': Colors.orangeAccent,
  'deepOrangeAccent': Colors.deepOrangeAccent,
};

Color _mapColorFromParse(dynamic value) {
  if (value is List) {
    final colorSwatch =
        _allMaterialColorsMap[value[1]] ?? _allAccentColorsMap[value[1]];
    if (colorSwatch == null) {
      return _allBlackAndWhiteColorsMap[value[1]]!;
    }
    if (value[2] == null) {
      return colorSwatch;
    } else {
      return colorSwatch[value[2] as int]!;
    }
  }
  throw Error();
}

final materialColorParser = (string('Colors.').optional() &
        stringsParser(_allMaterialColorsMap.keys) &
        (char('[') &
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
                char(']'))
            .pick(1)
            .optional())
    .map(_mapColorFromParse);

final blackAndWhiteColorParser = (string('Colors.').optional() &
        stringsParser(_allBlackAndWhiteColorsMap.keys))
    .map(_mapColorFromParse);

final accentColorParser = (string('Colors.').optional() &
        stringsParser(_allAccentColorsMap.keys) &
        (char('[') &
                stringsParser([
                  100,
                  200,
                  400,
                  700,
                ].map((v) => v.toString())).map(int.parse) &
                char(']'))
            .pick(1)
            .optional())
    .map(_mapColorFromParse);

final hexColorParser =
    (string('0x').optional() & anyOf('0123456789abcdefABCDEF').repeat(1, 8))
        .pick(1)
        .map<Color>((value) {
  if (value is List<String>) {
    final _int = value.length > 6
        ? value.join('')
        : ('FF' +
            Iterable<int>.generate(6 - value.length).map((e) => '0').join() +
            value.join());
    return Color(int.parse(_int, radix: 16));
  }
  throw Error();
});

final Map<String, Color Function(BuildContext)> _themeFactory = {
  'accentColor': (context) => Theme.of(context).accentColor,
  'primaryColorLight': (context) => Theme.of(context).primaryColorLight,
  'primaryColorDark': (context) => Theme.of(context).primaryColorDark,
  'primaryColor': (context) => Theme.of(context).primaryColor,
  'canvasColor': (context) => Theme.of(context).canvasColor,
  'scaffoldBackgroundColor': (context) =>
      Theme.of(context).scaffoldBackgroundColor,
  'cardColor': (context) => Theme.of(context).cardColor,
  'buttonColor': (context) => Theme.of(context).buttonColor,
  'backgroundColor': (context) => Theme.of(context).backgroundColor,
  'errorColor': (context) => Theme.of(context).errorColor,
  'toggleableActiveColor': (context) => Theme.of(context).toggleableActiveColor,
};

final Map<String, Color Function(BuildContext)> _colorSchemeFactory = {
  'primaryVariant': (context) => Theme.of(context).colorScheme.primaryVariant,
  'primary': (context) => Theme.of(context).colorScheme.primary,
  'secondaryVariant': (context) =>
      Theme.of(context).colorScheme.secondaryVariant,
  'secondary': (context) => Theme.of(context).colorScheme.secondary,
  'surface': (context) => Theme.of(context).colorScheme.surface,
  'background': (context) => Theme.of(context).colorScheme.background,
  'error': (context) => Theme.of(context).colorScheme.error,
  'onPrimary': (context) => Theme.of(context).colorScheme.onPrimary,
  'onSecondary': (context) => Theme.of(context).colorScheme.onSecondary,
  'onSurface': (context) => Theme.of(context).colorScheme.onSurface,
  'onBackground': (context) => Theme.of(context).colorScheme.onBackground,
  'onError': (context) => Theme.of(context).colorScheme.onError,
};

final themeColorParser =
    (string('theme.').trim().optional() & stringsParser(_themeFactory.keys) |
            string('colorScheme.').trim().optional() &
                stringsParser(_colorSchemeFactory.keys))
        .map<Color Function(BuildContext)>((l) {
  final key = (l as List)[1] as String;
  return _themeFactory[key] ?? _colorSchemeFactory[key]!;
});

final colorParser = (accentColorParser |
        materialColorParser |
        blackAndWhiteColorParser |
        hexColorParser)
    .cast<Color>();

void main() {
  test.test('main test', () {
    Result<Color> result = colorParser.parse('0xFA783792');
    test.expect(result.isSuccess, true);
    test.expect(result.value, const Color(0xFA783792));

    result = colorParser.parse('783792');
    test.expect(result.isSuccess, true);
    test.expect(result.value, const Color(0xFF783792));

    result = colorParser.parse('AB7');
    test.expect(result.isSuccess, true);
    test.expect(result.value, const Color(0xFF000AB7));

    result = colorParser.parse('red');
    test.expect(result.isSuccess, true);
    test.expect(result.value, Colors.red);

    result = colorParser.parse('yellowAccent');
    test.expect(result.isSuccess, true);
    test.expect(result.value, Colors.yellowAccent);

    result = colorParser.parse('Colors.lime');
    test.expect(result.isSuccess, true);
    test.expect(result.value, Colors.lime);

    result = colorParser.parse('Colors.lime[600]');
    test.expect(result.isSuccess, true);
    test.expect(result.value, Colors.lime[600]);

    result = colorParser.parse('Colors.orangeAccent[400]');
    test.expect(result.isSuccess, true);
    test.expect(result.value, Colors.orangeAccent[400]);
  });
}
