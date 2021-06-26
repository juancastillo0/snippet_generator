import 'package:flutter/material.dart';
import 'package:snippet_generator/parsers/widget_parsers/widget_parser.dart';
import 'package:test/test.dart';

void main() {
  WidgetParser.init();

  // test('SizedBox', () {
  //   final result = PSizedBox.parser.parse(" SizedBox (height: 3, width: 4)");
  //   print(result.message);
  //   print(result.toPositionString());
  //   print(result);

  //   expect(result.isSuccess, true);
  //   final value = result.value;
  //   print(value.token);
  //   expect(value.widget.height, 3);
  //   expect(value.widget.width, 4);
  // });

  test('nested Container and SizedBox', () {
    final result = WidgetParser.parser.parse(
        'Container(alignment: center, height: 10, child: SizedBox( width: 4),)');
    print(result.message);
    print(result.toPositionString());
    print(result);

    expect(result.isSuccess, true);
    final widget = result.value.widget;

    expect(widget is Container, true);
    if (widget is Container) {
      final innerWidget = widget.child;
      print(widget);
      print(innerWidget);
      expect(innerWidget is SizedBox, true);
      if (innerWidget is SizedBox) {
        expect(innerWidget.width, 4);
      }
    }
  });
}
