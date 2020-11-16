import 'package:flutter/material.dart';
import 'package:petitparser/petitparser.dart';
import 'package:snippet_generator/parsers/color_parser.dart';
import 'package:test/test.dart' as test;
import 'package:snippet_generator/parsers/parsers.dart';

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
final verticalDirectionParser =
    enumParser(VerticalDirection.values, optionalPrefix: "VerticalDirection");
final textBaselineParser =
    enumParser(TextBaseline.values, optionalPrefix: "TextBaseline");
final clipParser = enumParser(Clip.values, optionalPrefix: "Clip");
final stackFitParser = enumParser(StackFit.values, optionalPrefix: "StackFit");
final overflowParser = enumParser(Overflow.values, optionalPrefix: "Overflow");

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

final _alignmentEnumParser =
    enumParser(AlignmentEnum.values, optionalPrefix: "Alignment");
final alignmentParser = (_alignmentEnumParser |
        (string("Alignment").trim().optional() &
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

final edgeInsetsParser = (doubleParser.map((value) => EdgeInsets.all(value)) |
        structParser(
          {
            "horizontal": doubleParser,
            "vertical": doubleParser,
            "top": doubleParser,
            "bottom": doubleParser,
            "left": doubleParser,
            "right": doubleParser,
            "end": doubleParser,
            "start": doubleParser,
            "all": doubleParser,
          },
          optionalName: "EdgeInsets",
        ).map((value) {
          final horizontal = value["horizontal"];
          final vertical = value["vertical"];
          final top = value["top"];
          final bottom = value["bottom"];
          final left = value["left"];
          final right = value["right"];
          final end = value["end"];
          final start = value["start"];
          final all = value["all"];

          if (start != null || end != null) {
            return EdgeInsetsDirectional.only(
              bottom: bottom ?? vertical ?? all ?? 0.0,
              top: top ?? vertical ?? all ?? 0.0,
              start: start ?? horizontal ?? all ?? 0.0,
              end: end ?? horizontal ?? all ?? 0.0,
            );
          }

          return EdgeInsets.only(
            bottom: bottom ?? vertical ?? all ?? 0.0,
            top: top ?? vertical ?? all ?? 0.0,
            left: left ?? horizontal ?? all ?? 0.0,
            right: right ?? horizontal ?? all ?? 0.0,
          );
        }) |
        tupleParser(
          Iterable.generate(4).map((_) => doubleParser).toList(),
          numberRequired: 1,
          optionalName: "EdgeInsets",
        ).map((value) {
          print(value);
          switch (value.where((v) => v != null).length) {
            case 4:
              return EdgeInsets.fromLTRB(
                  value[0], value[1], value[2], value[3]);
            case 3:
              return EdgeInsets.only(
                top: value[0],
                bottom: value[0],
                left: value[1],
                right: value[2],
              );
            case 2:
              return EdgeInsets.symmetric(
                  vertical: value[0], horizontal: value[1]);
            case 1:
            default:
              return EdgeInsets.all(value[0]);
          }
        }))
    .map((v) => v as EdgeInsetsGeometry);

final boxConstraintsParser = structParser(
  {
    "height": doubleParser,
    "width": doubleParser,
    "maxHeight": doubleParser,
    "minHeight": doubleParser,
    "maxWidth": doubleParser,
    "minWidth": doubleParser,
    "factory": string("expand") |
        string("loose") |
        string("tight") |
        string("rightFor") |
        string("tightForFinite")
  },
  optionalName: "EdgeInsets",
).map((value) {
  switch (value["factory"] as String) {
    case "expand":
      return BoxConstraints.expand(
        height: value["height"] as double,
        width: value["width"] as double,
      );
    case "loose":
      return BoxConstraints.loose(Size(
        value["width"] as double,
        value["height"] as double,
      ));
    case "tight":
      return BoxConstraints.tight(Size(
        value["width"] as double,
        value["height"] as double,
      ));
    case "tightFor":
      return BoxConstraints.tightFor(
        height: value["height"] as double,
        width: value["width"] as double,
      );
    case "tightForFinite":
      return BoxConstraints.tightForFinite(
        height: value["height"] as double ?? double.infinity,
        width: value["width"] as double ?? double.infinity,
      );
    default:
      return BoxConstraints(
        maxHeight: value["maxHeight"] as double ?? double.infinity,
        minHeight: value["minHeight"] as double ?? 0,
        maxWidth: value["maxWidth"] as double ?? double.infinity,
        minWidth: value["minWidth"] as double ?? 0,
      );
  }
});

final boxShapeParser = enumParser(BoxShape.values, optionalPrefix: "BoxShape");
final borderStyleParser =
    enumParser(BorderStyle.values, optionalPrefix: "BorderStyle");
final borderSideParser =
    (string("none").trim().map((value) => BorderSide.none) |
            structParser({
              "color": colorParser,
              "style": borderStyleParser,
              "width": doubleParser,
            }, optionalName: "BorderSide")
                .map((params) {
              return BorderSide(
                color: params["color"] as Color,
                width: params["width"] as double,
                style: params["style"] as BorderStyle,
              );
            }))
        .cast<BorderSide>();

final borderParser =
    (borderSideParser.map((value) => Border.fromBorderSide(value)) |
            structParser({
              "factory": string("all") |
                  string("fromBorderSide") |
                  string("symmetric"),
              "vertical": borderSideParser,
              "horizontal": borderSideParser,
              "borderSide": borderSideParser,
              "left": borderSideParser,
              "bottom": borderSideParser,
              "right": borderSideParser,
              "top": borderSideParser,
              //
              "color": colorParser,
              "style": borderStyleParser,
              "width": doubleParser,
            }, optionalName: "Border")
                .map((params) {
              // TODO: BorderDirectional
              switch (params["factory"] as String) {
                case "all":
                  return Border.all(
                    color: params["color"] as Color,
                    width: params["width"] as double,
                    style: params["style"] as BorderStyle,
                  );
                case "symmetric":
                  return Border.symmetric(
                    horizontal: params["horizontal"] as BorderSide,
                    vertical: params["vertical"] as BorderSide,
                  );
                case "fromBorderSide":
                  return Border.fromBorderSide(
                    // TODO: unnecessary namedParam
                    params["borderSide"] as BorderSide,
                  );
                default:
                  return Border(
                    top: params["top"] as BorderSide,
                    bottom: params["bottom"] as BorderSide,
                    left: params["left"] as BorderSide,
                    right: params["right"] as BorderSide,
                  );
              }
            }))
        .cast<Border>();

final decorationParser = structParser({
  "color": colorParser,
  "shape": boxShapeParser,
  "border": borderParser,
}, optionalName: "BoxDecoration")
    .map((params) {
  return BoxDecoration(
    color: params["color"] as Color,
    shape: params["shape"] as BoxShape,
    border: params["border"] as BoxBorder,
  );
});

void main() {
  test.test("borderParser", () {
    final result =
        borderParser.parse("all (style: solid, color: red, width: 3)");
    print(result);
    test.expect(result.isSuccess, true);
  });

  test.test("flutter_props_parsers_test", () {
    var result = edgeInsetsParser.parse("2.3");
    print(result);
    test.expect(result.isSuccess, true);
    test.expect(result.value, const EdgeInsets.all(2.3));

    result = edgeInsetsParser.parse("(2.3, 9, )");
    print(result);
    test.expect(result.isSuccess, true);
    test.expect(
        result.value, const EdgeInsets.symmetric(vertical: 2.3, horizontal: 9));

    result = edgeInsetsParser.parse("EdgeInsets ( bottom : 202.3, top: 94 )");
    print(result);
    test.expect(result.isSuccess, true);
    test.expect(result.value, const EdgeInsets.only(bottom: 202.3, top: 94));
  });
}
