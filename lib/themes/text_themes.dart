import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobx/mobx.dart';
import 'package:snippet_generator/fields/enum_fields.dart';
import 'package:snippet_generator/fields/fields.dart';
import 'package:snippet_generator/globals/props_serializable.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';
import 'package:snippet_generator/notifiers/collection_notifier/list_notifier.dart';

class TextFamily {
  final String family;

  const TextFamily(this.family);

  @override
  bool operator ==(Object? other) {
    return other is TextFamily && other.family == family;
  }

  @override
  int get hashCode => family.hashCode;
}

class TextThemeNotifier {
  final defaultFamilyIndex = AppNotifier<int>(0, name: 'defaultFamily');
  final textFamilies = ListNotifier<String>(
    ['Nunito Sans'],
    propKey: 'textFamilies',
  );

  final customTextStyles = ListNotifier<TextStyleNotifier>(
    [],
    propKey: 'customTextStyles',
  );

  late final Computed<TextTheme> defaultTheme = Computed<TextTheme>(() {
    return GoogleFonts.getTextTheme(textFamilies[defaultFamilyIndex.value]);
  });

  late final headline1 = AppNotifier.withDefault<TextStyle>(
      () => defaultTheme.value.headline1!,
      name: 'headline1');
  late final headline2 = AppNotifier.withDefault<TextStyle>(
      () => defaultTheme.value.headline2!,
      name: 'headline2');
  late final headline3 = AppNotifier.withDefault<TextStyle>(
      () => defaultTheme.value.headline3!,
      name: 'headline3');
  late final headline4 = AppNotifier.withDefault<TextStyle>(
      () => defaultTheme.value.headline4!,
      name: 'headline4');
  late final headline5 = AppNotifier.withDefault<TextStyle>(
      () => defaultTheme.value.headline5!,
      name: 'headline5');
  late final headline6 = AppNotifier.withDefault<TextStyle>(
      () => defaultTheme.value.headline6!,
      name: 'headline6');
  late final subtitle1 = AppNotifier.withDefault<TextStyle>(
      () => defaultTheme.value.subtitle1!,
      name: 'subtitle1');
  late final subtitle2 = AppNotifier.withDefault<TextStyle>(
      () => defaultTheme.value.subtitle2!,
      name: 'subtitle2');
  late final bodyText1 = AppNotifier.withDefault<TextStyle>(
      () => defaultTheme.value.bodyText1!,
      name: 'bodyText1');
  late final bodyText2 = AppNotifier.withDefault<TextStyle>(
      () => defaultTheme.value.bodyText2!,
      name: 'bodyText2');
  late final caption = AppNotifier.withDefault<TextStyle>(
      () => defaultTheme.value.caption!,
      name: 'caption');
  late final button = AppNotifier.withDefault<TextStyle>(
      () => defaultTheme.value.button!,
      name: 'button');
  late final overline = AppNotifier.withDefault<TextStyle>(
      () => defaultTheme.value.overline!,
      name: 'overline');

  late final Computed<TextTheme> computedValue = Computed(() {
    return TextTheme(
      headline1: headline1.value,
      headline2: headline2.value,
      headline3: headline3.value,
      headline4: headline4.value,
      headline5: headline5.value,
      headline6: headline6.value,
      subtitle1: subtitle1.value,
      subtitle2: subtitle2.value,
      bodyText1: bodyText1.value,
      bodyText2: bodyText2.value,
      caption: caption.value,
      button: button.value,
      overline: overline.value,
    );
  });
}

