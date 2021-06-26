import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:petitparser/petitparser.dart';
import 'package:snippet_generator/parsers/dart_parser.dart';
import 'package:snippet_generator/parsers/parsers.dart';
import 'package:snippet_generator/parsers/widget_parsers/color_parser.dart';
import 'package:test/test.dart' as test;

final mainAxisAlignmentParser =
    enumParser(MainAxisAlignment.values, optionalPrefix: 'MainAxisAlignment');
final crossAxisAlignmentParser =
    enumParser(CrossAxisAlignment.values, optionalPrefix: 'CrossAxisAlignment');
final mainAxisSizeParser =
    enumParser(MainAxisSize.values, optionalPrefix: 'MainAxisSize');
final axisParser = enumParser(Axis.values, optionalPrefix: 'Axis');
final flexFitParser = enumParser(FlexFit.values, optionalPrefix: 'FlexFit');
final textOverflowParser =
    enumParser(TextOverflow.values, optionalPrefix: 'TextOverflow');
final textAlignParser =
    enumParser(TextAlign.values, optionalPrefix: 'TextAlign');
final textDirectionParser =
    enumParser(TextDirection.values, optionalPrefix: 'TextDirection');
final verticalDirectionParser =
    enumParser(VerticalDirection.values, optionalPrefix: 'VerticalDirection');
final textBaselineParser =
    enumParser(TextBaseline.values, optionalPrefix: 'TextBaseline');
final clipParser = enumParser(Clip.values, optionalPrefix: 'Clip');
final stackFitParser = enumParser(StackFit.values, optionalPrefix: 'StackFit');
final overflowParser = enumParser(Overflow.values, optionalPrefix: 'Overflow');
final fontStyleParser =
    enumParser(FontStyle.values, optionalPrefix: 'FontStyle');
final blurStyleParser =
    enumParser(BlurStyle.values, optionalPrefix: 'BlurStyle');
final blendModeParser =
    enumParser(BlendMode.values, optionalPrefix: 'BlendMode');
final strokeCapParser =
    enumParser(StrokeCap.values, optionalPrefix: 'StrokeCap');
final strokeJoinParser =
    enumParser(StrokeJoin.values, optionalPrefix: 'StrokeJoin');
final filterQualityParser =
    enumParser(FilterQuality.values, optionalPrefix: 'FilterQuality');
final paintingStyleParser =
    enumParser(PaintingStyle.values, optionalPrefix: 'PaintingStyle');
final tileModeParser = enumParser(TileMode.values, optionalPrefix: 'TileMode');
final visualDensityParser =
    ((string('VisualDensity') & char('.').trim()).optional() &
            (string('comfortable') | string('compact') | string('standard')))
        .map((value) => value[1] == 'comfortable'
            ? VisualDensity.comfortable
            : (value[1] == 'compact'
                ? VisualDensity.compact
                : VisualDensity.standard));
final materialTapTargetSizeParser = enumParser(MaterialTapTargetSize.values,
    optionalPrefix: 'MaterialTapTargetSize');

const alignmentList = [
  Alignment.topLeft,
  Alignment.topCenter,
  Alignment.topRight,
  Alignment.centerLeft,
  Alignment.centerRight,
  Alignment.center,
  Alignment.bottomLeft,
  Alignment.bottomCenter,
  Alignment.bottomRight,
];

final textDecorationStyleParser = enumParser(TextDecorationStyle.values,
    optionalPrefix: 'TextDecorationStyle');

final paintParser = structParser({
  'blendMode': blendModeParser,
  'color': colorParser,
  // "colorFilter": colorFilterParser,
  'filterQuality': filterQualityParser,
  // "imageFilter": imageFilterParser,
  'invertColors': boolParser,
  'isAntiAlias': boolParser,
  'strokeCap': strokeCapParser,
  'strokeJoin': strokeJoinParser,
  // "maskFilter": maskFilterParser,
  'strokeMiterLimit': doubleParser,
  'strokeWidth': doubleParser,
  'style': paintingStyleParser,
  // "shader": shaderParser,
}, optionalName: 'Paint')
    .map<Paint>((params) {
  final paint = Paint();
  return paint
    ..blendMode = params['blendMode'] as BlendMode? ?? paint.blendMode
    ..color = params['color'] as Color? ?? paint.color
    ..colorFilter = params['colorFilter'] as ColorFilter? ?? paint.colorFilter
    ..filterQuality =
        params['filterQuality'] as FilterQuality? ?? paint.filterQuality
    ..imageFilter = params['imageFilter'] as ImageFilter? ?? paint.imageFilter
    ..invertColors = params['invertColors'] as bool? ?? paint.invertColors
    ..isAntiAlias = params['isAntiAlias'] as bool? ?? paint.isAntiAlias
    ..maskFilter = params['maskFilter'] as MaskFilter? ?? paint.maskFilter
    ..strokeCap = params['strokeCap'] as StrokeCap? ?? paint.strokeCap
    ..strokeJoin = params['strokeJoin'] as StrokeJoin? ?? paint.strokeJoin
    ..strokeMiterLimit =
        params['strokeMiterLimit'] as double? ?? paint.strokeMiterLimit
    ..strokeWidth = params['strokeWidth'] as double? ?? paint.strokeWidth
    ..style = params['style'] as PaintingStyle? ?? paint.style
    ..shader = params['shader'] as Shader? ?? paint.shader;
});

