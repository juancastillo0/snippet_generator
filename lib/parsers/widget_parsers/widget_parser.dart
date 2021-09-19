import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:petitparser/petitparser.dart';
import 'package:snippet_generator/parsers/dart_parser.dart';
import 'package:snippet_generator/parsers/parsers.dart';
import 'package:snippet_generator/parsers/views/parser_fields.dart';
import 'package:snippet_generator/parsers/widget_parsers/color_parser.dart';
import 'package:snippet_generator/parsers/widget_parsers/flutter_props_parsers.dart';
import 'package:snippet_generator/parsers/widget_parsers/widget_child.dart';
import 'package:stack_portal/resizable.dart';
import 'package:test/test.dart' as test;

class PParamValue {
  final String? primitiveValue;
  final List<String>? listValue;
  final Widget? widgetValue;

  PParamValue(this.primitiveValue, this.listValue, this.widgetValue);

  static final parser =
      (separatedParser(word().plus().flatten()) | WidgetParser.parser.trim())
          .map<PParamValue>((Object? value) {
    if (value is String) {
      return PParamValue(value, null, null);
    } else if (value is List) {
      return PParamValue(null, List<String>.from(value), null);
    } else if (value is WidgetParser) {
      return PParamValue(null, null, value.widget);
    }
    throw Error();
  });

  double? toDouble() =>
      primitiveValue == null ? null : double.parse(primitiveValue!);
  int? toInt() => primitiveValue == null ? null : int.parse(primitiveValue!);
  Widget? toWidget() => widgetValue;
}

class PParam {
  final String key;
  final PParamValue value;
  const PParam({
    required this.key,
    required this.value,
  });
  static final parser =
      (word().plus().flatten() & char(':').trim() & PParamValue.parser).map(
    (value) => PParam(key: value[0] as String, value: value[2] as PParamValue),
  );
}

class PParams {
  final List<PParam> params;
  const PParams(this.params);

  static final parser = (char('(') &
          PParam.parser.separatedBy<PParam>(
            char(',').trim(),
            includeSeparators: false,
            optionalSeparatorAtEnd: true,
          ) &
          char(')'))
      .map(
    (value) => PParams(List<PParam>.from(value[1] as List)),
  );

  Map<String, PParamValue> toMap() {
    return Map.fromEntries(params.map((e) => MapEntry(e.key, e.value)));
  }
}

final pContainer = WidgetParser.createWithParams('Container', {
  'alignment': alignmentParser,
  'transformAlignment': alignmentParser,
  'width': doubleParser,
  'height': doubleParser,
  'margin': edgeInsetsParser,
  'padding': edgeInsetsParser,
  'child': WidgetParser.parser,
  'clipBehavior': clipParser,
  'constraints': boxConstraintsParser,
  'color': colorParser,
  'decoration': decorationParser,
  'foregroundDecoration': decorationParser,
}, (params) {
  return Container(
    alignment: params['alignment'] as AlignmentGeometry?,
    padding: params['padding'] as EdgeInsetsGeometry? ?? EdgeInsets.zero,
    margin: params['margin'] as EdgeInsetsGeometry? ?? EdgeInsets.zero,
    height: params['height'] as double?,
    clipBehavior: params['clipBehavior'] as Clip? ?? Clip.none,
    width: params['width'] as double?,
    color: params['color'] as Color?,
    constraints: params['constraints'] as BoxConstraints?,
    transformAlignment: params['transformAlignment'] as AlignmentGeometry?,
    decoration: params['decoration'] as Decoration?,
    foregroundDecoration: params['foregroundDecoration'] as Decoration?,
    child: (params['child'] as WidgetParser?)?.widget,
  );
}, form: (params, controller) {
  return ContainerForm(params: params, controller: controller);
});

