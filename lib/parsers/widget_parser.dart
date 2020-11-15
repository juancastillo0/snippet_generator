import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:petitparser/petitparser.dart';
import 'package:snippet_generator/parsers/color_parser.dart';
import 'package:snippet_generator/parsers/parsers.dart';

class PParamValue {
  final String primitiveValue;
  final List<String> listValue;
  final Widget widgetValue;

  PParamValue(this.primitiveValue, this.listValue, this.widgetValue);

  static final parser =
      (separatedParser(word().plus().flatten()) | WidgetParser.parser.trim())
          .map((value) {
    if (value is String) {
      return PParamValue(value, null, null);
    } else if (value is List) {
      return PParamValue(null, List<String>.from(value), null);
    } else if (value is WidgetParser) {
      return PParamValue(null, null, value.widget);
    }
    throw Error();
  });

  double toDouble() =>
      primitiveValue == null ? null : double.parse(primitiveValue);
  int toInt() => primitiveValue == null ? null : int.parse(primitiveValue);
  Widget toWidget() => widgetValue;
}

class PParam {
  final String key;
  final PParamValue value;
  const PParam({
    @required this.key,
    @required this.value,
  });
  static final parser =
      (word().plus().flatten() & char(":").trim() & PParamValue.parser).map(
    (value) => PParam(key: value[0] as String, value: value[2] as PParamValue),
  );
}

class PParams {
  final List<PParam> params;
  const PParams(this.params);

  static final parser = (char("(") &
          PParam.parser.separatedBy(
            char(",").trim(),
            includeSeparators: false,
            optionalSeparatorAtEnd: true,
          ) &
          char(")"))
      .map(
    (value) => PParams(List<PParam>.from(value[1] as List)),
  );

  Map<String, PParamValue> toMap() {
    return Map.fromEntries(params.map((e) => MapEntry(e.key, e.value)));
  }
}

// class PSizedBox implements WidgetParser {
//   @override
//   final SizedBox widget;
//   final Token<List<dynamic>> token;
//   PSizedBox(this.token, this.widget);

//   static final parser =
//       (string("SizedBox").trim() & PParams.parser.trim()).trim().token().map(
//     (token) {
//       final params = (token.value[1] as PParams).toMap();

//       return PSizedBox(
//         token,
//         SizedBox(
//           height: params["height"]?.toDouble(),
//           width: params["width"]?.toDouble(),
//           child: params["child"]?.toWidget(),
//         ),
//       );
//     },
//   );
// }