final fontWeightParser =
    (((string('FontWeight') & char('.').trim()).optional() &
                    (string('bold') | string('normal')).map((value) =>
                        value == 'bold' ? FontWeight.bold : FontWeight.normal))
                .pick(2) |
            enumParser(FontWeight.values, optionalPrefix: 'FontWeight'))
        .cast<FontWeight>();

final textDecorationParser =
    ((string('TextDecoration') & char('.').trim()).optional() &
            stringsParser(['none', 'overline', 'underline', 'lineThrough']))
        .pick(2)
        .map<TextDecoration>((value) {
  switch (value) {
    case 'none':
      return TextDecoration.none;
    case 'overline':
      return TextDecoration.overline;
    case 'underline':
      return TextDecoration.underline;
    case 'lineThrough':
      return TextDecoration.lineThrough;
  }
  throw Error();
});

final textStyleParser = structParser({
  'inherit': boolParser,
  'color': colorParser,
  'backgroundColor': colorParser,
  'fontSize': doubleParser,
  'fontWeight': fontWeightParser,
  'fontStyle': fontStyleParser,
  'letterSpacing': doubleParser,
  'wordSpacing': doubleParser,
  'textBaseline': textBaselineParser,
  'height': doubleParser,
  // "locale": localeParser,
  'foreground': paintParser,
  'background': paintParser,
  'shadows': separatedParser(boxShadowParser),
  // "fontFeatures": fontFeatureListParser,
  'decoration': textDecorationParser,
  'decorationColor': colorParser,
  'decorationStyle': textDecorationStyleParser,
  'decorationThickness': doubleParser,
  'debugLabel': dartStringParser,
  'fontFamily': dartStringParser,
  'fontFamilyFallback': separatedParser(dartStringParser),
  'package': dartStringParser,
}).map(
  (params) => TextStyle(
    inherit: params['inherit'] as bool? ?? true,
    color: params['color'] as Color?,
    backgroundColor: params['backgroundColor'] as Color?,
    fontSize: params['fontSize'] as double?,
    fontWeight: params['fontWeight'] as FontWeight?,
    fontStyle: params['fontStyle'] as FontStyle?,
    letterSpacing: params['letterSpacing'] as double?,
    wordSpacing: params['wordSpacing'] as double?,
    textBaseline: params['textBaseline'] as TextBaseline?,
    height: params['height'] as double?,
    locale: params['locale'] as Locale?,
    foreground: params['foreground'] as Paint?,
    background: params['background'] as Paint?,
    shadows: params['shadows'] as List<Shadow>?,
    fontFeatures: params['fontFeatures'] as List<FontFeature>?,
    decoration: params['decoration'] as TextDecoration?,
    decorationColor: params['decorationColor'] as Color?,
    decorationStyle: params['decorationStyle'] as TextDecorationStyle?,
    decorationThickness: params['decorationThickness'] as double?,
    debugLabel: params['debugLabel'] as String?,
    fontFamily: params['fontFamily'] as String?,
    fontFamilyFallback: params['fontFamilyFallback'] as List<String>?,
    package: params['package'] as String?,
  ),
);

final _alignmentEnumParser =
    enumParser(alignmentList, optionalPrefix: 'Alignment');
final alignmentParser = (_alignmentEnumParser |
        (string('Alignment').trim().optional() &
                char('(').trim() &
                doubleParser &
                char(',').trim() &
                doubleParser &
                char(')').trim())
            .map((value) {
          if (value is List) {
            return Alignment(value[2] as double, value[4] as double);
          }
          throw Error();
        }))
    .cast<Alignment>();

final sizeParser = (string('Size').trim().optional() &
        char('(').trim() &
        doubleParser &
        char(',').trim() &
        doubleParser &
        char(')').trim())
    .map<Size>((value) {
  if (value is List) {
    return Size(value[2] as double, value[4] as double);
  }
  throw Error();
});