class ContainerForm extends HookWidget {
  final Token<Map<String, Token<Object>>>? params;
  final TextEditingController controller;
  const ContainerForm({
    Key? key,
    required this.params,
    required this.controller,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return WidgetFormState(params, controller).provide(
      SingleScrollable(
        padding: const EdgeInsets.only(right: 10.0),
        child: Wrap(
          children: const [
            AlignmentParserFormInput(
              key: ValueKey('alignment'),
            ),
            PaddingParserFormInput(
              key: ValueKey('padding'),
            ),
            ColorInput(
              key: ValueKey('color'),
            ),
          ],
        ),
      ),
    );
  }
}

final _buttonParams = {
  'autofocus': boolParser,
  'clipBehavior': clipParser,
  'alignment': alignmentParser,
  'elevation': doubleParser,
  'fixedSize': sizeParser,
  'minimumSize': sizeParser,
  'onSurface': colorParser,
  'padding': edgeInsetsParser,
  'primary': colorParser,
  'shadowColor': colorParser,
  'side': borderSideParser,
  'visualDensity': visualDensityParser,
  'tapTargetSize': materialTapTargetSizeParser,
  'shape': shapeBorderParser,
  'child': WidgetParser.parser,
};

final pTextButton = WidgetParser.createWithParams('TextButton', {
  ..._buttonParams,
  'backgroundColor': colorParser,
}, (params) {
  return TextButton(
    onPressed: () {},
    style: TextButton.styleFrom(
      alignment: params['alignment'] as Alignment?,
      backgroundColor: params['backgroundColor'] as Color?,
      elevation: params['elevation'] as double?,
      fixedSize: params['fixedSize'] as Size?,
      minimumSize: params['minimumSize'] as Size?,
      onSurface: params['onSurface'] as Color?,
      padding: params['padding'] as EdgeInsetsGeometry?,
      primary: params['primary'] as Color?,
      shadowColor: params['shadowColor'] as Color?,
      side: params['side'] as BorderSide?,
      visualDensity: params['visualDensity'] as VisualDensity?,
      tapTargetSize: params['tapTargetSize'] as MaterialTapTargetSize?,
      shape: params['shape'] as OutlinedBorder?,
    ),
    clipBehavior: params['clipBehavior'] as Clip? ?? Clip.none,
    autofocus: params['autofocus'] as bool? ?? false,
    child: _extractChild(params),
  );
});

final pElevatedButton = WidgetParser.createWithParams('ElevatedButton', {
  ..._buttonParams,
  'onPrimary': colorParser,
}, (params) {
  return ElevatedButton(
    onPressed: () {},
    style: ElevatedButton.styleFrom(
      alignment: params['alignment'] as Alignment?,
      onPrimary: params['onPrimary'] as Color?,
      elevation: params['elevation'] as double?,
      fixedSize: params['fixedSize'] as Size?,
      minimumSize: params['minimumSize'] as Size?,
      onSurface: params['onSurface'] as Color?,
      padding: params['padding'] as EdgeInsetsGeometry?,
      primary: params['primary'] as Color?,
      shadowColor: params['shadowColor'] as Color?,
      side: params['side'] as BorderSide?,
      visualDensity: params['visualDensity'] as VisualDensity?,
      tapTargetSize: params['tapTargetSize'] as MaterialTapTargetSize?,
      shape: params['shape'] as OutlinedBorder?,
    ),
    clipBehavior: params['clipBehavior'] as Clip? ?? Clip.none,
    autofocus: params['autofocus'] as bool? ?? false,
    child: _extractChild(params),
  );
});

final pOutlinedButton = WidgetParser.createWithParams('OutlinedButton', {
  ..._buttonParams,
  'backgroundColor': colorParser,
}, (params) {
  return OutlinedButton(
    onPressed: () {},
    style: OutlinedButton.styleFrom(
      alignment: params['alignment'] as Alignment?,
      backgroundColor: params['backgroundColor'] as Color?,
      elevation: params['elevation'] as double?,
      fixedSize: params['fixedSize'] as Size?,
      minimumSize: params['minimumSize'] as Size?,
      onSurface: params['onSurface'] as Color?,
      padding: params['padding'] as EdgeInsetsGeometry?,
      primary: params['primary'] as Color?,
      shadowColor: params['shadowColor'] as Color?,
      side: params['side'] as BorderSide?,
      visualDensity: params['visualDensity'] as VisualDensity?,
      tapTargetSize: params['tapTargetSize'] as MaterialTapTargetSize?,
      shape: params['shape'] as OutlinedBorder?,
    ),
    clipBehavior: params['clipBehavior'] as Clip? ?? Clip.none,
    autofocus: params['autofocus'] as bool? ?? false,
    child: _extractChild(params),
  );
});

final pAlign = WidgetParser.createWithParams('Align', {
  'alignment': alignmentParser,
  'widthFactor': doubleParser,
  'heightFactor': doubleParser,
  'child': WidgetParser.parser,
}, (params) {
  return Align(
    alignment: params['alignment'] as Alignment? ?? Alignment.center,
    heightFactor: params['heightFactor'] as double?,
    widthFactor: params['widthFactor'] as double?,
    child: (params['child'] as WidgetParser?)?.widget,
  );
});

final pCenter = WidgetParser.createWithParams('Center', {
  'widthFactor': doubleParser,
  'heightFactor': doubleParser,
  'child': WidgetParser.parser,
}, (params) {
  return Center(
    heightFactor: params['heightFactor'] as double?,
    widthFactor: params['widthFactor'] as double?,
    child: (params['child'] as WidgetParser?)?.widget,
  );
});

final _flexParams = {
  'crossAxisAlignment': crossAxisAlignmentParser,
  'mainAxisAlignment': mainAxisAlignmentParser,
  'mainAxisSize': mainAxisSizeParser,
  'cross': crossAxisAlignmentParser,
  'main': mainAxisAlignmentParser,
  'size': mainAxisSizeParser,
  'textBaseline': textBaselineParser,
  'textDirection': textDirectionParser,
  'verticalDirection': verticalDirectionParser,
  'children': separatedParser(WidgetParser.parser),
};

final pColumn = WidgetParser.createWithParams('Column', _flexParams, (params) {
  return Column(
    crossAxisAlignment: (params['cross'] ?? params['crossAxisAlignment'])
            as CrossAxisAlignment? ??
        CrossAxisAlignment.center,
    mainAxisAlignment:
        (params['main'] ?? params['mainAxisAlignment']) as MainAxisAlignment? ??
            MainAxisAlignment.start,
    mainAxisSize: (params['size'] ?? params['mainAxisSize']) as MainAxisSize? ??
        MainAxisSize.max,
    textBaseline: params['textBaseline'] as TextBaseline?,
    textDirection: params['textDirection'] as TextDirection?,
    verticalDirection: params['verticalDirection'] as VerticalDirection? ??
        VerticalDirection.down,
    children: (params['children'] as List?)
            ?.map((Object? w) => (w as WidgetParser).child as Widget)
            .toList() ??
        [],
  );
});

final pRow = WidgetParser.createWithParams('Row', _flexParams, (params) {
  return Row(
    crossAxisAlignment: (params['cross'] ?? params['crossAxisAlignment'])
            as CrossAxisAlignment? ??
        CrossAxisAlignment.center,
    mainAxisAlignment:
        (params['main'] ?? params['mainAxisAlignment']) as MainAxisAlignment? ??
            MainAxisAlignment.start,
    mainAxisSize: (params['size'] ?? params['mainAxisSize']) as MainAxisSize? ??
        MainAxisSize.max,
    textBaseline: params['textBaseline'] as TextBaseline?,
    textDirection: params['textDirection'] as TextDirection?,
    verticalDirection: params['verticalDirection'] as VerticalDirection? ??
        VerticalDirection.down,
    children: (params['children'] as List?)
            ?.map((Object? w) => (w as WidgetParser).child)
            .whereType<Widget>()
            .toList() ??
        [],
  );
});

final pFlex = WidgetParser.createWithParams('Flex', {
  ..._flexParams,
  'direction': axisParser,
  'clipBehavior': clipParser,
}, (params) {
  return Flex(
    direction: params['direction'] as Axis,
    clipBehavior: params['clipBehavior'] as Clip? ?? Clip.none,
    crossAxisAlignment: (params['cross'] ?? params['crossAxisAlignment'])
            as CrossAxisAlignment? ??
        CrossAxisAlignment.center,
    mainAxisAlignment:
        (params['main'] ?? params['mainAxisAlignment']) as MainAxisAlignment? ??
            MainAxisAlignment.start,
    mainAxisSize: (params['size'] ?? params['mainAxisSize']) as MainAxisSize? ??
        MainAxisSize.max,
    textBaseline: params['textBaseline'] as TextBaseline?,
    textDirection: params['textDirection'] as TextDirection?,
    verticalDirection: params['verticalDirection'] as VerticalDirection? ??
        VerticalDirection.down,
    children: (params['children'] as List?)
            ?.map((Object? w) => (w as WidgetParser).child as Widget)
            .toList() ??
        [],
  );
});

final pStack = WidgetParser.createWithParams('Stack', {
  'alignment': alignmentParser,
  'overflow': overflowParser,
  'clipBehavior': clipParser,
  'fit': stackFitParser,
  'textDirection': textDirectionParser,
  'children': separatedParser(WidgetParser.parser),
}, (params) {
  return Stack(
    alignment:
        params['alignment'] as Alignment? ?? AlignmentDirectional.topStart,
    overflow: params['overflow'] as Overflow? ?? Overflow.clip,
    clipBehavior: params['clipBehavior'] as Clip? ?? Clip.hardEdge,
    fit: params['fit'] as StackFit? ?? StackFit.loose,
    textDirection: params['textDirection'] as TextDirection?,
    children: (params['children'] as List?)
            ?.map((Object? w) => (w as WidgetParser).child as Widget)
            .toList() ??
        [],
  );
});

final pFlexible = WidgetParser.createWithParams('Flexible', {
  'flex': intParser,
  'fit': flexFitParser,
  'child': WidgetParser.parser,
}, (params) {
  return Flexible(
    flex: params['flex'] as int? ?? 1,
    fit: params['fit'] as FlexFit? ?? FlexFit.loose,
    child: _extractChild(params),
  );
});

final pPositioned = WidgetParser.createWithParams('Positioned', {
  'factory': (string('directional') |
          string('fill') |
          string('fromRect') |
          string('fromRelativeRect'))
      .cast<String>(),
  'height': doubleParser,
  'width': doubleParser,
  'top': doubleParser,
  'bottom': doubleParser,
  'left': doubleParser,
  'right': doubleParser,
  'end': doubleParser,
  'start': doubleParser,
  'textDirection': textDirectionParser,
  'child': WidgetParser.parser,
}, (params) {
  final child = _extractChild(params);
  switch (params['factory'] as String?) {
    case 'directional':
      return Positioned.directional(
        height: params['height'] as double?,
        width: params['width'] as double?,
        top: params['top'] as double?,
        bottom: params['bottom'] as double?,
        end: params['end'] as double?,
        start: params['start'] as double?,
        textDirection:
            params['textDirection'] as TextDirection? ?? TextDirection.ltr,
        child: child,
      );
    case 'fill':
      return Positioned.fill(
        top: params['top'] as double?,
        bottom: params['bottom'] as double?,
        left: params['left'] as double?,
        right: params['right'] as double?,
        child: child,
      );
    case 'fromRect':
    case 'fromRelativeRect':
    // TODO:
    default:
      return Positioned(
        height: params['height'] as double?,
        width: params['width'] as double?,
        top: params['top'] as double?,
        bottom: params['bottom'] as double?,
        left: params['left'] as double?,
        right: params['right'] as double?,
        child: child,
      );
  }
});

final pExpanded = WidgetParser.createWithParams('Expanded', {
  'flex': intParser,
  'child': WidgetParser.parser,
}, (params) {
  return Expanded(
    flex: params['flex'] as int? ?? 1,
    child: _extractChild(params),
  );
});

Widget _extractChild(Map<String, Object> params) {
  return (params['child'] as WidgetParser?)?.widget ?? const SizedBox();
}

final pSizedBox = WidgetParser.createWithParams('SizedBox', {
  'width': doubleParser,
  'height': doubleParser,
  'child': WidgetParser.parser,
}, (params) {
  return SizedBox(
    height: params['height'] as double?,
    width: params['width'] as double?,
    child: (params['child'] as WidgetParser?)?.widget,
  );
});

final pPadding = WidgetParser.createWithParams('Padding', {
  'padding': edgeInsetsParser,
  'child': WidgetParser.parser,
}, (params) {
  return Padding(
    padding: params['padding'] as EdgeInsetsGeometry? ?? EdgeInsets.zero,
    child: (params['child'] as WidgetParser?)?.widget,
  );
});

final pText = WidgetParser.createWithParams('Text', {
  'text': dartStringParser,
  'maxLines': intParser,
  'textScaleFactor': doubleParser,
  'softWrap': boolParser,
  'overflow': textOverflowParser,
  'textAlign': textAlignParser,
  'textDirection': textDirectionParser,
  'style': textStyleParser,
}, (params) {
  return Text(
    params['text'] as String? ?? '',
    maxLines: params['maxLines'] as int?,
    textScaleFactor: params['textScaleFactor'] as double?,
    softWrap: params['softWrap'] as bool?,
    overflow: params['overflow'] as TextOverflow?,
    textAlign: params['textAlign'] as TextAlign?,
    textDirection: params['textDirection'] as TextDirection?,
    style: params['style'] as TextStyle?,
  );
});

typedef FormWidgetBuilder = Widget Function(
    Token<Map<String, Token<Object>>>?, TextEditingController);

class WidgetParser {
  final Widget widget;
  final Token<List> token;
  final Token<Map<String, Token<Object>>> tokenParsedParams;
  Map<String, Token<Object>> get parsedParams => tokenParsedParams.value;

