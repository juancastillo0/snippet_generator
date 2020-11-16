import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:petitparser/petitparser.dart';
import 'package:snippet_generator/parsers/color_parser.dart';
import 'package:snippet_generator/parsers/flutter_props_parsers.dart';
import 'package:snippet_generator/parsers/parsers.dart';
import 'package:test/test.dart' as test;

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

final pContainer = WidgetParser.createWithParams("Container", {
  "alignment": alignmentParser,
  "transformAlignment": alignmentParser,
  "width": doubleParser,
  "height": doubleParser,
  "margin": edgeInsetsParser,
  "padding": edgeInsetsParser,
  "child": WidgetParser.parser,
  "clipBehavior": clipParser,
  "constraints": boxConstraintsParser,
  "color": colorParser,
  "decoration": decorationParser,
  "foregroundDecoration": decorationParser,
}, (params) {
  return Container(
    alignment: params["alignment"] as AlignmentGeometry,
    padding: params["padding"] as EdgeInsetsGeometry ?? EdgeInsets.zero,
    margin: params["margin"] as EdgeInsetsGeometry ?? EdgeInsets.zero,
    height: params["height"] as double,
    clipBehavior: params["clipBehavior"] as Clip ?? Clip.none,
    width: params["width"] as double,
    color: params["color"] as Color,
    constraints: params["constraints"] as BoxConstraints,
    transformAlignment: params["transformAlignment"] as AlignmentGeometry,
    decoration: params["decoration"] as Decoration,
    // UnderlineTabIndicator, ShapeDecoration, BoxDecoration
    foregroundDecoration: params["foregroundDecoration"] as Decoration,
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

final _flexParams = {
  "crossAxisAlignment": crossAxisAlignmentParser,
  "mainAxisAlignment": mainAxisAlignmentParser,
  "mainAxisSize": mainAxisSizeParser,
  "cross": crossAxisAlignmentParser,
  "main": mainAxisAlignmentParser,
  "size": mainAxisSizeParser,
  "textBaseline": textBaselineParser,
  "textDirection": textDirectionParser,
  "verticalDirection": verticalDirectionParser,
  "children": separatedParser(WidgetParser.parser),
};

final pColumn = WidgetParser.createWithParams("Column", _flexParams, (params) {
  return Column(
    crossAxisAlignment: (params["cross"] ?? params["crossAxisAlignment"])
            as CrossAxisAlignment ??
        CrossAxisAlignment.center,
    mainAxisAlignment:
        (params["main"] ?? params["mainAxisAlignment"]) as MainAxisAlignment ??
            MainAxisAlignment.start,
    mainAxisSize: (params["size"] ?? params["mainAxisSize"]) as MainAxisSize ??
        MainAxisSize.max,
    textBaseline: params["textBaseline"] as TextBaseline,
    textDirection: params["textDirection"] as TextDirection,
    verticalDirection: params["verticalDirection"] as VerticalDirection ??
        VerticalDirection.down,
    children: (params["children"] as List)
            ?.map((w) => w.widget as Widget)
            ?.toList() ??
        [],
  );
});

final pRow = WidgetParser.createWithParams("Row", _flexParams, (params) {
  return Row(
    crossAxisAlignment: (params["cross"] ?? params["crossAxisAlignment"])
            as CrossAxisAlignment ??
        CrossAxisAlignment.center,
    mainAxisAlignment:
        (params["main"] ?? params["mainAxisAlignment"]) as MainAxisAlignment ??
            MainAxisAlignment.start,
    mainAxisSize: (params["size"] ?? params["mainAxisSize"]) as MainAxisSize ??
        MainAxisSize.max,
    textBaseline: params["textBaseline"] as TextBaseline,
    textDirection: params["textDirection"] as TextDirection,
    verticalDirection: params["verticalDirection"] as VerticalDirection ??
        VerticalDirection.down,
    children: (params["children"] as List)
            ?.map((w) => w.widget as Widget)
            ?.toList() ??
        [],
  );
});

final pFlex = WidgetParser.createWithParams("Flex", {
  ..._flexParams,
  "direction": axisParser,
  "clipBehavior": clipParser,
}, (params) {
  return Flex(
    direction: params["direction"] as Axis,
    clipBehavior: params["clipBehavior"] as Clip ?? Clip.none,
    crossAxisAlignment: (params["cross"] ?? params["crossAxisAlignment"])
            as CrossAxisAlignment ??
        CrossAxisAlignment.center,
    mainAxisAlignment:
        (params["main"] ?? params["mainAxisAlignment"]) as MainAxisAlignment ??
            MainAxisAlignment.start,
    mainAxisSize: (params["size"] ?? params["mainAxisSize"]) as MainAxisSize ??
        MainAxisSize.max,
    textBaseline: params["textBaseline"] as TextBaseline,
    textDirection: params["textDirection"] as TextDirection,
    verticalDirection: params["verticalDirection"] as VerticalDirection ??
        VerticalDirection.down,
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

final pPadding = WidgetParser.createWithParams("Padding", {
  "padding": edgeInsetsParser,
  "child": WidgetParser.parser,
}, (params) {
  return Padding(
    padding: params["padding"] as EdgeInsetsGeometry ?? EdgeInsets.zero,
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
            pFlex |
            pText |
            pStack |
            pPositioned |
            pPadding)
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
    final paramParsers = separatedParser(
      structParamsParser(params),
      left: char("("),
      right: char(")"),
    ).map((entries) => Map.fromEntries(entries));

    Parser nameParser = string(name).trim();
    final hasFactory = params["factory"] is Parser;
    if (hasFactory) {
      nameParser = nameParser &
          (char(".").trim() & params["factory"]).pick(1).optional();
    }

    Parser<List> nameAndPropParser = nameParser & paramParsers;

    if (params["child"] == WidgetParser.parser) {
      nameAndPropParser = nameAndPropParser &
          (char(".").trim() & params["child"]).pick(1).optional();
    } else if (params["children"] is Parser<List<WidgetParser>>) {
      nameAndPropParser = nameAndPropParser &
          (char(".").trim() & params["children"]).pick(1).optional();
    }

    return nameAndPropParser.trim().map(
      (value) {
        final params = value[hasFactory ? 2 : 1] as Map<String, Object>;

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

void expectIs<T>(dynamic value, [void Function(T) callback]) {
  test.expect(value is T, true);
  if (callback != null && value is T) {
    callback(value);
  }
}

void main() {
  WidgetParser.init();

  test.test("", () {
    final result = pContainer.parse(
      "Container(alignment: center, width: 102, margin: (3.4, 10,), "
      "decoration: (shape: circle, color: red[200], border: (style: solid, color: red[300], width: 3)),) "
      ".Padding (padding: 3, ).Text(text: 3)",
    );
    print(result);
    test.expect(result.isSuccess, true);

    expectIs<Container>(result.value.widget, (widget) {
      test.expect(
        widget.margin,
        const EdgeInsets.symmetric(vertical: 3.4, horizontal: 10),
      );
      expectIs<BoxDecoration>(widget.decoration, (decor) {
        test.expect(decor.color, Colors.red[200]);
        test.expect(decor.shape, BoxShape.circle);
        test.expect(
          decor.border,
          Border.all(
            color: Colors.red[300],
            width: 3,
            style: BorderStyle.solid,
          ),
        );
      });
      expectIs<Padding>(widget.child, (padding) {
        test.expect(padding.padding, const EdgeInsets.all(3));
        expectIs<Text>(padding.child, (text) {
          test.expect(text.data, "3");
        });
      });
    });
  });
}