enum AlignmentEnum {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  center,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

const Map<AlignmentEnum, Alignment> _alignmentEnumMap = {
  AlignmentEnum.topLeft: Alignment.topLeft,
  AlignmentEnum.topCenter: Alignment.topCenter,
  AlignmentEnum.topRight: Alignment.topRight,
  AlignmentEnum.centerLeft: Alignment.centerLeft,
  AlignmentEnum.center: Alignment.center,
  AlignmentEnum.centerRight: Alignment.centerRight,
  AlignmentEnum.bottomLeft: Alignment.bottomLeft,
  AlignmentEnum.bottomCenter: Alignment.bottomCenter,
  AlignmentEnum.bottomRight: Alignment.bottomRight,
};

final boolParser =
    (string('true') | string('false')).map((value) => value == 'true');

final unsignedIntParser =
    (char('0').or(digit().plus())).flatten().map((value) => int.parse(value));
final intParser = (char('-').optional() & char('0').or(digit().plus()))
    .flatten()
    .map((value) => int.parse(value));
final unsignedDoubleParser =
    (char('0').or(digit().plus()) & char('.').seq(digit().plus()).optional())
        .flatten()
        .map((value) => double.parse(value));
final doubleParser = (char('-').optional() &
        char('0').or(digit().plus()) &
        char('.').seq(digit().plus()).optional())
    .flatten()
    .map((value) => double.parse(value));

final mainAxisAlignmentParser =
    enumParser(MainAxisAlignment.values, optionalPrefix: "MainAxisAlignment");
final crossAxisAlignmentParser =
    enumParser(CrossAxisAlignment.values, optionalPrefix: "CrossAxisAlignment");
final mainAxisSizeParser =
    enumParser(MainAxisSize.values, optionalPrefix: "MainAxisSize");
final axisParser = enumParser(Axis.values, optionalPrefix: "Axis");
final flexFitParser = enumParser(FlexFit.values, optionalPrefix: "FlexFit");
final textOverflowParser =
    enumParser(TextOverflow.values, optionalPrefix: "TextOverflow");
final textAlignParser =
    enumParser(TextAlign.values, optionalPrefix: "TextAlign");
final textDirectionParser =
    enumParser(TextDirection.values, optionalPrefix: "TextDirection");
final clipParser = enumParser(Clip.values, optionalPrefix: "Clip");
final stackFitParser = enumParser(StackFit.values, optionalPrefix: "StackFit");
final overflowParser = enumParser(Overflow.values, optionalPrefix: "Overflow");

final _alignmentEnumParser =
    enumParser(AlignmentEnum.values, optionalPrefix: "Alignment");
final alignmentParser = (_alignmentEnumParser |
        (string("Alignment").optional() &
            char("(").trim() &
            doubleParser &
            char(",").trim() &
            doubleParser &
            char(")").trim()))
    .map((value) {
  if (value is AlignmentEnum) {
    return _alignmentEnumMap[value];
  } else if (value is List) {
    return Alignment(value[2] as double, value[4] as double);
  }
  throw Error();
});

// final pContainer = WidgetParser.create("Container", (params) {
//   return Container(
//     alignment: _alignmentEnumMap[parseEnum(
//       params["alignment"]?.primitiveValue,
//       AlignmentEnum.values,
//     )],
//     height: params["height"]?.toDouble(),
//     width: params["width"]?.toDouble(),
//     child: params["child"]?.toWidget(),
//   );
// });

final pContainer = WidgetParser.createWithParams("Container", {
  "alignment": alignmentParser,
  "width": doubleParser,
  "height": doubleParser,
  "child": WidgetParser.parser,
  "color": colorParser.trim(),
}, (params) {
  return Container(
    alignment: params["alignment"] as Alignment,
    height: params["height"] as double,
    width: params["width"] as double,
    color: params["color"] as Color,
    child: (params["child"] as WidgetParser)?.widget,
  );
});

final pAlign = WidgetParser.createWithParams("Align", {
  "alignment": alignmentParser,
  "widthFactor": doubleParser,
  "heightFactor": doubleParser,
  "child": WidgetParser.parser,
}, (params) {
  return Align(
    alignment: params["alignment"] as Alignment,
    heightFactor: params["heightFactor"] as double,
    widthFactor: params["widthFactor"] as double,
    child: (params["child"] as WidgetParser)?.widget,
  );
});

final pCenter = WidgetParser.createWithParams("Center", {
  "widthFactor": doubleParser,
  "heightFactor": doubleParser,
  "child": WidgetParser.parser,
}, (params) {
  return Center(
    heightFactor: params["heightFactor"] as double,
    widthFactor: params["widthFactor"] as double,
    child: (params["child"] as WidgetParser)?.widget,
  );
});

final pColumn = WidgetParser.createWithParams("Column", {
  "crossAxisAlignment": crossAxisAlignmentParser,
  "mainAxisAlignment": mainAxisAlignmentParser,
  "mainAxisSize": mainAxisSizeParser,
  "children": separatedParser(WidgetParser.parser),
}, (params) {
  return Column(
    crossAxisAlignment: params["crossAxisAlignment"] as CrossAxisAlignment ??
        CrossAxisAlignment.center,
    mainAxisAlignment: params["mainAxisAlignment"] as MainAxisAlignment ??
        MainAxisAlignment.start,
    mainAxisSize: params["mainAxisSize"] as MainAxisSize ?? MainAxisSize.max,
    children: (params["children"] as List)
            ?.map((w) => w.widget as Widget)
            ?.toList() ??
        [],
  );
});

final pRow = WidgetParser.createWithParams("Row", {
  "crossAxisAlignment": crossAxisAlignmentParser,
  "mainAxisAlignment": mainAxisAlignmentParser,
  "mainAxisSize": mainAxisSizeParser,
  "children": separatedParser(WidgetParser.parser),
}, (params) {
  return Row(
    crossAxisAlignment: params["crossAxisAlignment"] as CrossAxisAlignment ??
        CrossAxisAlignment.center,
    mainAxisAlignment: params["mainAxisAlignment"] as MainAxisAlignment ??
        MainAxisAlignment.start,
    mainAxisSize: params["mainAxisSize"] as MainAxisSize ?? MainAxisSize.max,
    children: (params["children"] as List)
            ?.map((w) => w.widget as Widget)
            ?.toList() ??
        [],
  );
});

final pStack = WidgetParser.createWithParams("Stack", {
  "alignment": alignmentParser,
  "overflow": overflowParser,
  "clipBehavior": clipParser,
  "fit": stackFitParser,
  "textDirection": textDirectionParser,
  "children": separatedParser(WidgetParser.parser),
}, (params) {
  return Stack(
    alignment:
        params["alignment"] as Alignment ?? AlignmentDirectional.topStart,
    overflow: params["overflow"] as Overflow ?? Overflow.clip,
    clipBehavior: params["clipBehavior"] as Clip ?? Clip.hardEdge,
    fit: params["fit"] as StackFit ?? StackFit.loose,
    textDirection: params["textDirection"] as TextDirection,
    children: (params["children"] as List)
            ?.map((w) => w.widget as Widget)
            ?.toList() ??
        [],
  );
});

final pFlexible = WidgetParser.createWithParams("Flexible", {
  "flex": intParser,
  "fit": flexFitParser,
  "child": WidgetParser.parser,
}, (params) {
  return Flexible(
    flex: params["flex"] as int,
    fit: params["fit"] as FlexFit,
    child: (params["child"] as WidgetParser)?.widget,
  );
});

final pPositioned = WidgetParser.createWithParams("Positioned", {
  "factory": string("directional") |
      string("fill") |
      string("fromRect") |
      string("fromRelativeRect"),
  "height": doubleParser,
  "width": doubleParser,
  "top": doubleParser,
  "bottom": doubleParser,
  "left": doubleParser,
  "right": doubleParser,
  "end": doubleParser,
  "start": doubleParser,
  "textDirection": textDirectionParser,
  "child": WidgetParser.parser,
}, (params) {
  final child = (params["child"] as WidgetParser)?.widget ?? const SizedBox();
  switch (params["factory"] as String) {
    case "directional":
      return Positioned.directional(
        height: params["height"] as double,
        width: params["width"] as double,
        top: params["top"] as double,
        bottom: params["bottom"] as double,
        end: params["end"] as double,
        start: params["start"] as double,
        textDirection: params["textDirection"] as TextDirection,
        child: child,
      );
    case "fill":
      return Positioned.fill(
        top: params["top"] as double,
        bottom: params["bottom"] as double,
        left: params["left"] as double,
        right: params["right"] as double,
        child: child,
      );
    case "fromRect":
    case "fromRelativeRect":
    // TODO:
    default:
      return Positioned(
        height: params["height"] as double,
        width: params["width"] as double,
        top: params["top"] as double,
        bottom: params["bottom"] as double,
        left: params["left"] as double,
        right: params["right"] as double,
        child: child,
      );
  }
});

final pExpanded = WidgetParser.createWithParams("Expanded", {
  "flex": intParser,
  "child": WidgetParser.parser,
}, (params) {
  return Expanded(
    flex: params["flex"] as int,
    child: (params["child"] as WidgetParser)?.widget,
  );
});

final pSizedBox = WidgetParser.createWithParams("SizedBox", {
  "width": doubleParser,
  "height": doubleParser,
  "child": WidgetParser.parser,
}, (params) {
  return SizedBox(
    height: params["height"] as double,
    width: params["width"] as double,
    child: (params["child"] as WidgetParser)?.widget,
  );
});

final pText = WidgetParser.createWithParams("Text", {
  "text": word().plus().flatten(),
  "maxLines": intParser,
  "textScaleFactor": doubleParser,
  "softWrap": boolParser,
  "overflow": textOverflowParser,
  "textAlign": textAlignParser,
  "textDirection": textDirectionParser,
}, (params) {
  return Text(
    params["text"] as String,
    maxLines: params["maxLines"] as int,
    textScaleFactor: params["textScaleFactor"] as double,
    softWrap: params["softWrap"] as bool,
    overflow: params["overflow"] as TextOverflow,
    textAlign: params["textAlign"] as TextAlign,
    textDirection: params["textDirection"] as TextDirection,
  );
});

class WidgetParser {
  final Widget widget;
  WidgetParser(this.widget);