  final FormWidgetBuilder? form;
  final Nested<WidgetParser?>? child;
  WidgetParser(
    this.widget,
    this.token,
    this.tokenParsedParams, {
    this.form,
    this.child,
  });

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
            pPadding |
            pTextButton |
            pOutlinedButton |
            pElevatedButton)
        .cast<WidgetParser>());
  }

  // static Parser<WidgetParser> create(
  //   String name,
  //   Widget Function(Map<String, PParamValue>) create,
  // ) {
  //   return (string(name).trim() & PParams.parser.trim()).trim().token().map(
  //     (token) {
  //       final params = (token.value[1] as PParams).toMap();
  //       return WidgetParser(create(params));
  //     },
  //   );
  // }

  static Parser<WidgetParser> createWithParams(
    String name,
    Map<String, Parser<Object>> params,
    Widget Function(Map<String, Object>) create, {
    FormWidgetBuilder? form,
  }) {
    final paramParsers = separatedParser(
      structParamsParserToken(params),
      left: char('('),
      right: char(')'),
    ).map((entries) => Map.fromEntries(entries));

    Parser nameParser = string(name).trim();
    final hasFactory = params['factory'] is Parser;
    if (hasFactory) {
      nameParser =
          nameParser & prefixPoint(params['factory']!.token()).optional();
    }

    Parser<List> nameAndPropParser = nameParser & paramParsers.token();

    if (params['child'] == WidgetParser.parser) {
      nameAndPropParser =
          nameAndPropParser & prefixPoint(params['child']!.token()).optional();
    } else if (params['children'] is Parser<List<WidgetParser>>) {
      nameAndPropParser = nameAndPropParser &
          prefixPoint(params['children']!.token()).optional();
    }

    return nameAndPropParser.trim().token().map(
      (token) {
        final value = token.value;
        final paramsToken =
            value[hasFactory ? 2 : 1] as Token<Map<String, Token<Object>>>;
        final params = paramsToken.value;

        if (hasFactory && value[1] != null) {
          params['factory'] = (value[1] as Token) as Token<Object>;
        }

        final childIndex = hasFactory ? 3 : 2;
        Nested<WidgetParser?>? _child;
        if (value.length > childIndex && value[childIndex] != null) {
          final Object? widgets = value[childIndex];
          if (widgets is Token && widgets.value is List) {
            params['children'] = widgets as Token<Object>;
            _child = Nested.children((widgets.value as List).cast());
          } else if (widgets != null) {
            params['child'] = (widgets as Token) as Token<Object>;
            _child = Nested.child(widgets.value as WidgetParser?);
          }
        }
        return WidgetParser(
          create(params.map((key, value) => MapEntry(key, value.value))),
          token,
          paramsToken,
          form: form,
          child: _child,
        );
      },
    );
  }

  static final SettableParser<WidgetParser> _parser = undefined<WidgetParser>();
  static Parser<WidgetParser> get parser => _parser;
}

void expectIs<T>(dynamic value, [void Function(T)? callback]) {
  test.expect(value is T, true);
  if (callback != null && value is T) {
    callback(value);
  }
}

Parser<T> prefixPoint<T>(Parser<T> parser) {
  return (char('.').trim().optional() & parser).pick(1).cast();
}

void main() {
  WidgetParser.init();

  test.test('', () {
    final result = pContainer.parse(
      'Container(alignment: center, width: 102, margin: (3.4, 10,), '
      'decoration: (shape: circle, color: red[200], border: '
      '(style: solid, color: red[300], width: 3)),) '
      '.Padding (padding: 3, ).Text(text: 3)',
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
            color: Colors.red[300]!,
            width: 3,
            style: BorderStyle.solid,
          ),
        );
      });
      expectIs<Padding>(widget.child, (padding) {
        test.expect(padding.padding, const EdgeInsets.all(3));
        expectIs<Text>(padding.child, (text) {
          test.expect(text.data, '3');
        });
      });
    });
  });
}