final edgeInsetsParser = (doubleParser.map((value) => EdgeInsets.all(value)) |
        structParser(
          {
            'horizontal': doubleParser,
            'vertical': doubleParser,
            'top': doubleParser,
            'bottom': doubleParser,
            'left': doubleParser,
            'right': doubleParser,
            'end': doubleParser,
            'start': doubleParser,
            'all': doubleParser,
          },
          optionalName: 'EdgeInsets',
        ).map((value) {
          final horizontal = value['horizontal'] as double?;
          final vertical = value['vertical'] as double?;
          final top = value['top'] as double?;
          final bottom = value['bottom'] as double?;
          final left = value['left'] as double?;
          final right = value['right'] as double?;
          final end = value['end'] as double?;
          final start = value['start'] as double?;
          final all = value['all'] as double?;

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
          optionalName: 'EdgeInsets',
        ).map((value) {
          print(value);
          // TODO:
          switch (value.where((v) => v != null).length) {
            case 4:
              return EdgeInsets.fromLTRB(
                value[0],
                value[1],
                value[2],
                value[3],
              );
            case 3:
              return EdgeInsets.only(
                top: value[0],
                bottom: value[0],
                left: value[1],
                right: value[2],
              );
            case 2:
              return EdgeInsets.symmetric(
                vertical: value[0],
                horizontal: value[1],
              );
            case 1:
            default:
              return EdgeInsets.all(value[0]);
          }
        }))
    .cast<EdgeInsetsGeometry>();

final boxConstraintsParser = structParser(
  {
    'height': doubleParser,
    'width': doubleParser,
    'maxHeight': doubleParser,
    'minHeight': doubleParser,
    'maxWidth': doubleParser,
    'minWidth': doubleParser,
    'factory': (string('expand') |
            string('loose') |
            string('tight') |
            string('rightFor') |
            string('tightForFinite'))
        .cast()
  },
  optionalName: 'EdgeInsets',
).map<BoxConstraints>((value) {
  switch (value['factory'] as String?) {
    case 'expand':
      return BoxConstraints.expand(
        height: value['height'] as double?,
        width: value['width'] as double?,
      );
    case 'loose':
      return BoxConstraints.loose(Size(
        value['width'] as double,
        value['height'] as double,
      ));
    case 'tight':
      return BoxConstraints.tight(Size(
        value['width'] as double,
        value['height'] as double,
      ));
    case 'tightFor':
      return BoxConstraints.tightFor(
        height: value['height'] as double?,
        width: value['width'] as double?,
      );
    case 'tightForFinite':
      return BoxConstraints.tightForFinite(
        height: value['height'] as double? ?? double.infinity,
        width: value['width'] as double? ?? double.infinity,
      );
    default:
      return BoxConstraints(
        maxHeight: value['maxHeight'] as double? ?? double.infinity,
        minHeight: value['minHeight'] as double? ?? 0,
        maxWidth: value['maxWidth'] as double? ?? double.infinity,
        minWidth: value['minWidth'] as double? ?? 0,
      );
  }
});

final boxShapeParser = enumParser(BoxShape.values, optionalPrefix: 'BoxShape');
final borderStyleParser =
    enumParser(BorderStyle.values, optionalPrefix: 'BorderStyle');
final borderSideParser =
    (string('none').trim().map((value) => BorderSide.none) |
            structParser({
              'color': colorParser,
              'style': borderStyleParser,
              'width': doubleParser,
            }, optionalName: 'BorderSide')
                .map((params) {
              return BorderSide(
                color: params['color'] as Color? ?? const Color(0xFF000000),
                width: params['width'] as double? ?? 1.0,
                style: params['style'] as BorderStyle? ?? BorderStyle.solid,
              );
            }))
        .cast<BorderSide>();

final borderParser =
    (borderSideParser.map((value) => Border.fromBorderSide(value)) |
            structParser({
              'factory': (string('all') |
                      string('fromBorderSide') |
                      string('symmetric'))
                  .cast(),
              'vertical': borderSideParser,
              'horizontal': borderSideParser,
              'borderSide': borderSideParser,
              'left': borderSideParser,
              'bottom': borderSideParser,
              'right': borderSideParser,
              'top': borderSideParser,
              //
              'color': colorParser,
              'style': borderStyleParser,
              'width': doubleParser,
            }, optionalName: 'Border')
                .map((params) {
              // TODO: BorderDirectional
              switch (params['factory'] as String?) {
                case 'all':
                  return Border.all(
                    color: params['color'] as Color? ?? const Color(0xFF000000),
                    width: params['width'] as double? ?? 1.0,
                    style: params['style'] as BorderStyle? ?? BorderStyle.solid,
                  );
                case 'symmetric':
                  return Border.symmetric(
                    horizontal:
                        params['horizontal'] as BorderSide? ?? BorderSide.none,
                    vertical:
                        params['vertical'] as BorderSide? ?? BorderSide.none,
                  );
                case 'fromBorderSide':
                  return Border.fromBorderSide(
                    // TODO: unnecessary namedParam
                    params['borderSide'] as BorderSide? ?? BorderSide.none,
                  );
                default:
                  return Border(
                    top: params['top'] as BorderSide? ?? BorderSide.none,
                    bottom: params['bottom'] as BorderSide? ?? BorderSide.none,
                    left: params['left'] as BorderSide? ?? BorderSide.none,
                    right: params['right'] as BorderSide? ?? BorderSide.none,
                  );
              }
            }))
        .cast<Border>();

final offsetParser = tupleParser(
  Iterable.generate(2).map((_) => doubleParser).toList(),
  numberRequired: 2,
  optionalName: 'Offset',
).map<Offset>((value) {
  return Offset(value[0], value[1]);
});

class CustomBoxShadow extends BoxShadow {
  final BlurStyle blurStyle;

  const CustomBoxShadow({
    Color color = const Color(0xFF000000),
    Offset offset = Offset.zero,
    double blurRadius = 0.0,
    this.blurStyle = BlurStyle.normal,
  }) : super(
          color: color,
          offset: offset,
          blurRadius: blurRadius,
        );

  @override
  Paint toPaint() {
    final Paint result = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(this.blurStyle, blurSigma);
    assert(() {
      if (debugDisableShadows) result.maskFilter = null;
      return true;
    }());
    return result;
  }
}

final boxShadowParser = structParser({
  'color': colorParser,
  'blurRadius': doubleParser,
  'spreadRadius': doubleParser,
  'offset': offsetParser,
  'blurStyle': blurStyleParser,
}, optionalName: 'BoxDecoration')
    .map<BoxShadow>((params) {
  if (params['blurStyle'] is BlurStyle) {
    return CustomBoxShadow(
      color: params['color'] as Color? ?? const Color(0xFF000000),
      blurRadius: params['blurRadius'] as double? ?? 0.0,
      blurStyle: params['blurStyle'] as BlurStyle? ?? BlurStyle.normal,
      offset: params['offset'] as Offset? ?? Offset.zero,
    );
  }
  return BoxShadow(
    color: params['color'] as Color? ?? const Color(0xFF000000),
    blurRadius: params['blurRadius'] as double? ?? 0.0,
    spreadRadius: params['spreadRadius'] as double? ?? 0.0,
    offset: params['offset'] as Offset? ?? Offset.zero,
  );
});

final gradientParser = structParser({
  'colors': separatedParser(colorParser),
  'stops': separatedParser(doubleParser),
  'tileMode': tileModeParser,
  'center': alignmentParser,
  'focal': alignmentParser,
  'focalRadius': doubleParser,
  'radius': doubleParser,
  'center': alignmentParser,
  'endAngle': doubleParser,
  'startAngle': doubleParser,
  'begin': doubleParser,
  'ends': doubleParser,
}).map<Gradient>((params) {
  // TODO:
  // LinearGradient, RadialGradient, SweepGradient
  // RadialGradient();
  // SweepGradient();
  // return LinearGradient();
  throw UnimplementedError();
});

final boxDecorationParser = structParser({
  'color': colorParser,
  'shape': boxShapeParser,
  'border': borderParser,
  'boxShadow': separatedParser(boxShadowParser),
  'borderRadius': borderRadiusParser,
  'backgroundBlendMode': blendModeParser,
  'gradient': gradientParser
}, optionalName: 'BoxDecoration')
    .map<BoxDecoration>((params) {
  // TODO: decoration image
  return BoxDecoration(
    color: params['color'] as Color?,
    shape: params['shape'] as BoxShape? ?? BoxShape.rectangle,
    border: params['border'] as BoxBorder?,
    boxShadow: params['boxShadow'] as List<BoxShadow>?,
    borderRadius: params['borderRadius'] as BorderRadiusGeometry?,
    backgroundBlendMode: params['backgroundBlendMode'] as BlendMode?,
    gradient: params['gradient'] as Gradient?,
  );
});

final radiusParser = (doubleParser.map((value) => Radius.circular(value)) |
        tupleParser(
          [doubleParser, doubleParser],
          numberRequired: 1,
          optionalName: 'Radius',
        ).map((value) {
          if (value.length == 1) {
            return Radius.circular(value[0]);
          } else {
            return Radius.elliptical(value[0], value[1]);
          }
        }))
    .cast<Radius>();

final borderRadiusParser =
    (radiusParser.map((value) => BorderRadius.all(value)) |
            structParser({
              'factory':
                  (string('horizontal') | string('only') | string('vertical'))
                      .cast(),
              'side': radiusParser,
              'top': radiusParser,
              'bottom': radiusParser,
              'left': radiusParser,
              'right': radiusParser,
              'topLeft': radiusParser,
              'topRight': radiusParser,
              'bottomLeft': radiusParser,
              'bottomRight': radiusParser,
            }, optionalName: 'BorderRadius')
                .map((params) {
              switch (params['factory'] as String?) {
                case 'horizontal':
                  return BorderRadius.horizontal(
                    left: params['left'] as Radius? ?? Radius.zero,
                    right: params['right'] as Radius? ?? Radius.zero,
                  );
                case 'vertical':
                  return BorderRadius.vertical(
                    bottom: params['bottom'] as Radius? ?? Radius.zero,
                    top: params['top'] as Radius? ?? Radius.zero,
                  );
                default:
                  return BorderRadius.only(
                    topLeft: params['topLeft'] as Radius? ?? Radius.zero,
                    topRight: params['topRight'] as Radius? ?? Radius.zero,
                    bottomLeft: params['bottomLeft'] as Radius? ?? Radius.zero,
                    bottomRight:
                        params['bottomRight'] as Radius? ?? Radius.zero,
                  );
              }
            }))
        .cast<BorderRadius>();

const shapeBorderFactories = {
  'Circle',
  'RoundedRectangle',
  'ContinuousRectangle',
  'BeveledRectangle',
  'Stadium',
};

final Parser<ShapeBorder> shapeBorderParser = (borderParser |
        ((orManyString(shapeBorderFactories)) &
                string('Border').optional() &
                structParser({
                  'side': borderSideParser,
                  'borderRadius': borderRadiusParser,
                }))
            .map((list) {
          final params = list[2] as Map<String, Object>;
          String name = list[0] as String;
          if (!name.endsWith('Border')) {
            name = '${name}Border';
          }
          final side = params['side'] as BorderSide? ?? BorderSide.none;
          final borderRadius =
              params['borderRadius'] as BorderRadiusGeometry? ??
                  BorderRadius.zero;
          switch (name) {
            case 'CircleBorder':
              return CircleBorder(
                side: side,
              );
            case 'StadiumBorder':
              return StadiumBorder(
                side: side,
              );
            case 'RoundedRectangleBorder':
              return RoundedRectangleBorder(
                side: side,
                borderRadius: borderRadius,
              );
            case 'ContinuousRectangleBorder':
              return ContinuousRectangleBorder(
                side: side,
                borderRadius: borderRadius,
              );
            case 'BeveledRectangleBorder':
              return BeveledRectangleBorder(
                side: side,
                borderRadius: borderRadius,
              );
          }
        }))
    .cast<ShapeBorder>();

final shapeDecorationParser = structParser({
  'color': colorParser,
  'shape': shapeBorderParser,
  'shadows': separatedParser(boxShadowParser),
}, optionalName: 'ShapeDecoration')
    .map<ShapeDecoration>((params) {
  return ShapeDecoration(
    color: params['color'] as Color?,
    shape: params['shape'] as ShapeBorder,
    shadows: params['shadows'] as List<BoxShadow>?,
  );
});

final decorationParser =
    (boxDecorationParser | shapeDecorationParser).cast<Decoration>();

void main() {
  test.test('borderParser', () {
    final result =
        borderParser.parse('all (style: solid, color: red, width: 3)');
    print(result);
    test.expect(result.isSuccess, true);
  });

  test.test('flutter_props_parsers_test', () {
    var result = edgeInsetsParser.parse('2.3');
    print(result);
    test.expect(result.isSuccess, true);
    test.expect(result.value, const EdgeInsets.all(2.3));

    result = edgeInsetsParser.parse('(2.3, 9, )');
    print(result);
    test.expect(result.isSuccess, true);
    test.expect(
        result.value, const EdgeInsets.symmetric(vertical: 2.3, horizontal: 9));

    result = edgeInsetsParser.parse('EdgeInsets ( bottom : 202.3, top: 94 )');
    print(result);
    test.expect(result.isSuccess, true);
    test.expect(result.value, const EdgeInsets.only(bottom: 202.3, top: 94));
  });
}