  static void init() {
    _parser.set((pSizedBox |
            pContainer |
            pAlign |
            pCenter |
            pExpanded |
            pFlexible |
            pRow |
            pColumn |
            pText |
            pStack |
            pPositioned)
        .map(
      (value) => value as WidgetParser,
    ));
  }

  static Parser<WidgetParser> create(
    String name,
    Widget Function(Map<String, PParamValue>) create,
  ) {
    return (string(name).trim() & PParams.parser.trim()).trim().token().map(
      (token) {
        final params = (token.value[1] as PParams).toMap();
        return WidgetParser(create(params));
      },
    );
  }

  static Parser<WidgetParser> createWithParams(
    String name,
    Map<String, Parser<Object>> params,
    Widget Function(Map<String, Object>) create,
  ) {
    final paramParsers = params.entries
        .fold<Parser<MapEntry<String, Object>>>(null, (previousValue, element) {
      final curr =
          (string(element.key).trim() & char(":").trim() & element.value.trim())
              .map((value) => MapEntry(value[0] as String, value[2] as Object));
      if (previousValue == null) {
        previousValue = curr;
      } else {
        previousValue =
            previousValue.or(curr).map((v) => v as MapEntry<String, Object>);
      }
      return previousValue;
    });

    Parser nameParser = string(name).trim();
    final hasFactory = params["factory"] is Parser;
    if (hasFactory) {
      nameParser = nameParser &
          (char(".").trim() & params["factory"]).pick(1).optional();
    }

    var nameAndPropParser = nameParser &
        separatedParser(
          paramParsers,
          left: char("("),
          right: char(")"),
        );

    if (params["child"] == WidgetParser.parser) {
      nameAndPropParser = nameAndPropParser &
          (char(".").trim() & params["child"]).pick(1).optional();
    } else if (params["children"] is Parser<List<WidgetParser>>) {
      nameAndPropParser = nameAndPropParser &
          (char(".").trim() & params["children"]).pick(1).optional();
    }

    return nameAndPropParser.trim().map(
      (value) {
        final entries = List.castFrom<dynamic, MapEntry<String, Object>>(
          value[hasFactory ? 2 : 1] as List,
        );
        final params = Map.fromEntries(entries);

        if (hasFactory && value[1] != null) {
          params["factory"] = value[1];
        }

        final childIndex = hasFactory ? 3 : 2;
        if (value.length > childIndex && value[childIndex] != null) {
          final widgets = value[childIndex];
          if (widgets is List) {
            params["children"] = widgets;
          } else if (widgets != null) {
            params["child"] = widgets;
          }
        }
        return WidgetParser(create(params));
      },
    );
  }

  static final SettableParser<WidgetParser> _parser = undefined<WidgetParser>();
  static Parser<WidgetParser> get parser => _parser;
}