class TextStyleNotifier
    with ListenableFromObservable, PropsSerializable
    implements PropClass<TextStyle> {
  final TextThemeNotifier textTheme;
  @override
  final String name;
  final TextStyle Function()? defaultStyle;

  TextStyleNotifier(
    this.textTheme, {
    this.defaultStyle,
    required this.name,
  });

  TextStyle defaultValue() {
    return defaultStyle?.call() ??
        baseThemeTextStyle.value.fromTheme(textTheme.computedValue.value)!;
  }

  final baseThemeTextStyle = AppNotifier<TextStyleEnum>(TextStyleEnum.bodyText1,
      name: 'baseThemeTextStyle');

  late final inherit = AppNotifier.withDefault<bool>(
      () => defaultValue().inherit,
      name: 'inherit');
  late final color = AppNotifier.withDefault<Color>(() => defaultValue().color!,
      name: 'color');
  late final backgroundColor = AppNotifier.withDefault<Color?>(
      () => defaultValue().backgroundColor,
      name: 'backgroundColor');
  late final fontFamily = AppNotifier.withDefault<String?>(
      () => defaultValue().fontFamily,
      name: 'fontFamily');
  late final fontSize = AppNotifier.withDefault<double?>(
      () => defaultValue().fontSize,
      name: 'fontSize');
  late final fontWeight = AppNotifier.withDefault<FontWeight?>(
      () => defaultValue().fontWeight,
      name: 'fontWeight');
  late final fontStyle = AppNotifier.withDefault<FontStyle?>(
      () => defaultValue().fontStyle,
      name: 'fontStyle');
  late final letterSpacing = AppNotifier.withDefault<double?>(
      () => defaultValue().letterSpacing,
      name: 'letterSpacing');
  late final wordSpacing = AppNotifier.withDefault<double?>(
      () => defaultValue().wordSpacing,
      name: 'wordSpacing');
  late final textBaseline = AppNotifier.withDefault<TextBaseline?>(
      () => defaultValue().textBaseline,
      name: 'textBaseline');
  late final height = AppNotifier.withDefault<double?>(
      () => defaultValue().height,
      name: 'height');
  late final leadingDistribution =
      AppNotifier.withDefault<ui.TextLeadingDistribution?>(
          () => defaultValue().leadingDistribution,
          name: 'leadingDistribution');
  late final locale = AppNotifier.withDefault<Locale?>(
      () => defaultValue().locale,
      name: 'locale');
  late final foreground = AppNotifier.withDefault<Paint?>(
      () => defaultValue().foreground,
      name: 'foreground');
  late final background = AppNotifier.withDefault<Paint?>(
      () => defaultValue().background,
      name: 'background');
  late final decoration = AppNotifier.withDefault<TextDecoration?>(
      () => defaultValue().decoration,
      name: 'decoration');
  late final decorationColor = AppNotifier.withDefault<Color?>(
      () => defaultValue().decorationColor,
      name: 'decorationColor');
  late final decorationStyle = AppNotifier.withDefault<TextDecorationStyle?>(
      () => defaultValue().decorationStyle,
      name: 'decorationStyle');
  late final decorationThickness = AppNotifier.withDefault<double?>(
      () => defaultValue().decorationThickness,
      name: 'decorationThickness');
  late final debugLabel = AppNotifier.withDefault<String?>(
      () => defaultValue().debugLabel,
      name: 'debugLabel');

  @override
  void set(TextStyle value) {
    inherit.value = value.inherit;
    color.value = value.color;
    backgroundColor.value = value.backgroundColor;
    fontFamily.value = value.fontFamily;
    fontSize.value = value.fontSize;
    fontWeight.value = value.fontWeight;
    fontStyle.value = value.fontStyle;
    letterSpacing.value = value.letterSpacing;
    wordSpacing.value = value.wordSpacing;
    textBaseline.value = value.textBaseline;
    height.value = value.height;
    leadingDistribution.value = value.leadingDistribution;
    locale.value = value.locale;
    foreground.value = value.foreground;
    background.value = value.background;
    decoration.value = value.decoration;
    decorationColor.value = value.decorationColor;
    decorationStyle.value = value.decorationStyle;
    decorationThickness.value = value.decorationThickness;
    debugLabel.value = value.debugLabel;
  }

  @override
  Type get type => TextStyle;

  @override
  TextStyle get value => computedValue.value;

  late final Computed<TextStyle> computedValue = Computed(() {
    return TextStyle(
      inherit: inherit.value,
      color: color.value,
      backgroundColor: backgroundColor.value,
      fontFamily: fontFamily.value,
      fontSize: fontSize.value,
      fontWeight: fontWeight.value,
      fontStyle: fontStyle.value,
      letterSpacing: letterSpacing.value,
      wordSpacing: wordSpacing.value,
      textBaseline: textBaseline.value,
      height: height.value,
      leadingDistribution: leadingDistribution.value,
      locale: locale.value,
      foreground: foreground.value,
      background: background.value,
      decoration: decoration.value,
      decorationColor: decorationColor.value,
      decorationStyle: decorationStyle.value,
      decorationThickness: decorationThickness.value,
      debugLabel: debugLabel.value,
    );
  });

  @override
  void Function() Function(void Function(dynamic)) get observeFunction =>
      computedValue.observe;

  @override
  late final List<SerializableProp> props = [
    inherit,
    color,
    backgroundColor,
    fontFamily,
    fontSize,
    fontWeight,
    fontStyle,
    letterSpacing,
    wordSpacing,
    textBaseline,
    height,
    leadingDistribution,
    locale,
    foreground,
    background,
    decoration,
    decorationColor,
    decorationStyle,
    decorationThickness,
    debugLabel,
  ];
}
